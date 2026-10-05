-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local RESOURCE_NAME <const> = GetCurrentResourceName()

---@param level string
---@param message string
local function bootLog(level, message)
    print(("[esx_whitelist] [%s] %s"):format(level:upper(), message))
end

local ESX
do
    local ok, result = pcall(function()
        return exports["es_extended"]:getSharedObject()
    end)
    if ok and result then
        ESX = result
    else
        bootLog("error", "es_extended is not available. Ensure es_extended starts before this resource.")
    end
end

local Util = xLib.require("@esx_whitelist.server.service.util")
local Enum = xLib.require("@esx_whitelist.server.service.enum")

local RuntimeConfig = xLib.require("@esx_whitelist.server.module.runtimeConfig.main")(Util, bootLog)
local Logger = xLib.require("@esx_whitelist.server.module.logger.main")(
    Util,
    xLib.require("@esx_whitelist.server.module.logger.util"),
    RuntimeConfig
)

---@param level string
---@param message string
local function Log(level, message)
    Logger:Console(level, message)
end

local Identifier = xLib.require("@esx_whitelist.server.module.identifier.main")(
    Util,
    xLib.require("@esx_whitelist.server.module.identifier.util"),
    RuntimeConfig,
    Log
)
local Discord = xLib.require("@esx_whitelist.server.module.discord.main")(
    Util,
    xLib.require("@esx_whitelist.server.module.discord.util"),
    RuntimeConfig,
    Log
)
local AdminCache = xLib.require("@esx_whitelist.server.module.admin.main")(Util, RuntimeConfig, Log)
local Service = xLib.require("@esx_whitelist.server.service.main")(Util, Enum, RuntimeConfig, Identifier, AdminCache, Discord, Log)

---Server-side admin check
---@param source any
---@return boolean
local function IsAdmin(source)
    if source == 0 or source == nil then
        return true -- server console
    end
    if not ESX then
        return false
    end
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end
    local group = xPlayer.getGroup()
    local groups = RuntimeConfig:Get().Admin.Groups
    return type(group) == "string" and groups[group] == true
end

local Panel = xLib.require("@esx_whitelist.server.module.panel.main")({
    Util = Util,
    RuntimeConfig = RuntimeConfig,
    Identifier = Identifier,
    AdminCache = AdminCache,
    Discord = Discord,
    Logger = Logger,
    Service = Service,
    IsAdmin = IsAdmin,
    ESX = ESX,
})
local Command = xLib.require("@esx_whitelist.server.module.command.main")({
    Util = Util,
    RuntimeConfig = RuntimeConfig,
    Identifier = Identifier,
    AdminCache = AdminCache,
    Discord = Discord,
    Logger = Logger,
    Service = Service,
    IsAdmin = IsAdmin,
})

RuntimeConfig:Load()
Identifier:Rebuild()
AdminCache:Load()
Discord:LoadCache()
Command:Register()

CreateThread(function()
    Wait(500) 

    local cfg = RuntimeConfig:Get()
    bootLog("info", ("Starting esx_whitelist | mode=%s (%s) | whitelist=%s | admin-only=%s"):format(
        cfg.Whitelist.Mode,
        cfg.Whitelist.CombinationMode,
        cfg.Whitelist.Enabled and "enabled" or "DISABLED",
        cfg.AdminOnly.Enabled and "ON" or "off"
    ))

    if not ESX then
        bootLog("error", "ESX unavailable: admin-group authorization and panel permissions will not work.")
    end

    local needsDiscord = cfg.Whitelist.Enabled
        and not cfg.AdminOnly.Enabled
        and (cfg.Whitelist.Mode == "discord" or cfg.Whitelist.Mode == "both")

    if needsDiscord then
        local configured, problem = Discord:IsConfigured()
        if configured then
            bootLog("info", "Discord verification ready (guild " .. cfg.Discord.GuildId .. ").")
        else
            bootLog("error", "Discord verification is NOT ready: " .. tostring(problem))
            bootLog("error", "Discord-mode connections will be denied until this is fixed.")
        end
    end

    local loggerStats = Logger:GetStats()
    if cfg.Logging.Enabled and loggerStats.webhookConfigured then
        bootLog("info", "Webhook logging enabled.")
    elseif cfg.Logging.Enabled then
        bootLog("warning", "Logging enabled but no webhook configured (set whitelist:webhook in server.cfg).")
    end

    local counts = Identifier:GetCounts()
    bootLog("info", ("Identifiers loaded: whitelist=%d adminOnly=%d bypass=%d"):format(
        counts.whitelist, counts.adminOnly, counts.bypass
    ))
    bootLog("info", "Startup complete.")
end)

AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
    local source = source

    deferrals.defer()
    Wait(0) 

    deferrals.update("Checking whitelist...")

    local ok, result = pcall(function()
        local rawIdentifiers = GetPlayerIdentifiers(source)
        if not rawIdentifiers or #rawIdentifiers == 0 then
            return {
                allowed = false,
                method = Enum.AuthMethod.DENIED,
                reason = Enum.Reason.ERROR,
                identifier = nil,
                playerMessage = "Your identifiers could not be read. Please restart FiveM and try again.",
            }
        end

        return Service:CheckConnection(rawIdentifiers, function(stage)
            deferrals.update(stage)
        end)
    end)

    if not ok then
        Log("error", ("Authorization pipeline error for %s: %s"):format(tostring(playerName), tostring(result)))
        result = {
            allowed = false,
            method = Enum.AuthMethod.DENIED,
            reason = Enum.Reason.ERROR,
            identifier = nil,
            playerMessage = "An internal error occurred during verification. Please try again.",
        }
    end

    Service:Record(result)
    Logger:LogDecision(result, playerName, source)

    if result.allowed then
        deferrals.done() 
    else
        deferrals.done(result.playerMessage or "You are not whitelisted on this server.")
    end
end)

AddEventHandler("esx:playerLoaded", function(playerId)
    local pid = tonumber(playerId)
    if not pid or not ESX then
        return
    end
    if not GetPlayerName(pid) then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(pid)
    if not xPlayer then
        return
    end

    local rawIdentifiers = GetPlayerIdentifiers(pid)
    if not rawIdentifiers then
        return
    end

    local normalized = {}
    for i = 1, #rawIdentifiers do
        normalized[i] = Util.NormalizeIdentifier(rawIdentifiers[i])
    end

    AdminCache:UpdateFromPlayer(normalized, xPlayer.getGroup())
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= RESOURCE_NAME then
        return
    end
    AdminCache:Flush()
    Discord:FlushCache()
end)
