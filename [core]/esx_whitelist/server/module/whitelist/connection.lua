-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local State <const> = xLib.require "@esx_whitelist.server.module.whitelist.state"
local Cache <const> = xLib.require "@esx_whitelist.server.module.whitelist.cache"
local Database <const> = xLib.require "@esx_whitelist.server.module.whitelist.database"
local Discord <const> = xLib.require "@esx_whitelist.server.module.whitelist.discord"
local Auth <const> = xLib.require "@esx_whitelist.server.module.whitelist.auth"
local Util <const> = xLib.require "@esx_whitelist.server.module.whitelist.util"

---@class Connection
---@description Manages player connection authorization, grace periods, and enforcement of whitelist rules.
local Connection = {}
local GRACE_MIN <const>, GRACE_MAX <const> = 0, 600
local KICK_CHUNK <const> = 25
local sessionSequence = 0
local playerSessions = {}

local function ensureSession(source)
    if playerSessions[source] then return playerSessions[source] end
    sessionSequence = sessionSequence + 1
    playerSessions[source] = sessionSequence
    return sessionSequence
end

local function isCurrentSession(source, sessionId)
    return sessionId ~= nil and playerSessions[source] == sessionId
end

function Connection.BeginSession(source)
    source = tonumber(source)
    if not source or source <= 0 then return nil end
    sessionSequence = sessionSequence + 1
    playerSessions[source] = sessionSequence
    return sessionSequence
end

function Connection.GetSessionId(source)
    source = tonumber(source)
    if not source or source <= 0 then return nil end
    return ensureSession(source)
end

function Connection.EndSession(source, sessionId)
    source = tonumber(source)
    if not source or (sessionId and playerSessions[source] ~= sessionId) then return end
    playerSessions[source] = nil
    State.gracePlayers[source] = nil
    Auth.Clear(source)
end

local function redactIdentifier(identifier)
    local idType, value = tostring(identifier):match("^([^:]+):(.+)$")
    if not idType then return "[redacted]" end
    if #value <= 8 then return idType .. ":" .. string.rep("*", #value) end
    return ("%s:%s...%s"):format(idType, value:sub(1, 4), value:sub(-4))
end

local function finish(deferrals, allow, reason)
    if allow then
        deferrals.done()
    else
        deferrals.done(reason or Util.Translate(State.translations, "kick_message"))
    end
end

local DATABASE_TIMEOUT <const> = 10000
local databaseWaiters = {}
local databaseWaitThreadRunning = false

local function completeDatabaseWaiter(waiter, ready)
    local ok, err = xpcall(function()
        waiter.callback(ready)
    end, debug.traceback)
    if not ok and Config.Debug then
        print("^1[esx_whitelist] Database readiness callback failed:^7 " .. tostring(err))
    end
end

