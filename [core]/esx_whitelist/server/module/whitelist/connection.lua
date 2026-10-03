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
local sessionAuthorized = {}
local lastGoodDiscordAuth = {}
local DISCORD_LAST_GOOD_TTL_MS <const> = 10 * 60 * 1000

---@description Helper function.
local function isCurrentDiscordPolicyTrusted(policy)
    if type(policy) ~= "table" then return false end
    return policy.method == "discord"
        and policy.guildId == State.config.discordGuildId
        and policy.roleId == State.config.discordRoleId
        and (GetGameTimer() - policy.at) <= DISCORD_LAST_GOOD_TTL_MS
end

---@description Helper function.
local function ensureSession(source)
    if playerSessions[source] then return playerSessions[source] end
    sessionSequence = sessionSequence + 1
    playerSessions[source] = sessionSequence
    return sessionSequence
end

---@description Helper function.
local function isCurrentSession(source, sessionId)
    return sessionId ~= nil and playerSessions[source] == sessionId
end

---@description Begins or replaces the current session for a player source.
function Connection.beginSession(source)
    source = tonumber(source)
    if not source or source <= 0 then return nil end
    local previous = playerSessions[source]
    if previous then
        sessionAuthorized[previous] = nil
        lastGoodDiscordAuth[previous] = nil
    end
    sessionSequence = sessionSequence + 1
    playerSessions[source] = sessionSequence
    return sessionSequence
end

---@description Helper function.
---@description Returns the current, or lazily creates a new, session ID for a source.
function Connection.getSessionId(source)
    source = tonumber(source)
    if not source or source <= 0 then return nil end
    return ensureSession(source)
end

---@description Ends the player session and clears session-bound caches.
function Connection.endSession(source, sessionId)
    source = tonumber(source)
    if not source then return end
    local currentSession = playerSessions[source]
    if sessionId and currentSession ~= sessionId then return end
    if currentSession then
        sessionAuthorized[currentSession] = nil
        lastGoodDiscordAuth[currentSession] = nil
    end
    playerSessions[source] = nil
    State.gracePlayers[source] = nil
    Auth.clear(source)
end

---@description Helper function.
local function redactIdentifier(identifier)
    local idType, value = tostring(identifier):match("^([^:]+):(.+)$")
    if not idType then return "[redacted]" end
    if #value <= 8 then return idType .. ":" .. string.rep("*", #value) end
    return ("%s:%s...%s"):format(idType, value:sub(1, 4), value:sub(-4))
end

---@description Helper function.
local function finish(deferrals, allow, reason)
    if allow then
        deferrals.done()
    else
        deferrals.done(reason or Util.translate(State.translations, "kick_message"))
    end
end

local DATABASE_TIMEOUT <const> = 10000
local databaseWaiters = {}
local databaseWaitThreadRunning = false

---@description Helper function.
local function completeDatabaseWaiter(waiter, ready)
    local ok, err = xpcall(function()
        waiter.callback(ready)
    end, debug.traceback)
    if not ok and Config.Debug then
        print("^1[esx_whitelist] Database readiness callback failed:^7 " .. tostring(err))
    end
end

---@description Helper function.
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

---@description Helper function.
local function enforce(source, translations, useGrace, sessionId, isMassEnforcement)
    source = tonumber(source)
    if not source or source <= 0 then return end
    sessionId = sessionId or ensureSession(source)

    if isMassEnforcement and sessionAuthorized[sessionId] == State.authorizationGeneration then
        return
    end

    Connection.authorize(source, function(allow)
        if not isCurrentSession(source, sessionId) then return end
        if allow then
            if State.gracePlayers[source] then
                State.gracePlayers[source] = nil
                TriggerClientEvent("esx_whitelist:cancelGracePeriod", source)
            end
            return
        end

        if State.config.kickConnected or useGrace == false then
            DropPlayer(tostring(source), Util.translate(translations or State.translations, "kick_message"))
        else
            Connection.startGrace(source, GetPlayerName(source) or "Unknown", translations or State.translations, sessionId)
        end
    end, nil, sessionId)
end

---@description Helper function.
local function identifiersFor(source)
    local identifiers = Util.getPlayerIdentifiersFiltered(source)
    Cache.setIdentifiers(source, identifiers)
    return identifiers
end

---@description Helper function.
local persistenceTasks = {}
local activePersistenceTasks = 0
local MAX_CONCURRENT_PERSISTENCE <const> = 12

---@description Helper function.
local function runNextPersistenceTasks()
    while activePersistenceTasks < MAX_CONCURRENT_PERSISTENCE and #persistenceTasks > 0 do
        local task = table.remove(persistenceTasks, 1)
        activePersistenceTasks = activePersistenceTasks + 1
        task(function()
            activePersistenceTasks = activePersistenceTasks - 1
            runNextPersistenceTasks()
        end)
    end
