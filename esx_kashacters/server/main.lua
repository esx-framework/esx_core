---------------------------------------------------------------------------------------
-- Edit this table to all the database tables and columns
-- where identifiers are used (such as users, owned_vehicles, owned_properties etc.)
---------------------------------------------------------------------------------------

local IdentifierTables = {
    {table = "addon_account_data", column = "owner"},
    {table = "addon_inventory_items", column = "owner"},
    {table = "datastore_data", column = "owner"},
    {table = "owned_properties", column = "owner"},
    {table = "owned_vehicles", column = "owner"},
    {table = "phone_calls", column = "owner"},
    {table = "phone_messages", column = "owner"},
    {table = "private_vehicles", column = "owner"},
    {table = "rented_vehicles", column = "owner"},
	{table = "user_licenses", column = "owner"},
    {table = "billing", column = "identifier"},
    {table = "crimerecord", column = "identifier"},
    {table = "phone_users_contacts", column = "identifier"},
    {table = "society_moneywash", column = "identifier"},
    {table = "users", column = "identifier"},
	{table = "twitter_tweets", column = "realUser"}
}

RegisterServerEvent("kashactersS:SetupCharacters")
AddEventHandler('kashactersS:SetupCharacters', function()
    local src = source
    local LastCharId = GetLastCharacter(src)

    SetIdentifierToChar(GetPlayerIdentifiers(src)[2], LastCharId)
    local Characters = GetPlayerCharacters(src)
    TriggerClientEvent('kashactersC:SetupUI', src, Characters)
end)

RegisterServerEvent("kashactersS:CharacterChosen")
AddEventHandler('kashactersS:CharacterChosen', function(charid, ischar)
    local src = source
--    local spawn = {}
	local isnew = true
    SetLastCharacter(src, tonumber(charid))
    SetCharToIdentifier(GetPlayerIdentifiers(src)[2], tonumber(charid))
    if ischar == "true" then
		isnew = false
        --spawn = GetSpawnPos(src)
		--TriggerClientEvent("kashactersC:SpawnCharacter", src, spawn)
    else
		TriggerClientEvent('skinchanger:loadDefaultModel', src, true, cb)
		--TriggerEvent('esx_identity:showRegisterIdentity')
		--TriggerClientEvent("kashactersC:SpawnCharacter", src, spawn)
    end
    TriggerClientEvent("kashactersC:SpawnCharacter", src, isnew)
end)

RegisterServerEvent("kashactersS:DeleteCharacter")
AddEventHandler('kashactersS:DeleteCharacter', function(charid)
    local src = source
    DeleteCharacter(GetPlayerIdentifiers(src)[2], charid)
    TriggerClientEvent("kashactersC:ReloadCharacters", src)
end)

function GetPlayerCharacters(source)
  local identifier = GetIdentifierWithoutLicense(GetPlayerIdentifiers(source)[2])
  local Chars = MySQLAsyncExecute("SELECT * FROM `users` WHERE identifier LIKE '%"..identifier.."%'")
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
    local LastChar = MySQLAsyncExecute("SELECT `charid` FROM `user_lastcharacter` WHERE `license` = '"..GetPlayerIdentifiers(source)[2].."'")
    if LastChar[1] ~= nil and LastChar[1].charid ~= nil then
        return tonumber(LastChar[1].charid)
    else
        MySQLAsyncExecute("INSERT INTO `user_lastcharacter` (`license`, `charid`) VALUES('"..GetPlayerIdentifiers(source)[2].."', 1)")
        return 1
    end
end

function SetLastCharacter(source, charid)
    MySQLAsyncExecute("UPDATE `user_lastcharacter` SET `charid` = '"..charid.."' WHERE `license` = '"..GetPlayerIdentifiers(source)[2].."'")
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

--function GetSpawnPos(source)
--    local SpawnPos = MySQLAsyncExecute("SELECT `position` FROM `users` WHERE `identifier` = '"..GetPlayerIdentifiers(source)[2].."'")
--    return json.decode(SpawnPos[1].position)
--end

function GetIdentifierWithoutLicense(Identifier)
    return string.gsub(Identifier, "license", "")
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
