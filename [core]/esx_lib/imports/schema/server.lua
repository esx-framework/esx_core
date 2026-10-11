-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Schema = {}

function Schema.column(tableName, columnName)
    local rows = MySQL.query.await(
        [[
        SELECT DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE,
               IS_NULLABLE, COLUMN_DEFAULT, COLLATION_NAME, EXTRA
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?
    ]],
        { tableName, columnName }
    )

    assert(rows, 'Unable to inspect schema for ' .. tableName .. '.' .. columnName)

    return rows[1]
end

function Schema.identifier(value)
    return '`' .. value:gsub('`', '``') .. '`'
end

function Schema.ensureColumn(tableName, columnName, definition)
    if Schema.column(tableName, columnName) then
        return false
    end

    local ok, err = pcall(
        MySQL.query.await,
        ('ALTER TABLE %s ADD COLUMN %s %s'):format(
            Schema.identifier(tableName),
            Schema.identifier(columnName),
            definition
        )
    )

    if not ok then
        if Schema.column(tableName, columnName) then
            return false
        end

        error(err, 0)
    end

    assert(
        Schema.column(tableName, columnName),
        'Column was not created: ' .. tableName .. '.' .. columnName
    )

    return true
end

function Schema.ensureProperty()
    Schema.ensureColumn('users', 'last_property', 'LONGTEXT NULL')

    local column = Schema.column('users', 'last_property')

    if column.DATA_TYPE == 'longtext' then
        return
    end

    assert(
        column.DATA_TYPE == 'varchar'
            or column.DATA_TYPE == 'text'
            or column.DATA_TYPE == 'mediumtext'
            or column.DATA_TYPE == 'tinytext',
        'users.last_property has an incompatible type'
    )

    MySQL.query.await('ALTER TABLE `users` MODIFY COLUMN `last_property` LONGTEXT NULL')
end

function Schema.ensureMileage()
    local added =
        Schema.ensureColumn('owned_vehicles', 'mileage', 'DECIMAL(10,2) NOT NULL DEFAULT 0.00')
    local column = Schema.column('owned_vehicles', 'mileage')

    if
        column.DATA_TYPE == 'decimal'
        and tonumber(column.NUMERIC_PRECISION) == 10
        and tonumber(column.NUMERIC_SCALE) == 2
        and column.IS_NULLABLE == 'NO'
        and tonumber(column.COLUMN_DEFAULT) == 0
    then
        return added, false
    end

    local numeric = {
        tinyint = true,
        smallint = true,
        mediumint = true,
        int = true,
        bigint = true,
        decimal = true,
        float = true,
        double = true,
    }

    assert(numeric[column.DATA_TYPE], 'owned_vehicles.mileage has an incompatible type')

    local invalid = MySQL.scalar.await([[
        SELECT EXISTS(SELECT 1 FROM `owned_vehicles`
            WHERE `mileage` < 0 OR ROUND(`mileage`, 2) > 99999999.99)
    ]])

    assert(
        invalid ~= nil and tonumber(invalid) == 0,
        'Mileage values outside DECIMAL(10,2) range; repair them before restarting'
    )

    MySQL.update.await('UPDATE `owned_vehicles` SET `mileage` = 0 WHERE `mileage` IS NULL')
    MySQL.query.await(
        'ALTER TABLE `owned_vehicles` MODIFY COLUMN `mileage` DECIMAL(10,2) NOT NULL DEFAULT 0.00'
    )

    return added, true
end

function Schema.widenVarchar(tableName, columnName, length, column)
    column = column or Schema.column(tableName, columnName)

    if not column then
        return false
    end

    assert(
        column.DATA_TYPE == nil or column.DATA_TYPE == 'varchar',
        'Expected a VARCHAR identifier'
    )

    if tonumber(column.CHARACTER_MAXIMUM_LENGTH) >= length then
        return false
    end

    assert(not column.EXTRA or column.EXTRA == '', 'Cannot widen a generated identifier column')

    local definition = ('VARCHAR(%d)'):format(length)

    if column.COLLATION_NAME then
        assert(column.COLLATION_NAME:match('^[%w_]+$'), 'Invalid collation')

        local charset = column.COLLATION_NAME:match('^([^_]+)_')

        assert(charset, 'Invalid character set')
        definition = definition
            .. ' CHARACTER SET '
            .. charset
            .. ' COLLATE '
            .. column.COLLATION_NAME
    end

    definition = definition .. (column.IS_NULLABLE == 'NO' and ' NOT NULL' or ' NULL')

    if column.COLUMN_DEFAULT ~= nil then
        local version = MySQL.scalar.await('SELECT VERSION()')

        assert(version, 'Unable to determine default literal format')

        if version:find('MariaDB', 1, true) then
            definition = definition .. ' DEFAULT ' .. column.COLUMN_DEFAULT
        else
            local value = tostring(column.COLUMN_DEFAULT)
            local hex = value:gsub('.', function(char)
                return ('%02X'):format(char:byte())
            end)

            definition = definition .. " DEFAULT X'" .. hex .. "'"
        end
    end

    MySQL.query.await(
        ('ALTER TABLE %s MODIFY COLUMN %s %s'):format(
            Schema.identifier(tableName),
            Schema.identifier(columnName),
            definition
        )
    )

    return true
end

return Schema
