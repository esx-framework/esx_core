CreateThread(function()
	Wait(3000)
	print('^1Do not run this resource in a live environment, it is solely intended for showcasing ESX functions^0')
end)

RegisterNetEvent('esx:playerLoaded') -- When a player loads in, we can store some basic information about them locally
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	print("Player | ".. playerId .. "spawned in")
	ESX.Players[playerId] = xPlayer.job.name
end)

RegisterNetEvent('esx:setJob') -- The stored data does not sync with the framework unless we tell it to
AddEventHandler('esx:setJob', function(playerId, job)
	print("Player | ".. playerId .. " | Changed Job. Job |".. job.label)
	ESX.Players[playerId] = job.name
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)	-- Remove any cached data once the player no longer exists
	print("Player | ".. playerId .. "Dropped. Reason | ".. reason)
	ESX.Players[playerId] = nil
end)

AddEventHandler('onResourceStart', function(resourceName) -- The resource just restarted so we actually have a fresh copy of ESX.Players from the framework
	if (GetCurrentResourceName() == resourceName) then -- Useful if we need to run functions or send events after a restart
		local players = {}
		for _, xPlayer in pairs(ESX.Players) do
			players[xPlayer.source] = xPlayer.job.name
			print( ('%s %s is online with player id %s'):format(xPlayer.job.grade_label, xPlayer.name, xPlayer.source) )
		end
		ESX.Players = players -- Replace the data as it is a waste of memory
	end
end)

ESX.RegisterCommand('get', 'user', function(xPlayer, args)
	print("Player |".. xPlayer.source.. "| Fetching all users.")
	local xPlayers = ESX.GetExtendedPlayers(args.key, args.val) -- New hitchless xPlayer loop, with the ability to only return players with specific data
	for _, xTarget in pairs(xPlayers) do					 	-- Job and any non-table variable will work, ie. name, group, identifier, source
		print("ID - ".. xTarget.source.." | Name - "..xTarget.getName().." | Job - ".. xTarget.job.label)
	end
end, true, {help = 'Display all online players with specific player data', validate = false, arguments = {
	{name = 'key', help = 'Variable to check (ie. job)', type = 'string'},
	{name = 'val', help = 'Value required (ie. police)', type = 'any'}
}})
