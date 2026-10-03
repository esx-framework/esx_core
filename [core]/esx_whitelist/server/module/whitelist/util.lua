-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Enum <const> = xLib.require "@esx_whitelist.server.module.whitelist.Enum"

local Util = {}

local INVALID_TOKENS <const> = {
    ["TU_TOKEN_AQUI"] = true,
    ["YOUR_TOKEN_HERE"] = true,
    ["YOUR_BOT_TOKEN"] = true,
    ["DISCORD_BOT_TOKEN"] = true,
    ["YOUR_DISCORD_BOT_TOKEN_HERE"] = true
}

local VALID_TYPES <const> = {
    steam = true,
    license = true,
    license2 = true,
    discord = true,
    xbl = true,
    fivem = true
}
local IDENTIFIER_TYPES <const> = {
    Enum.IdentifierType.LICENSE,
    Enum.IdentifierType.LICENSE2,
    Enum.IdentifierType.STEAM,
    Enum.IdentifierType.DISCORD,
    Enum.IdentifierType.XBL,
    Enum.IdentifierType.FIVEM
}

---@description Validates a Discord bot token format.
---@param token string The bot token
---@return boolean valid
function Util.IsValidBotToken(token)
    if type(token) ~= "string" or token == "" or #token < 50 or token:find("[%s%c]") then
        return false
    end
    if INVALID_TOKENS[token] then
        return false
    end
    local prefix = token:match("^([^.%s]+)%.[^.%s]+%.[^.%s]+$")
    return prefix ~= nil
end

local function stripWhitespace(value)
    return value:gsub("%s+", "")
end

local function validateValue(idType, value)
    if not VALID_TYPES[idType] or type(value) ~= "string" or value == "" then
        return false
    end

    if idType == Enum.IdentifierType.LICENSE then
        return value:match("^[0-9a-fA-F]+$") ~= nil and #value == 40
    elseif idType == Enum.IdentifierType.LICENSE2 then
        return (value:match("^[0-9a-fA-F]+%-[0-9a-fA-F]+%-[0-9a-fA-F]+%-[0-9a-fA-F]+%-[0-9a-fA-F]+$") ~= nil and #value == 36) or (value:match("^[0-9a-fA-F]+$") ~= nil and #value == 40)
    elseif idType == Enum.IdentifierType.DISCORD then
        return value:match("^%d+$") ~= nil and #value >= 17 and #value <= 19
    elseif idType == Enum.IdentifierType.XBL then
        return value:match("^%d+$") ~= nil and #value == 16
    elseif idType == Enum.IdentifierType.FIVEM then
        return value:match("^%d+$") ~= nil and #value >= 1 and #value <= 20
    elseif idType == Enum.IdentifierType.STEAM then
        return value:match("^[0-9a-fA-F]+$") ~= nil and #value >= 15 and #value <= 17
    end

    return false
end

local function detectIdentifierType(value)
    if type(value) ~= "string" or value == "" then
        return nil
    end

    local clean = stripWhitespace(value)
    local prefix, raw = clean:match("^(%w+):(.+)$")
    if prefix then
        prefix = prefix:lower()
        return VALID_TYPES[prefix] and validateValue(prefix, raw) and prefix or nil
    end

    if validateValue(Enum.IdentifierType.LICENSE2, clean) then return Enum.IdentifierType.LICENSE2 end
    if validateValue(Enum.IdentifierType.LICENSE, clean) then return Enum.IdentifierType.LICENSE end
    if validateValue(Enum.IdentifierType.DISCORD, clean) then return Enum.IdentifierType.DISCORD end
    if validateValue(Enum.IdentifierType.XBL, clean) then return Enum.IdentifierType.XBL end
    if validateValue(Enum.IdentifierType.FIVEM, clean) then return Enum.IdentifierType.FIVEM end
    if validateValue(Enum.IdentifierType.STEAM, clean) then return Enum.IdentifierType.STEAM end

    return nil
end

local function normalizeIdentifier(rawValue)
    if type(rawValue) ~= "string" then
        return nil, nil
    end

    local clean = stripWhitespace(rawValue)
    if clean == "" then
        return nil, nil
    end

    local prefix, value = clean:match("^(%w+):(.+)$")
    if prefix then
        prefix = prefix:lower()
        if not VALID_TYPES[prefix] or not validateValue(prefix, value) then
            return nil, nil
        end
        if prefix == Enum.IdentifierType.LICENSE or prefix == Enum.IdentifierType.LICENSE2 or prefix == Enum.IdentifierType.STEAM then
            value = value:lower()
        end
        return prefix, value
    end

    local detected = detectIdentifierType(clean)
    if not detected then
        return nil, nil
    end
    if detected == Enum.IdentifierType.LICENSE or detected == Enum.IdentifierType.LICENSE2 or detected == Enum.IdentifierType.STEAM then
        clean = clean:lower()
    end
    return detected, clean
end

local function getPlayerIdentifiersFiltered(playerId)
    local identifiers = {}
    for i = 1, #IDENTIFIER_TYPES do
        local idType = IDENTIFIER_TYPES[i]
        local raw = GetPlayerIdentifierByType(playerId, idType)
        if raw then
            local normalizedType, value = normalizeIdentifier(raw)
            if normalizedType == idType and value then
                identifiers[#identifiers + 1] = normalizedType .. ":" .. value
            end
        end
    end

    return identifiers
end

local function loadLocale(localeName)
    local raw = LoadResourceFile(GetCurrentResourceName(), ("locales/%s.json"):format(localeName))
        or LoadResourceFile(GetCurrentResourceName(), "locales/en.json")
    if not raw then return {} end

    local ok, decoded = pcall(json.decode, raw)
    return ok and type(decoded) == "table" and decoded or {}
end

local function translate(translations, key, ...)
    if not translations then return key end
    local template = translations[key] or key
    if select("#", ...) == 0 then return template end
    local ok, result = pcall(string.format, template, ...)
    return ok and result or template
end

---@description Normalizes a raw identifier string into type and value components.
Util.NormalizeIdentifier = normalizeIdentifier
---@description Gets filtered player identifiers by supported types.
---@param playerId number The player source ID
---@return string[] identifiers
Util.GetPlayerIdentifiersFiltered = getPlayerIdentifiersFiltered
---@description Loads a locale file from the resources directory.
---@param localeName string Locale file name
---@return table translations
Util.LoadLocale = loadLocale
---@description Translates a locale key with optional format arguments.
---@param translations table Locale string map
---@param key string Translation key
---@return string result
Util.Translate = translate

return Util
