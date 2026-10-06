-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@param Util table
---@param RuntimeConfig table
---@param Log fun(level: string, message: string, context: table?)
---@param Database table? database module
return function(Util, RuntimeConfig, Log, Database)
    local AdminCache = {}

    ---@type table<string, { group: string }>
    local entries = {}
    ---@type table<string, { group: string }>
    local dirtyEntries = {}
    local flushScheduled = false

    local function debugLog(level, message)
        if Config.Debug then
            Log(level, message)
        end
    end

    local function adminConfig()
        return RuntimeConfig:Get().Admin
    end

    local function cacheConfig()
        return RuntimeConfig:Get().Admin.Cache
    end

    local function persistentGroupLookup()
        local cfg = RuntimeConfig:Get()
        local groups = {}
        for group, enabled in pairs(cfg.Admin.Groups or {}) do
            if enabled then groups[group] = true end
        end
        for group, enabled in pairs(cfg.AdminOnly.Groups or {}) do
            if enabled then groups[group] = true end
        end
        return groups
    end
    ---Schedules a debounced flush. Bursts of group updates collapse into
    ---a single non-blocking database write.
    local function scheduleFlush()
        if flushScheduled then
            return
        end
        flushScheduled = true
        SetTimeout(cacheConfig().SaveDelay, function()
            flushScheduled = false
            if not next(dirtyEntries) then
                return
            end
            local batch = {}
            for k, v in pairs(dirtyEntries) do
                batch[#batch + 1] = { identifier = k, group = v.group }
            end
            dirtyEntries = {}
            if Database and Database.ready then
                Database:SaveAdminBatch(batch, false)
            end
        end)
    end

    ---Loads and validates the cache from database.
    ---Cache entries persist until explicitly updated or removed.
    function AdminCache:Load()
        if not Database or not Database.ready then
            return
        end
        local persistentGroups = persistentGroupLookup()
        local loaded = Database:LoadAdminCache(persistentGroups)
        local count = 0
        if loaded then
            for identifier, entry in pairs(loaded) do
                local validIdentifier = Util.ValidateIdentifier(identifier)
                if validIdentifier
                    and type(entry) == "table"
                    and type(entry.group) == "string"
                    and #entry.group <= 32
                    and persistentGroups[entry.group]
                then
                    entries[identifier] = { group = entry.group }
                    count = count + 1
                end
            end
        end
        debugLog("info", ("Admin group cache loaded from database (%d valid entries)"):format(count))
    end

    ---Immediately writes pending changes to the database.
    function AdminCache:Flush()
        if not next(dirtyEntries) then
            return
        end
        local batch = {}
        for k, v in pairs(dirtyEntries) do
            batch[#batch + 1] = { identifier = k, group = v.group }
        end
        dirtyEntries = {}
        if Database and Database.ready then
            Database:SaveAdminBatch(batch, true)
        end
    end

    ---Updates the cached group for a player from an authoritative source
    ---(the live xPlayer object, re-fetched server-side — never client data).
    ---@param identifiers string[] normalized identifiers of the player
    ---@param group string group read from xPlayer.getGroup()
    ---@return string? cacheKey the identifier the entry was stored under
    function AdminCache:UpdateFromPlayer(identifiers, group)
        if not cacheConfig().Enabled then
            return nil
        end
        if type(group) ~= "string" or group == "" or #group > 32 then
            return nil
        end

        local key = Util.PickStableIdentifier(identifiers, adminConfig().IdentifierPriority)
        if not key then
            return nil
        end

        if not persistentGroupLookup()[group] then
            local wasCached = entries[key] ~= nil or dirtyEntries[key] ~= nil
            entries[key] = nil
            dirtyEntries[key] = nil
            if wasCached and Database and Database.ready then
                Database:RemoveAdminCache(key)
            end
            return key
        end

        local existing = entries[key]
        if existing and existing.group == group then
            return key
        end

        local newEntry = { group = group }
        entries[key] = newEntry
        dirtyEntries[key] = newEntry
        scheduleFlush()
        debugLog("info", ("Admin cache updated: %s -> group '%s'"):format(Util.MaskIdentifier(key), group))
        return key
    end

    ---Looks up the cached group for a connecting player.
    ---When admin-only groups are supplied, falls back to ESX's users table on a cold cache.
    ---@param identifiers string[]
    ---@param allowedGroups table<string, boolean>?
    ---@return string? group
    ---@return string? cacheKey
    function AdminCache:GetGroup(identifiers, allowedGroups)
        local key = Util.PickStableIdentifier(identifiers, adminConfig().IdentifierPriority)
        if not key then
            return nil, nil
        end

        local function isAllowed(group)
            return group and (not allowedGroups or allowedGroups[group])
        end

        local entry = entries[key]
        if entry and isAllowed(entry.group) then
            return entry.group, key
        end

        if Database and Database.ready then
            if not allowedGroups then
                local row = Database:GetAdminCache(identifiers)
                if row and row.group_name then
                    entries[row.identifier] = { group = row.group_name }
                    return row.group_name, row.identifier
                end
            else
                local group = Database:GetESXAdminGroup(identifiers, allowedGroups)
                if group then
                    self:UpdateFromPlayer(identifiers, group)
                    return group, key
                end
            end
        end

        return nil, nil
    end
    
    ---Removes a cache entry (used by diagnostics commands).
    ---@param identifier string
    ---@return boolean removed
    function AdminCache:Remove(identifier)
        local normalized = Util.NormalizeIdentifier(identifier)
        local removed = false
        if entries[normalized] then
            entries[normalized] = nil
            removed = true
        end
        dirtyEntries[normalized] = nil
        if Database and Database.ready then
            Database:RemoveAdminCache(normalized)
        end
        return removed
    end

    ---@return integer
    function AdminCache:GetCount()
        local count = 0
        for _ in pairs(entries) do
            count = count + 1
        end
        return count
    end

    return AdminCache
end
