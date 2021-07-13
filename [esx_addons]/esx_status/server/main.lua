AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  	return
	end
	
	for _, xPlayer in pairs(ESX.Players) do
		local status = xPlayer.get('status')
		if status then
			ESX.Players[xPlayer.source] = status
		else
			MySQL.Async.fetchAll('SELECT status FROM users WHERE identifier = @identifier', {
				['@identifier'] = xPlayer.identifier
			}, function(result)
				local data = {}
		
				if result[1].status then
					data = json.decode(result[1].status)
				end
			
				xPlayer.set('status', data)	-- save to xPlayer for compatibility
				ESX.Players[xPlayer.source] = data -- save locally for performance
			end)
		end
		TriggerClientEvent('esx_status:load', xPlayer.source, data)
	end
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	MySQL.Async.fetchAll('SELECT status FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		local data = {}

		if result[1].status then
			data = json.decode(result[1].status)
		end

		xPlayer.set('status', data)
		ESX.Players[xPlayer.source] = data
		TriggerClientEvent('esx_status:load', playerId, data)
	end)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	local status = ESX.Players[xPlayer.source]

	MySQL.Async.execute('UPDATE users SET status = @status WHERE identifier = @identifier', {
		['@status']     = json.encode(status),
		['@identifier'] = xPlayer.identifier
	}, function(result)
		ESX.Players[xPlayer.source] = nil
	end)
end)

AddEventHandler('esx_status:getStatus', function(playerId, statusName, cb)
	for i=1, #ESX.Players, 1 do
		if status[i].name == statusName then
			cb(status[i])
			break
		end
	end
end)

RegisterServerEvent('esx_status:update')
AddEventHandler('esx_status:update', function(status)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		xPlayer.set('status', status)	-- save to xPlayer for compatibility
		ESX.Players[xPlayer.source] = status	-- save locally for performance
	end
end)

Citizen.CreateThread(function()
	while(true) do
		Citizen.Wait(10 * 60 * 1000)
		SaveData()
	end
end)

function SaveData()
	-- Example of a bulk update statement that we are building below
	--[[
	UPDATE users
    SET status = (case when identifier = 'license:123' then '{hunger:45, thirst:23}'
                         when identifier = 'license:456' then '{hunger:1000, thirst:1000}'
                         when identifier = 'license:789' then '{hunger:1000, thirst:1000}'
                    end)
    WHERE identifier in ('license:123', 'license:456', 'license:789')

	]]
	local updateStatement = 'UPDATE users SET status = (case %s end) where identifier in (%s)'
	local whenList = ''
	local whereList = ''
	local firstItem = true
	local playerCount = 0

	local xPlayers = ESX.GetExtendedPlayers()
	
	for _, xPlayer in pairs(xPlayers) do
		local status = ESX.Players[xPlayer.source]
		if status then
			whenList = whenList .. string.format('when identifier = \'%s\' then \'%s\' ', xPlayer.identifier, json.encode(status))

			if firstItem == false then
				whereList = whereList .. ', '
			end
			whereList = whereList .. string.format('\'%s\'', xPlayer.identifier)

			firstItem = false
			playerCount = playerCount + 1
		end
	end

	if playerCount > 0 then
		local sql = string.format(updateStatement, whenList, whereList)
		MySQL.Async.execute(sql)

	end

end
