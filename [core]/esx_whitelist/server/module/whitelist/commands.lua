-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local State <const> = xLib.require "@esx_whitelist.server.module.whitelist.state"
local Auth <const> = xLib.require "@esx_whitelist.server.module.whitelist.auth"
local Cache <const> = xLib.require "@esx_whitelist.server.module.whitelist.cache"
local Database <const> = xLib.require "@esx_whitelist.server.module.whitelist.database"
local ConfigService <const> = xLib.require "@esx_whitelist.server.module.whitelist.config"
local Util <const> = xLib.require "@esx_whitelist.server.module.whitelist.util"
local Connection <const> = xLib.require "@esx_whitelist.server.module.whitelist.connection"

---@class Commands
---@description In-game commands for whitelist management (wl_add, wl_remove, wl_check, wl_on, wl_off, wl_sync).
local Commands = {}

---@description Adds a connected player to the database whitelist by identifier or player ID.
---@param xPlayer table ESX player object
---@param targetId number Target player ID
local function addTarget(xPlayer, targetId)
    local target = targetId and ESX.GetPlayerFromId(targetId)
        if not target then return xPlayer.showNotification("~r~" .. Util.translate(State.translations, "player_not_found")) end

    local identifiers = Cache.setIdentifiers(targetId, Util.getPlayerIdentifiersFiltered(targetId))
    if #identifiers == 0 then return xPlayer.showNotification("~r~" .. Util.translate(State.translations, "no_identifiers_found")) end

    Database.findByIdentifiers(identifiers, function(existing)
        if existing and tonumber(existing.whitelisted) == 1 then
            return xPlayer.showNotification("~r~" .. Util.translate(State.translations, "player_already_wl"))
        end

        ---@description Helper function.
        local function done(success, id)
            if not success or not id then return xPlayer.showNotification("~r~" .. Util.translate(State.translations, "failed_to_update")) end
            Cache.setWhitelistBatch(identifiers, id)
            xPlayer.showNotification("~g~" .. Util.translate(State.translations, "player_added"))
            target.showNotification("~g~" .. Util.translate(State.translations, "added_to_whitelist"))
            if State.gracePlayers[targetId] then
                State.gracePlayers[targetId] = nil
                TriggerClientEvent("esx_whitelist:cancelGracePeriod", targetId)
            end
        end

        if existing then
            Database.addIdentifiers(existing.id, identifiers, function(success)
                if not success then return xPlayer.showNotification("~r~" .. Util.translate(State.translations, "identifier_conflict")) end
                Database.setStatus(existing.id, 1, xPlayer.getIdentifier(), function(affected)
                    done(affected and affected > 0, existing.id)
                end)
            end)
        else
            Database.insertPlayer(target.getName(), identifiers, true, xPlayer.getIdentifier(), function(id)
                done(id ~= nil, id)
            end)
        end
    end)
end

