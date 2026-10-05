-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@param Util table
---@param IdentifierUtil table
---@param RuntimeConfig table
---@param Log fun(level: string, message: string, context: table?)
return function(Util, IdentifierUtil, RuntimeConfig, Log)
    local Identifier = {}

    -- Lookup tables, rebuilt by Rebuild() whenever configuration changes.
    local whitelistLookup = {}
    local adminOnlyLookup = {}
    local bypassLookup = {}

    local function buildFromList(list, label)
        return Util.BuildIdentifierLookup(list, function(entry)
            Log("warning", ("Ignoring invalid identifier in %s: %s"):format(label, tostring(entry)))
        end)
    end

    ---Rebuilds all lookups from the effective configuration.
    ---Called at startup and after every accepted panel change.
    function Identifier:Rebuild()
        local cfg = RuntimeConfig:Get()
        whitelistLookup = buildFromList(cfg.Whitelist.AllowedIdentifiers, "Whitelist.AllowedIdentifiers")
        adminOnlyLookup = buildFromList(cfg.AdminOnly.AllowedIdentifiers, "AdminOnly.AllowedIdentifiers")
        bypassLookup = buildFromList(cfg.Bypass.AllowedIdentifiers, "Bypass.AllowedIdentifiers")
    end

    ---@param identifiers string[] raw identifiers of the connecting player
    ---@return string? matchedIdentifier
    function Identifier:MatchWhitelist(identifiers)
        return Util.MatchAnyIdentifier(identifiers, whitelistLookup)
    end

    ---@param identifiers string[]
    ---@return string? matchedIdentifier
    function Identifier:MatchAdminOnly(identifiers)
        return Util.MatchAnyIdentifier(identifiers, adminOnlyLookup)
    end

    ---@param identifiers string[]
    ---@return string? matchedIdentifier
    function Identifier:MatchBypass(identifiers)
        return Util.MatchAnyIdentifier(identifiers, bypassLookup)
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
