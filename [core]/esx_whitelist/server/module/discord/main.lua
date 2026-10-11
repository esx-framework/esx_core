-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local API_BASE <const> = 'https://discord.com/api/v10'

return function(Util, DiscordUtil, RuntimeConfig, Log, Database)
    local Discord = {}
    local latency = Util.NewLatencyMetrics()
    local cache, inFlight = {}, {}
    local cacheCount = 0
    local cacheHead, cacheTail
    local queueHead, queueTail
    local queueCount, activeCount = 0, 0
    local queueResumeScheduled = false
    local rateLimitedUntil = 0
    local nextRequestAt = 0
    local generation = 0
    local policyKey
    local gcScheduled = false
    local stats = {
        requests = 0,
        cacheHits = 0,
        shared = 0,
        rateLimits = 0,
        errors = 0,
        denied = 0,
        allowed = 0,
        cancelled = 0,
    }

    local function discordConfig()
        return RuntimeConfig:Get().Discord
    end

    local function resolveToken()
        local token = Util.Trim(GetConvar('discord:botToken', ''))

        return token ~= '' and token or Util.Trim(discordConfig().BotToken or '')
    end

    function Discord:HasToken()
        return resolveToken() ~= ''
    end

    function Discord:IsConfigured()
        local cfg = discordConfig()

        if not cfg.Enabled then
            return false, 'disabled'
        end

        if resolveToken() == '' then
            return false, 'missing bot token (set discord:botToken in server.cfg)'
        end

        if not Util.IsSnowflake(cfg.GuildId) then
            return false, 'invalid or missing guild id'
        end

        if type(cfg.AllowedRoles) ~= 'table' or #cfg.AllowedRoles == 0 then
            return false, 'no allowed roles configured'
        end

        return true
    end

    local function removeCache(entry)
        if entry.previous then
            entry.previous.next = entry.next
        else
            cacheHead = entry.next
        end

        if entry.next then
            entry.next.previous = entry.previous
        else
            cacheTail = entry.previous
        end

        cache[entry.userId] = nil
        cacheCount = cacheCount - 1
    end

    local function sweepCache()
        local now = GetGameTimer()
        local entry = cacheHead

        while entry do
            local nextEntry = entry.next

            if entry.expiresAt <= now then
                removeCache(entry)
            end

            entry = nextEntry
        end
    end

    local function scheduleGC()
        if gcScheduled then
            return
        end

        gcScheduled = true
        SetTimeout(30000, function()
            gcScheduled = false
            sweepCache()

            if cacheCount > 0 then
                scheduleGC()
            end
        end)
    end

    local function storeResult(job, result)
        if job.generation ~= generation or result.status == 'cancelled' then
            return
        end

        local cfg = job.config
        local verified = result.status == 'ok'
            or result.status == 'role_missing'
            or result.status == 'not_in_guild'
        local ttl = verified and (cfg.CacheTTL or 60) or 15

        if ttl <= 0 then
            return
        end

        local old = cache[job.userId]

        if old then
            removeCache(old)
        end

        local limit = math.max(1, cfg.CacheMaxEntries or 10000)

        while cacheCount >= limit do
            removeCache(cacheHead)
        end

        local entry = {
            userId = job.userId,
            allowed = result.allowed,
            status = result.status,
            expiresAt = GetGameTimer() + ttl * 1000,
            previous = cacheTail,
        }

        if cacheTail then
            cacheTail.next = entry
        else
            cacheHead = entry
        end

        cacheTail = entry
        cache[job.userId] = entry
        cacheCount = cacheCount + 1
        scheduleGC()
    end

    ---A doubly linked FIFO permits both dequeue and cancellation in O(1).
    local function unlink(job)
        if not job.queued then
            return
        end

        if job.previous then
            job.previous.next = job.next
        else
            queueHead = job.next
        end

        if job.next then
            job.next.previous = job.previous
        else
            queueTail = job.previous
        end

        job.previous, job.next, job.queued = nil, nil, false
        queueCount = queueCount - 1
    end

    local function alive(job)
        return job.waiterCount > 0 and job.generation == generation and not job.cancelled
    end

    ---Retries never hold a worker for a departed consumer's entire delay.
    local function pause(job, delay)
        local untilAt = GetGameTimer() + delay

        while alive(job) and GetGameTimer() < untilAt do
            Wait(math.min(100, untilAt - GetGameTimer()))
        end
    end

    local function waitForBudget(job)
        while alive(job) do
            local untilAt = math.max(rateLimitedUntil, nextRequestAt)

            if GetGameTimer() >= untilAt then
                local perSecond = math.max(1, job.config.RequestsPerSecond or 40)
                nextRequestAt = GetGameTimer() + math.ceil(1000 / perSecond)

                return true
            end

            pause(job, untilAt - GetGameTimer())
        end

        return false
    end

    local function httpGetMember(guildId, userId, token, timeoutMs, job)
        local requestPromise = promise.new()
        local settled = false

        local url = ('%s/guilds/%s/members/%s'):format(API_BASE, guildId, userId)
        PerformHttpRequest(
            url,
            function(statusCode, body, headers)
                if settled then
                    return
                end

                settled = true
                requestPromise:resolve({
                    status = tonumber(statusCode) or 0,
                    body = body,
                    headers = headers,
                })
            end,
            'GET',
            '',
            {
                ['Authorization'] = 'Bot ' .. token,
                ['Accept'] = 'application/json',
                ['User-Agent'] = 'esx_whitelist (https://github.com/esx-framework, 1.0.0)',
            }
        )

        job.cancelHttp = function()
            if not settled then
                settled = true
                requestPromise:resolve({ status = 0, cancelled = true })
            end
        end

        if not alive(job) then
            job.cancelHttp()
        end

        SetTimeout(timeoutMs, function()
            if settled then
                return
            end

            settled = true
            stats.errors = stats.errors + 1
            requestPromise:resolve({ status = 0, timedOut = true })
        end)

        local result = Citizen.Await(requestPromise)
        job.cancelHttp = nil

        return result
    end

    local function executeVerification(job)
        local cfg = job.config
        local token = job.token
        local allowedRoles = Util.ToSet(cfg.AllowedRoles)

        local attempts = cfg.MaxRetries + 1
        local delay = cfg.RetryBaseDelay

        for attempt = 1, attempts do
            if not alive(job) then
                return { allowed = false, status = 'cancelled' }
            end

            if not waitForBudget(job) then
                return { allowed = false, status = 'cancelled' }
            end

            stats.requests = stats.requests + 1
            local response = httpGetMember(cfg.GuildId, job.userId, token, cfg.Timeout, job)

            if not alive(job) or response.cancelled then
                return { allowed = false, status = 'cancelled' }
            end
            local status = response.status

            -- Proactive rate-limit awareness: if Discord reports an empty
            -- budget, hold the queue until the window resets.
            local remaining, resetAfterMs = DiscordUtil.GetBudgetHint(response.headers)

            if remaining == 0 and resetAfterMs then
                rateLimitedUntil = math.max(rateLimitedUntil, GetGameTimer() + resetAfterMs)
            end

            if status == 200 then
                local ok, member = pcall(json.decode, response.body)

                if ok and type(member) == 'table' and type(member.roles) == 'table' then
                    for i = 1, #member.roles do
                        if allowedRoles[member.roles[i]] then
                            stats.allowed = stats.allowed + 1

                            return { allowed = true, status = 'ok' }
                        end
                    end

                    stats.denied = stats.denied + 1

                    return { allowed = false, status = 'role_missing' }
                end
                -- 200 with an undecodable body is treated as transient.
                stats.errors = stats.errors + 1
            elseif status == 404 then
                -- User is not a member of the guild (or guild unknown to the
                -- bot: 404 also covers unknown guild for this route).
                stats.denied = stats.denied + 1

                return { allowed = false, status = 'not_in_guild' }
            elseif status == 401 or status == 403 then
                -- Token invalid or bot lacks access. Fatal: retrying is
                -- pointless and would just burn the rate-limit budget.
                stats.errors = stats.errors + 1
                Log(
                    'error',
                    ('Discord API rejected the request (HTTP %d). Check the bot token and guild access.'):format(
                        status
                    )
                )

                return { allowed = false, status = 'misconfigured' }
            elseif status == 429 then
                stats.rateLimits = stats.rateLimits + 1
                local waitMs =
                    DiscordUtil.GetRateLimitWait(status, response.body, response.headers, 2000)
                rateLimitedUntil = math.max(rateLimitedUntil, GetGameTimer() + waitMs)
                Log(
                    'warning',
                    ('Discord rate limit hit; pausing outbound requests for %d ms'):format(waitMs)
                )
                if attempt < attempts then
                    pause(job, waitMs)
                end
            else
                -- Timeout (status 0), network error or 5xx: transient.
                stats.errors = stats.errors + 1

                if attempt < attempts then
                    pause(job, delay)
                    delay = math.min(delay * 2, cfg.RetryMaxDelay)
                end
            end
        end

        return { allowed = false, status = 'unavailable' }
    end

    local processQueue

    local function release(job, waiter, result)
        if waiter.done then
            return
        end

        latency:Observe(GetGameTimer() - waiter.startedAt)
        waiter.done = true
        job.waiters[waiter] = nil
        job.waiterCount = job.waiterCount - 1
        local pending = waiter.promise
        waiter.job, waiter.promise = nil, nil
        pending:resolve(result)

        if job.waiterCount == 0 then
            job.cancelled = true
            unlink(job)

            if inFlight[job.userId] == job then
                inFlight[job.userId] = nil
            end

            if job.cancelHttp then
                job.cancelHttp()
            end
        end
    end

    processQueue = function()
        while queueHead do
            local limit = RuntimeConfig:Get().Performance.DiscordConcurrency

            if activeCount >= limit then
                return
            end

            if rateLimitedUntil > GetGameTimer() then
                if not queueResumeScheduled then
                    queueResumeScheduled = true
                    SetTimeout(rateLimitedUntil - GetGameTimer() + 25, function()
                        queueResumeScheduled = false
                        processQueue()
                    end)
                end

                return
            end

            local job = queueHead
            unlink(job)

            if alive(job) then
                activeCount = activeCount + 1
                job.running = true

                CreateThread(function()
                    local ok, result = pcall(executeVerification, job)
                    activeCount = activeCount - 1

                    if not ok then
                        stats.errors = stats.errors + 1
                        Log('error', 'Discord worker failed: ' .. tostring(result))
                        result = { allowed = false, status = 'unavailable' }
                    end

                    if alive(job) then
                        storeResult(job, result)
                    end

                    if inFlight[job.userId] == job then
                        inFlight[job.userId] = nil
                    end

                    for waiter in pairs(job.waiters) do
                        release(job, waiter, result)
                    end

                    processQueue()
                end)
            end
        end
    end

    function Discord:ClearCache()
        generation = generation + 1
        cache, cacheHead, cacheTail, cacheCount = {}, nil, nil, 0
        local jobs = inFlight
        inFlight = {}

        for _, job in pairs(jobs) do
            for waiter in pairs(job.waiters) do
                release(job, waiter, { allowed = false, status = 'cancelled' })
            end
        end

        return true
    end

    function Discord:LoadCache()
        self:ClearCache()
    end

    function Discord:FlushCache()
        -- Decisions are bounded, short-lived RAM data; no SQL per verification.
    end

    ---Every consumer has its own deadline and cancellation handle.
    function Discord:VerifyAsync(userId, timeoutMs)
        local outer = promise.new()
        local function immediate(result)
            outer:resolve(result)

            return outer, function() end
        end

        if not Util.IsSnowflake(userId) or not self:IsConfigured() then
            return immediate({ allowed = false, status = 'misconfigured' })
        end

        local cfg = discordConfig()
        local token = resolveToken()
        local key = tostring(cfg.Enabled)
            .. ':'
            .. cfg.GuildId
            .. ':'
            .. table.concat(cfg.AllowedRoles, ',')
            .. ':'
            .. token

        if key ~= policyKey then
            self:ClearCache()
            policyKey = key
        end

        local cached = cache[userId]

        if cached and cached.expiresAt > GetGameTimer() then
            stats.cacheHits = stats.cacheHits + 1

            return immediate({ allowed = cached.allowed, status = cached.status, fromCache = true })
        elseif cached then
            removeCache(cached)
        end

        local job = inFlight[userId]

        if job then
            stats.shared = stats.shared + 1
        else
            if queueCount >= RuntimeConfig:Get().Performance.DiscordQueueLimit then
                stats.errors = stats.errors + 1

                return immediate({ allowed = false, status = 'unavailable' })
            end

            job = {
                userId = userId,
                generation = generation,
                config = Util.DeepCopy(cfg),
                token = token,
                waiters = {},
                waiterCount = 0,
                queued = true,
                previous = queueTail,
            }

            if queueTail then
                queueTail.next = job
            else
                queueHead = job
            end

            queueTail = job
            queueCount = queueCount + 1
            inFlight[userId] = job
        end

        local waiter = { job = job, promise = outer, startedAt = GetGameTimer() }
        job.waiters[waiter] = true
        job.waiterCount = job.waiterCount + 1
        local deadline = timeoutMs or RuntimeConfig:Get().Performance.VerificationTimeout

        SetTimeout(deadline, function()
            local currentJob = waiter.job

            if currentJob then
                stats.cancelled = stats.cancelled + 1
                release(currentJob, waiter, { allowed = false, status = 'timeout' })
                processQueue()
            end
        end)

        local function cancel()
            local currentJob = waiter.job

            if currentJob then
                stats.cancelled = stats.cancelled + 1
                release(currentJob, waiter, { allowed = false, status = 'cancelled' })
                processQueue()
            end
        end

        processQueue()

        return outer, cancel
    end

    function Discord:Verify(userId)
        local pending = self:VerifyAsync(userId)

        return Citizen.Await(pending)
    end

    function Discord:GetStats()
        sweepCache()

        return {
            requests = stats.requests,
            cacheHits = stats.cacheHits,
            shared = stats.shared,
            rateLimits = stats.rateLimits,
            errors = stats.errors,
            allowed = stats.allowed,
            denied = stats.denied,
            cancelled = stats.cancelled,
            queueLength = queueCount,
            activeRequests = activeCount,
            latencyMs = latency:Get(),
            cachedEntries = cacheCount,
            rateLimited = rateLimitedUntil > GetGameTimer(),
        }
    end

    return Discord
end