end

---@description Helper function.
local function queuePersistence(task)
    persistenceTasks[#persistenceTasks + 1] = task
    runNextPersistenceTasks()
end

---@description Helper function.
local function persistAccessAsync(source, identifiers, addedBy, sessionId)
    local task = function(done)
        whenDatabaseReady(function(ready)
            if not isCurrentSession(source, sessionId) or not ready then return done() end
            Database.ensureWhitelisted(
                GetPlayerName(source) or "Unknown",
                identifiers,
                addedBy,
                function(saved, err, whitelistId)
                    if not isCurrentSession(source, sessionId) then return done() end
                    if saved and whitelistId then
                        TriggerEvent("esx_whitelist:notifyEntryChanged", whitelistId)
                    end
                    if not saved and Config.Debug then
                        print(("^3[esx_whitelist] Async Discord access persistence notice: %s^7"):format(err or "unknown"))
                    end
                    done()
                end
            )
        end)
    end
    queuePersistence(task)
end

---@description Helper function.
local function checkDiscord(source, callback, sessionId)
    local discordIdentifier = GetPlayerIdentifierByType(source, "discord")
    if not discordIdentifier then return callback(false, "missing_discord") end

    local discordId = discordIdentifier:gsub("^discord:", "")
    Discord.checkRole(discordId, function(hasRole, err)
        if not isCurrentSession(source, sessionId) then return end
        local lastKnown = lastGoodDiscordAuth[sessionId]
        if err then
            if isCurrentDiscordPolicyTrusted(lastKnown) then
                return callback(true, "discord_last_known_good")
            end
            return callback(false, "discord_error")
        end
        if hasRole then
            lastGoodDiscordAuth[sessionId] = {
                at = GetGameTimer(),
                method = State.config.authorizationMethod,
                guildId = State.config.discordGuildId,
                roleId = State.config.discordRoleId
            }
        end
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
function Connection.authorize(source, callback, currentIdentifiers, sessionId)
    source = tonumber(source)
    if not source or source <= 0 then return callback(false, "invalid_source") end
    sessionId = sessionId or ensureSession(source)

    ---@description Helper function.
    local function respond(allow, reason)
        if isCurrentSession(source, sessionId) then
            if allow then sessionAuthorized[sessionId] = State.authorizationGeneration end
            callback(allow, reason)
        end
    end

    if State.configError then
        return respond(false, "config_error")
    end

    if not State.config.enabled then return respond(true, "whitelist_disabled") end

    local identifiers = currentIdentifiers
    if type(identifiers) ~= "table" then
        identifiers = Cache.getIdentifiers(source)
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

    local configuredMatch = Auth.hasConfiguredIdentifier(identifiers)
    if Config.Debug then
        print(("^3[esx_whitelist] Configured identifier match: %s^7"):format(tostring(configuredMatch)))
    end
    if configuredMatch then return respond(true, "configured_identifier") end

    ---@description Helper function.
    local function checkWhitelist()
        if State.config.authorizationMethod == "discord" then
            return checkDiscord(source, function(hasRole, reason)
                if not hasRole then
                    return respond(false, reason or "not_whitelisted")
                end

                -- Immediately allow player into server without blocking deferrals on MySQL
                respond(true, reason)

                -- Only queue persistence for live Discord approvals, never for last-known-good trust.
                if reason == "discord" then
                    persistAccessAsync(source, identifiers, "system:discord", sessionId)
                end
            end, sessionId)
        end

        local whitelisted = Cache.isWhitelisted(identifiers)
        respond(whitelisted == true, whitelisted and "identifier" or "not_whitelisted")
    end

    local localAdmin = Auth.isAdmin(source)
    if localAdmin then return respond(true, "admin") end
    if State.databaseReady then return checkWhitelist() end

    whenDatabaseReady(function(ready)
        if not isCurrentSession(source, sessionId) then return end
        if not ready then return callback(false, "database_unavailable") end
        checkWhitelist()
    end)
end

local ensureGraceThread -- forward declaration: assigned by the grace scheduler below

---@description Starts a grace period for a non-whitelisted connected player before kicking them.
---@param source number The player source ID
---@param playerName string The player display name
---@param translations table Locale translation strings
---@param sessionId number? The player session generation
function Connection.startGrace(source, playerName, translations, sessionId)
    source = tonumber(source)
    translations = translations or State.translations
    if not source or source <= 0 then return end
    sessionId = sessionId or ensureSession(source)
    if not isCurrentSession(source, sessionId) then return end

    local seconds = math.max(GRACE_MIN, math.min(GRACE_MAX, tonumber(State.config.gracePeriod) or 0))
    if seconds <= 0 then
        DropPlayer(tostring(source), Util.translate(translations, "kick_message"))
        return
    end

    State.gracePlayers[source] = {
        endTime = GetGameTimer() + seconds * 1000,
        playerName = playerName or "Unknown",
        sessionId = sessionId,
        translations = translations
    }
    TriggerClientEvent("esx_whitelist:startGracePeriod", source, seconds)
    ensureGraceThread()
end

local enforcementRunning = false
local enforcementRequested = false

-- Single scheduler for all grace expirations. Instead of one SetTimeout per
-- player (which creates a thundering herd when many players expire together),
-- one loop checks expired entries and processes them in bounded batches.
local GRACE_TICK_MS <const> = 250
local GRACE_BATCH <const> = 50
local graceThreadRunning = false

ensureGraceThread = function()
    if graceThreadRunning then return end
    graceThreadRunning = true
    CreateThread(function()
        while true do
            Wait(GRACE_TICK_MS)
            local now = GetGameTimer()
            local due = {}
            for source, grace in pairs(State.gracePlayers) do
                if type(grace) == "table" and grace.endTime and grace.endTime <= now then
                    due[#due + 1] = source
                end
            end
            for i = 1, math.min(#due, GRACE_BATCH) do
                local source = due[i]
                local grace = State.gracePlayers[source]
                if grace and grace.endTime and grace.endTime <= now
                    and isCurrentSession(source, grace.sessionId) then
                    enforce(source, grace.translations or State.translations, false, grace.sessionId)
                end
            end
        end
    end)
end

---@description Kicks all connected players who are not whitelisted.
---@param translations table Locale translation strings
function Connection.kickNonWhitelisted(translations)
    if enforcementRunning then
        enforcementRequested = true
        return
    end

    enforcementRunning = true
    CreateThread(function()
        while true do
            enforcementRequested = false
            local players = GetPlayers()
            for i = 1, #players do
                local source = tonumber(players[i])
                if source and not State.gracePlayers[source] then
                    enforce(source, translations or State.translations, nil, Connection.getSessionId(source), true)
                end
                if i % KICK_CHUNK == 0 then Wait(0) end
            end
            if not enforcementRequested then break end
        end
        enforcementRunning = false
    end)
end

---@description Verifies a player during the connection deferral process.
---@param playerSource number The player source ID
---@param playerName string The player display name
---@param setKickReason fun(reason: string)
---@param deferrals table Connection deferral object
---@param translations table Locale translation strings
---@param sessionId number? The player session generation
---@description Helper function.
function Connection.verify(playerSource, playerName, setKickReason, deferrals, translations, sessionId)
    local source = tonumber(playerSource)
    if not source or source <= 0 then
        return finish(deferrals, false, "Invalid player connection.")
    end
    sessionId = sessionId or Connection.beginSession(source)

    deferrals.defer()
    Wait(0)
    deferrals.update(Util.translate(translations, "checking_whitelist"))
    Wait(0)

    local finished = false
    ---@description Helper function.
    local function finishOnce(allow, reason)
        if finished or not isCurrentSession(source, sessionId) then return end
        finished = true
        if not allow then Connection.endSession(source, sessionId) end
        finish(deferrals, allow, reason)
    end

    local timeoutMs
    if State.config.authorizationMethod == "discord" then
        timeoutMs = Discord.deferralTimeout() + 500
    else
        timeoutMs = tonumber(Config.IdentifierDeferralTimeout) or 5000
    end

    SetTimeout(timeoutMs, function()
        finishOnce(false, Util.translate(translations, "kick_message"))
    end)

    local identifiers = Util.getPlayerIdentifiersFiltered(source)
    Connection.authorize(source, function(allow, reason)
        if not isCurrentSession(source, sessionId) then return end
        if allow then
            State.gracePlayers[source] = nil
            return finishOnce(true)
        end

        if Config.Debug then
            print(("^1[esx_whitelist] Rejected source %s: %s^7"):format(source, reason or "unknown"))
        end
        if reason == "discord_error" then
            return finishOnce(false, Util.translate(translations, "discord_check_failed"))
        elseif reason == "config_error" then
            return finishOnce(false, Util.translate(translations, "config_error") or "Server configuration error: Whitelist is in safe-lock mode.")
        end

        finishOnce(false, Util.translate(translations, "kick_message"))
    end, identifiers, sessionId)
end

---@description Forces enforcement of whitelist rules on a player (public alias for local enforce).
---@param source number The player source ID
---@param translations table Locale translation strings
---@param useGrace boolean Whether grace period applies
Connection.enforce = enforce

return Connection
