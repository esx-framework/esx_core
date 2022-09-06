local playerIdentity = {}
local alreadyRegistered = {}
local multichar = ESX.GetConfig().Multichar

local function deleteIdentity(xPlayer)
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

local function saveIdentityToDatabase(identifier, identity)
    MySQL.update.await(
        'UPDATE users SET firstname = ?, lastname = ?, dateofbirth = ?, sex = ?, height = ? WHERE identifier = ?',
        {identity.firstName, identity.lastName, identity.dateOfBirth, identity.sex, identity.height, identifier})
end

local function deleteIdentityFromDatabase(xPlayer)
    MySQL.query.await(
        'UPDATE users SET firstname = ?, lastname = ?, dateofbirth = ?, sex = ?, height = ?, skin = ? WHERE identifier = ?',
        {nil, nil, nil, nil, nil, nil, xPlayer.identifier})

    if Config.FullCharDelete then
        MySQL.update.await('UPDATE addon_account_data SET money = 0 WHERE account_name IN (?) AND owner = ?',
            {{'bank_savings', 'caution'}, xPlayer.identifier})

        MySQL.prepare.await('UPDATE datastore_data SET data = ? WHERE name IN (?) AND owner = ?',
            {'\'{}\'', {'user_ears', 'user_glasses', 'user_helmet', 'user_mask'}, xPlayer.identifier})
    end
end

local function checkDate(str)
    if string.match(str, '(%d%d)/(%d%d)/(%d%d%d%d)') ~= nil then
        local d, m, y = string.match(str, '(%d+)/(%d+)/(%d+)')
        
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
            if y % 400 == 0 or (y % 100 ~= 0 and y % 4 == 0) then
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

local function formatDate(str)
    local d, m, y = string.match(str, '(%d+)/(%d+)/(%d+)')
    local date = str

    if Config.DateFormat == "MM/DD/YYYY" then
        date = m .. "/" .. d .. "/" .. y
    elseif Config.DateFormat == "YYYY/MM/DD" then
        date = y .. "/" .. m .. "/" .. d
    end

    return date
end

local function checkAlphanumeric(str)
    return (string.match(str, "%W"))
end

local function checkForNumbers(str)
    return (string.match(str, "%d"))
end

local function checkNameFormat(name)
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

local function checkDOBFormat(dob)
    local date = tostring(dob)

    if checkDate(date) then
        return true
    else
        return false
    end
end

local function checkSexFormat(sex)
    if sex == "m" or sex == "M" or sex == "f" or sex == "F" then
        return true
    else
        return false
    end
end

local function checkHeightFormat(height)
    local numHeight = tonumber(height)
    if numHeight < Config.MinHeight and numHeight > Config.MaxHeight then
        return false
    else
        return true
    end
end

local function convertToLowerCase(str)
    return string.lower(str)
end

local function convertFirstLetterToUpper(str)
    return str:gsub("^%l", string.upper)
end

local function formatName(name)
    local loweredName = convertToLowerCase(name)
    local formattedName = convertFirstLetterToUpper(loweredName)
    return formattedName
end

