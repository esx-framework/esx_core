local function DATABASE()
	local connectionString = GetConvar('mysql_connection_string', '');
	if connectionString == '' then
		error(connectionString..'\n^1Unable to start Multicharacter - unable to determine database from mysql_connection_string^0', 0)
	elseif connectionString:find('mysql://') then
		if connectionString:find('?*$') then
			return connectionString:match('[^/][%w]*[?$]'):sub(0, -2)
		else
			return connectionString:match('[^/][%w]*$')
		end
	else
		connectionString = {string.strsplit(';', connectionString)}
		for i=1, #connectionString do
			local v = connectionString[i]
			if v:match('database') then
				return v:sub(10, #v)
			end
		end
	end
end

if not ESX then
	error('\n^1WARNING: Unable to start Multicharacter - you must be using ESX Legacy^0')
elseif ESX.GetConfig().Multichar == true then
	DATABASE = DATABASE()
	local DB_TABLES = {}
	local FETCH = nil
	local PREFIX = 'char'
	-- enter a prefix to prepend to all user identifiers (keep it short)
	-- if you modify this, you will need to modify es_extended due to an oversight!
	-- https://github.com/esx-framework/esx-legacy/blob/main/%5Besx%5D/es_extended/server/classes/player.lua#L17
	-- if Config.Multichar then self.license = 'license'..identifier:sub(identifier:find(':')) else self.license = 'license:'..identifier end

	local function GetIdentifier(playerId)
		local identifier = 'license:'
		for _, v in pairs(GetPlayerIdentifiers(playerId)) do
			if string.match(v, identifier) then
				identifier = string.gsub(v, identifier, '')
				return identifier
			end
		end
	end

	if next(ESX.Players) then
		for k, v in pairs(ESX.Players) do
			ESX.Players[k] = GetIdentifier(v.source)
		end
	else ESX.Players = {} end

	local function SetupCharacters(playerId)
		repeat Citizen.Wait(200) until FETCH
		local identifier = GetIdentifier(playerId)
		local slots = MySQL.Sync.fetchScalar("SELECT slots FROM multicharacter_slots WHERE identifier = ?", {
			identifier
		}) or Config.Slots

		identifier = PREFIX..'%:'..identifier

		MySQL.Async.fetchAll(FETCH, {identifier, slots}, function(result)
			local characters = {}
			for i=1, #result, 1 do
				local job, grade = result[i].job or 'unemployed', tostring(result[i].job_grade)
				if ESX.Jobs[job] and ESX.Jobs[job].grades[grade] then
					if job ~= 'unemployed' then grade = ESX.Jobs[job].grades[grade].label else grade = '' end
					job = ESX.Jobs[job].label
				end
				local accounts = json.decode(result[i].accounts)
				local id = tonumber(string.sub(result[i].identifier, #PREFIX+1, string.find(result[i].identifier, ':')-1))
				characters[id] = {
					id = id,
					bank = accounts.bank,
					money = accounts.money,
					job = job,
					job_grade = grade,
					firstname = result[i].firstname,
					lastname = result[i].lastname,
					dateofbirth = result[i].dateofbirth,
					skin = json.decode(result[i].skin),
					disabled = result[i].disabled,
				}
				if result[i].sex == 'm' then characters[id].sex = _('male') else characters[id].sex = _('female') end
			end
			TriggerClientEvent('esx_multicharacter:SetupUI', playerId, characters, slots)
		end)
	end

	AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
		deferrals.defer()
		local identifier = GetIdentifier(source)
		Citizen.Wait(100)
		if ESX.Players[identifier] then
			deferrals.done('A player is already connected to the server with this identifier.')
		else
			ESX.Players[identifier] = true
			deferrals.done()
		end
	end)

	local function DeleteCharacter(playerId, charid)
		local identifier = GetIdentifier(playerId)
		local character = ('%s%s:%s'):format(PREFIX, charid, identifier)
		local counter = 0
		for _, v in pairs(DB_TABLES) do
			MySQL.Async.execute("DELETE FROM "..v.table.." WHERE "..v.column.." = ?", {
				character
			}, function()
				counter = counter + 1
				if counter == #DB_TABLES then
					print(('[^2INFO^7] Player [%s] %s has deleted a character (%s)'):format(GetPlayerName(playerId), playerId, character))
					Citizen.Wait(100)
					SetupCharacters(playerId)
				end
			end)
			Citizen.Wait(5)
		end
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
					for k, v in pairs(varchar) do
						MySQL.Sync.execute("ALTER TABLE "..k.." MODIFY COLUMN "..v.." VARCHAR(60)")
					end
					print(('[^2INFO^7] Attempted to update ^5%s^7 columns to use VARCHAR(60)'):format(varsize))
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
				ESX.Players[GetIdentifier(source)] = source
			end
		end
	end)

	AddEventHandler('esx_identity:completedRegistration', function(playerId, data)
		TriggerEvent('esx:onPlayerJoined', playerId, PREFIX..awaitingRegistration[playerId], data)
		awaitingRegistration[playerId] = nil
		ESX.Players[GetIdentifier(source)] = playerId
	end)

	AddEventHandler('playerDropped', function(reason)
		awaitingRegistration[source] = nil
		ESX.Players[GetIdentifier(source)] = nil
	end)

	RegisterServerEvent("esx_multicharacter:DeleteCharacter")
	AddEventHandler('esx_multicharacter:DeleteCharacter', function(charid)
		local src = source
		if type(charid) == "number" and string.len(charid) <= 2 then
			DeleteCharacter(src, charid)
		end
	end)

	RegisterServerEvent("esx_multicharacter:relog")
	AddEventHandler('esx_multicharacter:relog', function()
		local src = source
		TriggerEvent('esx:playerLogout', src)
	end)

else
	assert(nil, '^3WARNING: Multicharacter is disabled - please check your ESX configuration^0')
end
