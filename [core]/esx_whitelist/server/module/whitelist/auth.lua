-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local State <const> = xLib.require "@esx_whitelist.server.module.whitelist.state"
local Util <const> = xLib.require "@esx_whitelist.server.module.whitelist.util"
local ServerConfig <const> = xLib.require "@esx_whitelist.server.config.main"

---@class Auth
---@description Handles authorization checks including admin group membership, ACE permissions, and configured identifier allowlist.
local Auth = {}
local adminGroups = {}
for i = 1, #(Config.AdminGroups or {}) do
    adminGroups[string.lower(tostring(Config.AdminGroups[i]))] = true
end

local configuredIdentifiers = {}
for i = 1, #(ServerConfig.AllowedIdentifiers or {}) do
    local idType, value = Util.normalizeIdentifier(ServerConfig.AllowedIdentifiers[i])
    if idType and value then configuredIdentifiers[idType .. ":" .. value] = true end
end

if Config.Debug then
    print(("^3[esx_whitelist] Loaded %d configured identifier exceptions.^7"):format(#(ServerConfig.AllowedIdentifiers or {})))
end

---@description Helper function.
local function aceAdmin(source)
    source = tonumber(source)
    if not source or source <= 0 then return false end
    for i = 1, #(Config.AdminAcePermissions or {}) do
        local permission = tostring(Config.AdminAcePermissions[i])
        if permission ~= "" and IsPlayerAceAllowed(source, permission) then
            return true
        end
    end
    return false
end

---@description Checks if any of the player's identifiers match the configured allowlist.
---@param identifiers string[] List of identifier strings
---@return boolean hasMatch
function Auth.hasConfiguredIdentifier(identifiers)
    for i = 1, #(identifiers or {}) do
        if configuredIdentifiers[identifiers[i]] then return true end
    end
    return false
end

---@description Checks if a player is an admin via ESX group or ACE permission.
---@param source number The player source ID
---@return boolean isAdmin
function Auth.isAdmin(source)
    local id = tonumber(source)
    if not id then return false end
    if id <= 0 then
        State.adminSources[id] = nil
        return false
    end

    local xPlayer = ESX.GetPlayerFromId(id)
    local result = false
    if xPlayer then
        local group = xPlayer.getGroup and xPlayer.getGroup() or nil
        result = group ~= nil and adminGroups[string.lower(tostring(group))] == true or false
    end
    if not result then result = aceAdmin(id) end

    State.adminSources[id] = result
    return result
end

---@description Clears admin tracking state for a player.
---@param source number The player source ID
---@description Clears admin tracking state for a player.
function Auth.clear(source)
    source = tonumber(source)
    if source then State.adminSources[source] = nil end
end

---@description Returns the configured admin group list.
---@return string[]
function Auth.groups() return Config.AdminGroups or {} end

return Auth
