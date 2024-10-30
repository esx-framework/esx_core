Database = {}
Database.connected = false
Database.found = false
Database.tables = { users = "identifier" }

function Database:GetConnection()
    local connectionString = GetConvar("mysql_connection_string", "")

    if connectionString == "" then
        error(connectionString .. "\n^1Unable to start Multicharacter - unable to determine database from mysql_connection_string^0", 0)
    elseif connectionString:find("mysql://") then
        connectionString = connectionString:sub(9, -1)

        self.name = connectionString:sub(connectionString:find("/") + 1, -1):gsub("[%?]+[%w%p]*$", "")
        self.found = true
    else
        local connectionExtracted = { string.strsplit(";", connectionString) }

        for i = 1, #connectionExtracted do
            local v = connectionExtracted[i]
            if v:match("database") then
                self.name = connectionString:sub(connectionString:find("/") + 1, -1):gsub("[%?]+[%w%p]*$", "")
                self.found = true
                break
            end
        end
    end
end

MySQL.ready(function()
    local length = 42 + #Server.prefix
    local DB_COLUMNS = MySQL.query.await(('SELECT TABLE_NAME, COLUMN_NAME, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = "%s" AND DATA_TYPE = "varchar" AND COLUMN_NAME IN (?)'):format(Database.name, length), {
        { "identifier", "owner" },
    })

    if DB_COLUMNS then
        local columns = {}
        local count = 0

        for i = 1, #DB_COLUMNS do
            local column = DB_COLUMNS[i]
            Database.tables[column.TABLE_NAME] = column.COLUMN_NAME

            if column?.CHARACTER_MAXIMUM_LENGTH < length then
                count = count + 1
                columns[column.TABLE_NAME] = column.COLUMN_NAME
            end
        end

        if next(columns) then
            local query = "ALTER TABLE `%s` MODIFY COLUMN `%s` VARCHAR(%s)"
            local queries = table.create(count, 0)

            for k, v in pairs(columns) do
                queries[#queries + 1] = { query = query:format(k, v, length) }
            end

            if MySQL.transaction.await(queries) then
                print(("[^2INFO^7] Updated ^5%s^7 columns to use ^5VARCHAR(%s)^7"):format(count, length))
            else
                print(("[^2INFO^7] Unable to update ^5%s^7 columns to use ^5VARCHAR(%s)^7"):format(count, length))
            end
        end

        Database.connected = true

        while not next(ESX.Jobs) do
            Wait(500)
            ESX.Jobs = ESX.GetJobs()
        end
    end
end)

function Database:DeleteCharacter(source, charid)
    local identifier = ("%s%s:%s"):format(Server.prefix, charid, Server:GetIdentifier(source))
    local query = "DELETE FROM `%s` WHERE %s = ?"
    local queries = {}
    local count = 0

    for table, column in pairs(self.tables) do
        count = count + 1
        queries[count] = { query = query:format(table, column), values = { identifier } }
    end

    MySQL.transaction(queries, function(result)
        if result then
            local name = GetPlayerName(source)
            print(("[^2INFO^7] Player ^5%s %s^7 has deleted a character ^5(%s)^7"):format(name, source, identifier))
            Wait(50)
            Multicharacter:SetupCharacters(source)
        else
            error("\n^1Transaction failed while trying to delete " .. identifier .. "^0")
        end
    end)
end

function Database:GetPlayerSlots(identifier)
    return MySQL.scalar.await("SELECT slots FROM multicharacter_slots WHERE identifier = ?", { identifier }) or
        Server.slots
end

function Database:GetPlayerInfo(identifier, slots)
    return MySQL.query.await(
        "SELECT identifier, accounts, job, job_grade, firstname, lastname, dateofbirth, sex, skin, disabled FROM users WHERE identifier LIKE ? LIMIT ?",
        { identifier, slots })
end

function Database:SetSlots(identifier, slots)
    MySQL.insert("INSERT INTO `multicharacter_slots` (`identifier`, `slots`) VALUES (?, ?) ON DUPLICATE KEY UPDATE `slots` = VALUES(`slots`)", {
        identifier,
        slots,
    })
end

function Database:RemoveSlots(identifier)
    local slots = MySQL.scalar.await("SELECT `slots` FROM `multicharacter_slots` WHERE identifier = ?", {
        identifier,
    })

    if slots then
        MySQL.update("DELETE FROM `multicharacter_slots` WHERE `identifier` = ?", {
            identifier,
        })
        return true
    end
    return false
end

function Database:EnableSlot(identifier, slot)
    local selectedCharacter = ("char%s:%s"):format(slot, identifier)

    local updated = MySQL.update.await("UPDATE `users` SET `disabled` = 0 WHERE identifier = ?", {selectedCharacter})
    return updated > 0
end

function Database:DisableSlot(identifier, slot)
    local selectedCharacter = ("char%s:%s"):format(slot, identifier)

    local updated = MySQL.update.await("UPDATE `users` SET `disabled` = 1 WHERE identifier = ?", {selectedCharacter})
    return updated > 0
end

Database:GetConnection()