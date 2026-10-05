-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local CACHE_FILE <const> = "data/admin_cache.json"

---@param Util table
---@param RuntimeConfig table
---@param Log fun(level: string, message: string, context: table?)
return function(Util, RuntimeConfig, Log)
    local AdminCache = {}

    ---@type table<string, { group: string, updatedAt: integer }>
    local entries = {}
    local dirty = false
    local flushScheduled = false

    local function adminConfig()
        return RuntimeConfig:Get().Admin
    end

    local function cacheConfig()
        return RuntimeConfig:Get().Admin.Cache
    end

    ---Schedules a debounced flush. Bursts of group updates collapse into
    ---a single disk write.
    local function scheduleFlush()
        if flushScheduled then
            return
        end
        flushScheduled = true
        SetTimeout(cacheConfig().SaveDelay, function()
            flushScheduled = false
            if not dirty then
                return
            end
            dirty = false
            local payload = json.encode(entries)
            if type(payload) == "string" then
                SaveResourceFile(GetCurrentResourceName(), CACHE_FILE, payload, -1)
            end
        end)
    end

    ---Loads and validates the cache file. Corruption resets the cache
    ---safely; expired entries are pruned.
    function AdminCache:Load()
        local raw = LoadResourceFile(GetCurrentResourceName(), CACHE_FILE)
        if not raw or raw == "" then
            return
        end

        local ok, decoded = pcall(json.decode, raw)
        if not ok or type(decoded) ~= "table" then
            Log("warning", "Admin cache file is corrupted; starting with an empty cache")
            SaveResourceFile(GetCurrentResourceName(), CACHE_FILE .. ".broken", raw or "", -1)
            return
        end

        local now = Util.Now()
        local expiry = cacheConfig().Expiry
        local loaded = 0
        for identifier, entry in pairs(decoded) do
            local validIdentifier = Util.ValidateIdentifier(identifier)
            if validIdentifier
                and type(entry) == "table"
                and type(entry.group) == "string"
                and #entry.group <= 32
                and type(entry.updatedAt) == "number"
                and (now - entry.updatedAt) < expiry
            then
                entries[identifier] = { group = entry.group, updatedAt = entry.updatedAt }
                loaded = loaded + 1
            end
        end
        Log("info", ("Admin group cache loaded (%d valid entries)"):format(loaded))
    end

    ---Immediately writes pending changes (used on resource shutdown).
    function AdminCache:Flush()
        if not dirty then
            return
        end
        dirty = false
        local payload = json.encode(entries)
        if type(payload) == "string" then
            SaveResourceFile(GetCurrentResourceName(), CACHE_FILE, payload, -1)
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

        local existing = entries[key]
        if existing and existing.group == group then
            existing.updatedAt = Util.Now()
            dirty = true
            scheduleFlush()
            return key
        end

        entries[key] = { group = group, updatedAt = Util.Now() }
        dirty = true
        scheduleFlush()
        Log("info", ("Admin cache updated: %s -> group '%s'"):format(Util.MaskIdentifier(key), group))
        return key
    end

    ---Looks up the cached group for a connecting player.
    ---@param identifiers string[]
    ---@return string? group
    ---@return string? cacheKey
    function AdminCache:GetGroup(identifiers)
        if not cacheConfig().Enabled then
            return nil, nil
        end

        local key = Util.PickStableIdentifier(identifiers, adminConfig().IdentifierPriority)
        if not key then
            return nil, nil
        end

        local entry = entries[key]
        if not entry then
            return nil, nil
        end

        if (Util.Now() - entry.updatedAt) >= cacheConfig().Expiry then
            entries[key] = nil
            dirty = true
            scheduleFlush()
            return nil, nil
        end

        return entry.group, key
    end

    ---Removes a cache entry (used by diagnostics commands).
    ---@param identifier string
    ---@return boolean removed
    function AdminCache:Remove(identifier)
        local normalized = Util.NormalizeIdentifier(identifier)
        if entries[normalized] then
            entries[normalized] = nil
            dirty = true
            scheduleFlush()
            return true
        end
        return false
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
