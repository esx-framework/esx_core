---@class TokenOptions
---@field source? string|number Player source that is allowed to consume the token.
---@field ttl number Time to live in milliseconds.
---@field data? any Data returned when the token is consumed.

local DEFAULT_TTL <const> = 30000
local DEFAULT_MAX_ENTRIES <const> = 4096

local tokens = {}
local tokensBySource = {}
local tokenCount = 0

local function nowMs()
    return GetGameTimer()
end

local function normalizeSource(source)
    if source == nil then
        return nil
    end

    local sourceType = type(source)
    if sourceType ~= "number" and sourceType ~= "string" then
        return nil
    end

    return tostring(source)
end

local function isExpired(entry, now)
    return now - entry.createdAt >= entry.ttl
end

local function unindexSource(id, sourceKey)
    if not sourceKey then
        return
    end

    local index = tokensBySource[sourceKey]
    if not index then
        return
    end

    index[id] = nil

    if next(index) == nil then
        tokensBySource[sourceKey] = nil
    end
end

local function removeToken(id)
    local entry = tokens[id]

    if not entry then
        return false
    end

    tokens[id] = nil
    tokenCount = tokenCount - 1
    unindexSource(id, entry.source)

    return true
end

local function pruneExpired(now)
    for id, entry in pairs(tokens) do
        if isExpired(entry, now) then
            removeToken(id)
        end
    end
end

local function createTokenId()
    local id

    repeat
        id = ("%s:%s:%s"):format(GetCurrentResourceName(), nowMs(), xLib.string.randomHex(32))
    until not tokens[id]

    return id
end

---@class xLibToken
---@field create fun(options: TokenOptions): string?
---@field consume fun(id: string, source?: string|number): any
---@field remove fun(id: string): boolean
---@field reset fun(source: string|number): number
---@field clear fun()
---@field size fun(): number
local token = {}

---@param options TokenOptions
---@return string?
function token.create(options)
    if type(options) ~= "table" then
        error("[xLib] token.create requires an options table", 2)
    end

    local ttl = math.floor(tonumber(options.ttl) or DEFAULT_TTL)
    if ttl <= 0 then
        error("[xLib] token ttl must be a positive number", 2)
    end

    local now = nowMs()
    local maxEntries = math.floor(GetConvarInt("xLib:tokenMaxEntries", DEFAULT_MAX_ENTRIES))
    if maxEntries <= 0 then
        maxEntries = DEFAULT_MAX_ENTRIES
    end

    pruneExpired(now)

    if tokenCount >= maxEntries then
        return nil
    end

    local id = createTokenId()
    local sourceKey = normalizeSource(options.source)

    tokens[id] = {
        source = sourceKey,
        createdAt = now,
        ttl = ttl,
        data = options.data,
    }

    tokenCount = tokenCount + 1

    if sourceKey then
        tokensBySource[sourceKey] = tokensBySource[sourceKey] or {}
        tokensBySource[sourceKey][id] = true
    end

    SetTimeout(ttl, function()
        removeToken(id)
    end)

    return id
end

---@param id string
---@param source? string|number
---@return any
function token.consume(id, source)
    if type(id) ~= "string" then
        return nil
    end

    local entry = tokens[id]
    if not entry then
        return nil
    end

    if isExpired(entry, nowMs()) then
        removeToken(id)
        return nil
    end

    local sourceKey = normalizeSource(source)
    if entry.source and entry.source ~= sourceKey then
        return nil
    end

    removeToken(id)

    if entry.data ~= nil then
        return entry.data
    end

    return true
end

---@param id string
---@return boolean
function token.remove(id)
    if type(id) ~= "string" then
        return false
    end

    return removeToken(id)
end

---@param source string|number
---@return number
function token.reset(source)
    local sourceKey = normalizeSource(source)

    if not sourceKey then
        return 0
    end

    local index = tokensBySource[sourceKey]
    if not index then
        return 0
    end

    local removed = 0

    for id in pairs(index) do
        if removeToken(id) then
            removed = removed + 1
        end
    end

    return removed
end

function token.clear()
    tokens = {}
    tokensBySource = {}
    tokenCount = 0
end

---@return number
function token.size()
    pruneExpired(nowMs())
    return tokenCount
end

AddEventHandler("playerDropped", function()
    token.reset(source)
end)

xLib.token = token

return token
