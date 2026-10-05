-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local CACHE_FILE <const> = "data/discord_cache.json"
local API_BASE <const> = "https://discord.com/api/v10"
local FAILURE_CACHE_TTL <const> = 15 -- seconds; blunts reconnect loops during outages

---@param Util table
---@param DiscordUtil table
---@param RuntimeConfig table
---@param Log fun(level: string, message: string, context: table?)
return function(Util, DiscordUtil, RuntimeConfig, Log)
    local Discord = {}

    local cache = {}       ---@type table<string, { allowed: boolean, status: string, expiresAt: integer }>
    local inFlight = {}    ---@type table<string, any> userId -> shared promise
    local queue = {}       ---@type string[] FIFO of userIds waiting for a worker slot
    local activeCount = 0
    local rateLimitedUntil = 0 -- GetGameTimer() ms timestamp
    local cacheDirty = false
    local cacheFlushScheduled = false

    local stats = {
        requests = 0,      -- actual outbound HTTP requests
        cacheHits = 0,     -- served from cache
        shared = 0,        -- served by in-flight deduplication
        rateLimits = 0,    -- 429 responses seen
        errors = 0,        -- transient/fatal failures
        denied = 0,        -- verified but not allowed
        allowed = 0,       -- verified and allowed
    }

    local function discordConfig()
        return RuntimeConfig:Get().Discord
    end

    ---Resolves the bot token. Convar wins; the Lua value is a fallback.
    ---@return string
    local function resolveToken()
        local fromConvar = Util.Trim(GetConvar("discord:botToken", ""))
        if fromConvar ~= "" then
            return fromConvar
        end
        return Util.Trim(discordConfig().BotToken or "")
    end

    ---Whether a bot token is available (without revealing it).
    ---@return boolean
    function Discord:HasToken()
        return resolveToken() ~= ""
    end

    ---Whether Discord verification can run at all right now.
    ---@return boolean ok
    ---@return string? problem
    function Discord:IsConfigured()
        local cfg = discordConfig()
        if not cfg.Enabled then
            return false, "disabled"
        end
        if resolveToken() == "" then
            return false, "missing bot token (set discord:botToken in server.cfg)"
        end
        if not Util.IsSnowflake(cfg.GuildId) then
            return false, "invalid or missing guild id"
        end
        if type(cfg.AllowedRoles) ~= "table" or #cfg.AllowedRoles == 0 then
            return false, "no allowed roles configured"
        end
        return true, nil
    end

    --[[
        Cache persistence (debounced, same pattern as the admin cache).
    ]]

    local function scheduleCacheFlush()
        if cacheFlushScheduled then
            return
        end
        cacheFlushScheduled = true
        SetTimeout(2000, function()
            cacheFlushScheduled = false
            if not cacheDirty then
                return
            end
            cacheDirty = false
            local payload = json.encode(cache)
            if type(payload) == "string" then
                SaveResourceFile(GetCurrentResourceName(), CACHE_FILE, payload, -1)
            end
        end)
    end

    ---Loads the persisted cache, dropping expired or malformed entries.
    function Discord:LoadCache()
        local raw = LoadResourceFile(GetCurrentResourceName(), CACHE_FILE)
        if not raw or raw == "" then
            return
        end

        local ok, decoded = pcall(json.decode, raw)
        if not ok or type(decoded) ~= "table" then
            Log("warning", "Discord cache file is corrupted; starting with an empty cache")
            return
        end

        local now = Util.Now()
        local loaded = 0
        for userId, entry in pairs(decoded) do
            if type(userId) == "string"
                and Util.IsSnowflake(userId)
                and type(entry) == "table"
                and type(entry.allowed) == "boolean"
                and type(entry.status) == "string"
                and type(entry.expiresAt) == "number"
                and entry.expiresAt > now
            then
                cache[userId] = entry
                loaded = loaded + 1
            end
        end
        Log("info", ("Discord cache loaded (%d valid entries)"):format(loaded))
    end

    ---Flushes pending cache writes immediately (resource shutdown).
    function Discord:FlushCache()
        if cacheDirty then
            cacheDirty = false
            local payload = json.encode(cache)
            if type(payload) == "string" then
                SaveResourceFile(GetCurrentResourceName(), CACHE_FILE, payload, -1)
            end
        end
    end

    ---@param userId string
    ---@param result { allowed: boolean, status: string }
    local function storeResult(userId, result)
        local cfg = discordConfig()
        local ttl
        if result.allowed then
            ttl = cfg.CacheDuration
        elseif result.status == "role_missing" or result.status == "not_in_guild" then
            ttl = cfg.NegativeCacheDuration
        else
            ttl = FAILURE_CACHE_TTL
        end

        cache[userId] = {
            allowed = result.allowed,
            status = result.status,
            expiresAt = Util.Now() + ttl,
        }
        cacheDirty = true
        scheduleCacheFlush()
    end

    --[[
        HTTP layer. Every request races PerformHttpRequest against a
        SetTimeout so a stuck connection can never hang a verification.
    ]]

    ---@param guildId string
    ---@param userId string
    ---@param token string
    ---@param timeoutMs number
    ---@return { status: number, body: string?, headers: table?, timedOut: boolean? }
    local function httpGetMember(guildId, userId, token, timeoutMs)
        local requestPromise = promise.new()
        local settled = false

        local url = ("%s/guilds/%s/members/%s"):format(API_BASE, guildId, userId)
        PerformHttpRequest(url, function(statusCode, body, headers)
            if settled then
                return
            end
            settled = true
            requestPromise:resolve({
                status = tonumber(statusCode) or 0,
                body = body,
                headers = headers,
            })
        end, "GET", "", {
            ["Authorization"] = "Bot " .. token,
            ["Accept"] = "application/json",
            ["User-Agent"] = "esx_whitelist (https://github.com/esx-framework, 1.0.0)",
        })

        SetTimeout(timeoutMs, function()
            if settled then
                return
            end
            settled = true
            stats.errors = stats.errors + 1
            requestPromise:resolve({ status = 0, timedOut = true })
        end)

        return Citizen.Await(requestPromise)
    end

    --[[
        Verification worker. Must run inside a coroutine.
    ]]

    ---@param userId string
    ---@return { allowed: boolean, status: string }
    local function executeVerification(userId)
        local cfg = discordConfig()
        local token = resolveToken()
        local allowedRoles = Util.ToSet(cfg.AllowedRoles)

        local attempts = cfg.MaxRetries + 1
        local delay = cfg.RetryBaseDelay

        for attempt = 1, attempts do
            local response = httpGetMember(cfg.GuildId, userId, token, cfg.Timeout)
            stats.requests = stats.requests + 1
            local status = response.status

            -- Proactive rate-limit awareness: if Discord reports an empty
            -- budget, hold the queue until the window resets.
            local remaining, resetAfterMs = DiscordUtil.GetBudgetHint(response.headers)
            if remaining == 0 and resetAfterMs then
                rateLimitedUntil = GetGameTimer() + resetAfterMs
            end

            if status == 200 then
                local ok, member = pcall(json.decode, response.body)
                if ok and type(member) == "table" and type(member.roles) == "table" then
                    for i = 1, #member.roles do
                        if allowedRoles[member.roles[i]] then
                            stats.allowed = stats.allowed + 1
                            return { allowed = true, status = "ok" }
                        end
                    end
                    stats.denied = stats.denied + 1
                    return { allowed = false, status = "role_missing" }
                end
                -- 200 with an undecodable body is treated as transient.
                stats.errors = stats.errors + 1
            elseif status == 404 then
                -- User is not a member of the guild (or guild unknown to the
                -- bot: 404 also covers unknown guild for this route).
                stats.denied = stats.denied + 1
                return { allowed = false, status = "not_in_guild" }
            elseif status == 401 or status == 403 then
                -- Token invalid or bot lacks access. Fatal: retrying is
                -- pointless and would just burn the rate-limit budget.
                stats.errors = stats.errors + 1
                Log("error", ("Discord API rejected the request (HTTP %d). Check the bot token and guild access."):format(status))
                return { allowed = false, status = "misconfigured" }
            elseif status == 429 then
                stats.rateLimits = stats.rateLimits + 1
                local waitMs = DiscordUtil.GetRateLimitWait(status, response.body, response.headers, 2000)
                rateLimitedUntil = GetGameTimer() + waitMs
                Log("warning", ("Discord rate limit hit; pausing outbound requests for %d ms"):format(waitMs))
                Wait(waitMs)
            else
                -- Timeout (status 0), network error or 5xx: transient.
                stats.errors = stats.errors + 1
                if attempt < attempts then
                    Wait(delay)
                    delay = math.min(delay * 2, cfg.RetryMaxDelay)
                end
            end
        end

        return { allowed = false, status = "unavailable" }
    end

    --[[
        Queue draining. Event-driven: the queue is only touched when a
        request is enqueued or a worker finishes; there is no polling loop.
    ]]

    local function processQueue()
        while #queue > 0 do
            local limit = RuntimeConfig:Get().Performance.DiscordConcurrency
            if activeCount >= limit then
                return
            end

            local now = GetGameTimer()
            if rateLimitedUntil > now then
                local waitMs = rateLimitedUntil - now + 25
                SetTimeout(waitMs, processQueue)
                return
            end

            local userId = table.remove(queue, 1)
            activeCount = activeCount + 1

            CreateThread(function()
                local result = executeVerification(userId)
                activeCount = activeCount - 1

                local waiter = inFlight[userId]
                inFlight[userId] = nil
                if waiter then
                    waiter:resolve(result)
                end

                processQueue()
            end)
        end
    end

    --[[
        Public API
    ]]

    ---Verifies a Discord user. Yields until a result is available; callers
    ---needing a hard deadline should use Discord:VerifyAsync + a race.
    ---@param userId string Discord snowflake (validated by caller)
    ---@return { allowed: boolean, status: string, fromCache: boolean? }
    function Discord:Verify(userId)
        local now = Util.Now()
        local cached = cache[userId]
        if cached and cached.expiresAt > now then
            stats.cacheHits = stats.cacheHits + 1
            return { allowed = cached.allowed, status = cached.status, fromCache = true }
        end

        -- Deduplication: a concurrent verification for the same user
        -- awaits the already running request instead of starting a new one.
        local existing = inFlight[userId]
        if existing then
            stats.shared = stats.shared + 1
            return Citizen.Await(existing)
        end

        if #queue >= RuntimeConfig:Get().Performance.DiscordQueueLimit then
            stats.errors = stats.errors + 1
            return { allowed = false, status = "unavailable" }
        end

        local requestPromise = promise.new()
        inFlight[userId] = requestPromise
        queue[#queue + 1] = userId
        processQueue()

        local result = Citizen.Await(requestPromise)
        storeResult(userId, result)
        return result
    end

    ---Fire-and-await wrapper returning a promise, so the service can race
    ---the verification against Config.Performance.VerificationTimeout.
    ---@param userId string
    ---@return any promise
    function Discord:VerifyAsync(userId)
        local outer = promise.new()
        CreateThread(function()
            outer:resolve(self:Verify(userId))
        end)
        return outer
    end

    ---Drops all cached results (panel/command "cache clear").
    function Discord:ClearCache()
        cache = {}
        cacheDirty = true
        scheduleCacheFlush()
    end

    ---@return table
    function Discord:GetStats()
        return {
            requests = stats.requests,
            cacheHits = stats.cacheHits,
            shared = stats.shared,
            rateLimits = stats.rateLimits,
            errors = stats.errors,
            allowed = stats.allowed,
            denied = stats.denied,
            queueLength = #queue,
            activeRequests = activeCount,
            cachedEntries = (function()
                local count = 0
                for _ in pairs(cache) do
                    count = count + 1
                end
                return count
            end)(),
            rateLimited = rateLimitedUntil > GetGameTimer(),
        }
    end

    return Discord
end
