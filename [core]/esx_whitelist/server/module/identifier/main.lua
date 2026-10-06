-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@param Util table
---@param IdentifierUtil table
---@param RuntimeConfig table
---@param Log fun(level: string, message: string, context: table?)
---@param Database table? database module
return function(Util, IdentifierUtil, RuntimeConfig, Log, Database)
    local Identifier = {}

    local whitelistLookup = {}
    local adminOnlyLookup = {}
    local bypassLookup = {}

    local function buildFromList(list, label)
        return Util.BuildIdentifierLookup(list, function(entry)
            Log("warning", ("Ignoring invalid identifier in %s: %s"):format(label, tostring(entry)))
        end)
    end

    ---Rebuilds all lookups from effective configuration and database records.
    ---Called at startup and after every accepted change.
    function Identifier:Rebuild()
        local cfg = RuntimeConfig:Get()
        whitelistLookup = buildFromList(cfg.Whitelist.AllowedIdentifiers, "Whitelist.AllowedIdentifiers")
        adminOnlyLookup = buildFromList(cfg.AdminOnly.AllowedIdentifiers, "AdminOnly.AllowedIdentifiers")
        bypassLookup = buildFromList(cfg.Bypass.AllowedIdentifiers, "Bypass.AllowedIdentifiers")

        -- Load database stored identifiers
        if Database and Database.ready then
            local dbEntries = Database:LoadIdentifiers()
            if dbEntries then
                for i = 1, #dbEntries do
                    local row = dbEntries[i]
                    local normalized = Util.NormalizeIdentifier(row.identifier)
                    if Util.ValidateIdentifier(normalized) then
                        if row.type == "whitelist" then
                            whitelistLookup[normalized] = true
                        elseif row.type == "admin_only" then
                            adminOnlyLookup[normalized] = true
                        elseif row.type == "bypass" then
                            bypassLookup[normalized] = true
                        end
                    end
                end
            end
        end
    end

    ---Matches player identifiers against the whitelist.
    ---@param identifiers string[] raw identifiers of the connecting player
    ---@return string? matchedIdentifier
    function Identifier:MatchWhitelist(identifiers)
        local match = Util.MatchAnyIdentifier(identifiers, whitelistLookup)
        if match then
            return match
        end

        if Database and Database.ready then
            local found = Database:MatchIdentifier(identifiers, "whitelist")
            if found then
                whitelistLookup[found] = true
                return found
            end
        end

        return nil
    end

    ---Matches player identifiers against admin-only list.
    ---@param identifiers string[]
    ---@return string? matchedIdentifier
    function Identifier:MatchAdminOnly(identifiers)
        local match = Util.MatchAnyIdentifier(identifiers, adminOnlyLookup)
        if match then
            return match
        end

        if Database and Database.ready then
            local found = Database:MatchIdentifier(identifiers, "admin_only")
            if found then
                adminOnlyLookup[found] = true
                return found
            end
        end

        return nil
    end

    ---Matches player identifiers against bypass list.
    ---@param identifiers string[]
    ---@return string? matchedIdentifier
    function Identifier:MatchBypass(identifiers)
        local match = Util.MatchAnyIdentifier(identifiers, bypassLookup)
        if match then
            return match
        end

        if Database and Database.ready then
            local found = Database:MatchIdentifier(identifiers, "bypass")
            if found then
                bypassLookup[found] = true
                return found
            end
        end

        return nil
    end

    ---Returns array of all allowed identifiers for a specific category
    ---@param idType string "whitelist"|"admin_only"|"bypass"
    ---@return string[]
    function Identifier:GetList(idType)
        local lookup
        if idType == "whitelist" then
            lookup = whitelistLookup
        elseif idType == "admin_only" then
            lookup = adminOnlyLookup
        elseif idType == "bypass" then
            lookup = bypassLookup
        end
        local list = {}
        if lookup then
            for id in pairs(lookup) do
                list[#list + 1] = id
            end
            table.sort(list)
        end
        return list
    end

    ---Adds an identifier to database and lookup table
    ---@param identifier string
    ---@param idType string?
    ---@return boolean, string?
    function Identifier:Add(identifier, idType)
        idType = idType or "whitelist"
        local normalized = Util.NormalizeIdentifier(identifier)
        if not Util.ValidateIdentifier(normalized) then
            return false, "invalid identifier format"
        end

        if Database and Database.ready then
            local ok, err = Database:AddIdentifier(normalized, idType)
            if not ok then
                return false, err
            end
        end

        if idType == "whitelist" then
            whitelistLookup[normalized] = true
        elseif idType == "admin_only" then
            adminOnlyLookup[normalized] = true
        elseif idType == "bypass" then
            bypassLookup[normalized] = true
        end

        return true, nil
    end

    ---Removes an identifier from database and lookup table
    ---@param identifier string
    ---@param idType string?
    ---@return boolean
    function Identifier:Remove(identifier, idType)
        idType = idType or "whitelist"
        local normalized = Util.NormalizeIdentifier(identifier)

        if Database and Database.ready then
            Database:RemoveIdentifier(normalized, idType)
        end

        if idType == "whitelist" then
            whitelistLookup[normalized] = nil
        elseif idType == "admin_only" then
            adminOnlyLookup[normalized] = nil
        elseif idType == "bypass" then
            bypassLookup[normalized] = nil
        end

        return true
    end

    ---Counts for diagnostics.
    ---@return { whitelist: integer, adminOnly: integer, bypass: integer }
    function Identifier:GetCounts()
        local function count(lookup)
            local n = 0
            for _ in pairs(lookup) do
                n = n + 1
            end
            return n
        end
        return {
            whitelist = count(whitelistLookup),
            adminOnly = count(adminOnlyLookup),
            bypass = count(bypassLookup),
        }
    end

    return Identifier
end
