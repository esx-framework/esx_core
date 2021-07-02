local playerIdentity = {}
local alreadyRegistered = {}
local multichar = ESX.GetConfig().Multichar

if Config.UseDeferrals then
	AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
		deferrals.defer()
		local playerId, identifier = source, ESX.GetIdentifier(source)
		Citizen.Wait(100)
	
		if identifier then
			MySQL.Async.fetchAll('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = @identifier', {
				['@identifier'] = identifier
			}, function(result)
				if result[1] then
					if result[1].firstname then
						playerIdentity[identifier] = {
							firstName = result[1].firstname,
							lastName = result[1].lastname,
							dateOfBirth = result[1].dateofbirth,
							sex = result[1].sex,
							height = result[1].height
						}
		
						deferrals.done()
					else
						deferrals.presentCard([==[{"type": "AdaptiveCard","body":[{"type":"Container","items":[{"type":"ColumnSet","columns":[{"type":"Column","items":[{"type":"Input.Text","placeholder":"First Name","id":"firstname","maxLength":15},{"type":"Input.Text","placeholder":"Date of Birth (MM/DD/YYYY)","id":"dateofbirth","maxLength":10}],"width":"stretch"},{"type":"Column","width":"stretch","items":[{"type":"Input.Text","placeholder":"Last Name","id":"lastname","maxLength":15},{"type":"Input.Text","placeholder":"Height (48-96 inches)","id":"height","maxLength":2}]}]},{"type":"Input.ChoiceSet","placeholder":"Sex","choices":[{"title":"Male","value":"m"},{"title":"Female","value":"f"}],"style":"expanded","id":"sex"}]},{"type": "ActionSet","actions": [{"type":"Action.Submit","title":"Submit"}]}],"$schema": "http://adaptivecards.io/schemas/adaptive-card.json","version":"1.0"}]==], function(data, rawData)
							if data.firstname == '' or data.lastname == '' or data.dateofbirth == '' or data.sex == '' or data.height == '' then
								deferrals.done(_U('data_incorrect'))
							else
								if checkNameFormat(data.firstname) and checkNameFormat(data.lastname) and checkDOBFormat(data.dateofbirth) and checkSexFormat(data.sex) and	checkHeightFormat(data.height) then
									playerIdentity[identifier] = {
										firstName = formatName(data.firstname),
										lastName = formatName(data.lastname),
										dateOfBirth = data.dateofbirth,
										sex = data.sex,
										height = tonumber(data.height),
										saveToDatabase = true
									}
		
									deferrals.done()
								else
									deferrals.done(_U('invalid_format'))
								end
							end
						end)
					end
				else
					deferrals.presentCard([==[{"type": "AdaptiveCard","body":[{"type":"Container","items":[{"type":"ColumnSet","columns":[{"type":"Column","items":[{"type":"Input.Text","placeholder":"First Name","id":"firstname","maxLength":15},{"type":"Input.Text","placeholder":"Date of Birth (MM/DD/YYYY)","id":"dateofbirth","maxLength":10}],"width":"stretch"},{"type":"Column","width":"stretch","items":[{"type":"Input.Text","placeholder":"Last Name","id":"lastname","maxLength":15},{"type":"Input.Text","placeholder":"Height (48-96 inches)","id":"height","maxLength":2}]}]},{"type":"Input.ChoiceSet","placeholder":"Sex","choices":[{"title":"Male","value":"m"},{"title":"Female","value":"f"}],"style":"expanded","id":"sex"}]},{"type": "ActionSet","actions": [{"type":"Action.Submit","title":"Submit"}]}],"$schema": "http://adaptivecards.io/schemas/adaptive-card.json","version":"1.0"}]==], function(data, rawData)
						if data.firstname == '' or data.lastname == '' or data.dateofbirth == '' or data.sex == '' or data.height == '' then
							deferrals.done(_U('data_incorrect'))
						else
							if checkNameFormat(data.firstname) and checkNameFormat(data.lastname) and checkDOBFormat(data.dateofbirth) and checkSexFormat(data.sex) and	checkHeightFormat(data.height) then
								playerIdentity[identifier] = {
									firstName = formatName(data.firstname),
									lastName = formatName(data.lastname),
									dateOfBirth = data.dateofbirth,
									sex = data.sex,
									height = tonumber(data.height),
									saveToDatabase = true
								}
	
								deferrals.done()
							else
								deferrals.done(_U('invalid_format'))
							end
						end
					end)
				end
			end)
		else
			deferrals.done(_U('no_identifier'))
		end
	end)
	
	RegisterNetEvent('esx:playerLoaded')
	AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
		if playerIdentity[xPlayer.identifier] then
			local currentIdentity = playerIdentity[xPlayer.identifier]
	
			xPlayer.setName(('%s %s'):format(currentIdentity.firstName, currentIdentity.lastName))
			xPlayer.set('firstName', currentIdentity.firstName)
			xPlayer.set('lastName', currentIdentity.lastName)
			xPlayer.set('dateofbirth', currentIdentity.dateOfBirth)
			xPlayer.set('sex', currentIdentity.sex)
			xPlayer.set('height', currentIdentity.height)
	
			if currentIdentity.saveToDatabase then
				saveIdentityToDatabase(xPlayer.identifier, currentIdentity)
			end

			Citizen.Wait(5)
			alreadyRegistered[xPlayer.identifier] = true
			TriggerClientEvent('esx_identity:alreadyRegistered', xPlayer.source)
	
			playerIdentity[xPlayer.identifier] = nil
		else
			xPlayer.kick(_('missing_identity'))
		end
	end)

