-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---Persistent storage. Authorization reads identifier snapshots from RAM.
return function(Util, Log)
    local Database = { ready = false }
    local latency = Util.NewLatencyMetrics()
    local categories = {
        ['Whitelist.AllowedIdentifiers'] = 'whitelist',
        ['AdminOnly.AllowedIdentifiers'] = 'admin_only',
        ['Bypass.AllowedIdentifiers'] = 'bypass',
    }

    local function safeQuery(fn, query, params, allowEmpty)
        local startedAt = GetGameTimer()
        local ok, result = pcall(fn, query, params)
        latency:Observe(GetGameTimer() - startedAt)

        if not ok or (result == nil and not allowEmpty) or result == false then
            Log(
                'error',
                ('Whitelist database operation failed: %s'):format(
                    ok and 'no result' or tostring(result)
                )
            )

            return nil, 'database operation failed'
        end

        return result
    end

    local function transaction(queries)
        if #queries == 0 then
            return true
        end

        local result, err = safeQuery(MySQL.transaction.await, queries)

        return result == true, err or (result ~= true and 'database transaction failed' or nil)
    end

    function Database:Init(cb)
        MySQL.ready(function()
            local ddl = {
                [[CREATE TABLE IF NOT EXISTS esx_whitelist_config (
                    setting_key VARCHAR(64) NOT NULL,
                    setting_value LONGTEXT NOT NULL,
                    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    PRIMARY KEY (setting_key)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]],
                [[CREATE TABLE IF NOT EXISTS esx_whitelist_identifiers (
                    identifier VARCHAR(128) NOT NULL,
                    type VARCHAR(32) NOT NULL DEFAULT 'whitelist',
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    PRIMARY KEY (identifier, type),
                    KEY idx_type (type)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]],
            }

            self.ready = false

            for i = 1, #ddl do
                if not safeQuery(MySQL.query.await, ddl[i]) then
                    return
                end
            end

            local indexes = safeQuery(
                MySQL.query.await,
                'SHOW INDEX FROM esx_whitelist_identifiers WHERE Key_name = ?',
                { 'idx_identifier' }
            )

            if not indexes then
                return
            end

            if
                #indexes > 0
                and not safeQuery(
                    MySQL.query.await,
                    'ALTER TABLE esx_whitelist_identifiers DROP INDEX idx_identifier'
                )
            then
                return
            end

            self.ready = true

            if cb then
                cb()
            end
        end)
    end

    function Database:LoadConfig()
        local rows, err = safeQuery(
            MySQL.query.await,
            'SELECT setting_key, setting_value FROM esx_whitelist_config'
        )

        if not rows then
            return nil, err
        end

        local result = {}

        for i = 1, #rows do
            local row = rows[i]
            local ok, value = pcall(json.decode, row.setting_value)

            if not ok or value == nil then
                Log('error', 'Invalid persisted whitelist setting: ' .. tostring(row.setting_key))

                return nil, 'invalid persisted configuration'
            end

            result[row.setting_key] = value
        end

        return result
    end

    function Database:SaveConfig(key, valueString)
        local result, err = safeQuery(
            MySQL.query.await,
            'INSERT INTO esx_whitelist_config (setting_key, setting_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)',
            { key, valueString }
        )

        return result ~= nil, err
    end

    function Database:ResetConfig()
        local result, err = safeQuery(
            MySQL.query.await,
            'DELETE FROM esx_whitelist_config WHERE setting_key <> ?',
            { '_identifiers_migrated' }
        )

        return result ~= nil, err
    end

    function Database:LoadIdentifiers()
        return safeQuery(
            MySQL.query.await,
            'SELECT identifier, type FROM esx_whitelist_identifiers'
        )
    end

    ---Import the old JSON/file lists once, in the same transaction as the marker.
    ---Subsequent reloads never restore entries that an administrator removed.
    function Database:InitializeIdentifiers(defaults, stored)
        if stored._identifiers_migrated == true then
            return true
        end

        local queries = {}

        for key, category in pairs(categories) do
            local section = key:match('^([^.]+)')
            local list = stored[key] or defaults[section].AllowedIdentifiers or {}

            if type(list) ~= 'table' then
                return false, 'invalid legacy identifier list'
            end

            for i = 1, #list do
                if not Util.ValidateAccessIdentifier(list[i]) then
                    return false, 'invalid legacy access identifier; review ' .. key
                end

                queries[#queries + 1] = {
                    query = 'INSERT INTO esx_whitelist_identifiers (identifier, type) VALUES (?, ?) ON DUPLICATE KEY UPDATE identifier = VALUES(identifier)',
                    values = { Util.NormalizeIdentifier(list[i]), category },
                }
            end

            queries[#queries + 1] = {
                query = 'DELETE FROM esx_whitelist_config WHERE setting_key = ?',
                values = { key },
            }
        end

        queries[#queries + 1] = {
            query = 'INSERT INTO esx_whitelist_config (setting_key, setting_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)',
            values = { '_identifiers_migrated', 'true' },
        }

        return transaction(queries)
    end

    ---Only insert/delete the difference. Each batch is bounded at 250 identifiers.
    function Database:SyncIdentifiers(idType, list)
        local rows, err = self:LoadIdentifiers()

        if not rows then
            return false, err
        end

        local existing, wanted = {}, {}

        for i = 1, #rows do
            if rows[i].type == idType then
                existing[Util.NormalizeIdentifier(rows[i].identifier)] = true
            end
        end

        for i = 1, #list do
            if not Util.ValidateAccessIdentifier(list[i]) then
                return false, 'invalid access identifier'
            end

            wanted[Util.NormalizeIdentifier(list[i])] = true
        end

        local added, removed, queries = {}, {}, {}

        for identifier in pairs(wanted) do
            if not existing[identifier] then
                added[#added + 1] = identifier
            end
        end

        for identifier in pairs(existing) do
            if not wanted[identifier] then
                removed[#removed + 1] = identifier
            end
        end

        for first = 1, #added, 250 do
            local placeholders, values = {}, {}

            for i = first, math.min(first + 249, #added) do
                placeholders[#placeholders + 1] = '(?, ?)'
                values[#values + 1] = added[i]
                values[#values + 1] = idType
            end

            queries[#queries + 1] = {
                query = 'INSERT INTO esx_whitelist_identifiers (identifier, type) VALUES '
                    .. table.concat(placeholders, ', ')
                    .. ' ON DUPLICATE KEY UPDATE identifier = VALUES(identifier)',
                values = values,
            }
        end

        for first = 1, #removed, 250 do
            local placeholders, values = {}, { idType }

            for i = first, math.min(first + 249, #removed) do
                placeholders[#placeholders + 1] = '?'
                values[#values + 1] = removed[i]
            end

            queries[#queries + 1] = {
                query = 'DELETE FROM esx_whitelist_identifiers WHERE type = ? AND identifier IN ('
                    .. table.concat(placeholders, ', ')
                    .. ')',
                values = values,
            }
        end

        return transaction(queries)
    end

    function Database:AddIdentifier(identifier, idType)
        local result, err = safeQuery(
            MySQL.query.await,
            'INSERT INTO esx_whitelist_identifiers (identifier, type) VALUES (?, ?) ON DUPLICATE KEY UPDATE identifier = VALUES(identifier)',
            { identifier, idType }
        )

        return result ~= nil, err
    end

    function Database:RemoveIdentifier(identifier, idType)
        local result, err = safeQuery(
            MySQL.query.await,
            'DELETE FROM esx_whitelist_identifiers WHERE identifier = ? AND type = ?',
            { identifier, idType }
        )

        return result ~= nil, err
    end

    function Database:LoadAdminCandidates(allowedGroups)
        local groups = {}

        for group, enabled in pairs(allowedGroups) do
            if enabled then
                groups[#groups + 1] = group
            end
        end

        if #groups == 0 then
            return {}
        end

        return safeQuery(
            MySQL.query.await,
            'SELECT identifier, `group` FROM users WHERE `group` IN (?)',
            { groups }
        )
    end

    ---Check the actual ESX record before a discovered admin bypasses authorization.
    function Database:GetESXAdminGroup(identifiers, allowedGroups)
        local prefix = Util.Trim(GetConvar('esx:identifier', 'license')) .. ':'
        local value

        for i = 1, #identifiers do
            local identifier = Util.NormalizeIdentifier(identifiers[i])

            if identifier:sub(1, #prefix) == prefix then
                value = identifier:sub(#prefix + 1)
                break
            end
        end

        if not value then
            return nil
        end

        local groups = {}

        for group, enabled in pairs(allowedGroups) do
            if enabled then
                groups[#groups + 1] = group
            end
        end

        if #groups == 0 then
            return nil
        end

        local row, err = safeQuery(
            MySQL.single.await,
            "SELECT `group` FROM users WHERE (identifier = ? OR identifier LIKE ? ESCAPE '=') AND `group` IN (?) LIMIT 1",
            { value, 'char%:' .. value:gsub('[=%%_]', '=%0'), groups },
            true
        )

        -- A missing row is a valid denial, never an authorization grant.
        return row and row.group or nil, err
    end

    function Database:GetStats()
        return { latencyMs = latency:Get() }
    end

    return Database
end
