-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local State <const> = xLib.require "@esx_whitelist.server.module.whitelist.state"
local Auth <const> = xLib.require "@esx_whitelist.server.module.whitelist.auth"
local Cache <const> = xLib.require "@esx_whitelist.server.module.whitelist.cache"
local Database <const> = xLib.require "@esx_whitelist.server.module.whitelist.database"
local ConfigService <const> = xLib.require "@esx_whitelist.server.module.whitelist.config"
local Validation <const> = xLib.require "@esx_whitelist.server.module.whitelist.validation"
local Discord <const> = xLib.require "@esx_whitelist.server.module.whitelist.discord"
local Util <const> = xLib.require "@esx_whitelist.server.module.whitelist.util"
local Enum <const> = xLib.require "@esx_whitelist.server.module.whitelist.Enum"
local Connection <const> = xLib.require "@esx_whitelist.server.module.whitelist.connection"
local Rules <const> = xLib.require "@esx_whitelist.server.module.whitelist.rules"

---@class Callbacks
---@description NUI server callbacks for the whitelist admin panel (getConfig, getWhitelistEntries, updateConfig, etc.).
local Callbacks = {}
local uiSubscribers = {}
local RULE_FIELDS <const> = { "id", "type", "enabled", "priority", "operator", "value", "action", "startTime", "endTime" }
local callbackLimiter = xLib.rateLimiter({
    capacity = 30,
    refill = 15,
    interval = 1000
})

local function sameRules(first, second)
    if #(first or {}) ~= #(second or {}) then return false end
    for i = 1, #(first or {}) do
        for j = 1, #RULE_FIELDS do
            local field = RULE_FIELDS[j]
            if first[i][field] ~= second[i][field] then return false end
        end
    end
    return true
end

local function authorizationConfigChanged(previous, current)
    return previous.enabled ~= current.enabled
        or previous.kickConnected ~= current.kickConnected
        or previous.authorizationMethod ~= current.authorizationMethod
        or previous.discordEnabled ~= current.discordEnabled
        or previous.discordGuildId ~= current.discordGuildId
        or previous.discordRoleId ~= current.discordRoleId
end

    local function rulesChanged(previous, current)
        return not sameRules(previous.rules, current.rules)
    end

local function allowed(source)
    source = tonumber(source)
    return source and source > 0 and Auth.IsAdmin(source) or false
end

local function callbackAllowed(source)
    source = tonumber(source)
    if not source or source <= 0 then return false end
    if not callbackLimiter:consume(source) then return false end
    return Auth.IsAdmin(source)
end