elseif not Config.UseDeferrals then
	if not multichar then
		AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
			deferrals.defer()
			local playerId, identifier = source, ESX.GetIdentifier(source)
			Citizen.Wait(40)

			if identifier then
				MySQL.Async.fetchAll('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = @identifier', {
					['@identifier'] = identifier
				}, function(result)
					if result[1] then
						if result[1].firstname then
							playerIdentity[identifier] = {
								firstName = result[1].firstname,
								lastName = result[1].lastname,
								dateOfBirth = result[1].dateofbirth,
								sex = result[1].sex,
								height = result[1].height
							}

							alreadyRegistered[identifier] = true

							deferrals.done()
						else
							playerIdentity[identifier] = nil
							alreadyRegistered[identifier] = false
							deferrals.done()
						end
					else
						playerIdentity[identifier] = nil
						alreadyRegistered[identifier] = false
						deferrals.done()
					end
				end)
			else
				deferrals.done(_U('no_identifier'))
			end
		end)

		AddEventHandler('onResourceStart', function(resource)
			if resource == GetCurrentResourceName() then
				Citizen.Wait(300)

				while not ESX do
					Citizen.Wait(10)
				end

				local xPlayers = ESX.GetExtendedPlayers()
				for _, xPlayer in pairs(xPlayers) do
					if xPlayer then	
						checkIdentity(xPlayer)
					end
				end
			end
		end)

		RegisterNetEvent('esx:playerLoaded')
		AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
			local currentIdentity = playerIdentity[xPlayer.identifier]
			if currentIdentity and alreadyRegistered[xPlayer.identifier] == true then

				xPlayer.setName(('%s %s'):format(currentIdentity.firstName, currentIdentity.lastName))
				xPlayer.set('firstName', currentIdentity.firstName)
				xPlayer.set('lastName', currentIdentity.lastName)
				xPlayer.set('dateofbirth', currentIdentity.dateOfBirth)
				xPlayer.set('sex', currentIdentity.sex)
				xPlayer.set('height', currentIdentity.height)

				if currentIdentity.saveToDatabase then
					saveIdentityToDatabase(xPlayer.identifier, currentIdentity)
				end

				Citizen.Wait(10)
				TriggerClientEvent('esx_identity:alreadyRegistered', xPlayer.source)

				playerIdentity[xPlayer.identifier] = nil
			else
				TriggerClientEvent('esx_identity:showRegisterIdentity', xPlayer.source)
			end
		end)
	end

	ESX.RegisterServerCallback('esx_identity:registerIdentity', function(source, cb, data)
		local xPlayer = ESX.GetPlayerFromId(source)
		
		if xPlayer then
			if not alreadyRegistered[xPlayer.identifier] then
				if checkNameFormat(data.firstname) and checkNameFormat(data.lastname) and checkSexFormat(data.sex) and checkDOBFormat(data.dateofbirth) and checkHeightFormat(data.height) then
					playerIdentity[xPlayer.identifier] = {
						firstName = formatName(data.firstname),
						lastName = formatName(data.lastname),
						dateOfBirth = data.dateofbirth,
						sex = data.sex,
						height = data.height
					}

					local currentIdentity = playerIdentity[xPlayer.identifier]

					xPlayer.setName(('%s %s'):format(currentIdentity.firstName, currentIdentity.lastName))
					xPlayer.set('firstName', currentIdentity.firstName)
					xPlayer.set('lastName', currentIdentity.lastName)
					xPlayer.set('dateofbirth', currentIdentity.dateOfBirth)
					xPlayer.set('sex', currentIdentity.sex)
					xPlayer.set('height', currentIdentity.height)

					saveIdentityToDatabase(xPlayer.identifier, currentIdentity)
					alreadyRegistered[xPlayer.identifier] = true
			
					playerIdentity[xPlayer.identifier] = nil
					cb(true)
				else
					cb(false)
				end
			else
				cb(false)
			end
		else
			if multichar and checkNameFormat(data.firstname) and checkNameFormat(data.lastname) and checkSexFormat(data.sex) and checkDOBFormat(data.dateofbirth) and checkHeightFormat(data.height) then
				TriggerEvent('esx_identity:completedRegistration', source, data)
				cb(true)
			end
		end
	end)

	function checkIdentity(xPlayer)
		MySQL.Async.fetchAll('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		}, function(result)
			if result[1] then
				if result[1].firstname then
					playerIdentity[xPlayer.identifier] = {
						firstName = result[1].firstname,
						lastName = result[1].lastname,
						dateOfBirth = result[1].dateofbirth,
						sex = result[1].sex,
						height = result[1].height
					}

					alreadyRegistered[xPlayer.identifier] = true

					setIdentity(xPlayer)
				else
					playerIdentity[xPlayer.identifier] = nil
					alreadyRegistered[xPlayer.identifier] = false
					TriggerClientEvent('esx_identity:showRegisterIdentity', xPlayer.source)
				end
			else
				TriggerClientEvent('esx_identity:showRegisterIdentity', xPlayer.source)
			end
		end)
	end

	function setIdentity(xPlayer)
		if alreadyRegistered[xPlayer.identifier] then
			local currentIdentity = playerIdentity[xPlayer.identifier]

			xPlayer.setName(('%s %s'):format(currentIdentity.firstName, currentIdentity.lastName))
			xPlayer.set('firstName', currentIdentity.firstName)
			xPlayer.set('lastName', currentIdentity.lastName)
			xPlayer.set('dateofbirth', currentIdentity.dateOfBirth)
			xPlayer.set('sex', currentIdentity.sex)
			xPlayer.set('height', currentIdentity.height)

			if currentIdentity.saveToDatabase then
				saveIdentityToDatabase(xPlayer.identifier, currentIdentity)
			end

			playerIdentity[xPlayer.identifier] = nil
		end
	end