local function whenDatabaseReady(callback)
    if State.databaseReady then return callback(true) end

    databaseWaiters[#databaseWaiters + 1] = {
        callback = callback,
        deadline = GetGameTimer() + DATABASE_TIMEOUT
    }
    if databaseWaitThreadRunning then return end

    databaseWaitThreadRunning = true
    CreateThread(function()
        while #databaseWaiters > 0 do
            Wait(100)

            local waiters = databaseWaiters
            databaseWaiters = {}
            local now = GetGameTimer()
            local ready = State.databaseReady

            for i = 1, #waiters do
                local waiter = waiters[i]
                if ready then
                    completeDatabaseWaiter(waiter, true)
                elseif now >= waiter.deadline then
                    completeDatabaseWaiter(waiter, false)
                else
                    databaseWaiters[#databaseWaiters + 1] = waiter
                end
            end
        end

        databaseWaitThreadRunning = false
    end)
end

local function enforce(source, translations, useGrace, sessionId)
    source = tonumber(source)
    if not source or source <= 0 then return end
    sessionId = sessionId or ensureSession(source)

    Connection.Authorize(source, function(allow)
        if not isCurrentSession(source, sessionId) then return end
        if allow then
            if State.gracePlayers[source] then
                State.gracePlayers[source] = nil
                TriggerClientEvent("esx_whitelist:cancelGracePeriod", source)
            end
            return
        end

        if State.config.kickConnected or useGrace == false then
            DropPlayer(tostring(source), Util.Translate(translations or State.translations, "kick_message"))
        else
            Connection.StartGrace(source, GetPlayerName(source) or "Unknown", translations or State.translations, sessionId)
        end
    end, nil, sessionId)
end

local function identifiersFor(source)
    local identifiers = Util.GetPlayerIdentifiersFiltered(source)
    Cache.SetIdentifiers(source, identifiers)
    return identifiers
end

local function persistAccess(source, identifiers, addedBy, callback, sessionId)
    local function persist()
        if not isCurrentSession(source, sessionId) then return end
        Database.EnsureWhitelisted(
            GetPlayerName(source) or "Unknown",
            identifiers,
            addedBy,
            function(saved, err, whitelistId)
                if not isCurrentSession(source, sessionId) then return end
                if saved and whitelistId then
                    TriggerEvent("esx_whitelist:notifyEntryChanged", whitelistId)
                end
                callback(saved == true, err, whitelistId)
            end
        )
    end

    whenDatabaseReady(function(ready)
        if not isCurrentSession(source, sessionId) then return end
        if not ready then return callback(false, "database_unavailable") end
        persist()
    end)
end

local function checkDiscord(source, callback, sessionId)
    local discordIdentifier = GetPlayerIdentifierByType(source, "discord")
    if not discordIdentifier then return callback(false, "missing_discord") end

    local discordId = discordIdentifier:gsub("^discord:", "")
    Discord.CheckRole(discordId, function(hasRole, err)
        if not isCurrentSession(source, sessionId) then return end
        if err then return callback(false, "discord_error") end
        callback(hasRole == true, hasRole and "discord" or "not_whitelisted")
    end)
end

-- The configured method is authoritative. Identifier and Discord checks are
-- never silently used as each other's fallback.
---@description Authorizes a player connection by checking configured identifiers, admin status, Discord role, or database whitelist.
---@param source number The player source ID
---@param callback fun(allow: boolean, reason: string?)
---@param currentIdentifiers string[]? Identifiers captured for this connection attempt
---@param sessionId number? The player session generation
function Connection.Authorize(source, callback, currentIdentifiers, sessionId)
    source = tonumber(source)
    if not source or source <= 0 then return callback(false, "invalid_source") end
    sessionId = sessionId or ensureSession(source)

    local function respond(allow, reason)
        if isCurrentSession(source, sessionId) then callback(allow, reason) end
    end

    if not State.config.enabled then return respond(true, "whitelist_disabled") end

    local identifiers = currentIdentifiers
    if type(identifiers) ~= "table" then
        identifiers = Cache.GetIdentifiers(source)
        if #identifiers == 0 then identifiers = identifiersFor(source) end
    end

    if Config.Debug then
        local redactedIdentifiers = {}
        for i = 1, #identifiers do
            redactedIdentifiers[i] = redactIdentifier(identifiers[i])
        end
        local identifierList = #redactedIdentifiers > 0 and table.concat(redactedIdentifiers, ", ") or "none"
        print(("^3[esx_whitelist] Authorization check for source %s: identifiers=[%s]^7"):format(source, identifierList))
    end

    local configuredMatch = Auth.HasConfiguredIdentifier(identifiers)
    if Config.Debug then
        print(("^3[esx_whitelist] Configured identifier match: %s^7"):format(tostring(configuredMatch)))
    end
    if configuredMatch then return respond(true, "configured_identifier") end

    local function checkWhitelist()
        if State.config.authorizationMethod == "discord" then
            return checkDiscord(source, function(hasRole, reason)
                if not hasRole then
                    return respond(false, reason or "not_whitelisted")
                end

                if Cache.IsWhitelisted(identifiers) then return respond(true, "discord") end
                persistAccess(source, identifiers, "system:discord", function(saved, err)
                    respond(saved, saved and "discord" or (err or "discord_persist_failed"))
                end, sessionId)
            end, sessionId)
        end

        local whitelisted = Cache.IsWhitelisted(identifiers)
        respond(whitelisted == true, whitelisted and "identifier" or "not_whitelisted")
    end

    local localAdmin = Auth.IsAdmin(source)
    if localAdmin then return respond(true, "admin") end
    if State.databaseReady then return checkWhitelist() end

    whenDatabaseReady(function(ready)
        if not isCurrentSession(source, sessionId) then return end
        if not ready then return callback(false, "database_unavailable") end
        checkWhitelist()
    end)
end

---@description Starts a grace period for a non-whitelisted connected player before kicking them.
---@param source number The player source ID
---@param playerName string The player display name
---@param translations table Locale translation strings
---@param sessionId number? The player session generation
function Connection.StartGrace(source, playerName, translations, sessionId)
    source = tonumber(source)
    translations = translations or State.translations
    if not source or source <= 0 then return end
    sessionId = sessionId or ensureSession(source)
    if not isCurrentSession(source, sessionId) then return end

    local seconds = math.max(GRACE_MIN, math.min(GRACE_MAX, tonumber(State.config.gracePeriod) or 0))
    if seconds <= 0 then
        DropPlayer(tostring(source), Util.Translate(translations, "kick_message"))
        return
    end

    State.gracePlayers[source] = {
        endTime = GetGameTimer() + seconds * 1000,
        playerName = playerName or "Unknown",
        sessionId = sessionId
    }
    TriggerClientEvent("esx_whitelist:startGracePeriod", source, seconds)

    SetTimeout(seconds * 1000, function()
        local grace = State.gracePlayers[source]
        if not grace or grace.sessionId ~= sessionId or not isCurrentSession(source, sessionId) then return end
        enforce(source, translations, false, sessionId)
    end)
end

---@description Kicks all connected players who are not whitelisted.
---@param translations table Locale translation strings
function Connection.KickNonWhitelisted(translations)
    CreateThread(function()
        local players = GetPlayers()
        for i = 1, #players do
            local source = tonumber(players[i])
            if source and not State.gracePlayers[source] then
                enforce(source, translations, nil, Connection.GetSessionId(source))
            end
            if i % KICK_CHUNK == 0 then Wait(0) end
        end
    end)
end

---@description Verifies a player during the connection deferral process.
---@param playerSource number The player source ID
---@param playerName string The player display name
---@param setKickReason fun(reason: string)
---@param deferrals table Connection deferral object
---@param translations table Locale translation strings
---@param sessionId number? The player session generation
function Connection.Verify(playerSource, playerName, setKickReason, deferrals, translations, sessionId)
    local source = tonumber(playerSource)
    if not source or source <= 0 then
        return finish(deferrals, false, "Invalid player connection.")
    end
    sessionId = sessionId or Connection.BeginSession(source)

    deferrals.defer()
    Wait(0)
    deferrals.update(Util.Translate(translations, "checking_whitelist"))
    Wait(0)

    local finished = false
    local function finishOnce(allow, reason)
        if finished or not isCurrentSession(source, sessionId) then return end
        finished = true
        if not allow then Connection.EndSession(source, sessionId) end
        finish(deferrals, allow, reason)
    end

    SetTimeout(Discord.DeferralTimeout() + 500, function()
        finishOnce(false, Util.Translate(translations, "kick_message"))
    end)

    local identifiers = Util.GetPlayerIdentifiersFiltered(source)
    Connection.Authorize(source, function(allow, reason)
        if not isCurrentSession(source, sessionId) then return end
        if allow then
            State.gracePlayers[source] = nil
            return finishOnce(true)
        end

        if Config.Debug then
            print(("^1[esx_whitelist] Rejected source %s: %s^7"):format(source, reason or "unknown"))
        end
        if reason == "discord_error" then
            return finishOnce(false, Util.Translate(translations, "discord_check_failed"))
        end

        finishOnce(false, Util.Translate(translations, "kick_message"))
    end, identifiers, sessionId)
end

---@description Forces enforcement of whitelist rules on a player (public alias for local enforce).
---@param source number The player source ID
---@param translations table Locale translation strings
---@param useGrace boolean Whether grace period applies
Connection.Enforce = enforce

return Connection
