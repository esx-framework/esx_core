-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Database = {}
Database.connected = false
Database.found = false
Database.tables = { users = 'identifier' }
Database.characterColumns = { users = { identifier = true } }

local function ensureDeletionIndex(tableName, columnName)
    local function indexed()
        local count = MySQL.scalar.await([[
            SELECT COUNT(*) FROM information_schema.STATISTICS
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?
                AND SEQ_IN_INDEX = 1 AND SUB_PART IS NULL
        ]], { tableName, columnName })
        assert(count ~= nil, 'Unable to inspect character deletion index')
        return tonumber(count) > 0
    end

    if indexed() then return end

    local quote = xLib.schema.identifier
    local indexName = 'esx_char_' .. columnName
    local ok, err = pcall(MySQL.query.await,
        ('CREATE INDEX %s ON %s (%s)'):format(quote(indexName), quote(tableName), quote(columnName)))

    if not ok and not indexed() then error(err, 0) end
end

function Database:GetConnection()
    local connectionString = GetConvar('mysql_connection_string', '')

    if connectionString == '' then
        error(
            connectionString
                .. '\n^1Unable to start Multicharacter - unable to determine database from mysql_connection_string^0',
            0
        )
    elseif connectionString:find('mysql://') then
        connectionString = connectionString:sub(9, -1)

        self.name =
            connectionString:sub(connectionString:find('/') + 1, -1):gsub('[%?]+[%w%p]*$', '')
        self.found = true
    else
        local confPairs = { string.strsplit(';', connectionString) }
        for i = 1, #confPairs do
            local confPair = confPairs[i]
            local key, value = confPair:match('^%s*(.-)%s*=%s*(.-)%s*$')
            if key == 'database' then
                self.name = value
                self.found = true
                break
            end
        end
    end
end

function Database:MigrateSchema()
    xLib.schema.ensureColumn('users', 'disabled', 'TINYINT(1) NULL DEFAULT 0')

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `multicharacter_slots` (
            `identifier` VARCHAR(60) NOT NULL,
            `slots` INT NOT NULL,
            PRIMARY KEY (`identifier`), INDEX `slots` (`slots`)
        ) ENGINE=InnoDB
    ]])

    MySQL.query.await('SELECT `identifier`, `slots` FROM `multicharacter_slots` LIMIT 0')

    local length = 42 + #Server.prefix
    local columns = MySQL.query.await(
        [[
        SELECT TABLE_NAME, COLUMN_NAME, CHARACTER_MAXIMUM_LENGTH,
               IS_NULLABLE, COLUMN_DEFAULT, COLLATION_NAME, EXTRA
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND DATA_TYPE = 'varchar' AND COLUMN_NAME IN (?)
            AND TABLE_NAME IN (SELECT TABLE_NAME FROM information_schema.TABLES
                WHERE TABLE_SCHEMA = DATABASE() AND TABLE_TYPE = 'BASE TABLE')
    ]],
        { { 'identifier', 'owner' } }
    )

    assert(columns, 'Unable to inspect character identifier columns')

    for i = 1, #columns do
        local column = columns[i]
        self.tables[column.TABLE_NAME] = column.COLUMN_NAME

        local characterColumns = self.characterColumns[column.TABLE_NAME] or {}
        self.characterColumns[column.TABLE_NAME] = characterColumns
        characterColumns[column.COLUMN_NAME] = true

        xLib.schema.widenVarchar(column.TABLE_NAME, column.COLUMN_NAME, length, column)
        ensureDeletionIndex(column.TABLE_NAME, column.COLUMN_NAME)
    end
end

MySQL.ready(function()
    ESXCatalog.awaitReady()

    local ok, err = pcall(Database.MigrateSchema, Database)

    if not ok then
        print(
            ('[esx_multicharacter] 1.16.0 migration failed; character selection is disabled: %s'):format(
                tostring(err)
            )
        )
        return
    end

    Database.connected = true
    local logKey = 'esx_multicharacter:1.16.0:schema_ready'
    if GetResourceKvpInt(logKey) ~= 1 then
        print('[esx_multicharacter] 1.16.0 schema ready')
        SetResourceKvpInt(logKey, 1)
    end
    ESX.Jobs = ESX.GetJobs()

    while not next(ESX.Jobs) do
        Wait(500)
        ESX.Jobs = ESX.GetJobs()
    end
end)

function Database:DeleteCharacter(source, charid, session)
    local identifier = ('%s%s:%s'):format(Server.prefix, charid, session.identifier)
    local queries = {}
    local tables = {}
    for tableName in pairs(self.tables) do
        if tableName ~= 'users' then tables[#tables + 1] = tableName end
    end

    table.sort(tables)
    tables[#tables + 1] = 'users'
    
    for _, tableName in ipairs(tables) do
        local columns = {}
        for columnName in pairs(self.characterColumns[tableName] or { [self.tables[tableName]] = true }) do
            columns[#columns + 1] = columnName
        end
        table.sort(columns)
        for _, columnName in ipairs(columns) do
            queries[#queries + 1] = {
                query = ('DELETE FROM %s WHERE %s = ?'):format(
                    xLib.schema.identifier(tableName), xLib.schema.identifier(columnName)),
                values = { identifier },
            }
        end
    end
    return MySQL.transaction.await(queries) == true
end

function Database:GetPlayerSlots(identifier)
    return MySQL.scalar.await(
        'SELECT slots FROM multicharacter_slots WHERE identifier = ?',
        { identifier }
    ) or Server.slots
end

function Database:GetPlayerInfo(identifier, slots)
    local placeholders = {}
    local identifiers = {}

    for i = 1, slots do
        placeholders[i] = '?'
        identifiers[i] = ('%s%s:%s'):format(Server.prefix, i, identifier)
    end

    return MySQL.query.await(
        ('SELECT identifier, accounts, job, job_grade, firstname, lastname, dateofbirth, sex, skin, disabled FROM users WHERE identifier IN (%s)'):format(
            table.concat(placeholders, ', ')
        ),
        identifiers
    )
end

function Database:GetCharacter(identifier, slot)
    local selectedCharacter = ('%s%s:%s'):format(Server.prefix, slot, identifier)
    local result = MySQL.query.await(
        'SELECT identifier, disabled FROM users WHERE identifier = ? LIMIT 1',
        { selectedCharacter }
    )

    return result and result[1]
end

function Database:SetSlots(identifier, slots)
    MySQL.insert(
        'INSERT INTO `multicharacter_slots` (`identifier`, `slots`) VALUES (?, ?) ON DUPLICATE KEY UPDATE `slots` = VALUES(`slots`)',
        {
            identifier,
            slots,
        }
    )
end

function Database:RemoveSlots(identifier)
    local slots =
        MySQL.scalar.await('SELECT `slots` FROM `multicharacter_slots` WHERE identifier = ?', {
            identifier,
        })

    if slots then
        MySQL.update('DELETE FROM `multicharacter_slots` WHERE `identifier` = ?', {
            identifier,
        })
        return true
    end
    return false
end

function Database:EnableSlot(identifier, slot)
    local selectedCharacter = ('char%s:%s'):format(slot, identifier)

    local updated = MySQL.update.await(
        'UPDATE `users` SET `disabled` = 0 WHERE identifier = ?',
        { selectedCharacter }
    )
    return updated > 0
end

function Database:DisableSlot(identifier, slot)
    local selectedCharacter = ('char%s:%s'):format(slot, identifier)

    local updated = MySQL.update.await(
        'UPDATE `users` SET `disabled` = 1 WHERE identifier = ?',
        { selectedCharacter }
    )
    return updated > 0
end

Database:GetConnection()
