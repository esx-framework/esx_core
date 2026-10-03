-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local ServerConfig <const> = xLib.require "@esx_whitelist.server.config.main"
local Util <const> = xLib.require "@esx_whitelist.server.module.whitelist.util"
local Enum <const> = xLib.require "@esx_whitelist.server.module.whitelist.Enum"
local State <const> = xLib.require "@esx_whitelist.server.module.whitelist.state"

---@class Discord
---@description Discord integration for role verification, webhook logging, and API communication with retry logic.
local Discord = {}

local POSITIVE_TTL <const> = math.max(60, math.min(3600, math.floor(tonumber(Config.DiscordCacheTTL) or 300)))
local NEGATIVE_TTL <const> = 30
local MAX_ATTEMPTS <const> = 3
local RETRY_DELAY <const> = 1000
local TIMEOUT <const> = 15000
local QUEUE_TIMEOUT <const> = 65000
local MAX_CONCURRENT_REQUESTS <const> = math.max(1, math.min(64, math.floor(tonumber(Config.DiscordMaxConcurrentRequests) or 8)))
local MAX_QUEUED_REQUESTS <const> = math.max(1, math.min(10000, math.floor(tonumber(Config.DiscordMaxQueuedRequests) or 2048)))
local REQUEST_INTERVAL <const> = math.max(0, math.min(1000, math.floor(tonumber(Config.DiscordRequestIntervalMs) or 25)))
local cache = {}
local pending = {}
local webhookCooldownUntil = 0
local requestQueue = {}
local queueHead, queueTail, queuedCount = 1, 0, 0
local activeRequests = 0
local globalRetryAt = 0
local nextRequestAt = 0
local pumpTimerScheduled = false
local pump
local pendingTimeouts = {}
local timeoutSweeperRunning = false

State.config.discordBotToken = ServerConfig.DiscordBotToken or ""

