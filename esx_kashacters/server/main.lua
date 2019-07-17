---------------------------------------------------------------------------------------
-- Edit this table to all the database tables and columns
-- where identifiers are used (such as users, owned_vehicles, owned_properties etc.)
---------------------------------------------------------------------------------------
local IdentifierTables = {
    {table = "users", column = "identifier"},
    {table = "user_accounts", column = "identifier"},
   -- {table = "user_contacts", column = "identifier"},
    {table = "user_inventory", column = "identifier"},
   -- {table = "user_parkings", column = "identifier"},
    {table = "society_moneywash", column = "identifier"},
    {table = "phone_users_contacts", column = "identifier"},
    --{table = "jail", column = "identifier"},
    {table = "characters", column = "identifier"},
    {table = "billing", column = "identifier"},
    {table = "rented_vehicles", column = "owner"},
    {table = "addon_account_data", column = "owner"},
    {table = "addon_inventory_items", column = "owner"},
    {table = "datastore_data", column = "owner"}, 
    {table = "owned_vehicles", column = "owner"}, 
    {table = "phone_calls", column = "owner"}, 
    {table = "phone_messages", column = "owner"}, 
    {table = "rented_vehicles", column = "owner"}, 
    {table = "user_licenses", column = "owner"}, 
}

RegisterServerEvent("kashactersS:SetupCharacters")
AddEventHandler('kashactersS:SetupCharacters', function()
    local src = source
    local LastCharId = GetLastCharacter(src)
    SetIdentifierToChar(GetPlayerIdentifiers(src)[1], LastCharId)
    local Characters = GetPlayerCharacters(src)
    TriggerClientEvent('kashactersC:SetupUI', src, Characters)
end)

RegisterServerEvent("kashactersS:CharacterChosen")
AddEventHandler('kashactersS:CharacterChosen', function(charid, ischar)
    local src = source
    local spawn = {}
    SetLastCharacter(src, tonumber(charid))
    SetCharToIdentifier(GetPlayerIdentifiers(src)[1], tonumber(charid))
    if ischar == "true" then
        spawn = GetSpawnPos(src)
    else
		TriggerClientEvent('skinchanger:loadDefaultModel', src, true, cb)
        spawn = { x = 195.55, y = -933.36, z = 29.90 } -- DEFAULT SPAWN POSITION
    end
    TriggerClientEvent("kashactersC:SpawnCharacter", src, spawn)
end)

RegisterServerEvent("kashactersS:DeleteCharacter")
AddEventHandler('kashactersS:DeleteCharacter', function(charid)
    local src = source
    DeleteCharacter(GetPlayerIdentifiers(src)[1], charid)
    TriggerClientEvent("kashactersC:ReloadCharacters", src)
end)

function GetPlayerCharacters(source)
  local identifier = GetIdentifierWithoutSteam(GetPlayerIdentifiers(source)[1])
  local Chars = MySQLAsyncExecute("SELECT * FROM `users` WHERE identifier LIKE '%"..identifier.."%'")
  for i = 1, #Chars, 1 do
    charJob = MySQLAsyncExecute("SELECT * FROM `jobs` WHERE `name` = '"..Chars[i].job.."'")
    charJobgrade = MySQLAsyncExecute("SELECT * FROM `job_grades` WHERE `grade` = '"..Chars[i].job_grade.."'")
    Chars[i].job = charJob[1].label
    Chars[i].job_grade = charJobgrade[1].label
  end
  return Chars
end

function GetLastCharacter(source)
    local LastChar = MySQLAsyncExecute("SELECT `charid` FROM `user_lastcharacter` WHERE `steamid` = '"..GetPlayerIdentifiers(source)[1].."'")
    if LastChar[1] ~= nil and LastChar[1].charid ~= nil then
        return tonumber(LastChar[1].charid)
    else
        MySQLAsyncExecute("INSERT INTO `user_lastcharacter` (`steamid`, `charid`) VALUES('"..GetPlayerIdentifiers(source)[1].."', 1)")
        return 1
    end
end

function SetLastCharacter(source, charid)
    MySQLAsyncExecute("UPDATE `user_lastcharacter` SET `charid` = '"..charid.."' WHERE `steamid` = '"..GetPlayerIdentifiers(source)[1].."'")
end

function SetIdentifierToChar(identifier, charid)
    for _, itable in pairs(IdentifierTables) do
        MySQLAsyncExecute("UPDATE `"..itable.table.."` SET `"..itable.column.."` = 'Char"..charid..GetIdentifierWithoutSteam(identifier).."' WHERE `"..itable.column.."` = '"..identifier.."'")
    end
end

function SetCharToIdentifier(identifier, charid)
    for _, itable in pairs(IdentifierTables) do
        MySQLAsyncExecute("UPDATE `"..itable.table.."` SET `"..itable.column.."` = '"..identifier.."' WHERE `"..itable.column.."` = 'Char"..charid..GetIdentifierWithoutSteam(identifier).."'")
    end
end

function DeleteCharacter(identifier, charid)
    for _, itable in pairs(IdentifierTables) do
        MySQLAsyncExecute("DELETE FROM `"..itable.table.."` WHERE `"..itable.column.."` = 'Char"..charid..GetIdentifierWithoutSteam(identifier).."'")
    end
end

function GetSpawnPos(source)
    local SpawnPos = MySQLAsyncExecute("SELECT `position` FROM `users` WHERE `identifier` = '"..GetPlayerIdentifiers(source)[1].."'")
    return json.decode(SpawnPos[1].position)
end

function GetIdentifierWithoutSteam(Identifier)
    return string.gsub(Identifier, "steam", "")
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