---@description Registers all whitelist commands.
function Commands.register()
    if not Config.InGameCommands then return end

    ESX.RegisterCommand(Config.Commands.Add, Auth.groups(), function(xPlayer, args)
        addTarget(xPlayer, tonumber(args.id))
    end, false, {
        help = "Add player to whitelist",
        validate = true,
        arguments = {{ name = "id", help = "Player ID", type = "number" }}
    })

    ESX.RegisterCommand(Config.Commands.Remove, Auth.groups(), function(xPlayer, args)
        local targetId = tonumber(args.id)
        local target = targetId and ESX.GetPlayerFromId(targetId)
        local identifiers = target and Cache.getIdentifiers(targetId) or nil

        ---@description Helper function.
        local function enforceTarget()
            if targetId then Connection.enforce(targetId, State.translations) end
        end

        ---@description Helper function.
        local function removeByIdentifiers(ids)
            Database.findByIdentifiers(ids, function(existing)
                if not existing or tonumber(existing.whitelisted) ~= 1 then
                    return xPlayer.showNotification("~r~" .. Util.translate(State.translations, "player_not_in_wl"))
                end

                Database.getIdentifierList(existing.id, function(identifiers)
                    Database.setStatus(existing.id, 0, xPlayer.getIdentifier(), function(affected)
                        if not affected or affected < 1 then return xPlayer.showNotification("~r~" .. Util.translate(State.translations, "failed_to_update")) end
                        Cache.removeWhitelistBatch(identifiers)
                        xPlayer.showNotification("~g~" .. Util.translate(State.translations, "player_removed"))
                        enforceTarget()
                    end)
                end)
            end)
        end

        if identifiers and #identifiers > 0 then
            removeByIdentifiers(identifiers)
        else
            xPlayer.showNotification("~r~" .. Util.translate(State.translations, "player_not_found"))
        end
    end, false, {
        help = "Remove player from whitelist",
        validate = true,
        arguments = {{ name = "id", help = "Player ID", type = "number" }}
    })

    ESX.RegisterCommand(Config.Commands.Check, Auth.groups(), function(xPlayer, args)
        local targetId = tonumber(args.id)
        local target = targetId and ESX.GetPlayerFromId(targetId)
    if not target then return xPlayer.showNotification("~r~" .. Util.translate(State.translations, "player_not_found")) end

        Connection.authorize(targetId, function(allow, reason)
            local status = allow and ("~g~" .. Util.translate(State.translations, "authorized")) or ("~r~" .. Util.translate(State.translations, "not_authorized"))
            xPlayer.showNotification(("%s~s~ %s (%s)"):format(status, target.getName(), reason or "unknown"))
        end)
    end, false, {
        help = "Check player whitelist status",
        validate = true,
        arguments = {{ name = "id", help = "Player ID", type = "number" }}
    })

    ESX.RegisterCommand(Config.Commands.On, Auth.groups(), function(xPlayer)
        if State.config.enabled then return xPlayer.showNotification("~y~" .. Util.translate(State.translations, "whitelist_already_enabled")) end
        local ok = ConfigService.setEnabled(true)
        if not ok then return xPlayer.showNotification("~r~" .. Util.translate(State.translations, "failed_to_save_state")) end
        xPlayer.showNotification("~g~" .. Util.translate(State.translations, "whitelist_enabled_notification"))
        TriggerClientEvent("esx_whitelist:stateChanged", -1, true)
        Connection.kickNonWhitelisted(State.translations)
    end, false, { help = "Enable whitelist" })

    ESX.RegisterCommand(Config.Commands.Off, Auth.groups(), function(xPlayer)
        if not State.config.enabled then return xPlayer.showNotification("~y~" .. Util.translate(State.translations, "whitelist_already_disabled")) end
        local ok = ConfigService.setEnabled(false)
        if not ok then return xPlayer.showNotification("~r~" .. Util.translate(State.translations, "failed_to_save_state")) end
        xPlayer.showNotification("~g~" .. Util.translate(State.translations, "whitelist_disabled_notification"))
        TriggerClientEvent("esx_whitelist:stateChanged", -1, false)
        local graceSources = {}
        for source in pairs(State.gracePlayers) do graceSources[#graceSources + 1] = source end
        CreateThread(function()
            for i = 1, #graceSources do
                local source = graceSources[i]
                State.gracePlayers[source] = nil
                TriggerClientEvent("esx_whitelist:cancelGracePeriod", source)
                if i % 25 == 0 then Wait(0) end
            end
        end)
    end, false, { help = "Disable whitelist" })

    ESX.RegisterCommand(Config.Commands.Sync, Auth.groups(), function(xPlayer)
        Database.refreshCache(function(ok)
            if xPlayer then
                xPlayer.showNotification(ok and ("~g~" .. Util.translate(State.translations, "cache_synced")) or ("~r~" .. Util.translate(State.translations, "cache_sync_failed")))
            end
        end)
    end, false, { help = "Sync whitelist cache with database" })
end

return Commands