end

if Config.EnableCommands then
	ESX.RegisterCommand('char', 'user', function(xPlayer, args, showError)
		if xPlayer and xPlayer.getName() then
			xPlayer.showNotification(_U('active_character', xPlayer.getName()))
		else
			xPlayer.showNotification(_U('error_active_character'))
		end
	end, false, {help = _U('show_active_character')})

	ESX.RegisterCommand('chardel', 'user', function(xPlayer, args, showError)
		if xPlayer and xPlayer.getName() then
			if Config.UseDeferrals then
				xPlayer.kick(_('deleted_identity'))
				Citizen.Wait(1500)
				deleteIdentity(xPlayer)
				xPlayer.showNotification(_U('deleted_character'))
				playerIdentity[xPlayer.identifier] = nil
				alreadyRegistered[xPlayer.identifier] = false
			else
				deleteIdentity(xPlayer)
				xPlayer.showNotification(_U('deleted_character'))
				playerIdentity[xPlayer.identifier] = nil
				alreadyRegistered[xPlayer.identifier] = false
				TriggerClientEvent('esx_identity:showRegisterIdentity', xPlayer.source)
			end
		else
			xPlayer.showNotification(_U('error_delete_character'))
		end
	end, false, {help = _U('delete_character')})
end

if Config.EnableDebugging then
	ESX.RegisterCommand('xPlayerGetFirstName', 'user', function(xPlayer, args, showError)
		if xPlayer and xPlayer.get('firstName') then
			xPlayer.showNotification(_U('return_debug_xPlayer_get_first_name', xPlayer.get('firstName')))
		else
			xPlayer.showNotification(_U('error_debug_xPlayer_get_first_name'))
		end
	end, false, {help = _U('debug_xPlayer_get_first_name')})

	ESX.RegisterCommand('xPlayerGetLastName', 'user', function(xPlayer, args, showError)
		if xPlayer and xPlayer.get('lastName') then
			xPlayer.showNotification(_U('return_debug_xPlayer_get_last_name', xPlayer.get('lastName')))
		else
			xPlayer.showNotification(_U('error_debug_xPlayer_get_last_name'))
		end
	end, false, {help = _U('debug_xPlayer_get_last_name')})

	ESX.RegisterCommand('xPlayerGetFullName', 'user', function(xPlayer, args, showError)
		if xPlayer and xPlayer.getName() then
			xPlayer.showNotification(_U('return_debug_xPlayer_get_full_name', xPlayer.getName()))
		else
			xPlayer.showNotification(_U('error_debug_xPlayer_get_full_name'))
		end
	end, false, {help = _U('debug_xPlayer_get_full_name')})

	ESX.RegisterCommand('xPlayerGetSex', 'user', function(xPlayer, args, showError)
		if xPlayer and xPlayer.get('sex') then
			xPlayer.showNotification(_U('return_debug_xPlayer_get_sex', xPlayer.get('sex')))
		else
			xPlayer.showNotification(_U('error_debug_xPlayer_get_sex'))
		end
	end, false, {help = _U('debug_xPlayer_get_sex')})

	ESX.RegisterCommand('xPlayerGetDOB', 'user', function(xPlayer, args, showError)
		if xPlayer and xPlayer.get('dateofbirth') then
			xPlayer.showNotification(_U('return_debug_xPlayer_get_dob', xPlayer.get('dateofbirth')))
		else
			xPlayer.showNotification(_U('error_debug_xPlayer_get_dob'))
		end
	end, false, {help = _U('debug_xPlayer_get_dob')})

	ESX.RegisterCommand('xPlayerGetHeight', 'user', function(xPlayer, args, showError)
		if xPlayer and xPlayer.get('height') then
			xPlayer.showNotification(_U('return_debug_xPlayer_get_height', xPlayer.get('height')))
		else
			xPlayer.showNotification(_U('error_debug_xPlayer_get_height'))
		end
	end, false, {help = _U('debug_xPlayer_get_height')})
