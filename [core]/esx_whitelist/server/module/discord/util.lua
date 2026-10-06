-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local DiscordUtil = {}

---Case-insensitive header lookup.
---@param headers table?
---@param name string lowercase header name
---@return string?
function DiscordUtil.GetHeader(headers, name)
    if type(headers) ~= "table" then
        return nil
    end
    for key, value in pairs(headers) do
        if type(key) == "string" and key:lower() == name then
            if type(value) == "table" then
                return value[1]
            end
            return tostring(value)
        end
    end
    return nil
end

---Extracts how long we must wait before the next Discord request.
---Discord returns `retry_after` (seconds, float) in the JSON body of 429
---responses, plus `Retry-After` / `X-RateLimit-Reset-After` headers.
---@param statusCode number
---@param body string?
---@param headers table?
---@param fallbackMs number
---@return number waitMs
function DiscordUtil.GetRateLimitWait(statusCode, body, headers, fallbackMs)
    if statusCode == 429 and type(body) == "string" then
        local ok, decoded = pcall(json.decode, body)
        if ok and type(decoded) == "table" and type(decoded.retry_after) == "number" then
            return math.max(100, math.floor(decoded.retry_after * 1000) + 50)
        end
    end

    local retryAfter = DiscordUtil.GetHeader(headers, "retry-after")
        or DiscordUtil.GetHeader(headers, "x-ratelimit-reset-after")
    if retryAfter then
        local seconds = tonumber(retryAfter)
        if seconds and seconds > 0 then
            return math.max(100, math.floor(seconds * 1000) + 50)
        end
    end

    return fallbackMs
end

---Reads the remaining-budget hint Discord sends on every response, so the
---queue can slow down proactively instead of only reacting to a 429.
---@param headers table?
---@return number? remaining
---@return number? resetAfterMs
function DiscordUtil.GetBudgetHint(headers)
    local remaining = tonumber(DiscordUtil.GetHeader(headers, "x-ratelimit-remaining") or "")
    local resetAfter = tonumber(DiscordUtil.GetHeader(headers, "x-ratelimit-reset-after") or "")
    if remaining and resetAfter then
        return remaining, math.floor(resetAfter * 1000)
    end
    return remaining, nil
end

return DiscordUtil
