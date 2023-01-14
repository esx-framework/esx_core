RegisterNetEvent('esx:playerLoaded') -- Store the players data
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew)
	print(('Player Loaded. New | %s'):format(isNew))
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:playerLogout') -- When a player logs out (multicharacter), reset their data
AddEventHandler('esx:playerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

-- These two functions can perform the same task
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	print('PlayerData.job was set to '..job)
	if ESX.PlayerData.job.name ~= job.name then
		print('You are now in a different job')
	end
	ESX.PlayerData.job = job
end)

function OnPlayerData(key, val, last)
	if type(val) == 'table' then val = json.encode(val) end
	print(('PlayerData.%s was set to %s'):format(key, val))
	if key == 'job' then
		if last.name ~= val.name then
			print('You are now in a different job')
		end
	elseif key == 'dead' then -- However, this function can be used for other PlayerData
		if val == true then
			print('You die too easily')
			SetTimeout(2000, function()
				if ESX.PlayerData.dead then
					print('Why are you still dead?')
				end
			end)
		end
	end
end
-----------------------------------------------

RegisterCommand('closestobject', function()
	local result = ESX.Game.GetClosestObject(GetEntityCoords(PlayerPedId()))
	print(result)
end)

RegisterCommand('closestped', function()
	local result = ESX.Game.GetClosestPed(GetEntityCoords(PlayerPedId()))
	print(result)
end)

RegisterCommand('closestplayer', function()
	local result = ESX.Game.GetClosestPlayer(GetEntityCoords(PlayerPedId()))
	print(result)
end)

RegisterCommand('closestvehicle', function()
	local result = ESX.Game.GetClosestVehicle(GetEntityCoords(PlayerPedId()))
	print(result)
end)

RegisterCommand('areaplayer', function()
	local result = ESX.Game.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 20)
	print(json.encode(result))
end)

RegisterCommand('areavehicle', function()
	local result = ESX.Game.GetVehiclesInArea(GetEntityCoords(PlayerPedId()), 20)
	print(json.encode(result))
end)
