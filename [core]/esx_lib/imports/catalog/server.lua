-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Catalog = {}

local function identifier(value)
    assert(type(value) == 'string' and value:match('^[%w_]+$'), 'Invalid catalog identifier')
    return '`' .. value .. '`'
end

function Catalog.service(db, data, onReady)
    local busy = false

    local function hasTable(name)
        local count = db.scalar.await(
            [[
            SELECT COUNT(*) FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?
        ]],
            { name }
        )

        assert(count ~= nil, 'Unable to inspect catalog table ' .. name)

        return tonumber(count) > 0
    end

    local function ensureTable(name)
        if hasTable(name) then
            return
        end

        local schema = assert(data.schemas[name], 'Missing catalog schema for ' .. name)
        local sql = schema.sql

        if not sql:upper():find('CHARSET', 1, true) then
            sql = sql .. ' DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci'
        end

        db.query.await(sql)
        assert(hasTable(name), 'Catalog table was not created: ' .. name)
    end

    local function requireTransactional(name)
        local engine = db.scalar.await(
            [[
            SELECT ENGINE FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?
        ]],
            { name }
        )

        assert(
            engine and engine:lower() == 'innodb',
            'Catalog table ' .. name .. ' must use InnoDB'
        )
    end

    local function ensureColumn(column)
        ensureTable(column.table)

        local count = db.scalar.await(
            [[
            SELECT COUNT(*) FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?
        ]],
            { column.table, column.name }
        )

        assert(count ~= nil, 'Unable to inspect catalog column ' .. column.name)

        if tonumber(count) == 0 then
            db.query.await(
                ('ALTER TABLE %s ADD COLUMN %s %s'):format(
                    identifier(column.table),
                    identifier(column.name),
                    column.definition
                )
            )
        end
    end

    local function reconcile(resource, locale)
        local definition =
            assert(data.resources[resource], 'Unknown SQL catalog resource: ' .. tostring(resource))

        assert(type(locale) == 'string' and #locale <= 32, 'Invalid catalog locale')

        locale = locale:lower():gsub('_', '-')

        if (locale == 'pt-br' or locale == 'pt') and definition.locales.br then
            locale = 'br'
        end

        local selected = definition.locales[locale] and locale
            or (definition.locales[locale:match('^[^-]+') or locale] and locale:match('^[^-]+'))
            or (definition.locales.en and 'en')
            or 'default'

        local sourceSeeds = selected == 'default' and definition.seeds
            or definition.locales[selected]
        local seeds = {}
        local sortKeys = {}

        for i = 1, #sourceSeeds do
            local seed = sourceSeeds[i]
            local values = {}

            for index, key in ipairs(data.keys[seed.table]) do
                values[index] = seed.row[key]
            end

            seeds[i] = seed
            sortKeys[seed] = json.encode(values)
        end

        local priority = {
            jobs = 1,
            items = 2,
            licenses = 3,
            vehicle_categories = 4,
            addon_account = 5,
            addon_inventory = 6,
            datastore = 7,
            job_grades = 8,
            vehicles = 9,
            fine_types = 10,
        }

        table.sort(seeds, function(a, b)
            if priority[a.table] ~= priority[b.table] then
                return priority[a.table] < priority[b.table]
            end

            return sortKeys[a] < sortKeys[b]
        end)

        for _, name in ipairs(definition.schema) do
            ensureTable(name)
        end

        for _, column in ipairs(definition.columns) do
            ensureColumn(column)
        end

        if resource == 'es_extended' then
            ensureTable('owned_vehicles')
        end

        if not hasTable('esx_catalog_imports') then
            db.query.await([[
                CREATE TABLE IF NOT EXISTS `esx_catalog_imports` (
                    `resource` VARCHAR(64) NOT NULL,
                    `version` VARCHAR(32) NOT NULL,
                    `locale` VARCHAR(32) NOT NULL,
                    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    PRIMARY KEY (`resource`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            ]])
        end

        requireTransactional('esx_catalog_imports')

        local existing = {}
        local touched = {}
        local queries = {}

        for _, seed in ipairs(seeds) do
            local name = seed.table
            local keys = assert(data.keys[name], 'Unsupported catalog table ' .. name)

            if not existing[name] then
                ensureTable(name)
                requireTransactional(name)

                local columns = {}

                for i = 1, #keys do
                    columns[i] = identifier(keys[i])
                end

                local rows = db.query.await(
                    ('SELECT %s FROM %s'):format(table.concat(columns, ', '), identifier(name))
                )

                assert(rows, 'Unable to read existing catalog keys for ' .. name)

                existing[name] = {}

                for _, row in ipairs(rows) do
                    local values = {}

                    for i = 1, #keys do
                        values[i] = row[keys[i]]
                    end

                    existing[name][json.encode(values)] = true
                end
            end

            local keyValues = {}

            for i = 1, #keys do
                keyValues[i] = assert(seed.row[keys[i]], 'Missing catalog key ' .. keys[i])
            end

            local key = json.encode(keyValues)

            if not existing[name][key] then
                local names = {}
                local fields = {}
                local placeholders = {}
                local values = {}
                local conditions = {}

                for field in pairs(seed.row) do
                    names[#names + 1] = field
                end

                table.sort(names)

                for i = 1, #names do
                    fields[i] = identifier(names[i])
                    placeholders[i] = '?'
                    values[i] = seed.row[names[i]]
                end

                for i = 1, #keys do
                    conditions[i] = identifier(keys[i]) .. ' <=> ?'
                    values[#values + 1] = keyValues[i]
                end

                queries[#queries + 1] = {
                    query = ('INSERT INTO %s (%s) SELECT %s FROM (SELECT COUNT(*) AS matches FROM %s WHERE %s) AS catalog_existing WHERE catalog_existing.matches = 0'):format(
                        identifier(name),
                        table.concat(fields, ', '),
                        table.concat(placeholders, ', '),
                        identifier(name),
                        table.concat(conditions, ' AND ')
                    ),
                    values = values,
                }

                existing[name][key] = true
                touched[name] = true
            end
        end

        local imported = #queries
        local marker = db.single.await(
            'SELECT `version`, `locale` FROM `esx_catalog_imports` WHERE `resource` = ?',
            { resource }
        )

        if
            imported > 0
            or not marker
            or marker.version ~= data.version
            or marker.locale ~= selected
        then
            queries[#queries + 1] = {
                query = [[INSERT INTO `esx_catalog_imports` (`resource`, `version`, `locale`) VALUES (?, ?, ?)
                    ON DUPLICATE KEY UPDATE `version` = VALUES(`version`), `locale` = VALUES(`locale`), `updated_at` = CURRENT_TIMESTAMP]],
                values = { resource, data.version, selected },
            }

            assert(db.transaction.await(queries), 'Catalog transaction failed for ' .. resource)
        end

        local catalogs = {}

        for _, seed in ipairs(seeds) do
            catalogs[seed.table] = true
        end

        return {
            imported = imported,
            locale = selected,
            changed = touched,
            catalogs = catalogs,
        }
    end

    return function(resource, locale)
        while busy do
            Wait(0)
        end

        busy = true

        local ok, result = pcall(function()
            local result = reconcile(resource, locale)

            if onReady then
                onReady(result)
            end

            return result
        end)

        busy = false

        if not ok then
            error(result, 0)
        end

        return result
    end
end

return Catalog
