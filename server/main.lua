ESX = nil
local playerIdentity = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
	deferrals.defer()
	local playerId, identifier = source
	Citizen.Wait(100)

	for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
		if string.match(v, 'license:') then
			identifier = string.sub(v, 9)
			break
		end
	end

	if identifier then
		MySQL.Async.fetchAll('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = @identifier', {
			['@identifier'] = identifier
		}, function(result)
			if result[1] then
				playerIdentity[identifier] = {
					firstName = result[1].firstname,
					lastName = result[1].lastname,
					dateOfBirth = result[1].dateofbirth,
					sex = result[1].sex,
					height = result[1].height
				}

				deferrals.done()
			else
				deferrals.presentCard([==[{"type":"AdaptiveCard","body":[{"type":"Container","items":[{"type":"TextBlock","text":"Identity Registration","horizontalAlignment":"Center","size":"Large","weight":"Bolder"},{"type":"ColumnSet","columns":[{"type":"Column","items":[{"type":"Input.Text","placeholder":"First Name","id":"firstname","maxLength":15}],"width":"stretch"},{"type":"Column","width":"stretch","items":[{"type":"Input.Text","placeholder":"Last Name","id":"lastname","maxLength":15}]}]},{"type":"ColumnSet","columns":[{"type":"Column","width":"stretch","items":[{"type":"Input.Text","placeholder":"Date of Birth (YYYY-MM-DD)","id":"dateofbirth","maxLength":10}],"style":"default"},{"type":"Column","width":"stretch","items":[{"type":"Input.Text","placeholder":"Height (24-96 inches)","id":"height","maxLength":2}]}]},{"type":"Input.ChoiceSet","placeholder":"Sex","choices":[{"title":"Male","value":"m"},{"title":"Female","value":"f"}],"style":"expanded","id":"sex"}],"style":"default","backgroundImage":"https://nischat.se/wp-content/uploads/Light-grey-background-1024x683.jpg"}],"actions":[{"type":"Action.Submit","title":"Submit"}],"$schema":"http://adaptivecards.io/schemas/adaptive-card.json","version":"1.0"}]==], function(data, rawData)
					if
						data.firstname == '' or
						data.lastname == '' or
						data.dateofbirth == '' or
						data.sex == '' or 
						data.height == ''
					then
						deferrals.done(_U('data_incorrect'))
					else
						if
							checkNameFormat(data.firstname) and
							checkNameFormat(data.lastname) and
							checkDOBFormat(data.dateofbirth) and
							checkSexFormat(data.sex) and
							checkHeightFormat(data.height)
						then
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
			SaveIdentityToDatabase(xPlayer.identifier, currentIdentity)
		end

		playerIdentity[xPlayer.identifier] = nil
	else
		xPlayer.kick(_('missing_identity'))
	end
end)

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
	if string.match(str, '(%d%d%d%d)-(%d%d)-(%d%d)') ~= nil then
		local y, m, d = string.match(str, '(%d+)-(%d+)-(%d+)')
		y = tonumber(y)
		m = tonumber(m)
		d = tonumber(d)
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

function SaveIdentityToDatabase(identifier, identity)
	MySQL.Sync.execute('UPDATE users SET firstname = @firstname, lastname = @lastname, dateofbirth = @dateofbirth, sex = @sex, height = @height WHERE identifier = @identifier', {
		['@identifier']  = identifier,
		['@firstname'] = identity.firstName,
		['@lastname'] = identity.lastName,
		['@dateofbirth'] = identity.dateOfBirth,
		['@sex'] = identity.sex,
		['@height'] = identity.height
	})
end
