-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Enum <const> = xLib.require "@esx_whitelist.server.module.whitelist.Enum"
local Util <const> = xLib.require "@esx_whitelist.server.module.whitelist.util"

---@class Validation
---@description Validates configuration, rules, webhook URLs, and identifier formats.
local Validation = {}

local RULE_TYPES <const> = {
    [Enum.RuleType.ADMIN_PRESENCE] = true,
    [Enum.RuleType.PLAYER_COUNT] = true,
    [Enum.RuleType.SCHEDULED] = true
}
local OPERATORS <const> = { ["<"] = true, [">"] = true, ["<="] = true, [">="] = true, ["=="] = true }
local ACTIONS <const> = { enable = true, disable = true }

local function trim(value, max)
    if type(value) ~= "string" then return nil end
    value = value:gsub("^%s+", ""):gsub("%s+$", "")
    if max and #value > max then value = value:sub(1, max) end
    return value
end

local function validDiscordId(value)
    value = trim(value, 20)
    if not value or #value < 15 or value:match("^%d+$") == nil then return nil end
    return value
end

---@description Validates a Discord webhook URL format and host.
---@param url string The webhook URL to validate
---@return boolean valid
function Validation.Webhook(url)
    if url == "" then return true end
    if type(url) ~= "string" or #url > 250 then return false end

    local host, path = url:match("^https://([%w.-]+)(/.*)$")
    if host ~= "discord.com" and host ~= "discordapp.com" then return false end
    local webhookId, token = path:match("^/api/webhooks/(%d+)/([A-Za-z0-9_-]+)$")
    return webhookId ~= nil and token ~= nil
end

---@description Parses and validates an identifier string into type and value components.
---@param raw string Raw identifier string
---@return string? fullIdentifier
---@return string? idType
---@return string? value
function Validation.Identifier(raw)
    local idType, value = Util.NormalizeIdentifier(raw)
    if not idType or not value then return nil end
    return idType .. ":" .. value, idType, value
end

---@description Validates and normalizes a single whitelist rule.
---@param rule table The rule data
---@param index number Rule index for error reporting
---@return table? normalized
---@return string? error
function Validation.Rule(rule, index)
    if type(rule) ~= "table" then return nil, "rule " .. index .. " is invalid" end
    if not RULE_TYPES[rule.type] then return nil, "rule " .. index .. " has an invalid type" end
    if rule.operator ~= nil and not OPERATORS[rule.operator] then return nil, "rule " .. index .. " has an invalid operator" end
    if rule.action ~= nil and not ACTIONS[rule.action] then return nil, "rule " .. index .. " has an invalid action" end

    local normalized = {
        id = trim(tostring(rule.id or index), 64),
        type = rule.type,
        enabled = rule.enabled == true,
        priority = math.max(0, math.min(100000, math.floor(tonumber(rule.priority) or index))),
        operator = rule.operator,
        value = tonumber(rule.value),
        action = rule.action,
        startTime = trim(rule.startTime or "00:00", 5),
        endTime = trim(rule.endTime or "23:59", 5)
    }

    if normalized.type ~= Enum.RuleType.SCHEDULED then
        normalized.operator = normalized.operator or "<"
        normalized.value = normalized.value or 0
        normalized.action = normalized.action or "enable"
        if normalized.value ~= normalized.value or normalized.value == math.huge or normalized.value == -math.huge then
            return nil, "rule " .. index .. " has an invalid value"
        end
    else
        normalized.action = normalized.action or "enable"
        local function validTime(value)
            if type(value) ~= "string" then return false end
            local hour, minute = value:match("^(%d%d?):(%d%d?)$")
            hour, minute = tonumber(hour), tonumber(minute)
            return hour ~= nil and minute ~= nil and hour <= 23 and minute <= 59
        end
        if not validTime(normalized.startTime) or not validTime(normalized.endTime) then
            return nil, "rule " .. index .. " has an invalid schedule"
        end
    end

    return normalized
end

---@description Validates a list of rules.
---@param rules table[] List of rule tables
---@return table? normalizedRules
---@return string? error
function Validation.Rules(rules)
    if type(rules) ~= "table" or #rules > 50 then return nil, "invalid rules" end
    local output = {}
    for i = 1, #rules do
        local rule, err = Validation.Rule(rules[i], i)
        if not rule then return nil, err end
        output[#output + 1] = rule
    end
    return output
end

---@description Validates and normalizes the full whitelist configuration.
---@param data table Incoming config data
---@param current table Current/fallback config
---@return table? normalized
---@return string? error
function Validation.Config(data, current)
    if type(data) ~= "table" then return nil, "invalid config" end

    local out = {}
    -- `whitelistEnabled` is the NUI/JSON boundary representation; `enabled`
    -- is the single internal runtime model used everywhere else.
    local enabledRaw = data.whitelistEnabled ~= nil and data.whitelistEnabled or data.enabled
    out.enabled = enabledRaw == true
    out.gracePeriod = math.max(0, math.min(600, math.floor(tonumber(data.gracePeriod) or current.gracePeriod or 60)))
    out.kickConnected = data.kickConnected == true
    out.discordEnabled = data.discordEnabled == true
    out.discordGuildId = validDiscordId(data.discordGuildId or current.discordGuildId or "") or ""
    out.discordRoleId = validDiscordId(data.discordRoleId or current.discordRoleId or "") or ""
    local method = tostring(data.authorizationMethod or (out.discordEnabled and "discord" or "identifier")):lower()
    if method ~= "identifier" and method ~= "discord" then
        return nil, "Invalid authorization method"
    end
    out.authorizationMethod = method
    out.discordEnabled = method == "discord"

    local webhook = trim(data.discordWebhook or "", 250)
    if webhook == "***CONFIGURED***" then webhook = current.discordWebhook end
    if not Validation.Webhook(webhook) then return nil, "Invalid Discord webhook URL" end
    out.discordWebhook = webhook

    local rules, err = Validation.Rules(data.rules or current.rules)
    if not rules then return nil, err end
    out.rules = rules

    if out.authorizationMethod == "discord" and (out.discordGuildId == "" or out.discordRoleId == "") then
        return nil, "Discord configuration incomplete"
    end

    return out
end

return Validation
