-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Util = {}

local stringSub = string.sub
local stringLen = string.len
local stringMatch = string.match
local stringFormat = string.format
local stringLower = string.lower
local osTime = os.time

---Trims whitespace from both ends of a string.
---@param value any
---@return string
function Util.Trim(value)
    if type(value) ~= "string" then
        return ""
    end
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

---Normalizes an identifier for comparison: trimmed and lowercased.
---@param identifier any
---@return string
function Util.NormalizeIdentifier(identifier)
    if type(identifier) ~= "string" then
        return ""
    end
    return stringLower(Util.Trim(identifier))
end

local IDENTIFIER_PATTERN <const> = "^([a-z0-9]+):([%w%._%-]+)$"

---Validates the structural format "prefix:value".
---@param identifier any
---@return boolean valid
---@return string? prefix
---@return string? value
function Util.ValidateIdentifier(identifier)
    if type(identifier) ~= "string" then
        return false, nil, nil
    end

    local normalized = Util.NormalizeIdentifier(identifier)
    if stringLen(normalized) < 3 or stringLen(normalized) > 128 then
        return false, nil, nil
    end

    local prefix, value = stringMatch(normalized, IDENTIFIER_PATTERN)
    if not prefix then
        return false, nil, nil
    end

    return true, prefix, value
end

---Extracts the raw Discord user ID from a "discord:<snowflake>" identifier.
---@param identifier string
---@return string? userId
function Util.ExtractDiscordId(identifier)
    local valid, prefix, value = Util.ValidateIdentifier(identifier)
    if not valid or prefix ~= "discord" then
        return nil
    end
    if not Util.IsSnowflake(value) then
        return nil
    end
    return value
end

---Validates a Discord snowflake (guild, role or user ID).
---@param value any
---@return boolean
function Util.IsSnowflake(value)
    return type(value) == "string"
        and #value >= 17
        and #value <= 20
        and value:match("^%d+$") ~= nil
end

---Masks an identifier for logs: keeps prefix, head and tail only.
---Example: license2:abcdef12...wxyz
---@param identifier any
---@return string
function Util.MaskIdentifier(identifier)
    if type(identifier) ~= "string" or identifier == "" then
        return "unknown"
    end

    local prefix, value = identifier:match("^([a-z0-9]+):(.*)$")
    if not prefix then
        return "invalid"
    end

    local valueLength = stringLen(value)
    if valueLength <= 10 then
        return stringFormat("%s:%s...", prefix, stringSub(value, 1, 2))
    end

    return stringFormat("%s:%s...%s", prefix, stringSub(value, 1, 6), stringSub(value, -4))
end

---Invalid entries are skipped and reported to the optional sink.
---@param list any
---@param onInvalid fun(entry: any)? optional callback for invalid entries
---@return table<string, true>
function Util.BuildIdentifierLookup(list, onInvalid)
    local lookup = {}
    if type(list) ~= "table" then
        return lookup
    end

    for i = 1, #list do
        local entry = list[i]
        if Util.ValidateIdentifier(entry) then
            lookup[Util.NormalizeIdentifier(entry)] = true
        elseif onInvalid then
            onInvalid(entry)
        end
    end

    return lookup
end

---Builds a set (value -> true) from an array.
---@generic T
---@param list any
---@return table<any, true>
function Util.ToSet(list)
    local set = {}
    if type(list) ~= "table" then
        return set
    end
    for i = 1, #list do
        set[list[i]] = true
    end
    return set
end

---Returns the first matching identifier from `identifiers` present in `lookup`.
---@param identifiers string[]
---@param lookup table<string, true>
---@return string? matched
function Util.MatchAnyIdentifier(identifiers, lookup)
    for i = 1, #identifiers do
        local normalized = Util.NormalizeIdentifier(identifiers[i])
        if lookup[normalized] then
            return normalized
        end
    end
    return nil
end

---Picks the most stable available identifier according to the priority list.
---@param identifiers string[]
---@param priority string[] e.g. { "license2", "license" }
---@return string? identifier
function Util.PickStableIdentifier(identifiers, priority)
    for p = 1, #priority do
        local wanted = priority[p]
        local prefixWithColon = wanted .. ":"
        local prefixLength = #prefixWithColon
        for i = 1, #identifiers do
            local identifier = Util.NormalizeIdentifier(identifiers[i])
            if stringSub(identifier, 1, prefixLength) == prefixWithColon then
                return identifier
            end
        end
    end
    return nil
end

---Current unix timestamp in seconds.
---@return integer
function Util.Now()
    return osTime()
end

---Shallow-copies an array of strings, dropping non-string entries.
---@param list any
---@return string[]
function Util.SanitizeStringArray(list)
    local out = {}
    if type(list) ~= "table" then
        return out
    end
    for i = 1, #list do
        if type(list[i]) == "string" then
            out[#out + 1] = list[i]
        end
    end
    return out
end

---Deep-copies a value (tables by value, everything else as-is).
---@generic T
---@param value T
---@return T
function Util.DeepCopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for key, item in pairs(value) do
        copy[key] = Util.DeepCopy(item)
    end
    return copy
end

---@param value any
---@return boolean
local function isList(value)
    return type(value) == "table" and (next(value) == nil or value[1] ~= nil)
end

---Merges runtime overrides onto a deep copy of the defaults.
---Semantics:
---  - scalar override replaces the default
---  - arrays (lists) are replaced wholesale, never index-merged, so lists
---    can grow beyond the shipped defaults
---  - plain maps are merged key-by-key so new map entries (e.g. an admin
---    group added from the panel) are picked up
---Overrides only ever enter through the schema validators, so unknown
---keys cannot reach this function with unvalidated values.
---@param base table
---@param override any
---@return table
function Util.MergeOverrides(base, override)
    if type(override) ~= "table" then
        if override ~= nil then
            return Util.DeepCopy(override)
        end
        return Util.DeepCopy(base)
    end
    if type(base) ~= "table" then
        return Util.DeepCopy(override)
    end
    if next(override) == nil then
        return Util.DeepCopy(base)
    end
    if isList(base) or isList(override) then
        return Util.DeepCopy(override)
    end

    local result = Util.DeepCopy(base)
    for key, overrideValue in pairs(override) do
        result[key] = Util.MergeOverrides(result[key], overrideValue)
    end
    return result
end

return Util
