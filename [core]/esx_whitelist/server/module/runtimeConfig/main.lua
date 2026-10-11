-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@param Util table
---@param Log fun(level: string, message: string, context: table?) console/logger sink
---@param Database table? database module
return function(Util, Log, Database)
    local RuntimeConfig = {}

    --[[
        Validators. Each returns: ok:boolean, valueOrError
        Sanitization happens inside the validators, so nothing unvalidated
        ever reaches the effective config.
    ]]

    local function validateBoolean(value)
        if type(value) == 'boolean' then
            return true, value
        end

        return false, 'expected boolean'
    end

    local function makeEnumValidator(...)
        local allowed = { ... }

        return function(value)
            for i = 1, #allowed do
                if value == allowed[i] then
                    return true, value
                end
            end

            return false, 'expected one of: ' .. table.concat(allowed, ', ')
        end
    end

    local function makeIntRangeValidator(minValue, maxValue)
        return function(value)
            if type(value) ~= 'number' or value ~= math.floor(value) then
                return false, 'expected integer'
            end

            if value < minValue or value > maxValue then
                return false, ('expected integer between %d and %d'):format(minValue, maxValue)
            end

            return true, value
        end
    end

    local function validateGuildId(value)
        if value == '' or Util.IsSnowflake(value) then
            return true, value
        end

        return false, 'expected a Discord snowflake or empty string'
    end

    local function makeIdentifierArrayValidator(maxEntries)
        return function(value)
            if type(value) ~= 'table' then
                return false, 'expected a list of identifiers'
            end

            if #value > maxEntries then
                return false, ('too many entries (max %d)'):format(maxEntries)
            end

            local out = {}
            local seen = {}

            for i = 1, #value do
                local entry = value[i]

                if not Util.ValidateAccessIdentifier(entry) then
                    return false, ('invalid identifier at position %d'):format(i)
                end

                local normalized = Util.NormalizeIdentifier(entry)

                if not seen[normalized] then
                    seen[normalized] = true
                    out[#out + 1] = normalized
                end
            end

            return true, out
        end
    end

    local function makeSnowflakeArrayValidator(maxEntries)
        return function(value)
            if type(value) ~= 'table' then
                return false, 'expected a list of Discord IDs'
            end

            if #value > maxEntries then
                return false, ('too many entries (max %d)'):format(maxEntries)
            end

            local out = {}
            local seen = {}

            for i = 1, #value do
                local entry = value[i]

                if not Util.IsSnowflake(entry) then
                    return false, ('invalid Discord ID at position %d'):format(i)
                end

                if not seen[entry] then
                    seen[entry] = true
                    out[#out + 1] = entry
                end
            end

            return true, out
        end
    end

    local function validateGroupMap(value)
        if type(value) ~= 'table' then
            return false, 'expected a map of group name -> boolean'
        end

        local out = {}
        local count = 0

        for groupName, enabled in pairs(value) do
            if
                type(groupName) ~= 'string'
                or not groupName:match('^[%w_]+$')
                or #groupName > 32
            then
                return false, 'invalid group name: ' .. tostring(groupName)
            end

            if type(enabled) ~= 'boolean' then
                return false, 'group values must be boolean'
            end

            count = count + 1

            if count > 64 then
                return false, 'too many groups (max 64)'
            end

            out[groupName] = enabled
        end

        return true, out
    end

    -- Dotted-path schema of everything the panel is allowed to touch.
    -- Absence from this table means "server-file only".
    local Schema <const> = {
        ['Whitelist.Enabled'] = validateBoolean,
        ['Whitelist.Mode'] = makeEnumValidator('discord', 'identifier', 'both'),
        ['Whitelist.CombinationMode'] = makeEnumValidator('or', 'and'),
        ['Whitelist.AllowedIdentifiers'] = makeIdentifierArrayValidator(20000),
        ['Discord.Enabled'] = validateBoolean,
        ['Discord.GuildId'] = validateGuildId,
        ['Discord.AllowedRoles'] = makeSnowflakeArrayValidator(64),
        ['Discord.Timeout'] = makeIntRangeValidator(1000, 15000),
        ['Discord.MaxRetries'] = makeIntRangeValidator(0, 5),
        ['Admin.Groups'] = validateGroupMap,
        ['Admin.Cache.Enabled'] = validateBoolean,
        ['Admin.Cache.SaveDelay'] = makeIntRangeValidator(1000, 60000),
        ['AdminOnly.Enabled'] = validateBoolean,
        ['AdminOnly.Groups'] = validateGroupMap,
        ['AdminOnly.AllowedIdentifiers'] = makeIdentifierArrayValidator(256),
        ['Bypass.AllowedIdentifiers'] = makeIdentifierArrayValidator(64),
        ['Logging.Enabled'] = validateBoolean,
        ['Logging.MinInterval'] = makeIntRangeValidator(500, 10000),
        ['Logging.BatchSize'] = makeIntRangeValidator(1, 10),
        ['Performance.DiscordConcurrency'] = makeIntRangeValidator(1, 25),
        ['Performance.DiscordQueueLimit'] = makeIntRangeValidator(64, 8192),
        ['Performance.VerificationTimeout'] = makeIntRangeValidator(2000, 180000),
    }

    local defaults = Config -- set by the shared config script
    local overrides = {}
    local effective = Util.MergeOverrides(defaults, nil)
    local writeBusy = false
    local Identifier
    local categories = {
        ['Whitelist.AllowedIdentifiers'] = 'whitelist',
        ['AdminOnly.AllowedIdentifiers'] = 'admin_only',
        ['Bypass.AllowedIdentifiers'] = 'bypass',
    }

    function RuntimeConfig:BindIdentifiers(module)
        Identifier = module
    end

    ---Serialize administrative writes across panel, console and reload.
    function RuntimeConfig:WithWriteLock(action)
        if writeBusy then
            return false, 'another whitelist change is in progress; retry'
        end

        writeBusy = true
        local ok, result, err = pcall(action)
        writeBusy = false

        if not ok then
            Log('error', 'Whitelist change failed: ' .. tostring(result))

            return false, 'whitelist change failed'
        end

        return result, err
    end

    ---Splits "Discord.GuildId" into { "Discord", "GuildId" }.
    ---@param path string
    ---@return string[]?
    local function splitPath(path)
        if type(path) ~= 'string' or #path > 64 then
            return nil
        end

        local parts = {}

        for part in path:gmatch('[^%.]+') do
            parts[#parts + 1] = part
        end

        if #parts == 0 then
            return nil
        end

        return parts
    end

    ---Navigates a table along a dotted path, creating tables when missing.
    ---@param root table
    ---@param parts string[]
    ---@param value any
    local function setPath(root, parts, value)
        local node = root

        for i = 1, #parts - 1 do
            if type(node[parts[i]]) ~= 'table' then
                node[parts[i]] = {}
            end

            node = node[parts[i]]
        end

        node[parts[#parts]] = value
    end

    ---@param root table
    ---@param parts string[]
    ---@return any
    local function getPath(root, parts)
        local node = root

        for i = 1, #parts do
            if type(node) ~= 'table' then
                return nil
            end

            node = node[parts[i]]
        end

        return node
    end

    local function rebuild()
        effective = Util.MergeOverrides(defaults, overrides)

        -- Group maps are complete policies; an empty map revokes every group.
        for _, path in ipairs({ 'Admin.Groups', 'AdminOnly.Groups' }) do
            local parts = splitPath(path)
            local value = getPath(overrides, parts)

            if value ~= nil then
                setPath(effective, parts, Util.DeepCopy(value))
            end
        end

        if Identifier then
            for key, category in pairs(categories) do
                local section = key:match('^([^.]+)')
                effective[section].AllowedIdentifiers = Identifier:GetList(category)
            end
        end
    end

    function RuntimeConfig:RefreshIdentifierProjection()
        rebuild()
    end

    ---Loads and validates persisted overrides from database.
    function RuntimeConfig:Load()
        return self:WithWriteLock(function()
            if not Database or not Database.ready or not Identifier then
                return false, 'whitelist storage unavailable'
            end

            local stored, err = Database:LoadConfig()

            if not stored then
                return false, err
            end

            local migrated, migrationError = Database:InitializeIdentifiers(defaults, stored)

            if not migrated then
                Log('error', 'Identifier migration failed: ' .. tostring(migrationError))

                return false, migrationError
            end

            local rows, loadError = Database:LoadIdentifiers()

            if not rows then
                return false, loadError
            end

            local sanitized = {}

            for path, validator in pairs(Schema) do
                local val = stored[path]

                if val ~= nil and not categories[path] then
                    local valid, valueOrError = validator(val)

                    if not valid then
                        Log('error', 'Invalid persisted whitelist setting: ' .. path)

                        return false, tostring(valueOrError)
                    end

                    setPath(sanitized, splitPath(path), valueOrError)
                end
            end

            Identifier:ReplaceFromRows(rows)
            overrides = sanitized
            rebuild()

            return true
        end)
    end

    ---Returns the effective configuration table. Rebuilt only when a
    ---change is applied, so hot paths read a stable reference.
    ---@return table
    function RuntimeConfig:Get()
        return effective
    end

    ---Applies a single runtime change after schema validation and persists to database.
    ---@param path string dotted path, must exist in the schema
    ---@param value any
    ---@return boolean ok
    ---@return string? errorMessage
    function RuntimeConfig:Set(path, value)
        local validator = Schema[path]

        if not validator then
            return false, 'setting is not runtime-configurable'
        end

        local valid, valueOrError = validator(value)

        if not valid then
            return false, tostring(valueOrError)
        end

        local parts = splitPath(path)

        if not parts then
            return false, 'invalid setting path'
        end

        return self:WithWriteLock(function()
            if not Database or not Database.ready or not Identifier or not Identifier.ready then
                return false, 'whitelist storage unavailable'
            end

            local ok, err

            if categories[path] then
                ok, err = Identifier:Sync(categories[path], valueOrError)
            else
                ok, err = Database:SaveConfig(path, json.encode(valueOrError))
            end

            if not ok then
                return false, err
            end

            if not categories[path] then
                setPath(overrides, parts, valueOrError)
            end

            rebuild()

            return true
        end)
    end

    ---Returns a copy of the raw overrides (for diagnostics).
    ---@return table
    function RuntimeConfig:GetOverrides()
        return Util.MergeOverrides(overrides, nil)
    end

    ---Removes all overrides (back to file defaults) and clears database settings.
    function RuntimeConfig:Reset()
        return self:WithWriteLock(function()
            if not Database or not Database.ready then
                return false, 'whitelist storage unavailable'
            end

            local ok, err = Database:ResetConfig()

            if not ok then
                return false, err
            end

            overrides = {}
            rebuild()

            return true
        end)
    end

    ---Builds the NUI-facing state projection. Contains only values the
    ---panel is allowed to display; secrets are reduced to booleans.
    ---@param extra table? additional fields (stats, token presence, ...)
    ---@return table
    function RuntimeConfig:BuildPanelState(extra)
        local cfg = effective
        local state = {
            whitelist = {
                enabled = cfg.Whitelist.Enabled,
                mode = cfg.Whitelist.Mode,
                combinationMode = cfg.Whitelist.CombinationMode,
                identifierTypes = (function()
                    local types = {}

                    for prefix, enabled in pairs(cfg.IdentifierTypes) do
                        if enabled and prefix ~= 'ip' then
                            types[#types + 1] = prefix
                        end
                    end

                    table.sort(types)

                    return types
                end)(),
                allowedIdentifiers = Util.SanitizeStringArray(cfg.Whitelist.AllowedIdentifiers),
            },
            discord = {
                enabled = cfg.Discord.Enabled,
                guildId = cfg.Discord.GuildId,
                allowedRoles = Util.SanitizeStringArray(cfg.Discord.AllowedRoles),
                timeout = cfg.Discord.Timeout,
                maxRetries = cfg.Discord.MaxRetries,
            },
            admin = {
                groups = cfg.Admin.Groups,
                cacheEnabled = cfg.Admin.Cache.Enabled,
                cacheSaveDelay = cfg.Admin.Cache.SaveDelay,
            },
            adminOnly = {
                enabled = cfg.AdminOnly.Enabled,
                groups = cfg.AdminOnly.Groups,
                allowedIdentifiers = Util.SanitizeStringArray(cfg.AdminOnly.AllowedIdentifiers),
            },
            bypass = {
                allowedIdentifiers = Util.SanitizeStringArray(cfg.Bypass.AllowedIdentifiers),
            },
            logging = {
                enabled = cfg.Logging.Enabled,
                minInterval = cfg.Logging.MinInterval,
                batchSize = cfg.Logging.BatchSize,
            },
            performance = {
                discordConcurrency = cfg.Performance.DiscordConcurrency,
                discordQueueLimit = cfg.Performance.DiscordQueueLimit,
                verificationTimeout = cfg.Performance.VerificationTimeout,
            },
        }

        if type(extra) == 'table' then
            for key, value in pairs(extra) do
                state[key] = value
            end
        end

        return state
    end

    return RuntimeConfig
end
