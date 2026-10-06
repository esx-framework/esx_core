-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@param Util table
---@param Log fun(level: string, message: string)
return function(Util, Log)
    local Database = {}
    Database.ready = false

    local function safeQuery(fn, query, params)
        local ok, result = pcall(fn, query, params)
        if not ok then
            Log("error", ("Database error executing [%s]: %s"):format(tostring(query), tostring(result)))
            return nil
        end
        return result
    end

    ---Ensures tables exist in the database with proper indexed schemas
    ---@param cb fun()?
    function Database:Init(cb)
        MySQL.ready(function()
            local ddl = {
                [[
                    CREATE TABLE IF NOT EXISTS `esx_whitelist_config` (
                        `setting_key` VARCHAR(64) NOT NULL,
                        `setting_value` LONGTEXT NOT NULL,
                        `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        PRIMARY KEY (`setting_key`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
                ]],
                [[
                    CREATE TABLE IF NOT EXISTS `esx_whitelist_identifiers` (
                        `identifier` VARCHAR(128) NOT NULL,
                        `type` VARCHAR(32) NOT NULL DEFAULT 'whitelist',
                        `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        PRIMARY KEY (`identifier`, `type`),
                        KEY `idx_type` (`type`),
                        KEY `idx_identifier` (`identifier`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
                ]],
                [[
                    CREATE TABLE IF NOT EXISTS `esx_whitelist_admin` (
                        `identifier` VARCHAR(128) NOT NULL,
                        `group_name` VARCHAR(32) NOT NULL,
                        PRIMARY KEY (`identifier`),
                        KEY `idx_group_name` (`group_name`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
                ]],
                [[
                    CREATE TABLE IF NOT EXISTS `esx_whitelist_discord` (
                        `user_id` VARCHAR(32) NOT NULL,
                        `allowed` TINYINT(1) NOT NULL,
                        `status` VARCHAR(32) NOT NULL,
                        PRIMARY KEY (`user_id`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
                ]]
            }

            for i = 1, #ddl do
                safeQuery(MySQL.query.await, ddl[i])
            end
            Database.ready = true
            Log("info", "Database initialized successfully with indexed schemas.")

            if cb then
                cb()
            end
        end)
    end

    ---Loads all runtime configuration overrides from MySQL
    ---@return table<string, any>?
    function Database:LoadConfig()
        local rows = safeQuery(MySQL.query.await, "SELECT setting_key, setting_value FROM esx_whitelist_config")
        if not rows then
            return nil
        end
        local result = {}
        for i = 1, #rows do
            local row = rows[i]
            local ok, val = pcall(json.decode, row.setting_value)
            if ok then
                result[row.setting_key] = val
            end
        end
        return result
    end

    ---Saves a single configuration key into MySQL
    ---@param key string
    ---@param valueString string JSON-encoded value
    function Database:SaveConfig(key, valueString)
        safeQuery(MySQL.query.await, "INSERT INTO esx_whitelist_config (setting_key, setting_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)", { key, valueString })
    end

    ---Resets all config overrides
    function Database:ResetConfig()
        safeQuery(MySQL.query.await, "TRUNCATE TABLE esx_whitelist_config")
    end

    ---Loads all identifiers from MySQL
    ---@return { identifier: string, type: string }[]?
    function Database:LoadIdentifiers()
        return safeQuery(MySQL.query.await, "SELECT identifier, type FROM esx_whitelist_identifiers")
    end

    ---Matches any of the player's identifiers against esx_whitelist_identifiers table
    ---Uses indexed query directly on PRIMARY KEY (identifier, type) or KEY (identifier)
    ---@param identifiers string[]
    ---@param idType string
    ---@return string? matchedIdentifier
    function Database:MatchIdentifier(identifiers, idType)
        idType = idType or "whitelist"
        if not identifiers or #identifiers == 0 then
            return nil
        end

        if #identifiers == 1 then
            local row = safeQuery(MySQL.single.await, "SELECT identifier FROM esx_whitelist_identifiers WHERE identifier = ? AND type = ? LIMIT 1", { identifiers[1], idType })
            return row and row.identifier or nil
        end

        local row = safeQuery(MySQL.single.await, "SELECT identifier FROM esx_whitelist_identifiers WHERE identifier IN (?) AND type = ? LIMIT 1", { identifiers, idType })
        return row and row.identifier or nil
    end

    ---Syncs an identifier list for a specific type (e.g. whitelist, admin_only, bypass)
    ---@param idType string
    ---@param list string[]
    function Database:SyncIdentifiers(idType, list)
        local queries = {
            { query = "DELETE FROM esx_whitelist_identifiers WHERE type = ?", values = { idType } }
        }
        if type(list) == "table" and #list > 0 then
            for i = 1, #list do
                if Util.ValidateIdentifier(list[i]) then
                    queries[#queries + 1] = {
                        query = "INSERT IGNORE INTO esx_whitelist_identifiers (identifier, type) VALUES (?, ?)",
                        values = { Util.NormalizeIdentifier(list[i]), idType }
                    }
                end
            end
        end
        safeQuery(MySQL.transaction.await, queries)
    end

    ---Adds a single identifier
    ---@param identifier string
    ---@param idType string?
    ---@return boolean, string?
    function Database:AddIdentifier(identifier, idType)
        idType = idType or "whitelist"
        local normalized = Util.NormalizeIdentifier(identifier)
        if not Util.ValidateIdentifier(normalized) then
            return false, "invalid identifier"
        end
        safeQuery(MySQL.query.await, "INSERT IGNORE INTO esx_whitelist_identifiers (identifier, type) VALUES (?, ?)", { normalized, idType })
        return true, nil
    end

    ---Removes a single identifier
    ---@param identifier string
    ---@param idType string?
    ---@return boolean
    function Database:RemoveIdentifier(identifier, idType)
        idType = idType or "whitelist"
        local normalized = Util.NormalizeIdentifier(identifier)
        safeQuery(MySQL.query.await, "DELETE FROM esx_whitelist_identifiers WHERE identifier = ? AND type = ?", { normalized, idType })
        return true
    end

    ---Loads persisted admin group entries.
    ---@param allowedGroups table<string, boolean>
    ---@return table<string, { group: string }>?
    function Database:LoadAdminCache(allowedGroups)
        local groups = {}
        for groupName, enabled in pairs(allowedGroups or {}) do
            if enabled then
                groups[#groups + 1] = groupName
            end
        end
        if #groups == 0 then
            return {}
        end

        local rows = safeQuery(MySQL.query.await, "SELECT identifier, group_name FROM esx_whitelist_admin WHERE group_name IN (?)", { groups })
        if not rows then
            return nil
        end
        local entries = {}
        for i = 1, #rows do
            local row = rows[i]
            entries[row.identifier] = { group = row.group_name }
        end
        return entries
    end

    ---Queries the admin cache for a player's identifiers using the primary key.
    ---@param identifiers string[]|string
    ---@return { identifier: string, group_name: string }?
    function Database:GetAdminCache(identifiers)
        if not identifiers then
            return nil
        end
        if type(identifiers) == "string" then
            return safeQuery(MySQL.single.await, "SELECT identifier, group_name FROM esx_whitelist_admin WHERE identifier = ? LIMIT 1", { identifiers })
        end
        if #identifiers == 0 then
            return nil
        end
        if #identifiers == 1 then
            return safeQuery(MySQL.single.await, "SELECT identifier, group_name FROM esx_whitelist_admin WHERE identifier = ? LIMIT 1", { identifiers[1] })
        end
        return safeQuery(MySQL.single.await, "SELECT identifier, group_name FROM esx_whitelist_admin WHERE identifier IN (?) LIMIT 1", { identifiers })
    end

    ---Looks up an ESX group before a player session exists, for admin-only access.
    ---@param identifiers string[] FiveM identifiers
    ---@param allowedGroups table<string, boolean>
    ---@return string? group
    function Database:GetESXAdminGroup(identifiers, allowedGroups)
        local identifierType = Util.Trim(GetConvar("esx:identifier", "license"))
        local identifierValue
        local prefix = identifierType .. ":"

        for i = 1, #identifiers do
            local identifier = Util.NormalizeIdentifier(identifiers[i])
            if identifier:sub(1, #prefix) == prefix then
                identifierValue = identifier:sub(#prefix + 1)
                break
            end
        end

        if not identifierValue then
            return nil
        end

        local groups = {}
        for groupName, enabled in pairs(allowedGroups or {}) do
            if enabled and type(groupName) == "string" then
                groups[#groups + 1] = groupName
            end
        end
        if #groups == 0 then
            return nil
        end

        local row = safeQuery(MySQL.single.await,
            "SELECT `group` FROM `users` WHERE (`identifier` = ? OR `identifier` LIKE ?) AND `group` IN (?) LIMIT 1",
            { identifierValue, "char%:" .. identifierValue, groups }
        )
        return row and row.group or nil
    end

    ---Saves a batch of dirty admin cache entries
    ---@param batch { identifier: string, group: string }[]
    ---@param isSync boolean
    function Database:SaveAdminBatch(batch, isSync)
        if not batch or #batch == 0 then
            return
        end

        local queries = {}
        for i = 1, #batch do
            local item = batch[i]
            queries[#queries + 1] = {
                query = "INSERT INTO esx_whitelist_admin (identifier, group_name) VALUES (?, ?) ON DUPLICATE KEY UPDATE group_name = VALUES(group_name)",
                values = { item.identifier, item.group }
            }
        end

        if isSync then
            safeQuery(MySQL.transaction.await, queries)
        else
            MySQL.transaction(queries, function(success)
                if not success then
                    Log("warning", "Failed to save debounced admin cache batch to database")
                end
            end)
        end
    end

    ---Removes an identifier from the admin cache using indexed query on PRIMARY KEY
    ---@param identifier string
    function Database:RemoveAdminCache(identifier)
        safeQuery(MySQL.query.await, "DELETE FROM esx_whitelist_admin WHERE identifier = ?", { identifier })
    end

    ---Saves a batch of dirty discord cache entries
    ---@param batch { userId: string, allowed: boolean, status: string }[]
    ---@param isSync boolean
    function Database:SaveDiscordBatch(batch, isSync)
        if not batch or #batch == 0 then
            return
        end

        local chunkSize = 250
        local function buildQueries(first, last)
            local queries = {}
            for i = first, last do
                local item = batch[i]
                queries[#queries + 1] = {
                    query = "INSERT INTO esx_whitelist_discord (user_id, allowed, status) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE allowed = VALUES(allowed), status = VALUES(status)",
                    values = { item.userId, item.allowed and 1 or 0, item.status }
                }
            end
            return queries
        end

        if isSync then
            for first = 1, #batch, chunkSize do
                local last = math.min(first + chunkSize - 1, #batch)
                safeQuery(MySQL.transaction.await, buildQueries(first, last))
            end
            return
        end

        local function saveChunk(first)
            local last = math.min(first + chunkSize - 1, #batch)
            MySQL.transaction(buildQueries(first, last), function(success)
                if not success then
                    Log("warning", "Failed to save debounced discord cache batch to database")
                end
                local nextFirst = last + 1
                if nextFirst <= #batch then
                    saveChunk(nextFirst)
                end
            end)
        end

        saveChunk(1)
    end
    
    ---Clears the discord cache in database
    function Database:ClearDiscordCache()
        safeQuery(MySQL.query.await, "TRUNCATE TABLE esx_whitelist_discord")
    end

    return Database
end

