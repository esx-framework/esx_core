if not ESX then
	error('\n^1Unable to start Multicharacter - you must be using ESX Legacy^0')
elseif ESX.GetConfig().Multichar == true then
	local DATABASE do
		local connectionString = GetConvar('mysql_connection_string', '');
		if connectionString == '' then
			error(connectionString..'\n^1Unable to start Multicharacter - unable to determine database from mysql_connection_string^0', 0)
		elseif connectionString:find('mysql://') then
			connectionString = connectionString:sub(9, -1)
			DATABASE = connectionString:sub(connectionString:find('/')+1, -1):gsub('[%?]+[%w%p]*$', '')
		else
			connectionString = {string.strsplit(';', connectionString)}
			for i=1, #connectionString do
				local v = connectionString[i]
				if v:match('database') then
					DATABASE = v:sub(10, #v)
				end
			end
		end
	end

	local DB_TABLES = {}
	local FETCH = nil
	local SLOTS = Config.Slots or 4
	local PREFIX = Config.Prefix or 'char'
	local PRIMARY_IDENTIFIER = ESX.GetConfig().Identifier or GetConvar('sv_lan', '') == 'true' and 'ip' or Config.Identifier

	local function GetIdentifier(source)
		local identifier = PRIMARY_IDENTIFIER..':'
		for _, v in pairs(GetPlayerIdentifiers(source)) do
			if string.match(v, identifier) then
				identifier = string.gsub(v, identifier, '')
				return identifier
			end
		end
	end

	if next(ESX.Players) then
		local players = table.clone(ESX.Players)
		table.wipe(ESX.Players)
		for _, v in pairs(players) do
			ESX.Players[GetIdentifier(v.source)] = true
		end
	else ESX.Players = {} end

	local function SetupCharacters(source)
		while not FETCH do Citizen.Wait(100) end
		local identifier = GetIdentifier(source)
		ESX.Players[identifier] = true

		local slots = MySQL.Sync.fetchScalar("SELECT slots FROM multicharacter_slots WHERE identifier = ?", {
			identifier
		}) or SLOTS
		identifier = PREFIX..'%:'..identifier

		MySQL.Async.fetchAll(FETCH, {identifier, slots}, function(result)
			local characters
			if result then
				local characterCount = #result
				characters = table.create(0, characterCount)
				for i=1, characterCount, 1 do
					local i = result[i]
					local job, grade = i.job or 'unemployed', tostring(i.job_grade)
					if ESX.Jobs[job] and ESX.Jobs[job].grades[grade] then
						if job ~= 'unemployed' then grade = ESX.Jobs[job].grades[grade].label else grade = '' end
						job = ESX.Jobs[job].label
					end
					local accounts = json.decode(i.accounts)
					local id = tonumber(string.sub(i.identifier, #PREFIX+1, string.find(i.identifier, ':')-1))
					characters[id] = {
						id = id,
						bank = accounts.bank,
						money = accounts.money,
						job = job,
						job_grade = grade,
						firstname = i.firstname,
						lastname = i.lastname,
						dateofbirth = i.dateofbirth,
						skin = json.decode(i.skin),
						disabled = i.disabled,
						sex = i.sex == 'm' and _('male') or _('female')
					}
				end
			end
			TriggerClientEvent('esx_multicharacter:SetupUI', source, characters, slots)
		end)
	end

	AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
		deferrals.defer()
		local identifier = GetIdentifier(source)
		Citizen.Wait(100)
		if identifier then
			if ESX.Players[identifier] then
				deferrals.done(('A player is already connected to the server with this identifier.\nYour identifier: %s:%s'):format(PRIMARY_IDENTIFIER, identifier))
			else
				deferrals.done()
			end
		else
			deferrals.done(('Unable to retrieve player identifier.\nIdentifier type: %s'):format(PRIMARY_IDENTIFIER))
		end
	end)

	local function DeleteCharacter(source, charid)
		local identifier = ('%s%s:%s'):format(PREFIX, charid, GetIdentifier(source))
		local query = "DELETE FROM ?? WHERE ?? = ?"
		local tableCount = #DB_TABLES
		local queries = table.create(tableCount, 0)

		for i=1, tableCount do
			local v = DB_TABLES[i]
			queries[i] = {query = query, values = {v.table, v.column, identifier}}
		end

		MySQL.Async.transaction(queries, function(result)
			if result then
				print(('[^2INFO^7] Player [%s] %s has deleted a character (%s)'):format(GetPlayerName(source), source, identifier))
				Citizen.Wait(50)
				SetupCharacters(source)
			else
				error('\n^1Transaction failed while trying to delete '..identifier..'^0')
			end
		end)
	end

	MySQL.ready(function()
		MySQL.Async.fetchAll('SELECT TABLE_NAME, COLUMN_NAME, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = ? AND (COLUMN_NAME = ? OR COLUMN_NAME = ?) ', {
			DATABASE, 'identifier', 'owner'
		}, function(result)
			if result then
				local varchar, varsize = {}, 0
				for k, v in pairs(result) do
					if v.CHARACTER_MAXIMUM_LENGTH and v.CHARACTER_MAXIMUM_LENGTH >= 40 and v.CHARACTER_MAXIMUM_LENGTH < 60 then varchar[v.TABLE_NAME] = v.COLUMN_NAME varsize = varsize+1 end
					table.insert(DB_TABLES, {table = v.TABLE_NAME, column = v.COLUMN_NAME})
				end
				if next(varchar) then
					local query = "ALTER TABLE ?? MODIFY COLUMN ?? VARCHAR(60)"
					local queries = table.create(varsize, 0)

					for k, v in pairs(varchar) do
						queries[#queries+1] = {query = query, values = {k, v}}
					end

					MySQL.Async.transaction(queries, function(result)
						if result then
							print(('[^2INFO^7] Updated ^5%s^7 columns to use VARCHAR(60)'):format(varsize))
						else
							print(('[^2INFO^7] Unable to update ^5%s^7 columns to use VARCHAR(60)'):format(varsize))
						end
					end)
				end
				ESX.Jobs = {}
				local function GetJobs()
					if ESX.GetJobs then return ESX.GetJobs()
					else return exports['es_extended']:getSharedObject().Jobs end
				end
				repeat
					ESX.Jobs = GetJobs()
					Citizen.Wait(50)
				until next(ESX.Jobs)
				FETCH = MySQL.Sync.store("SELECT identifier, accounts, job, job_grade, firstname, lastname, dateofbirth, sex, skin, disabled FROM users WHERE identifier LIKE ? LIMIT ?")
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
		if type(charid) == 'number' and string.len(charid) <= 2 and type(isNew) == 'boolean' then
			if isNew then
				awaitingRegistration[source] = charid
			else
				TriggerEvent('esx:onPlayerJoined', source, PREFIX..charid)
				ESX.Players[GetIdentifier(source)] = true
			end
		end
	end)

	AddEventHandler('esx_identity:completedRegistration', function(source, data)
		TriggerEvent('esx:onPlayerJoined', source, PREFIX..awaitingRegistration[source], data)
		awaitingRegistration[source] = nil
		ESX.Players[GetIdentifier(source)] = true
	end)

	AddEventHandler('playerDropped', function(reason)
		awaitingRegistration[source] = nil
		ESX.Players[GetIdentifier(source)] = nil
	end)

	RegisterServerEvent("esx_multicharacter:DeleteCharacter")
	AddEventHandler('esx_multicharacter:DeleteCharacter', function(charid)
		if type(charid) == "number" and string.len(charid) <= 2 then
			DeleteCharacter(source, charid)
		end
	end)

	RegisterServerEvent("esx_multicharacter:relog")
	AddEventHandler('esx_multicharacter:relog', function()
		TriggerEvent('esx:playerLogout', source)
	end)

else
	assert(nil, '^3WARNING: Multicharacter is disabled - please check your ESX configuration^0')
end
