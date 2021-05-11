if ESX.GetConfig().Kashacters then
	local IdentifierTables = {}

	function GetTables()
		MySQL.ready(function ()
			MySQL.Async.fetchAll('SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = @id AND TABLE_SCHEMA = @db', { ['@id'] = "owner", ["@db"] = Config.databaseName}, function(result)
				if result then
				--print(json.encode(result))
					for k, v in pairs(result) do
						table.insert( IdentifierTables, {table = v.TABLE_NAME, column = "owner"})
					end
				end
			end)
			MySQL.Async.fetchAll('SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = @id AND TABLE_SCHEMA = @db', { ['@id'] = "identifier", ["@db"] = Config.databaseName}, function(result)
				if result then
					--print(json.encode(result))
					for k, v in pairs(result) do
						table.insert( IdentifierTables, {table = v.TABLE_NAME, column = "identifier"})
					end
				end
			end)
		end)
	end

	GetTables()

	RegisterServerEvent("kashactersS:SetupCharacters")
	AddEventHandler('kashactersS:SetupCharacters', function()
		local src = source
		local Characters = GetPlayerCharacters(src)
		TriggerClientEvent('kashactersC:SetupUI', src, Characters)
	end)

	RegisterServerEvent("kashactersS:CharacterChosen")
	AddEventHandler('kashactersS:CharacterChosen', function(charid, ischar)
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

	RegisterServerEvent("kashactersS:DeleteCharacter")
	AddEventHandler('kashactersS:DeleteCharacter', function(charid)
		local src = source
		if type(charid) == "number" and string.len(charid) == 1 then
			DeleteCharacter(ESX.GetIdentifier(src), charid)
			TriggerClientEvent("kashactersC:ReloadCharacters", src)
		else
			-- Trigger Ban Event here to ban individuals trying to use SQL Injections
		end
	end)

	function GetPlayerCharacters(source)
		local Chars = MySQLAsyncExecute("SELECT * FROM `users` WHERE `identifier` LIKE 'char%:"..ESX.GetIdentifier(source).."'")
		for i = 1, #Chars, 1 do
			local charJob = ESX.Jobs[Chars[i].job]
			local charGrade = charJob.grades[tostring(Chars[i].job_grade)]
			local accounts = json.decode(Chars[i].accounts)
			Chars[i].bank = accounts["bank"]
			Chars[i].money = accounts["money"]
			Chars[i].job = charJob.label
			if charJob.label == "Unemployed" then
				Chars[i].job_grade = ""
			else
				Chars[i].job_grade = charGrade.label
			end
			if Chars[i].sex == "m" then
				Chars[i].sex = "Male"
			else
				Chars[i].sex = "Female"	
			end
		end
		return Chars
	end

	function DeleteCharacter(identifier, charid)
		local identifier = 'char'..charid..':'..identifier
		for _, itable in pairs(IdentifierTables) do
			MySQLAsyncExecute("DELETE FROM `"..itable.table.."` WHERE `"..itable.column.."` = '"..identifier.."'")
		end
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
end