local function adminName(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer and xPlayer.getName() or GetPlayerName(source) or "Admin"
end

local function getAllIdentifiers(identifier, cb)
    local online = Cache.FindOnline(identifier)
    if online then
        local xPlayer = ESX.GetPlayerFromId(online)
        return cb(Cache.GetIdentifiers(online), GetPlayerName(online) or (xPlayer and xPlayer.getName()) or "Unknown", true, online)
    end

    Database.FindByIdentifier(identifier, function(row)
        if not row then return cb({ identifier }, nil, false, nil) end
        Database.GetIdentifierList(row.id, function(identifiers)
            cb(identifiers, row.player_name, false, nil)
        end)
    end)
end

function Callbacks.Register(translations, onStateChanged)
    RegisterNetEvent("esx_whitelist:subscribeUpdates", function()
        local subscriber = tonumber(source)
        if subscriber and allowed(subscriber) then uiSubscribers[subscriber] = true end
    end)

    RegisterNetEvent("esx_whitelist:unsubscribeUpdates", function()
        local subscriber = tonumber(source)
        if subscriber then uiSubscribers[subscriber] = nil end
    end)

    AddEventHandler("playerDropped", function()
        local subscriber = tonumber(source)
        if subscriber then uiSubscribers[subscriber] = nil end
    end)

    AddEventHandler("esx_whitelist:notifyEntryChanged", function(whitelistId)
        for subscriber in pairs(uiSubscribers) do
            if GetPlayerName(subscriber) and allowed(subscriber) then
                TriggerClientEvent("esx_whitelist:entryChanged", subscriber, whitelistId)
            else
                uiSubscribers[subscriber] = nil
            end
        end
    end)

    ESX.RegisterServerCallback("esx_whitelist:getConfig", function(source, cb)
        if not callbackAllowed(source) then return cb(nil) end
        cb({
            whitelistEnabled = State.config.enabled,
            gracePeriod = State.config.gracePeriod,
            kickConnected = State.config.kickConnected,
            discordWebhook = State.config.discordWebhook ~= "" and "***CONFIGURED***" or "",
            discordEnabled = State.config.discordEnabled,
            discordGuildId = State.config.discordGuildId,
            discordRoleId = State.config.discordRoleId,
            authorizationMethod = State.config.authorizationMethod,
            rules = State.config.rules,
            locale = Config.Locale,
            translations = translations,
            hasBotToken = State.config.discordEnabled and Discord.HasValidToken()
        })
    end)

    ESX.RegisterServerCallback("esx_whitelist:getWhitelistEntries", function(source, cb, request)
        if not callbackAllowed(source) then
            return cb({ entries = {}, cursor = nil, nextCursor = nil, hasMore = false, limit = 50 })
        end
        Database.Search(type(request) == "table" and request or {}, cb)
    end)

    ESX.RegisterServerCallback("esx_whitelist:updateConfig", function(source, cb, data)
        if not callbackAllowed(source) or type(data) ~= "table" then return cb(false) end

        if (data.authorizationMethod == "discord" or data.discordEnabled) and not Discord.HasValidToken() then
            TriggerClientEvent("esx:showNotification", source, "~r~" .. Util.Translate(translations, "discord_no_token"))
            return cb(false)
        end

        local previousConfig = State.config
        local ok, err, oldEnabled = ConfigService.Apply(data)
        if not ok then
            TriggerClientEvent("esx:showNotification", source, "~r~" .. (err or Util.Translate(translations, "invalid_configuration")))
            return cb(false)
        end

        local authorizationChanged = authorizationConfigChanged(previousConfig, State.config)
        local changedRules = rulesChanged(previousConfig, State.config)
        if State.config.enabled ~= oldEnabled then
            onStateChanged(State.config.enabled, true, adminName(source))
        elseif changedRules then
            local stateChangedByRules = Rules.EvaluateAndApply(onStateChanged)
            if not stateChangedByRules and authorizationChanged then
                TriggerClientEvent("esx_whitelist:stateChanged", -1, State.config.enabled)
                if State.config.enabled then Connection.KickNonWhitelisted(State.translations) end
            end
        elseif authorizationChanged then
            TriggerClientEvent("esx_whitelist:stateChanged", -1, State.config.enabled)
            if State.config.enabled then
                Connection.KickNonWhitelisted(State.translations)
            end
        end

        TriggerClientEvent("esx:showNotification", source, "~g~" .. Util.Translate(translations, "config_saved"))
        cb(true)
    end)

    ESX.RegisterServerCallback("esx_whitelist:testWebhook", function(source, cb)
        if not callbackAllowed(source) then return cb(false) end
        cb(Discord.SendLog(Util.Translate(translations, "webhook_test", adminName(source)), Enum.DiscordEmbedColor.PRIMARY, translations))
    end)

    ESX.RegisterServerCallback("esx_whitelist:managePlayer", function(source, cb, data)
        if not callbackAllowed(source) or type(data) ~= "table" then return cb(false, Util.Translate(translations, "invalid_request")) end
        if data.action ~= "add" and data.action ~= "remove" then return cb(false, Util.Translate(translations, "invalid_request")) end

        local fullIdentifier = Validation.Identifier(data.identifier)
        if not fullIdentifier then return cb(false, Util.Translate(translations, "invalid_identifier")) end

        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return cb(false, Util.Translate(translations, "error_getting_admin_data")) end

        if data.action == "add" then
            getAllIdentifiers(fullIdentifier, function(allIdentifiers, existingName, isOnline, onlineSource)
                local targetName = existingName or "Pending..."
                Database.FindByIdentifier(fullIdentifier, function(existing)
                    local function complete(id)
                        if not id then return cb(false, Util.Translate(translations, "failed_to_update")) end
                        Cache.SetWhitelistBatch(allIdentifiers, id)
                        if isOnline and onlineSource and State.gracePlayers[onlineSource] then
                            State.gracePlayers[onlineSource] = nil
                            TriggerClientEvent("esx_whitelist:cancelGracePeriod", onlineSource)
                        end
                        cb(true, Util.Translate(translations, "player_added_success"))
                    end

                    if existing then
                        if tonumber(existing.whitelisted) == 1 then return cb(false, Util.Translate(translations, "player_already_wl")) end
                        Database.AddIdentifiers(existing.id, allIdentifiers, function(success)
                            if not success then return cb(false, Util.Translate(translations, "identifier_conflict")) end
                            Database.SetStatus(existing.id, 1, xPlayer.getIdentifier(), function(affected)
                                if not affected or affected < 1 then return cb(false, Util.Translate(translations, "failed_to_update")) end
                                complete(existing.id)
                            end)
                        end)
                    else
                        Database.InsertPlayer(targetName, allIdentifiers, true, xPlayer.getIdentifier(), function(id, err)
                            if not id then
                                if err == "identifier_already_exists" then
                                    return cb(false, Util.Translate(translations, "identifier_conflict"))
                                end
                                return cb(false, Util.Translate(translations, "failed_to_update"))
                            end
                            complete(id)
                        end)
                    end
                end)
            end)
        else
            Database.FindByIdentifier(fullIdentifier, function(existing)
                if not existing or tonumber(existing.whitelisted) ~= 1 then return cb(false, Util.Translate(translations, "player_not_in_wl")) end

                Database.GetIdentifierList(existing.id, function(identifiers)
                    Database.SetStatus(existing.id, 0, xPlayer.getIdentifier(), function(affected)
                        if not affected or affected < 1 then return cb(false, Util.Translate(translations, "failed_to_update")) end
                        Cache.RemoveWhitelistBatch(identifiers)
                        cb(true, Util.Translate(translations, "player_removed_success"))
                    end)
                end)
            end)
        end
    end)

    ESX.RegisterServerCallback("esx_whitelist:toggleWhitelistStatus", function(source, cb, data)
        if not callbackAllowed(source) or type(data) ~= "table" then return cb(false) end
        local id, status = tonumber(data.id), tonumber(data.status)
        if not id or (status ~= 0 and status ~= 1) then return cb(false) end

        Database.GetIdentifierList(id, function(identifiers)
            if #identifiers == 0 then return cb(false) end
            Database.SetStatus(id, status, adminName(source), function(affected)
                if not affected or affected < 1 then return cb(false) end

                if status == 1 then
                    Cache.SetWhitelistBatch(identifiers, id)
                else
                    Cache.RemoveWhitelistBatch(identifiers)
                end

                if status == 0 then
                    -- If this entry belongs to an online player, immediately re-evaluate.
                    for i = 1, #identifiers do
                        local onlineSource = Cache.FindOnline(identifiers[i])
                        if onlineSource then
                            Connection.Enforce(onlineSource, translations)
                            break
                        end
                    end
                end

                cb(true)
            end)
        end)
    end)

end

return Callbacks
