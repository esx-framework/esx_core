TriggerEvent('es:addGroupCommand', 'tp', 'admin', function(source, args, user)

	TriggerClientEvent("esx:teleport", source, {
		x = tonumber(args[2]),
		y = tonumber(args[3]),
		z = tonumber(args[4])
	})

end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end)

TriggerEvent('es:addGroupCommand', 'setjob', 'jobmaster', function(source, args, user)
	local xPlayer = ESX.GetPlayerFromId(args[2])
	xPlayer.setJob(args[3], tonumber(args[4]))
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = 'Assigner job => setjob [id] [job] [grade_id]'})

TriggerEvent('es:addGroupCommand', 'loadipl', 'admin', function(source, args, user)
	TriggerClientEvent('esx:loadIPL', -1, args[2])
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = 'Charger ipl'})

TriggerEvent('es:addGroupCommand', 'unloadipl', 'admin', function(source, args, user)
	TriggerClientEvent('esx:unloadIPL', -1, args[2])
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = 'Décharger ipl'})

TriggerEvent('es:addGroupCommand', 'playanim', 'admin', function(source, args, user)
	TriggerClientEvent('esx:playAnim', -1, args[2], args[3])
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = 'Jouer animation'})

TriggerEvent('es:addGroupCommand', 'playemote', 'admin', function(source, args, user)
	TriggerClientEvent('esx:playEmote', -1, args[2])
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = 'Jouer emote'})

TriggerEvent('es:addGroupCommand', 'car', 'admin', function(source, args, user)
	TriggerClientEvent('esx:spawnVehicle', source, args[2])
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = 'Spawn un véhicule'})

