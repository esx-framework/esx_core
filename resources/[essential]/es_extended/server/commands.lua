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

TriggerEvent('es:addGroupCommand', 'givemoney', 'admin', function(source, args, user)
	
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(args[2])
	local amount  = tonumber(args[3])
	
	if amount ~= nil then
		xPlayer.addMoney(amount)
	else
		TriggerClientEvent('esx:showNotification', _source, 'Montant invalide')
	end

end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = 'givemoney [id] [montant]'})

TriggerEvent('es:addGroupCommand', 'giveaccountmoney', 'admin', function(source, args, user)
	
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(args[2])
	local account = args[3]
	local amount  = tonumber(args[4])
	
	if amount ~= nil then
		if xPlayer.getAccount(account) ~= nil then
			xPlayer.addAccountMoney(account, amount)
		else
			TriggerClientEvent('esx:showNotification', _source, 'Compte invalide')
		end
	else
		TriggerClientEvent('esx:showNotification', _source, 'Montant invalide')
	end

end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = 'giveaccountmoney [id] [compte] [montant]'})

TriggerEvent('es:addGroupCommand', 'giveitem', 'admin', function(source, args, user)
	
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(args[2])
	local item    = args[3]
	local count   = (args[4] == nil and 1 or tonumber(args[4]))
	
	if count ~= nil then
		if xPlayer.getInventoryItem(item) ~= nil then
			xPlayer.addInventoryItem(item, count)
		else
			TriggerClientEvent('esx:showNotification', _source, 'Item invalide')
		end
	else
		TriggerClientEvent('esx:showNotification', _source, 'Quantité invalide')
	end

end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = 'giveitem [id] [item] [[quantité]]'})

TriggerEvent('es:addGroupCommand', 'giveweapon', 'admin', function(source, args, user)
	
	local xPlayer    = ESX.GetPlayerFromId(args[2])
	local weaponName = string.upper(args[3])
	
	xPlayer.addWeapon(weaponName, 1000)

end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = 'giveweapon [id] [arme]'})