---@description Helper function.
local function compactQueue()
    local compacted = {}
    for index = queueHead, queueTail do
        local request = requestQueue[index]
        if request and request.queued and not request.settled then
            compacted[#compacted + 1] = request
            request.queueIndex = #compacted
        end
    end
    requestQueue = compacted
    queueHead = 1
    queueTail = #compacted
    queuedCount = queueTail
end

---@description Helper function.
local function removeQueued(request)
    if not request.queued then return end
    requestQueue[request.queueIndex] = nil
    request.queueIndex = nil
    request.queued = false
    queuedCount = math.max(0, queuedCount - 1)
    if queuedCount == 0 then
        requestQueue = {}
        queueHead, queueTail = 1, 0
    end
end

---@description Helper function.
local function takeQueued()
    while queueHead <= queueTail do
        local request = requestQueue[queueHead]
        requestQueue[queueHead] = nil
        queueHead = queueHead + 1
        if request then
            request.queueIndex = nil
            request.queued = false
            queuedCount = math.max(0, queuedCount - 1)
            if not request.settled then
                if queueHead > queueTail then
                    requestQueue = {}
                    queueHead, queueTail = 1, 0
                end
                return request
            end
        end
    end
    requestQueue = {}
    queueHead, queueTail, queuedCount = 1, 0, 0
    return nil
end

---@description Helper function.
local function sweepQueueTimeouts()
    while true do
        Wait(500)
        local now = GetGameTimer()
        local remaining = {}
        for i = 1, #pendingTimeouts do
            local request = pendingTimeouts[i]
            if request and request.queued and not request.settled then
                if now >= request.queueDeadline then
                    request.finish(false, "discord_queue_timeout")
                else
                    remaining[#remaining + 1] = request
                end
            end
        end
        pendingTimeouts = remaining
    end
end

---@description Helper function.
local function ensureTimeoutSweeper()
    if timeoutSweeperRunning then return end
    timeoutSweeperRunning = true
    CreateThread(sweepQueueTimeouts)
end

---@description Helper function.
local function schedulePump(delay)
    if pumpTimerScheduled then return end
    pumpTimerScheduled = true
    SetTimeout(math.max(0, delay), function()
        pumpTimerScheduled = false
        pump()
    end)
end

---@description Helper function.
local function enqueue(request)
    if request.settled or request.queued or request.active then return end
    if queuedCount >= MAX_QUEUED_REQUESTS then return false end
    if queueTail >= MAX_QUEUED_REQUESTS * 2 then compactQueue() end
    queueTail = queueTail + 1
    requestQueue[queueTail] = request
    request.queueIndex = queueTail
    request.queued = true
    request.queueDeadline = GetGameTimer() + QUEUE_TIMEOUT
    queuedCount = queuedCount + 1
    pendingTimeouts[#pendingTimeouts + 1] = request
    ensureTimeoutSweeper()
    pump()
    return true
end

pump = function()
    local delay = globalRetryAt - GetGameTimer()
    if delay > 0 then
        schedulePump(delay)
        return
    end

    while activeRequests < MAX_CONCURRENT_REQUESTS do
        local intervalDelay = nextRequestAt - GetGameTimer()
        if intervalDelay > 0 then
            schedulePump(intervalDelay)
            return
        end

        local request = takeQueued()
        if not request then return end
        request.active = true
        activeRequests = activeRequests + 1
        nextRequestAt = GetGameTimer() + REQUEST_INTERVAL
        request.run()
    end
end

---@description Helper function.
local function retryDelay(headers, data, attempts)
    local retryAfter
    if type(headers) == "table" then
        for name, value in pairs(headers) do
            if tostring(name):lower() == "retry-after" then
                retryAfter = tonumber(value)
                break
            end
        end
    end

    if not retryAfter and type(data) == "string" then
        local ok, decoded = pcall(json.decode, data)
        if ok and type(decoded) == "table" then
            retryAfter = tonumber(decoded.retry_after)
        end
    end

    if retryAfter and retryAfter > 0 then
        return math.max(100, math.ceil(retryAfter * 1000))
    end
    return RETRY_DELAY * attempts
end

---@description Helper function.
local function isGlobalRateLimit(headers, data)
    if type(headers) == "table" then
        for name, value in pairs(headers) do
            local normalizedName = tostring(name):lower()
            if (normalizedName == "x-ratelimit-global" or normalizedName == "x-rate-limit-global")
                and tostring(value):lower() == "true" then
                return true
            end
        end
    end

    if type(data) == "string" then
        local ok, decoded = pcall(json.decode, data)
        return ok and type(decoded) == "table" and decoded.global == true
    end
    return false
end

---@description Helper function.
local function configured()
    return State.config.discordEnabled
        and State.config.discordGuildId ~= ""
        and State.config.discordRoleId ~= ""
        and Util.isValidBotToken(State.config.discordBotToken)
end

---@description Checks if the Discord bot token is valid.
---@return boolean valid
function Discord.hasValidToken()
    return Util.isValidBotToken(State.config.discordBotToken)
end

---@description Checks if a Discord user has the configured role, with caching and deduplication.
---@param discordId string Discord user ID
---@param callback fun(hasRole: boolean, error?: string)
---@param opts table? Optional { isAlive = function(): boolean }
function Discord.checkRole(discordId, callback, opts)
    if not configured() then
        return callback(false, "not_configured")
    end

    if type(discordId) ~= "string" or not discordId:match("^%d+$") then
        return callback(false, "invalid_discord_id")
    end

    local guildId = State.config.discordGuildId
    local roleId = State.config.discordRoleId
    local botToken = State.config.discordBotToken
    local now = os.time()
    local cacheKey = ("%s:%s:%s"):format(guildId, roleId, discordId)
    local cached = cache[cacheKey]
    if cached and cached.expires > now then
        return callback(cached.hasRole, nil)
    end

    if pending[cacheKey] then
        pending[cacheKey].callbacks[#pending[cacheKey].callbacks + 1] = callback
        return
    end

    if queuedCount >= MAX_QUEUED_REQUESTS then
        return callback(false, "discord_queue_full")
    end

    local request = { callbacks = { callback }, settled = false, attempts = 0, opts = opts }
    pending[cacheKey] = request

    ---@description Helper function.
    local function finish(hasRole, err)
        if request.settled then return end
        request.settled = true
        removeQueued(request)
        if request.active then
            request.active = false
            activeRequests = math.max(0, activeRequests - 1)
        end

        if not err then
            cache[cacheKey] = {
                hasRole = hasRole,
                expires = os.time() + (hasRole and POSITIVE_TTL or NEGATIVE_TTL)
            }
        end

        pending[cacheKey] = nil
        pump()
        local callbacks = request.callbacks
        for i = 1, #callbacks do callbacks[i](hasRole, err) end
    end
    request.finish = finish

    local endpoint = ("https://discord.com/api/v10/guilds/%s/members/%s"):format(guildId, discordId)
    local headers = {
        ["Authorization"] = "Bot " .. botToken,
        ["Content-Type"] = "application/json"
    }
    request.run = function()
        if request.settled then
            request.active = false
            activeRequests = math.max(0, activeRequests - 1)
            return pump()
        end

        if request.opts and request.opts.isAlive and not request.opts.isAlive() then
            return finish(false, "session_disconnect")
        end

        request.attempts = request.attempts + 1
        local attempt = request.attempts
        SetTimeout(TIMEOUT, function()
            if request.active and request.attempts == attempt then
                finish(false, "discord_timeout")
            end
        end)

        PerformHttpRequest(endpoint, function(statusCode, data, responseHeaders)
            if request.active then
                request.active = false
                activeRequests = math.max(0, activeRequests - 1)
            end

            if statusCode == 429 then
                local delay = retryDelay(responseHeaders, data, request.attempts)
                if isGlobalRateLimit(responseHeaders, data) then
                    globalRetryAt = math.max(globalRetryAt, GetGameTimer() + delay)
                end
            end

            if request.settled then return pump() end

            if statusCode == 200 and data then
                local member = data
                if type(data) == "string" then
                    local ok, decoded = pcall(json.decode, data)
                    if not ok then return finish(false, "invalid_response") end
                    member = decoded
                end
                if type(member) ~= "table" then return finish(false, "invalid_response") end

                local hasRole = false
                for i = 1, #(member.roles or {}) do
                    if member.roles[i] == roleId then
                        hasRole = true
                        break
                    end
                end
                return finish(hasRole, nil)
            end

            if statusCode == 404 then
                return finish(false, nil)
            end

            if statusCode == 429 then
                if request.attempts < MAX_ATTEMPTS then
                    local delay = retryDelay(responseHeaders, data, request.attempts)
                    SetTimeout(delay, function()
                        if not enqueue(request) then finish(false, "discord_queue_full") end
                    end)
                    return pump()
                end
                return finish(false, "discord_api_error:429")
            end

            if (statusCode >= 500 or statusCode == 0) and request.attempts < MAX_ATTEMPTS then
                local delay = RETRY_DELAY * request.attempts
                SetTimeout(delay, function()
                    if not enqueue(request) then finish(false, "discord_queue_full") end
                end)
                return pump()
            end

            finish(false, "discord_api_error:" .. tostring(statusCode))
        end, "GET", "", headers)
    end

    if not enqueue(request) then finish(false, "discord_queue_full") end
end

---@description Sends a log message to the Discord webhook with cooldown.
---@param message string Log message
---@param color number Discord embed color
---@param translations table Locale strings
---@return boolean sent
function Discord.sendLog(message, color, translations)
    local webhook = State.config.discordWebhook
    if type(webhook) ~= "string" or webhook == "" or webhook == "***CONFIGURED***" then return false end

    local now = GetGameTimer()
    if now < webhookCooldownUntil then return false end
    webhookCooldownUntil = now + 5000

    local payload = json.encode({ embeds = {{
        title = Util.translate(translations, "discord_title"),
        description = tostring(message or ""):sub(1, 1800),
        color = color or Enum.DiscordEmbedColor.PRIMARY,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
    }}})

    PerformHttpRequest(webhook, function() end, "POST", payload, {
        ["Content-Type"] = "application/json"
    })
    return true
end

---@description Helper function.
function Discord.sweep()
    local now = os.time()
    for id, entry in pairs(cache) do
        if entry.expires <= now then cache[id] = nil end
    end
end

---@description Returns the HTTP timeout duration in milliseconds.
---@return number timeoutMs
function Discord.deferralTimeout()
    return QUEUE_TIMEOUT + TIMEOUT + 5000
end

return Discord
