ESX = exports['es_extended']:getSharedObject()
if ESX.GetConfig().Multichar then
	local IdentifierTables = {}

	function GetTables()
		Citizen.CreateThread(function()
			MySQL.ready(function ()
				MySQL.Async.fetchAll('SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = @id AND TABLE_SCHEMA = @db', { ['@id'] = "owner", ["@db"] = Config.databaseName}, function(result)
					if result then
						for k, v in pairs(result) do
							table.insert( IdentifierTables, {table = v.TABLE_NAME, column = "owner"})
						end
					end
				end)
				MySQL.Async.fetchAll('SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = @id AND TABLE_SCHEMA = @db', { ['@id'] = "identifier", ["@db"] = Config.databaseName}, function(result)
					if result then
						for k, v in pairs(result) do
							table.insert( IdentifierTables, {table = v.TABLE_NAME, column = "identifier"})
						end
					end
				end)
			end)
			Citizen.Wait(500)
			ESX.Jobs = exports['es_extended']:getSharedObject().Jobs
		end)
	end

	GetTables()

	RegisterServerEvent("esx_multicharacter:SetupCharacters")
	AddEventHandler('esx_multicharacter:SetupCharacters', function()
		local playerId = source
		local identifier = 'char%:'..ESX.GetIdentifier(playerId)
		MySQL.Async.fetchAll("SELECT `identifier`, `accounts`, `job`, `job_grade`, `firstname`, `lastname`, `dateofbirth`, `sex` FROM `users` WHERE `identifier` LIKE @identifier", {
			['@identifier'] = identifier
		}, function(result)
			local characters = {}
			for i=1, #result, 1 do
				local job = ESX.Jobs[result[i].job]
				local grade = ESX.Jobs[job.name].grades[tostring(result[i].job_grade)].label
				local accounts = json.decode(result[i].accounts)
				if grade == 'Unemployed' then grade = '' end
				characters[i] = {
					bank = accounts.bank,
					money = accounts.money,
					job = job.label,
					job_grade = grade,
					firstname = result[i].firstname,
					lastname = result[i].lastname,
					dateofbirth = result[i].dateofbirth,
					identifier = result[i].identifier
				}
				if result[i].sex == 'm' then characters[i].sex = 'Male' else characters[i].sex = 'Female' end
			end
			TriggerClientEvent('esx_multicharacter:SetupUI', playerId, characters)
		end)
	end)

	RegisterServerEvent("esx_multicharacter:CharacterChosen")
	AddEventHandler('esx_multicharacter:CharacterChosen', function(charid, ischar)
		local src = source
		local isNew = true
		if ischar then isNew = false end
		local spawn = {}
		if type(charid) == "number" and string.len(charid) == 1 and type(ischar) == "boolean" then
			TriggerEvent('esx:onPlayerJoined', src, charid, isNew)
		else
			-- Trigger Ban Event here to ban individuals trying to use SQL Injections
		end
	end)

	RegisterServerEvent("esx_multicharacter:DeleteCharacter")
	AddEventHandler('esx_multicharacter:DeleteCharacter', function(charid)
		local src = source
		if type(charid) == "number" and string.len(charid) == 1 then
			DeleteCharacter(src, charid)
			TriggerClientEvent("esx_multicharacter:ReloadCharacters", src)
		else
			-- Trigger Ban Event here to ban individuals trying to use SQL Injections
		end
	end)

	function DeleteCharacter(playerId, charid)
		local identifier = 'char'..charid..':'..ESX.GetIdentifier(playerId)
		for _, itable in pairs(IdentifierTables) do
			MySQL.Async.fetchAll("DELETE FROM @table WHERE @column = @identifier", {
				['@table'] = itable.table,
				['@column'] = itable.column,
				['@identifier'] = identifier
			})
		end
	end
end

RegisterCommand('relog', function(source, args, rawCommand)
	TriggerEvent('esx:playerLogout', source)
end, true)
