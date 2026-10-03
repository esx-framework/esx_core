-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local State <const> = xLib.require "@esx_whitelist.server.module.whitelist.state"
local ConfigService <const> = xLib.require "@esx_whitelist.server.module.whitelist.config"
local Database <const> = xLib.require "@esx_whitelist.server.module.whitelist.database"
local Cache <const> = xLib.require "@esx_whitelist.server.module.whitelist.cache"
local Auth <const> = xLib.require "@esx_whitelist.server.module.whitelist.auth"
local Rules <const> = xLib.require "@esx_whitelist.server.module.whitelist.rules"
local Connection <const> = xLib.require "@esx_whitelist.server.module.whitelist.connection"
local Callbacks <const> = xLib.require "@esx_whitelist.server.module.whitelist.callbacks"
local Commands <const> = xLib.require "@esx_whitelist.server.module.whitelist.commands"
local Discord <const> = xLib.require "@esx_whitelist.server.module.whitelist.discord"
local Enum <const> = xLib.require "@esx_whitelist.server.module.whitelist.Enum"
local Util <const> = xLib.require "@esx_whitelist.server.module.whitelist.util"

---@class Whitelist
---@description Main entry point for the ESX whitelist system.
local Whitelist = {}
local RECONCILE_CHUNK_SIZE <const> = 50
local reconcilingOnline = false
local pendingOnlineChanges = {}

---@description Helper function.
local function applyStateChanged(enabled, manual, adminName)
    if manual then
        Discord.sendLog(Util.translate(State.translations, enabled and "whitelist_enabled_manual" or "whitelist_disabled_manual", adminName), enabled and Enum.DiscordEmbedColor.DANGER or Enum.DiscordEmbedColor.SUCCESS, State.translations)
    else
        Discord.sendLog(Util.translate(State.translations, enabled and "whitelist_enabled_auto" or "whitelist_disabled_auto"), enabled and Enum.DiscordEmbedColor.DANGER or Enum.DiscordEmbedColor.SUCCESS, State.translations)
    end

    if not enabled then
        for source in pairs(State.gracePlayers) do
            State.gracePlayers[source] = nil
            TriggerClientEvent("esx_whitelist:cancelGracePeriod", source)
        end
    else
        Connection.kickNonWhitelisted(State.translations)
    end
    TriggerClientEvent("esx_whitelist:stateChanged", -1, enabled)
end

---@description Helper function.
local function reconcileOnline()
    CreateThread(function()
        reconcilingOnline = true
        pendingOnlineChanges = {}
        State.onlinePlayerCount = 0
        State.onlineAdminCount = 0
        State.onlineSources = {}
        State.adminSources = {}
        State.playerIdentifiers = {}
        State.onlineIdentifierSources = {}
        Wait(2000)

        local snapshot = {}
        local players = ESX.GetExtendedPlayers()
        for i = 1, #players do
            local player = players[i]
            local source = player and tonumber(player.source)
            if source and GetPlayerName(source) then
                Connection.getSessionId(source)
                snapshot[source] = {
                    identifiers = Util.getPlayerIdentifiersFiltered(source),
                    isAdmin = Auth.isAdmin(source)
                }
            end
            if i % RECONCILE_CHUNK_SIZE == 0 then Wait(0) end
        end

        for source, isOnline in pairs(pendingOnlineChanges) do
            if not isOnline or not GetPlayerName(source) then
                snapshot[source] = nil
            else
                Connection.getSessionId(source)
                snapshot[source] = {
                    identifiers = Util.getPlayerIdentifiersFiltered(source),
                    isAdmin = Auth.isAdmin(source)
                }
            end
        end

        State.onlineSources = {}
        State.adminSources = {}
        for source, player in pairs(snapshot) do
            State.onlineSources[source] = true
            State.adminSources[source] = player.isAdmin
            Cache.setIdentifiers(source, player.identifiers)
            State.onlinePlayerCount = State.onlinePlayerCount + 1
            if player.isAdmin then State.onlineAdminCount = State.onlineAdminCount + 1 end
        end

        reconcilingOnline = false
        pendingOnlineChanges = {}
        Rules.evaluateAndApply(applyStateChanged)
    end)