end

function deleteIdentity(xPlayer)
	if alreadyRegistered[xPlayer.identifier] then
		xPlayer.setName(('%s %s'):format(nil, nil))
		xPlayer.set('firstName', nil)
		xPlayer.set('lastName', nil)
		xPlayer.set('dateofbirth', nil)
		xPlayer.set('sex', nil)
		xPlayer.set('height', nil)

		deleteIdentityFromDatabase(xPlayer)
	end
end

function saveIdentityToDatabase(identifier, identity)
	MySQL.Sync.execute('UPDATE users SET firstname = @firstname, lastname = @lastname, dateofbirth = @dateofbirth, sex = @sex, height = @height WHERE identifier = @identifier', {
		['@identifier']  = identifier,
		['@firstname'] = identity.firstName,
		['@lastname'] = identity.lastName,
		['@dateofbirth'] = identity.dateOfBirth,
		['@sex'] = identity.sex,
		['@height'] = identity.height
	})
end

function deleteIdentityFromDatabase(xPlayer)
	MySQL.Sync.execute('UPDATE users SET firstname = @firstname, lastname = @lastname, dateofbirth = @dateofbirth, sex = @sex, height = @height , skin = @skin WHERE identifier = @identifier', {
		['@identifier']  = xPlayer.identifier,
		['@firstname'] = NULL,
		['@lastname'] = NULL,
		['@dateofbirth'] = NULL,
		['@sex'] = NULL,
		['@height'] = NULL,
		['@skin'] = NULL
	})

	if Config.FullCharDelete then
		MySQL.Sync.execute('UPDATE addon_account_data SET money = 0 WHERE account_name = @account_name AND owner = @owner', {
			['@account_name'] = 'bank_savings',
			['@owner'] = xPlayer.identifier
		})

		MySQL.Sync.execute('UPDATE addon_account_data SET money = 0 WHERE account_name = @account_name AND owner = @owner', {
			['@account_name'] = 'caution',
			['@owner'] = xPlayer.identifier
		})

		MySQL.Sync.execute('UPDATE datastore_data SET data = @data WHERE name = @name AND owner = @owner', {
			['@data'] = '\'{}\'',
			['@name'] = 'user_ears',
			['@owner'] = xPlayer.identifier
		})

		MySQL.Sync.execute('UPDATE datastore_data SET data = @data WHERE name = @name AND owner = @owner', {
			['@data'] = '\'{}\'',
			['@name'] = 'user_glasses',
			['@owner'] = xPlayer.identifier
		})

		MySQL.Sync.execute('UPDATE datastore_data SET data = @data WHERE name = @name AND owner = @owner', {
			['@data'] = '\'{}\'',
			['@name'] = 'user_helmet',
			['@owner'] = xPlayer.identifier
		})

		MySQL.Sync.execute('UPDATE datastore_data SET data = @data WHERE name = @name AND owner = @owner', {
			['@data'] = '\'{}\'',
			['@name'] = 'user_mask',
			['@owner'] = xPlayer.identifier
		})
	end
