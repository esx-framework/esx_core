ESX                = nil
local tempIdentity = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
	local player = source
	local identifiers = GetPlayerIdentifiers(player)
	local identifier
	deferrals.defer()

	Citizen.Wait(500)

	for k, v in pairs(identifiers) do
		if string.match(v, 'license:') then
			identifier = string.sub(v, 9)
			break
		end
	end

	Citizen.Wait(500)
	
	if identifier then
		MySQL.Async.fetchAll('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = @identifier', {
			['@identifier'] = identifier
		}, function(result)
			if result[1] then
				if result[1].firstname then
					tempIdentity[identifier] = {
						firstName   = result[1].firstname,
						lastName    = result[1].lastname,
						dateOfBirth = result[1].dateofbirth,
						sex         = result[1].sex,
						height      = result[1].height,
						registered  = false
					}
				end
			end                
		end)

		Citizen.Wait(500)

		if tempIdentity[identifier] and tempIdentity[identifier].firstName then
			tempIdentity[identifier].registered = true
			deferrals.done()
		else
			deferrals.presentCard([==[{"type": "AdaptiveCard", "body": [{ "type": "ColumnSet", "columns": [{ "type": "Column", "items": [
				{ "type": "Input.Text", "placeholder": "First Name (Max 15 Characters)", "id": "firstname" }], "width": "stretch" }]},
				{ "type": "Input.Text", "placeholder": "Last Name (Max 15 Characters)", "id": "lastname" },
				{ "type": "Input.Text", "placeholder": "Height (24-96 Inches)", "id": "height" },
				{ "type": "Input.Date", "id": "dateofbirth" },
				{ "type": "Input.ChoiceSet", "placeholder": "Sex", "choices": [{ "title": "Male", "value": "m" }, { "title": "Female",  "value": "f" }], "style": "expanded", "value": "m", "id": "sex" }],
				"actions": [{ "type": "Action.Submit", "title": "Submit" }],
				"$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
				"version": "1.0"
			}]==], function(submittedData, rawData)
				if submittedData.firstname == "" or submittedData.lastname == "" or submittedData.dateofbirth == "" or submittedData.sex == "" or submittedData.height == "" then
					deferrals.done(_U('data_incorrect'))
				else
					if checkNameFormat(submittedData.firstname) and checkNameFormat(submittedData.lastname) and checkDOBFormat(submittedData.dateofbirth) and checkSexFormat(submittedData.sex) and checkHeightFormat(submittedData.height) then
						local formattedFirstName = formatName(submittedData.firstname)
						local formattedLastName = formatName(submittedData.lastname)
						local formattedHeight = tonumber(submittedData.height)
						tempIdentity[identifier] = {
							firstName   = formattedFirstName,
							lastName    = formattedLastName,
							dateOfBirth = submittedData.dateofbirth,
							sex         = submittedData.sex,
							height      = formattedHeight,
							registered  = false
						}
						deferrals.done()
					else
						deferrals.done(_U('invalid_format')
					end
				end
			end)
		end
	else
		deferrals.done(_U('no_identifiers'))
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	if tempIdentity[xPlayer.identifier] then
		local currentIdentity = tempIdentity[xPlayer.identifier]
		xPlayer.setName(('%s %s'):format(currentIdentity.firstName, currentIdentity.lastName))
		xPlayer.set('firstName', currentIdentity.firstName)
		xPlayer.set('lastName', currentIdentity.lastName)
		xPlayer.set('dateofbirth', currentIdentity.dateOfBirth)
		xPlayer.set('sex', currentIdentity.sex)
		xPlayer.set('height', currentIdentity.height)
		if not currentIdentity.registered then
			currentIdentity.registered = true
			SetIdentity(xPlayer.identifier, currentIdentity)
		else
			tempIdentity[xPlayer.identifier] = nil
		end
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

function SetIdentity(identifier, identity)
	MySQL.Async.execute('UPDATE users SET firstname = @firstname, lastname = @lastname, dateofbirth = @dateofbirth, sex = @sex, height = @height WHERE identifier = @identifier', {
		['@identifier']		= identifier,
		['@firstname']		= identity.firstName,
		['@lastname']       = identity.lastName,
		['@dateofbirth']    = identity.dateOfBirth,
		['@sex']            = identity.sex,
		['@height']         = identity.height
	})

	tempIdentity[identifier] = nil
end
