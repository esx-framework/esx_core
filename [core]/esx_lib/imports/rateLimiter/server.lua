---@class RateLimiterOptions
---@field capacity number Maximum tokens a key can accumulate.
---@field refill number Tokens restored per interval.
---@field interval number Refill interval in milliseconds.
---@field maxEntries? number Maximum keys retained by this limiter.
---@field staleMs? number Idle time before full buckets can be pruned.
---@field pruneInterval? number Minimum time between opportunistic stale prunes.

---@class RateLimiter
---@field consume fun(self: RateLimiter, key: string|number, cost?: number): boolean, number
---@field reset fun(self: RateLimiter, key: string|number): boolean
---@field clear fun(self: RateLimiter)
---@field retryAfter fun(self: RateLimiter, key: string|number, cost?: number): number
---@field size fun(self: RateLimiter): number

local math_floor = math.floor
local math_ceil = math.ceil
local math_min = math.min

local function nowMs()
    return GetGameTimer()
end

local function positiveConvarInt(name, fallback)
    local value = GetConvarInt(name, fallback)

    if value <= 0 then
        return fallback
    end

    return value
end

local function positiveNumber(name, value, default, integer)
    local number = tonumber(value)

    if not number or number <= 0 then
        if default ~= nil then
            number = tonumber(default)
        end

        if not number or number <= 0 then
            error(("[xLib] rateLimiter option '%s' must be a positive number"):format(name), 3)
        end
    end

    if integer then
        number = math_floor(number)

        if number <= 0 then
            error(("[xLib] rateLimiter option '%s' must be at least 1"):format(name), 3)
        end
    end

    return number
end

local function normalizeKey(key)
    local keyType = type(key)

    if keyType == "number" or keyType == "string" then
        return tostring(key)
    end
end

---@param options RateLimiterOptions
---@return RateLimiter
local function createRateLimiter(options)
    if type(options) ~= "table" then
        error("[xLib] rateLimiter requires an options table", 2)
    end

    local capacity = positiveNumber("capacity", options.capacity, nil)
    local refill = positiveNumber("refill", options.refill, nil)
    local interval = positiveNumber("interval", options.interval, nil, true)
    local maxEntries = positiveNumber("maxEntries", options.maxEntries, positiveConvarInt("xLib:rateLimiterMaxEntries", 4096), true)
    local staleMs = positiveNumber("staleMs", options.staleMs, math.max(60000, math_ceil((capacity / refill) * interval * 4)), true)
    local pruneInterval = positiveNumber("pruneInterval", options.pruneInterval, staleMs, true)

    local buckets = {}
    local bucketCount = 0
    local lastPrune = 0

    local limiter = {}

    local function removeBucket(key)
        if buckets[key] then
            buckets[key] = nil
            bucketCount = bucketCount - 1
            return true
        end

        return false
    end

    local function refillBucket(bucket, now)
        local elapsed = now - bucket.updated

        if elapsed <= 0 then
            return
        end

        bucket.tokens = math_min(capacity, bucket.tokens + (elapsed / interval) * refill)
        bucket.updated = now
    end

    local function prune(now, force)
        if not force and now - lastPrune < pruneInterval and bucketCount < maxEntries then
            return
        end

        lastPrune = now

        for key, bucket in pairs(buckets) do
            refillBucket(bucket, now)

            if bucket.tokens >= capacity and now - bucket.lastUsed >= staleMs then
                removeBucket(key)
            end
        end

        if bucketCount < maxEntries then
            return
        end

        local entries = {}

        for key, bucket in pairs(buckets) do
            entries[#entries + 1] = { key = key, lastUsed = bucket.lastUsed }
        end

        table.sort(entries, function(a, b)
            return a.lastUsed < b.lastUsed
        end)

        local index = 1

        while bucketCount >= maxEntries and entries[index] do
            removeBucket(entries[index].key)
            index = index + 1
        end
    end

    local function getBucket(key, now)
        local bucket = buckets[key]

        if bucket then
            refillBucket(bucket, now)
            return bucket
        end

        if bucketCount >= maxEntries then
            prune(now, true)
        end

        if bucketCount >= maxEntries then
            return nil
        end

        bucket = {
            tokens = capacity,
            updated = now,
            lastUsed = now,
        }

        buckets[key] = bucket
        bucketCount = bucketCount + 1

        return bucket
    end

    function limiter:consume(key, cost)
        local bucketKey = normalizeKey(key)

        if not bucketKey then
            return false, 0
        end

        cost = tonumber(cost) or 1

        if cost <= 0 then
            return true, 0
        end

        if cost > capacity then
            return false, math.huge
        end

        local now = nowMs()
        prune(now, false)

        local bucket = getBucket(bucketKey, now)
        if not bucket then
            return false, 0
        end

        if bucket.tokens >= cost then
            bucket.tokens = bucket.tokens - cost
            bucket.updated = now
            bucket.lastUsed = now
            return true, 0
        end

        bucket.lastUsed = now

        return false, math_ceil(((cost - bucket.tokens) / refill) * interval)
    end

    function limiter:retryAfter(key, cost)
        local bucketKey = normalizeKey(key)

        if not bucketKey then
            return 0
        end

        cost = tonumber(cost) or 1

        if cost <= 0 then
            return 0
        end

        if cost > capacity then
            return math.huge
        end

        local bucket = buckets[bucketKey]
        if not bucket then
            return 0
        end

        local now = nowMs()
        refillBucket(bucket, now)

        if bucket.tokens >= cost then
            return 0
        end

        return math_ceil(((cost - bucket.tokens) / refill) * interval)
    end

    function limiter:reset(key)
        local bucketKey = normalizeKey(key)

        if not bucketKey then
            return false
        end

        return removeBucket(bucketKey)
    end

    function limiter:clear()
        buckets = {}
        bucketCount = 0
        lastPrune = 0
    end

    function limiter:size()
        return bucketCount
    end

    AddEventHandler("playerDropped", function()
        limiter:reset(source)
    end)

    return limiter
end

return createRateLimiter