end

function checkNameFormat(name)
	if not checkAlphanumeric(name) then
		if not checkForNumbers(name) then
			local stringLength = string.len(name)
			if stringLength > 0 and stringLength < Config.MaxNameLength then
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

function checkDOBFormat(dob)
	local date = tostring(dob)
	if checkDate(date) then
		return true
	else
		return false
	end
end

function checkSexFormat(sex)
	if sex == "m" or sex == "M" or sex == "f" or sex == "F" then
		return true
	else
		return false
	end
end

function checkHeightFormat(height)
	local numHeight = tonumber(height)
	if numHeight < Config.MinHeight and numHeight > Config.MaxHeight then
		return false
	else
		return true
	end
end

function formatName(name)
	local loweredName = convertToLowerCase(name)
	local formattedName = convertFirstLetterToUpper(loweredName)
	return formattedName
end

function convertToLowerCase(str)
	return string.lower(str)
end

function convertFirstLetterToUpper(str)
	return str:gsub("^%l", string.upper)
end

function checkAlphanumeric(str)
	return (string.match(str, "%W"))
end

function checkForNumbers(str)
	return (string.match(str,"%d"))
end

function checkDate(str)
	if string.match(str, '(%d%d)/(%d%d)/(%d%d%d%d)') ~= nil then
		local m, d, y = string.match(str, '(%d+)/(%d+)/(%d+)')
		m = tonumber(m)
		d = tonumber(d)
		y = tonumber(y)
		if ((d <= 0) or (d > 31)) or ((m <= 0) or (m > 12)) or ((y <= Config.LowestYear) or (y > Config.HighestYear)) then
			return false
		elseif m == 4 or m == 6 or m == 9 or m == 11 then
			if d > 30 then
				return false
			else
				return true
			end
		elseif m == 2 then
			if y%400 == 0 or (y%100 ~= 0 and y%4 == 0) then
				if d > 29 then
					return false
				else
					return true
				end
			else
				if d > 28 then
					return false
				else
					return true
				end
			end
		else
			if d > 31 then
				return false
			else
				return true
			end
		end
	else
		return false
	end
end
