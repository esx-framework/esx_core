-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---The old persisted cache is never an authority for administrator access.
return function(Util, RuntimeConfig, Log, Database)
    local AdminCache = {}
    local entries = {}
    local liveGroups = {}

    local function groups()
        local cfg = RuntimeConfig:Get()
        local result = {}

        for group, enabled in pairs(cfg.Admin.Groups) do
            if enabled then
                result[group] = true
            end
        end

        for group, enabled in pairs(cfg.AdminOnly.Groups) do
            if enabled then
                result[group] = true
            end
        end

        return result
    end

    local function esxIdentifier(identifiers)
        return Util.PickStableIdentifier(identifiers, { GetConvar('esx:identifier', 'license') })
    end

    function AdminCache:Load()
        if not RuntimeConfig:Get().Admin.Cache.Enabled then
            entries = {}

            return true
        end

        if not Database or not Database.ready then
            return false
        end

        local allowed = groups()
        local rows = Database:LoadAdminCandidates(allowed)

        if not rows then
            -- Discovery failure cannot leave an obsolete privilege snapshot.
            entries = {}

            return false
        end

        local replacement = {}
        local prefix = GetConvar('esx:identifier', 'license') .. ':'

        for i = 1, #rows do
            local identifier = rows[i].identifier:gsub('^char%d+:', '')
            local key = Util.NormalizeIdentifier(prefix .. identifier)

            if Util.ValidateAccessIdentifier(key) then
                replacement[key] = { group = rows[i].group }
            end
        end

        -- Player events can arrive while discovery awaits SQL. Keep their current groups.
        for key, group in pairs(liveGroups) do
            replacement[key] = allowed[group] and { group = group } or nil
        end

        entries = RuntimeConfig:Get().Admin.Cache.Enabled and replacement or {}

        return true
    end

    function AdminCache:UpdateFromPlayer(identifiers, group)
        local key = esxIdentifier(identifiers)

        if key then
            liveGroups[key] = group
            entries[key] = RuntimeConfig:Get().Admin.Cache.Enabled
                    and groups()[group]
                    and { group = group }
                or nil
        end

        return key
    end

    function AdminCache:GetGroup(identifiers, allowedGroups)
        if not RuntimeConfig:Get().Admin.Cache.Enabled then
            return nil
        end

        local key = esxIdentifier(identifiers)
        local candidate = key and entries[key]
        local allowed = allowedGroups or RuntimeConfig:Get().Admin.Groups

        if key and liveGroups[key] and not allowed[liveGroups[key]] then
            return nil
        end

        if not candidate then
            return nil
        end

        -- Discovery is only a hint; each administrator connection checks ESX again.
        local group = Database:GetESXAdminGroup(identifiers, allowed)

        if not group then
            -- Do not erase discovery for a different group filter (AdminOnly).
            return nil
        end

        return group, key
    end

    function AdminCache:ForgetPlayer(identifiers)
        local key = esxIdentifier(identifiers)

        if key then
            liveGroups[key] = nil
        end
    end

    function AdminCache:Flush()
        -- No admin decisions are persisted. ESX users is the authority.
    end

    function AdminCache:Remove(identifier)
        local key = Util.NormalizeIdentifier(identifier)
        local removed = entries[key] ~= nil
        entries[key] = nil

        return removed
    end

    function AdminCache:GetCount()
        if not RuntimeConfig:Get().Admin.Cache.Enabled then
            return 0
        end

        local count = 0

        for _ in pairs(entries) do
            count = count + 1
        end

        return count
    end

    return AdminCache
end