if Config.UseDeferrals then
    AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
        deferrals.defer()
        local playerId, identifier = source, ESX.GetIdentifier(source)
        Wait(100)

        if identifier then
            MySQL.single('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = ?',
                {identifier}, function(result)
                    if result then
                        if result.firstname then
                            playerIdentity[identifier] = {
                                firstName = result.firstname,
                                lastName = result.lastname,
                                dateOfBirth = result.dateofbirth,
                                sex = result.sex,
                                height = result.height
                            }

                            deferrals.done()
                        else
                            deferrals.presentCard(
                                [==[{"type": "AdaptiveCard","body":[{"type":"Container","items":[{"type":"ColumnSet",
                                "columns":[{"type":"Column","items":[{"type":"Input.Text","placeholder":"First Name",
                                "id":"firstname","maxLength":15},{"type":"Input.Text","placeholder":"Date of Birth (MM/DD/YYYY)",
                                "id":"dateofbirth","maxLength":10}],"width":"stretch"},{"type":"Column","width":"stretch",
                                "items":[{"type":"Input.Text","placeholder":"Last Name","id":"lastname","maxLength":15},
                                {"type":"Input.Text","placeholder":"Height (48-96 inches)","id":"height","maxLength":2}]}]},
                                {"type":"Input.ChoiceSet","placeholder":"Sex","choices":[{"title":"Male","value":"m"},
                                {"title":"Female","value":"f"}],"style":"expanded","id":"sex"}]},{"type": "ActionSet",
                                "actions": [{"type":"Action.Submit","title":"Submit"}]}],
                                "$schema": "http://adaptivecards.io/schemas/adaptive-card.json","version":"1.0"}]==],
                                function(data, rawData)
                                    if data.firstname == '' or data.lastname == '' or data.dateofbirth == '' or data.sex ==
                                        '' or data.height == '' then
                                        deferrals.done(_U('data_incorrect'))
                                    else
                                        if checkNameFormat(data.firstname) and checkNameFormat(data.lastname) and
                                            checkDOBFormat(data.dateofbirth) and checkSexFormat(data.sex) and
                                            checkHeightFormat(data.height) then
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
                        deferrals.presentCard(
                            [==[{"type": "AdaptiveCard","body":[{"type":"Container","items":[{"type":"ColumnSet","columns":[{
                            "type":"Column","items":[{"type":"Input.Text","placeholder":"First Name","id":"firstname",
                            "maxLength":15},{"type":"Input.Text","placeholder":"Date of Birth (MM/DD/YYYY)","id":"dateofbirth",
                            "maxLength":10}],"width":"stretch"},{"type":"Column","width":"stretch","items":[{"type":"Input.Text",
                            "placeholder":"Last Name","id":"lastname","maxLength":15},{"type":"Input.Text",
                            "placeholder":"Height (48-96 inches)","id":"height","maxLength":2}]}]},{"type":"Input.ChoiceSet",
                            "placeholder":"Sex","choices":[{"title":"Male","value":"m"},{"title":"Female","value":"f"}],
                            "style":"expanded","id":"sex"}]},{"type": "ActionSet","actions": [{"type":"Action.Submit",
                            "title":"Submit"}]}],"$schema": "http://adaptivecards.io/schemas/adaptive-card.json","version":"1.0"}]==],
                            function(data, rawData)
                                if data.firstname == '' or data.lastname == '' or data.dateofbirth == '' or data.sex ==
                                    '' or data.height == '' then
                                    deferrals.done(_U('data_incorrect'))
                                else
                                    if checkNameFormat(date.firstname) then
                                        if checkNameFormat(data.lastname) then
                                            if checkDOBFormat(data.dateofbirth) then
                                                if checkSexFormat(data.sex) then
                                                    if checkHeightFormat(data.height) then
                                                        local formattedFirstName = formatName(data.firstname)
                                                        local formattedLastName = formatName(data.lastname)
                                                        local formattedDate = formatDate(data.dateofbirth)

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
                                                        deferrals.done(_U('invalid_height_format'))
                                                    end
                                                else
                                                    deferrals.done(_U('invalid_sex_format'))
                                                end
                                            else
                                                deferrals.done(_U('invalid_dob_format'))
                                            end
                                        else
                                            deferrals.done(_U('invalid_lastname_format'))
                                        end
                                    else
                                        deferrals.done(_U('invalid_firstname_format'))
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

            Wait(0)
            alreadyRegistered[xPlayer.identifier] = true
            TriggerClientEvent('esx_identity:alreadyRegistered', xPlayer.source)
            playerIdentity[xPlayer.identifier] = nil
        else
            xPlayer.kick(_('missing_identity'))
        end
    end)
else
	local function checkIdentity(xPlayer)
		MySQL.single('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = ?',
            {xPlayer.identifier}, function(result)
                if result then
                    if result.firstname then
                        playerIdentity[xPlayer.identifier] = {
                            firstName = result.firstname,
                            lastName = result.lastname,
                            dateOfBirth = result.dateofbirth,
                            sex = result.sex,
                            height = result.height
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

	local function setIdentity(xPlayer)
		if alreadyRegistered[xPlayer.identifier] then
			local currentIdentity = playerIdentity[xPlayer.identifier]

			xPlayer.setName(('%s %s'):format(currentIdentity.firstName, currentIdentity.lastName))
			xPlayer.set('firstName', currentIdentity.firstName)
			xPlayer.set('lastName', currentIdentity.lastName)
			xPlayer.set('dateofbirth', currentIdentity.dateOfBirth)
			xPlayer.set('sex', currentIdentity.sex)
			xPlayer.set('height', currentIdentity.height)
            TriggerClientEvent('esx_identity:setPlayerData', xPlayer.source, currentIdentity)
			if currentIdentity.saveToDatabase then
				saveIdentityToDatabase(xPlayer.identifier, currentIdentity)
			end

			playerIdentity[xPlayer.identifier] = nil
		end
	end

	if not multichar then
		AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
			deferrals.defer()
			local playerId, identifier = source, ESX.GetIdentifier(source)
			Wait(40)

			if identifier then
				MySQL.single('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = ?',
				    {identifier}, function(result)
                        if result then
                            if result.firstname then
                                playerIdentity[identifier] = {
                                    firstName = result.firstname,
                                    lastName = result.lastname,
                                    dateOfBirth = result.dateofbirth,
                                    sex = result.sex,
                                    height = result.height
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
                Wait(300)

                while not ESX do Wait(0) end

                local xPlayers = ESX.GetExtendedPlayers()

                for i=1, #(xPlayers) do 
                    if xPlayers[i] then
                        checkIdentity(xPlayers[i])
                    end
                end
            end
        end)

		RegisterNetEvent('esx:playerLoaded', function(playerId, xPlayer)
			local currentIdentity = playerIdentity[xPlayer.identifier]

            if currentIdentity and alreadyRegistered[xPlayer.identifier] == true then
                xPlayer.setName(('%s %s'):format(currentIdentity.firstName, currentIdentity.lastName))
                xPlayer.set('firstName', currentIdentity.firstName)
                xPlayer.set('lastName', currentIdentity.lastName)
                xPlayer.set('dateofbirth', currentIdentity.dateOfBirth)
                xPlayer.set('sex', currentIdentity.sex)
                xPlayer.set('height', currentIdentity.height)
                TriggerClientEvent('esx_identity:setPlayerData', xPlayer.source, currentIdentity)
                if currentIdentity.saveToDatabase then
                    saveIdentityToDatabase(xPlayer.identifier, currentIdentity)
                end

                Wait(0)

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
                xPlayer.showNotification(_U('running'), "error")
				if checkNameFormat(data.firstname) then
					if checkNameFormat(data.lastname) then
						if checkSexFormat(data.sex) then
							if checkDOBFormat(data.dateofbirth) then
								if checkHeightFormat(data.height) then
									local formattedFirstName = formatName(data.firstname)
									local formattedLastName = formatName(data.lastname)
                                    local formattedDate = formatDate(data.dateofbirth)

									playerIdentity[xPlayer.identifier] = {
										firstName = formattedFirstName,
										lastName = formattedLastName,
										dateOfBirth = formattedDate,
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
                                    TriggerClientEvent('esx_identity:setPlayerData', xPlayer.source, currentIdentity)
									saveIdentityToDatabase(xPlayer.identifier, currentIdentity)
									alreadyRegistered[xPlayer.identifier] = true
									playerIdentity[xPlayer.identifier] = nil
									cb(true)
								else
									xPlayer.showNotification(_U('invalid_height_format'), "error")
									cb(false)
								end
							else
								xPlayer.showNotification(_U('invalid_dob_format'), "error")
								cb(false)
							end
						else
							xPlayer.showNotification(_U('invalid_sex_format'), "error")
							cb(false)
						end
					else
						xPlayer.showNotification(_U('invalid_lastname_format'), "error")
						cb(false)
					end
				else
					xPlayer.showNotification(_U('invalid_firstname_format'), "error")
					cb(false)
				end
			else
				xPlayer.showNotification(_U('already_registered'), "error")
				cb(false)
			end
		else
			if multichar then
				if checkNameFormat(data.firstname) then
					if checkNameFormat(data.lastname) then
						if checkSexFormat(data.sex) then
							if checkDOBFormat(data.dateofbirth) then
                                local formattedFirstName = formatName(data.firstname)
                                local formattedLastName = formatName(data.lastname)
                                local formattedDate = formatDate(data.dateofbirth)
             
                                data.firstname = formattedFirstName
                                data.lastname = formattedLastName
                                data.dateofbirth = formattedDate
								if checkHeightFormat(data.height) then
                                    local Identity= {
										firstName = formattedFirstName,
										lastName = formattedLastName,
										dateOfBirth = formattedDate,
										sex = data.sex,
										height = data.height
									}
									TriggerEvent('esx_identity:completedRegistration', source, data)
                                    TriggerClientEvent('esx_identity:setPlayerData', source, Identity)
									cb(true)
								else
									TriggerClientEvent("esx:showNotification", source, _U('invalid_height_format'), "error")
									cb(false)
								end
							else
								TriggerClientEvent("esx:showNotification", source, _U('invalid_dob_format'), "error")
								cb(false)
							end
						else
							TriggerClientEvent("esx:showNotification", source, _U('invalid_sex_format'), "error")
							cb(false)
						end
					else
						TriggerClientEvent("esx:showNotification", source, _U('invalid_lastname_format'), "error")
						cb(false)
					end
				else
					TriggerClientEvent("esx:showNotification", source, _U('invalid_firstname_format'), "error")
					cb(false)
				end
			else
				TriggerClientEvent("esx:showNotification", source, _U('data_incorrect'), "error")
                cb(false)
			end
		end
	end)
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
                xPlayer.kick(_U('deleted_identity'))
                Wait(1500)
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
