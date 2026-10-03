-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local State <const> = xLib.require "@esx_whitelist.server.module.whitelist.state"
local Util <const> = xLib.require "@esx_whitelist.server.module.whitelist.util"

---@class Cache
---@description Manages in-memory caches for whitelist entries, player identifiers, and online player tracking.
local Cache = {}
local whitelistGeneration = 0

local function bumpWhitelistGeneration()
    whitelistGeneration = whitelistGeneration + 1
end

---@description Starts a whitelist refresh cycle and returns the new generation number.
---@return number generation
function Cache.beginWhitelistRefresh()
    whitelistGeneration = whitelistGeneration + 1
    return whitelistGeneration
end

---@description Sets multiple whitelist identifiers to the same whitelist ID.
---@param identifiers string[] List of identifier strings
---@param id number The whitelist database ID
function Cache.setWhitelistBatch(identifiers, id)
    if not id then return end
    bumpWhitelistGeneration()
    State.authorizationGeneration = State.authorizationGeneration + 1
    for i = 1, #(identifiers or {}) do
        State.whitelistCache[identifiers[i]] = id
    end
end

---@description Removes multiple whitelist identifier mappings.
---@param identifiers string[] List of identifier strings
function Cache.removeWhitelistBatch(identifiers)
    bumpWhitelistGeneration()
    State.authorizationGeneration = State.authorizationGeneration + 1
    for i = 1, #(identifiers or {}) do
        State.whitelistCache[identifiers[i]] = nil
    end
end

---@description Sets and indexes a player's identifiers.
---@param source number The player source ID
---@param identifiers string[] List of identifier strings
---@return string[] identifiers
function Cache.setIdentifiers(source, identifiers)
    source = tonumber(source)
    identifiers = identifiers or {}
    if not source or source <= 0 then return identifiers end
    Cache.clearIdentifiers(source)
    State.playerIdentifiers[source] = identifiers
    for i = 1, #identifiers do
        State.onlineIdentifierSources[identifiers[i]] = source
    end
    return identifiers
end

---@description Gets a player's identifiers, fetching them if not cached.
---@param source number The player source ID
---@return string[] identifiers
function Cache.getIdentifiers(source)
    source = tonumber(source)
    if not source or source <= 0 then return {} end
    return State.playerIdentifiers[source] or Cache.setIdentifiers(source, Util.getPlayerIdentifiersFiltered(source))
end

---@description Clears a player's cached identifiers and online index.
---@param source number The player source ID
function Cache.clearIdentifiers(source)
    source = tonumber(source)
    if not source then return end
    local identifiers = State.playerIdentifiers[source]
    if identifiers then
        for i = 1, #identifiers do
            if State.onlineIdentifierSources[identifiers[i]] == source then
                State.onlineIdentifierSources[identifiers[i]] = nil
            end
        end
    end
    State.playerIdentifiers[source] = nil
end

---@description Finds which online player owns an identifier.
---@param identifier string The identifier string
---@return number? onlineSource
function Cache.findOnline(identifier)
    return State.onlineIdentifierSources[identifier]
end

---@description Replaces the whitelist cache if the generation matches.
---@param newCache table New whitelist cache
---@param generation number Expected generation
---@return boolean success
function Cache.replaceWhitelist(newCache, generation)
    if generation and generation ~= whitelistGeneration then return false end
    State.whitelistCache = newCache or {}
    State.authorizationGeneration = State.authorizationGeneration + 1
    return true
end

---@description Helper function.
local function buildTypeSet(types)
    if type(types) ~= "table" then return nil end
    local set = {}
    local count = 0
    for i = 1, #types do
        local t = types[i]
        if type(t) == "string" and t ~= "" then
            set[t:lower()] = true
            count = count + 1
        end
    end
    return count > 0 and set or nil
end

local allowedAuthTypes = nil
if Config and Config.AuthorizationIdentifierTypes then
    allowedAuthTypes = buildTypeSet(Config.AuthorizationIdentifierTypes)
end

---@description Sets or overrides the allowed identifier types for whitelist authorization.
---@param types string[]? Table of allowed identifier type strings, or nil to allow all
function Cache.setAllowedAuthTypes(types)
    allowedAuthTypes = buildTypeSet(types)
end

---@description Checks if any identifier is in the whitelist cache.
---@param identifiers string[] List of identifier strings
---@param allowedTypes? table<string, boolean> Optional set of allowed identifier types to restrict check
---@return boolean isWhitelisted
---@return number? whitelistId
function Cache.isWhitelisted(identifiers, allowedTypes)
    local filter = allowedTypes or allowedAuthTypes
    for i = 1, #(identifiers or {}) do
        local identifier = identifiers[i]
        local allow = true
        if filter then
            local idType = type(identifier) == "string" and identifier:match("^(%w+):")
            allow = idType ~= nil and filter[idType:lower()] == true
        end
        if allow then
            local id = State.whitelistCache[identifier]
            if id then return true, id end
        end
    end
    return false, nil
end

return Cache
