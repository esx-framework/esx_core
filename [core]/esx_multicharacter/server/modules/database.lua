-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Database = {}
Database.connected = false
Database.found = false
Database.tables = { users = 'identifier' }

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
    ]],
        { { 'identifier', 'owner' } }
    )

    assert(columns, 'Unable to inspect character identifier columns')

    for i = 1, #columns do
        local column = columns[i]
        self.tables[column.TABLE_NAME] = column.COLUMN_NAME
        xLib.schema.widenVarchar(column.TABLE_NAME, column.COLUMN_NAME, length, column)
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
    print('[esx_multicharacter] 1.16.0 schema ready')
    ESX.Jobs = ESX.GetJobs()

    while not next(ESX.Jobs) do
        Wait(500)
        ESX.Jobs = ESX.GetJobs()
    end
end)

function Database:DeleteCharacter(source, charid)
    local identifier = ('%s%s:%s'):format(Server.prefix, charid, ESX.GetIdentifier(source))
    local query = 'DELETE FROM `%s` WHERE %s = ?'
    local queries = {}
    local count = 0

    for table, column in pairs(self.tables) do
        count = count + 1
        queries[count] = { query = query:format(table, column), values = { identifier } }
    end

    MySQL.transaction(queries, function(result)
        if result then
            local name = GetPlayerName(source)
            print(
                ('[^2INFO^7] Player ^5%s %s^7 has deleted a character ^5(%s)^7'):format(
                    name,
                    source,
                    identifier
                )
            )
            Wait(50)
            Multicharacter:SetupCharacters(source)
        else
            error('\n^1Transaction failed while trying to delete ' .. identifier .. '^0')
        end
    end)
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
