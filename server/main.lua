ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
	ESX = obj
end)

local RegisteredCallbacks = {}
local DisptachRequestId   = 0

function GenerateUniquePhoneNumber()

	local foundNumber = false
	local phoneNumber = nil

	while not foundNumber do

		phoneNumber = math.random(10000, 99999)

		local result = MySQL.Sync.fetchAll(
			'SELECT COUNT(*) as count FROM users WHERE phone_number = @phoneNumber',
			{
				['@phoneNumber'] = phoneNumber
			}
		)

		local count  = tonumber(result[1].count)

		if count == 0 then
			foundNumber = true
		end

	end

	return phoneNumber
end

function GetDistpatchRequestId()

	local requestId = DisptachRequestId

	if DisptachRequestId < 65535 then
		DisptachRequestId = DisptachRequestId + 1
	else
		DisptachRequestId = 0
	end

	return requestId

end

AddEventHandler('esx_phone:getDistpatchRequestId', function(cb)
	cb(GetDistpatchRequestId())
end)

AddEventHandler('onResourceStart', function(ressource)
	if ressource == 'esx_phone' then
		TriggerEvent('esx_phone:ready')
	end
end)

AddEventHandler('esx:playerLoaded', function(source)

	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll(
		'SELECT * FROM users WHERE identifier = @identifier',
		{
			['@identifier'] = xPlayer.identifier
		},
		function(result)

			local phoneNumber = result[1].phone_number

			if phoneNumber == nil then

				phoneNumber = GenerateUniquePhoneNumber()

				MySQL.Async.execute(
					'UPDATE users SET phone_number = @phone_number WHERE identifier = @identifier',
					{
						['@identifier']   = xPlayer.identifier,
						['@phone_number'] = phoneNumber
					}
				)
			end

			xPlayer.set('phoneNumber', phoneNumber)

			local contacts = {}

			MySQL.Async.fetchAll(
				'SELECT * FROM user_contacts WHERE identifier = @identifier ORDER BY name ASC',
				{
					['@identifier'] = xPlayer.identifier
				},
				function(result2)

					for i=1, #result2, 1 do

						table.insert(contacts, {
							name   = result2[i].name,
							number = result2[i].number,
							online = false
						})

						local xPlayers = ESX.GetPlayers()

						for k, v in pairs(xPlayers) do
							if v.get('phoneNumber') == contacts[i].number then
								contacts[i].online = true
							end
						end

					end

					xPlayer.set('contacts', contacts)

					TriggerClientEvent('esx_phone:loaded', source, phoneNumber, contacts)

				end
			)

		end
	)

end)


RegisterServerEvent('esx_phone:reload')
AddEventHandler('esx_phone:reload', function(phoneNumber)

	local _source  = source
	local xPlayer  = ESX.GetPlayerFromId(_source)
	local contacts = {}

	MySQL.Async.fetchAll(
		'SELECT * FROM user_contacts WHERE identifier = @identifier ORDER BY name ASC',
		{
			['@identifier'] = xPlayer.identifier
		},
		function(result2)

			for i=1, #result2, 1 do

				table.insert(contacts, {
					name   = result2[i].name,
					number = result2[i].number,
					online = false
				})

				local xPlayers = ESX.GetPlayers()

				for k, v in pairs(xPlayers) do
					if v.get('phoneNumber') == contacts[i].number then
						contacts[i].online = true
					end
				end

			end

			xPlayer.set('contacts', contacts)

			TriggerClientEvent('esx_phone:loaded', _source, phoneNumber, contacts)

		end
	)

end)

RegisterServerEvent('esx_phone:registerCallback')
AddEventHandler('esx_phone:registerCallback', function(cb)
	table.insert(RegisteredCallbacks, cb)
end)

RegisterServerEvent('esx_phone:send')
AddEventHandler('esx_phone:send', function(phoneNumber, message, anon)

	local _source = source

	for i=1, #RegisteredCallbacks, 1 do
		RegisteredCallbacks[i](_source, phoneNumber, message, anon)
	end
end)

RegisterServerEvent('esx_phone:addPlayerContact')
AddEventHandler('esx_phone:addPlayerContact', function(phoneNumber, contactName)

	local _source     = source
	local xPlayer     = ESX.GetPlayerFromId(_source)
	local xPlayers    = ESX.GetPlayers()
	local foundNumber = false
	local foundPlayer = nil

	MySQL.Async.fetchAll(
		'SELECT phone_number FROM users WHERE phone_number = @number',
		{
			['@number'] = phoneNumber
		},
		function(result)

			if result[1] ~= nil then
				foundNumber = true
			end

			if foundNumber then

				if phoneNumber == xPlayer.get('phoneNumber') then
					TriggerClientEvent('esx:showNotification', _source, _U('cannot_add_self'))
				else

					local hasAlreadyAdded = false
					local contacts        = xPlayer.get('contacts')

					for i=1, #contacts, 1 do
						if contacts[i].number == phoneNumber then
							hasAlreadyAdded = true
						end
					end

					if hasAlreadyAdded then
						TriggerClientEvent('esx:showNotification', _source, _U('number_in_contacts'))
					else

						table.insert(contacts, {
							name   = contactName,
							number = phoneNumber,
						})

						xPlayer.set('contacts', contacts)

						MySQL.Async.execute(
							'INSERT INTO user_contacts (identifier, name, number) VALUES (@identifier, @name, @number)',
							{
								['@identifier'] = xPlayer.identifier,
								['@name']       = contactName,
								['@number']     = phoneNumber
							},
							function(rowsChanged)

								TriggerClientEvent('esx:showNotification', _source, _U('contact_added'))

								local xPlayers = ESX.GetPlayers()
								local isOnline = false

								for k,v in pairs(xPlayers) do
									if v.get('phoneNumber') == phoneNumber then
										isOnline = true
										break
									end
								end

								TriggerClientEvent('esx_phone:addContact', _source, contactName, phoneNumber, isOnline)
							end
						)

					end
				end

			else
				TriggerClientEvent('esx:showNotification', source, _U('number_not_assigned'))
			end

		end
	)

end)

AddEventHandler('esx_phone:ready', function()
	TriggerEvent('esx_phone:registerCallback', function(source, phoneNumber, message, anon)

		local xPlayer  = ESX.GetPlayerFromId(source)
		local xPlayers = ESX.GetPlayers()

		print('MESSAGE => ' .. xPlayer.name .. '@' .. phoneNumber .. ' : ' .. message)

		for k, v in pairs(xPlayers) do
 			if v.get('phoneNumber') == phoneNumber then
 				TriggerClientEvent('esx_phone:onMessage', v.source, xPlayer.get('phoneNumber'), message, false, anon, 'player', false)
 			end
 		end

	end)
end)

RegisterServerEvent('esx_phone:stopDispatch')
AddEventHandler('esx_phone:stopDispatch', function(dispatchRequestId)
	TriggerClientEvent('esx_phone:stopDispatch', -1, dispatchRequestId, GetPlayerName(source))
end)
