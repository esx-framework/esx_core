AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  	return
	end

	for _, xPlayer in pairs(ESX.Players) do
		local status = xPlayer.get('status')
		if status then
			ESX.Players[xPlayer.source] = status
		else
			exports.oxmysql:scalar('SELECT status FROM users WHERE identifier = ?', {
				xPlayer.identifier
			}, function(result)
				local data = result and json.decode(result) or {}

				xPlayer.set('status', data)	-- save to xPlayer for compatibility
				ESX.Players[xPlayer.source] = data -- save locally for performance
			end)
		end
		TriggerClientEvent('esx_status:load', xPlayer.source, data)
	end
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	exports.oxmysql:scalar('SELECT status FROM users WHERE identifier = ?', {
		xPlayer.identifier
	}, function(result)
		local data = result and json.decode(result) or {}

		xPlayer.set('status', data)
		ESX.Players[xPlayer.source] = data
		TriggerClientEvent('esx_status:load', playerId, data)
	end)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	local status = ESX.Players[xPlayer.source]

	exports.oxmysql:update('UPDATE users SET status = ? WHERE identifier = ?', {
		json.encode(status), xPlayer.identifier
	}, function(result)
		ESX.Players[xPlayer.source] = nil
	end)
end)

AddEventHandler('esx_status:getStatus', function(playerId, statusName, cb)
	local status = ESX.Players[playerId]
	for i=1, #status, 1 do
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
		xPlayer.set('status', status) -- save to xPlayer for compatibility
		ESX.Players[xPlayer.source] = status -- save locally for performance
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10 * 60 * 1000)
		local parameters = {}
		for _, xPlayer in pairs(ESX.GetExtendedPlayers()) do
			local status = ESX.Players[xPlayer.source]
			if status and next(status) then
				parameters[#parameters+1] = {json.encode(status), xPlayer.identifier}
			end
		end
		if #parameters > 0 then
			exports.oxmysql:prepare('UPDATE users SET status = ? WHERE identifier = ?', parameters)
		end
	end
end)
