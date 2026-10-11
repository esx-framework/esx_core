-- SPDX-License-Identifier: GPL-3.0-only
local function setting(name, fallback)
    return math.max(1, GetConvarInt('xLib:' .. name, fallback))
end

local requestLimiter = xLib.rateLimiter({
    capacity = setting('callbackBurst', 60),
    refill = setting('callbackRate', 30),
    interval = 1000,
})
local byteLimiter = xLib.rateLimiter({
    capacity = setting('callbackByteBurst', 262144),
    refill = setting('callbackByteRate', 65536),
    interval = 1000,
})
local replyLimiter = xLib.rateLimiter({
    capacity = 5,
    refill = 5,
    interval = 1000,
})
local maxPerPlayer = setting('callbackMaxInFlight', 8)
local maxGlobal = setting('callbackMaxGlobalInFlight', 4096)
local leases = {}
local counts = {}
local total = 0
local sequence = 0
local instance = xLib.string.randomHex(32)

function xLib.acquireCallbackBudget(playerId, bytes)
    if
        type(playerId) ~= 'number'
        or playerId <= 0
        or playerId % 1 ~= 0
        or not GetPlayerName(playerId)
    then
        return nil, false
    end

    if
        type(bytes) ~= 'number'
        or bytes < 0
        or bytes > setting('callbackMaxPayloadBytes', 65536)
    then
        return nil, replyLimiter:consume(playerId)
    end

    if
        not requestLimiter:consume(playerId)
        or not byteLimiter:consume(playerId, math.max(1, bytes))
        or (counts[playerId] or 0) >= maxPerPlayer
        or total >= maxGlobal
    then
        return nil, replyLimiter:consume(playerId)
    end

    sequence = sequence + 1
    local token = instance .. ':' .. tostring(sequence)
    leases[token] = { source = playerId, owner = GetInvokingResource() or GetCurrentResourceName() }
    counts[playerId] = (counts[playerId] or 0) + 1
    total = total + 1
    return token, false
end

function xLib.releaseCallbackBudget(token)
    local lease = leases[token]

    if not lease or lease.owner ~= (GetInvokingResource() or GetCurrentResourceName()) then
        return false
    end

    leases[token] = nil

    if not lease.detached then
        counts[lease.source] = math.max(0, (counts[lease.source] or 1) - 1)

        if counts[lease.source] == 0 then
            counts[lease.source] = nil
        end
    end

    total = total - 1
    return true
end

function xLib.chargeCallbackBytes(token, bytes)
    local lease = leases[token]

    if not lease or lease.owner ~= (GetInvokingResource() or GetCurrentResourceName()) then
        return false
    end

    if
        type(bytes) ~= 'number'
        or bytes ~= bytes
        or bytes < 0
        or bytes > setting('callbackMaxPayloadBytes', 65536)
    then
        return false
    end

    return byteLimiter:consume(lease.source, math.max(1, bytes))
end

local function clearWhere(predicate)
    for token, lease in pairs(leases) do
        if predicate(lease) then
            leases[token] = nil

            if not lease.detached then
                counts[lease.source] = math.max(0, (counts[lease.source] or 1) - 1)

                if counts[lease.source] == 0 then
                    counts[lease.source] = nil
                end
            end

            total = total - 1
        end
    end
end

AddEventHandler('playerDropped', function()
    local playerId = source
    counts[playerId] = nil

    for _, lease in pairs(leases) do
        if lease.source == playerId then
            lease.detached = true
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    clearWhere(function(lease)
        return lease.owner == resource
    end)
end)
