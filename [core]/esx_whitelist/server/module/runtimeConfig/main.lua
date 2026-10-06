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

                if not Util.ValidateIdentifier(entry) then
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
        ['Whitelist.AllowedIdentifiers'] = makeIdentifierArrayValidator(1024),
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
    local dirty = false
    local flushScheduled = false

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
    end

    ---Loads and validates persisted overrides from database.
    function RuntimeConfig:Load()
        if not Database or not Database.ready then
            rebuild()

            return true
        end

        local stored = Database:LoadConfig()

        if not stored or next(stored) == nil then
            rebuild()

            return true
        end

        -- Re-validate every persisted value against the schema so an
        -- edited or outdated record can never inject invalid state.
        local sanitized = {}

        for path, validator in pairs(Schema) do
            local val = stored[path]

            if val ~= nil then
                local valid, valueOrError = validator(val)

                if valid then
                    local parts = splitPath(path)

                    if parts then
                        setPath(sanitized, parts, valueOrError)
                    end
                else
                    Log(
                        'warning',
                        ('Ignoring invalid persisted setting %s (%s)'):format(
                            path,
                            tostring(valueOrError)
                        )
                    )
                end
            end
        end

        overrides = sanitized
        rebuild()
        Log('info', 'Runtime configuration loaded from database.')

        return true
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

        setPath(overrides, parts, valueOrError)
        rebuild()

        if Database and Database.ready then
            Database:SaveConfig(path, json.encode(valueOrError))
        end

        return true, nil
    end

    ---Returns a copy of the raw overrides (for diagnostics).
    ---@return table
    function RuntimeConfig:GetOverrides()
        return Util.MergeOverrides(overrides, nil)
    end

    ---Removes all overrides (back to file defaults) and clears database settings.
    function RuntimeConfig:Reset()
        overrides = {}
        rebuild()

        if Database and Database.ready then
            Database:ResetConfig()
        end
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