end

---@description Helper function.
local function startMaintenance()
    CreateThread(function()
        while true do
            Wait(30000)
            Rules.evaluateAndApply(applyStateChanged)
        end
    end)
    CreateThread(function()
        while true do
            Wait(300000)
            Discord.sweep()
        end
    end)
end

---@description Initializes the whitelist system: loads config, initializes database, refreshes cache, and starts maintenance threads.
function Whitelist.init()
    if State.initializing then return end
    State.initializing = true
    ConfigService.load()
    Database.init(function(databaseOk)
        if not databaseOk then
            State.databaseReady = false
            State.initializing = false
            if Config.Debug then
                print("^1[esx_whitelist] Database initialization failed. Whitelist connections will be rejected safely.^7")
            end
            return
        end

        Database.refreshCache(function(cacheOk)
            if not cacheOk then
                State.databaseReady = false
                State.initializing = false
                if Config.Debug then
                    print("^1[esx_whitelist] Whitelist cache initialization failed. Connections will be rejected safely.^7")
                end
                return
            end

            State.databaseReady = true
            Callbacks.register(State.translations, applyStateChanged)
            Commands.register()
            reconcileOnline()
            startMaintenance()
            State.initializing = false
            if Config.Debug then
                print(("^2[esx_whitelist]^0 Initialized - %s - Grace: %ss"):format(State.config.enabled and "enabled" or "disabled", State.config.gracePeriod))
            end
        end)
    end)
end

---@description Handles player loaded event: tracks online state, identifiers, and triggers rule evaluation.
---@param playerId number The player source ID
function Whitelist.onPlayerLoaded(playerId)
    local source = tonumber(playerId)
    if not source or source <= 0 or State.onlineSources[source] then return end
    if reconcilingOnline then
        pendingOnlineChanges[source] = true
        return
    end
    State.onlineSources[source] = true
    Cache.setIdentifiers(source, Util.getPlayerIdentifiersFiltered(source))
    State.onlinePlayerCount = State.onlinePlayerCount + 1
    if Auth.isAdmin(source) then State.onlineAdminCount = State.onlineAdminCount + 1 end
    Rules.evaluateAndApply(applyStateChanged)
end

---@description Caches identifiers once the native player source is stable.
---@param playerId number The player source ID
---@param previousPlayerId number? The temporary player source ID
function Whitelist.onPlayerJoining(playerId, previousPlayerId)
    local source = tonumber(playerId)
    if not source or source <= 0 then return end

    previousPlayerId = tonumber(previousPlayerId)
    if previousPlayerId and previousPlayerId > 0 and previousPlayerId ~= source then
        if reconcilingOnline then pendingOnlineChanges[previousPlayerId] = false end
        Cache.clearIdentifiers(previousPlayerId)
        State.gracePlayers[previousPlayerId] = nil
        Auth.clear(previousPlayerId)
    end

    Cache.setIdentifiers(source, Util.getPlayerIdentifiersFiltered(source))
end

---@description Handles player dropped event: cleans up identifiers, grace state, and triggers rule evaluation.
---@param playerId number The player source ID
---@param reason string Drop reason
function Whitelist.onPlayerDropped(playerId)
    local source = tonumber(playerId)
    if not source or source <= 0 then return end
    Cache.clearIdentifiers(source)
    State.gracePlayers[source] = nil
    Auth.clear(source)
    if reconcilingOnline then
        pendingOnlineChanges[source] = false
        return
    end
    if State.onlineSources[source] then
        State.onlineSources[source] = nil
        if State.adminSources[source] then State.onlineAdminCount = math.max(0, State.onlineAdminCount - 1) end
        State.onlinePlayerCount = math.max(0, State.onlinePlayerCount - 1)
        Rules.evaluateAndApply(applyStateChanged)
    end
end

---@description Refreshes the in-memory whitelist cache from the database.
---@param cb fun(success: boolean)
function Whitelist.refreshCache(cb)
    Database.refreshCache(cb)
end

return Whitelist
