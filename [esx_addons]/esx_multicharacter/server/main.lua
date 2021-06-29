if not ESX then
	SetTimeout(3000, print('[^3WARNING^7] Unable to start Multicharacter - your version of ESX is not compatible '))
elseif ESX.GetConfig().Multichar == true then
	local IdentifierTables, Fetch = {}, -1

	-- enter the name of your database here
	Config.Database = 'es_extended'

	-- enter a prefix to prepend to all user identifiers (keep it short)
	Config.Prefix = 'char'

	local SetupCharacters = function(playerId)
		while Fetch == -1 do Citizen.Wait(500) end
		local identifier = Config.Prefix..'%:'..ESX.GetIdentifier(playerId)
		MySQL.Async.fetchAll(Fetch, {
			identifier,
			Config.Slots
		}, function(result)
			local characters = {}
			for i=1, #result, 1 do
				local job, grade = result[i].job or 'unemployed', tostring(result[i].job_grade)
				if ESX.Jobs[job] and ESX.Jobs[job].grades[grade] then
					if job ~= 'unemployed' then grade = ESX.Jobs[job].grades[grade].label else grade = '' end
					job = ESX.Jobs[job].label
				end
				local accounts = json.decode(result[i].accounts)
				local id = tonumber(string.sub(result[i].identifier, #Config.Prefix+1, string.find(result[i].identifier, ':')-1))
				characters[id] = {
					id = id,
					bank = accounts.bank,
					money = accounts.money,
					job = job,
					job_grade = grade,
					firstname = result[i].firstname,
					lastname = result[i].lastname,
					dateofbirth = result[i].dateofbirth,
					skin = json.decode(result[i].skin)
				}
				if result[i].sex == 'm' then characters[id].sex = _('male') else characters[id].sex = _('female') end
			end
			TriggerClientEvent('esx_multicharacter:SetupUI', playerId, characters)
		end)
	end

	local DeleteCharacter = function(playerId, charid)
		local identifier = Config.Prefix..charid..':'..ESX.GetIdentifier(playerId)
		for k, v in pairs(IdentifierTables) do
			MySQL.Async.execute("DELETE FROM "..v.table.." WHERE "..v.column.." = ?", {
				identifier
			})
		end
		print(('[^2INFO^7] Player [%s] %s has deleted a character (%s)'):format(GetPlayerName(playerId), playerId, identifier))
	end

	MySQL.ready(function()
		MySQL.Async.fetchAll('SELECT `TABLE_NAME`, `COLUMN_NAME`, `CHARACTER_MAXIMUM_LENGTH` FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = ? AND (COLUMN_NAME = ? OR COLUMN_NAME = ?) ', {
			Config.Database, 'identifier', 'owner'
		}, function(result)
			if result then
				local varchar, varsize = {}, 0
				for k, v in pairs(result) do
					if v.CHARACTER_MAXIMUM_LENGTH and v.CHARACTER_MAXIMUM_LENGTH >= 40 and v.CHARACTER_MAXIMUM_LENGTH < 60 then varchar[v.TABLE_NAME] = v.COLUMN_NAME varsize = varsize+1 end
					table.insert(IdentifierTables, {table = v.TABLE_NAME, column = v.COLUMN_NAME})
				end
				if next(varchar) then
					for k, v in pairs(varchar) do
						MySQL.Sync.execute("ALTER TABLE "..k.." MODIFY COLUMN "..v.." VARCHAR(60)")
					end
					print(('[^2INFO^7] Attempted to update ^5%s^7 columns to use VARCHAR(60)'):format(varsize))
				end
				if not next(ESX.Jobs) then ESX.Jobs = GetJobs() end
				Fetch = MySQL.Sync.store("SELECT `identifier`, `accounts`, `job`, `job_grade`, `firstname`, `lastname`, `dateofbirth`, `sex`, `skin` FROM `users` WHERE identifier LIKE ? LIMIT ?")
			end
		end)
	end)

	RegisterServerEvent("esx_multicharacter:SetupCharacters")
	AddEventHandler('esx_multicharacter:SetupCharacters', function()
		SetupCharacters(source)
	end)

	local awaitingRegistration = {}
	RegisterServerEvent("esx_multicharacter:CharacterChosen")
	AddEventHandler('esx_multicharacter:CharacterChosen', function(charid, isNew)
		local src = source
		if type(charid) == 'number' and string.len(charid) <= 2 and type(isNew) == 'boolean' then
			if isNew then
				awaitingRegistration[src] = charid
			else
				TriggerEvent('esx:onPlayerJoined', src, Config.Prefix..charid)
			end
		end
	end)

	AddEventHandler('esx_identity:completedRegistration', function(playerId, data)
		TriggerEvent('esx:onPlayerJoined', playerId, Config.Prefix..awaitingRegistration[playerId], data)
		awaitingRegistration[playerId] = nil
	end)

	AddEventHandler('playerDropped', function(reason)
		awaitingRegistration[source] = nil
	end)

	RegisterServerEvent("esx_multicharacter:DeleteCharacter")
	AddEventHandler('esx_multicharacter:DeleteCharacter', function(charid)
		local src = source
		if type(charid) == "number" and string.len(charid) <= 2 then
			DeleteCharacter(src, charid)
			SetupCharacters(src)
		end
	end)

	RegisterServerEvent("esx_multicharacter:relog")
	AddEventHandler('esx_multicharacter:relog', function()
		local src = source
		TriggerEvent('esx:playerLogout', src)
	end)

	RegisterCommand('forcelog', function(source, args, rawCommand)
		TriggerEvent('esx:playerLogout', source)
	end, true)

else
	SetTimeout(3000, print('[^3WARNING^7] Multicharacter is disabled - please check your ESX configuration'))
end
