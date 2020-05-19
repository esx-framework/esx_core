---------------------------------------------------------------------------------------
-- Edit this table to all the database tables and columns
-- where identifiers are used (such as users, owned_vehicles, owned_properties etc.)
---------------------------------------------------------------------------------------

local IdentifierTables = {
    {table = "addon_account_data", column = "owner"},
    {table = "addon_inventory_items", column = "owner"},
    {table = "billing", column = "identifier"},
    {table = "datastore_data", column = "owner"},
    {table = "owned_vehicles", column = "owner"},
    {table = "owned_properties", column = "owner"},
    {table = "rented_vehicles", column = "owner"},
    {table = "users", column = "identifier"},
    {table = "user_licenses", column = "owner"}
}

RegisterServerEvent("kashactersS:SetupCharacters")
AddEventHandler('kashactersS:SetupCharacters', function()
    local src = source
    local LastCharId = GetLastCharacter(src)

    SetIdentifierToChar(GetRockstarID(src), LastCharId)
    local Characters = GetPlayerCharacters(src)
    TriggerClientEvent('kashactersC:SetupUI', src, Characters)
end)

RegisterServerEvent("kashactersS:CharacterChosen")
AddEventHandler('kashactersS:CharacterChosen', function(charid, ischar)
    local src = source
    local new = true
    local spawn = {}
    if type(charid) == "number" and string.len(charid) == 1 and type(ischar) == "boolean" then
        SetLastCharacter(src, tonumber(charid))
        SetCharToIdentifier(GetRockstarID(src), tonumber(charid))
    
        if ischar == true then
            new = false
            spawn = GetSpawnPos(src)
        else
            TriggerClientEvent('skinchanger:loadDefaultModel', src, true, cb)
            spawn = { x = 195.55, y = -933.36, z = 29.90 } -- DEFAULT SPAWN POSITION
        end

        TriggerClientEvent("kashactersC:SpawnCharacter", src, spawn, new)
    else
        -- Trigger Ban Event here to ban individuals trying to use SQL Injections
    end
end)

RegisterServerEvent("kashactersS:DeleteCharacter")
AddEventHandler('kashactersS:DeleteCharacter', function(charid)
    local src = source
    if type(charid) == "number" and string.len(charid) == 1 then
        DeleteCharacter(GetRockstarID(src), charid)
        TriggerClientEvent("kashactersC:ReloadCharacters", src)
    else
        -- Trigger Ban Event here to ban individuals trying to use SQL Injections
    end
end)

function GetPlayerCharacters(source)
    local Chars = MySQLAsyncExecute("SELECT * FROM `users` WHERE identifier LIKE '%"..GetIdentifierWithoutLicense(GetRockstarID(source)).."%'")
    for i = 1, #Chars, 1 do
        charJob = MySQLAsyncExecute("SELECT * FROM `jobs` WHERE `name` = '"..Chars[i].job.."'")
        charJobgrade = MySQLAsyncExecute("SELECT * FROM `job_grades` WHERE `grade` = '"..Chars[i].job_grade.."' AND `job_name` = '"..Chars[i].job.."'")
        local accounts = json.decode(Chars[i].accounts)
        Chars[i].bank = accounts["bank"]
        Chars[i].money = accounts["money"]
        Chars[i].job = charJob[1].label
        if charJob[1].label == "Unemployed" then
            Chars[i].job_grade = ""
        else
            Chars[i].job_grade = charJobgrade[1].label	
        end
        if Chars[i].sex == "m" then
            Chars[i].sex = "Male"
        else
            Chars[i].sex = "Female"	
        end
    end
    return Chars
end

function GetLastCharacter(source)
    local LastChar = MySQLAsyncExecute("SELECT `charid` FROM `user_lastcharacter` WHERE `license` = '"..GetRockstarID(source).."'")

    if LastChar[1] ~= nil and LastChar[1].charid ~= nil then
        return tonumber(LastChar[1].charid)
    else
        MySQLAsyncExecute("INSERT INTO `user_lastcharacter` (`license`, `charid`) VALUES('"..GetRockstarID(source).."', 1)")
        return 1
    end
end

function SetLastCharacter(source, charid)
    MySQLAsyncExecute("UPDATE `user_lastcharacter` SET `charid` = '"..charid.."' WHERE `license` = '"..GetRockstarID(source).."'")
end

function SetIdentifierToChar(identifier, charid)
    for _, itable in pairs(IdentifierTables) do
        MySQLAsyncExecute("UPDATE `"..itable.table.."` SET `"..itable.column.."` = 'Char"..charid..GetIdentifierWithoutLicense(identifier).."' WHERE `"..itable.column.."` = '"..identifier.."'")
    end
end

function SetCharToIdentifier(identifier, charid)
    for _, itable in pairs(IdentifierTables) do
        MySQLAsyncExecute("UPDATE `"..itable.table.."` SET `"..itable.column.."` = '"..identifier.."' WHERE `"..itable.column.."` = 'Char"..charid..GetIdentifierWithoutLicense(identifier).."'")
    end
end

function DeleteCharacter(identifier, charid)
    for _, itable in pairs(IdentifierTables) do
        MySQLAsyncExecute("DELETE FROM `"..itable.table.."` WHERE `"..itable.column.."` = 'Char"..charid..GetIdentifierWithoutLicense(identifier).."'")
    end
end

function GetSpawnPos(source)
    local spawn = MySQLAsyncExecute("SELECT `position` FROM `users` WHERE `identifier` = '"..GetRockstarID(source).."'")
    return json.decode(spawn[1].position)
end

function GetIdentifierWithoutLicense(Identifier)
    return string.gsub(Identifier, "license", "")
end

function GetRockstarID(playerId)
    local identifier

    for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
        if string.match(v, 'license') then
            identifier = v
            break
        end
    end

    return identifier
end

function MySQLAsyncExecute(query)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchAll(query, {}, function(data)
        result = data
        IsBusy = false
    end)
    while IsBusy do
        Citizen.Wait(0)
    end
    return result
end
