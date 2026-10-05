-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core.Migrations = Core.Migrations or {}
Core.Migrations['v1.16.0'] = Core.Migrations['v1.16.0'] or {}

local function prepareSSNBatch(users)
    local generated = {}
    local parameters = {}
    local pending = {}

    for i = 1, #users do
        pending[i] = i
    end

    repeat
        local candidates = {}
        local placeholders = {}

        for _, index in ipairs(pending) do
            local ssn

            repeat
                ssn = Core.generateSSN(true)
            until not generated[ssn]

            generated[ssn] = true
            parameters[index] = { ssn, users[index].identifier }
            candidates[#candidates + 1] = ssn
            placeholders[#placeholders + 1] = '?'
        end

        local existing = MySQL.query.await(
            'SELECT `ssn` FROM `users` WHERE `ssn` IN (' .. table.concat(placeholders, ', ') .. ')',
            candidates
        )

        assert(type(existing) == 'table', 'Unable to check SSN batch uniqueness')

        local collisions = {}

        for _, row in ipairs(existing) do
            collisions[row.ssn] = true
        end

        pending = {}

        for i = 1, #parameters do
            if collisions[parameters[i][1]] then
                pending[#pending + 1] = i
            end
        end
    until #pending == 0

    return parameters
end

function Core.MigrateSSNSchema()
    local schema = xLib.schema

    schema.ensureColumn('users', 'ssn', 'VARCHAR(11) NULL DEFAULT NULL AFTER `identifier`')

    local column = schema.column('users', 'ssn')

    assert(
        column.DATA_TYPE == 'varchar' and tonumber(column.CHARACTER_MAXIMUM_LENGTH) == 11,
        'users.ssn must be VARCHAR(11); migration stopped without replacing existing SSNs'
    )

    local duplicates = MySQL.scalar.await([[
        SELECT EXISTS(SELECT 1 FROM `users` WHERE `ssn` IS NOT NULL
            GROUP BY `ssn` HAVING COUNT(*) > 1)
    ]])

    assert(
        duplicates ~= nil and tonumber(duplicates) == 0,
        'Duplicate SSNs found; repair duplicates before restarting es_extended'
    )

    local indexed = MySQL.scalar.await([[
        SELECT COUNT(*) FROM (
            SELECT INDEX_NAME FROM information_schema.STATISTICS
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users' AND NON_UNIQUE = 0
            GROUP BY INDEX_NAME
            HAVING COUNT(*) = 1 AND MAX(COLUMN_NAME) = 'ssn' AND SUM(SUB_PART IS NOT NULL) = 0
        ) AS ssn_unique_keys
    ]])

    assert(indexed ~= nil, 'Unable to inspect SSN indexes')

    if tonumber(indexed) == 0 then
        MySQL.query.await('ALTER TABLE `users` ADD UNIQUE KEY `uq_users_ssn_1160` (`ssn`)')
    end

    local batchSize = 500
    local lastIdentifier = nil
    local repaired = false

    while true do
        local query = 'SELECT `identifier` FROM `users` WHERE `ssn` IS NULL'
        local values = {}

        if lastIdentifier then
            query = query .. ' AND `identifier` > ?'
            values[#values + 1] = lastIdentifier
        end

        query = query .. ' ORDER BY `identifier` LIMIT ?'
        values[#values + 1] = batchSize

        local users = MySQL.query.await(query, values)

        assert(type(users) == 'table', 'Unable to read users without SSNs')

        if #users == 0 then
            break
        end

        local parameters = prepareSSNBatch(users)
        local saved = MySQL.prepare.await(
            'UPDATE `users` SET `ssn` = ? WHERE `identifier` = ? AND `ssn` IS NULL',
            parameters
        )

        assert(saved ~= nil and saved ~= false, 'Unable to persist SSN batch')

        repaired = true
        lastIdentifier = users[#users].identifier

        if #users < batchSize then
            break
        end
    end

    if column.IS_NULLABLE ~= 'NO' or column.COLUMN_DEFAULT ~= nil then
        MySQL.query.await('ALTER TABLE `users` MODIFY COLUMN `ssn` VARCHAR(11) NOT NULL')
    end

    return repaired
end

Core.Migrations['v1.16.0'].ssn = Core.MigrateSSNSchema

Core.Migrations['v1.16.0'].jobTypes = function()
    return xLib.schema.ensureColumn(
        'jobs',
        'type',
        "VARCHAR(50) NOT NULL DEFAULT 'civ' AFTER `label`"
    )
end

Core.Migrations['v1.16.0'].addonCompatibility = function()
    local schema = xLib.schema

    schema.widenVarchar('billing', 'target', 60)
    schema.widenVarchar('rented_vehicles', 'owner', 60)

    local targets = {
        { 'billing', 'identifier' },
        { 'owned_vehicles', 'owner' },
        { 'user_licenses', 'owner' },
        { 'society_moneywash', 'identifier' },
        { 'addon_account_data', 'owner' },
        { 'addon_inventory_items', 'owner' },
        { 'datastore_data', 'owner' },
    }

    for i = 1, #targets do
        local tableName = targets[i][1]
        local columnName = targets[i][2]

        if schema.column(tableName, columnName) then
            local indexed = MySQL.scalar.await(
                [[
                SELECT COUNT(*) FROM information_schema.STATISTICS
                WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?
                    AND SEQ_IN_INDEX = 1 AND SUB_PART IS NULL
            ]],
                { tableName, columnName }
            )

            assert(indexed ~= nil, 'Unable to inspect character deletion indexes')

            if tonumber(indexed) == 0 then
                MySQL.query.await(
                    ('CREATE INDEX %s ON %s (%s)'):format(
                        schema.identifier('esx_1160_' .. tableName .. '_' .. columnName),
                        schema.identifier(tableName),
                        schema.identifier(columnName)
                    )
                )
            end
        end
    end

    return false
end
