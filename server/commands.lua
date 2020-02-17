ESX.RegisterCommand('setcoords', 'admin', function(xPlayer, args, showError)
	xPlayer.setCoords({x = args.x, y = args.y, z = args.z})
end, false, {help = 'Teleport to coordinates', validate = true, arguments = {
	{name = 'x', help = 'X coords', type = 'number'},
	{name = 'y', help = 'Y coords', type = 'number'},
	{name = 'z', help = 'Z coords', type = 'number'}
}})

ESX.RegisterCommand('setjob', 'admin', function(xPlayer, args, showError)
	if ESX.DoesJobExist(args.job, args.grade) then
		args.playerId.setJob(args.job, args.grade)
	else
		showError('That job does not exist')
	end
end, true, {help = _U('setjob'), validate = true, arguments = {
	{name = 'playerId', help = _U('id_param'), type = 'player'},
	{name = 'job', help = _U('setjob_param2'), type = 'string'},
	{name = 'grade', help = _U('setjob_param3'), type = 'number'}
}})

ESX.RegisterCommand('car', 'admin', function(xPlayer, args, showError)
	xPlayer.triggerEvent('esx:spawnVehicle', args.car)
end, false, {help = _U('spawn_car'), validate = false, arguments = {
	{name = 'car', help = _U('spawn_car_param'), type = 'any'}
}})

ESX.RegisterCommand({'cardel', 'dv'}, 'admin', function(xPlayer, args, showError)
	xPlayer.triggerEvent('esx:deleteVehicle', args.radius)
end, false, {help = _U('spawn_car'), validate = false, arguments = {
	{name = 'radius', help = 'Optional, delete every vehicle within the specified radius', type = 'any'}
}})

ESX.RegisterCommand('giveaccountmoney', 'admin', function(xPlayer, args, showError)
	if args.playerId.getAccount(args.account) then
		args.playerId.addAccountMoney(args.account, args.amount)
	else
		showError(_U('invalid_account'))
	end
end, true, {help = _U('giveaccountmoney'), validate = true, arguments = {
	{name = 'playerId', help = _U('id_param'), type = 'player'},
	{name = 'account', help = _U('account'), type = 'string'},
	{name = 'amount', help = _U('money_amount'), type = 'number'}
}})

ESX.RegisterCommand('giveitem', 'admin', function(xPlayer, args, showError)
	args.playerId.addInventoryItem(args.item, args.count)
end, true, {help = _U('giveitem'), validate = true, arguments = {
	{name = 'playerId', help = _U('id_param'), type = 'player'},
	{name = 'item', help = _U('item'), type = 'item'},
	{name = 'count', help = _U('amount'), type = 'number'}
}})

ESX.RegisterCommand('giveweapon', 'admin', function(xPlayer, args, showError)
	if args.playerId.hasWeapon(args.weapon) then
		showError('Player already has that weapon')
	else
		xPlayer.addWeapon(args.weapon, args.ammo)
	end
end, true, {help = _U('giveweapon'), validate = true, arguments = {
	{name = 'playerId', help = _U('id_param'), type = 'player'},
	{name = 'weapon', help = _U('weapon'), type = 'weapon'},
	{name = 'ammo', help = _U('amountammo'), type = 'number'}
}})

ESX.RegisterCommand('giveweaponcomponent', 'admin', function(xPlayer, args, showError)
	if args.playerId.hasWeapon(args.weaponName) then
		local component = ESX.GetWeaponComponent(args.weaponName, args.componentName)

		if component then
			if xPlayer.hasWeaponComponent(args.weaponName, args.componentName) then
				showError('Player already has that weapon component')
			else
				xPlayer.addWeaponComponent(args.weaponName, args.componentName)
			end
		else
			showError('Invalid weapon component')
		end
	else
		showError('Player does not have that weapon')
	end
end, true, {help = 'Give weapon component', validate = true, arguments = {
	{name = 'playerId', help = _U('id_param'), type = 'player'},
	{name = 'weaponName', help = _U('weapon'), type = 'weapon'},
	{name = 'componentName', help = 'weapon component', type = 'string'}
}})

ESX.RegisterCommand({'clear', 'cls'}, 'user', function(xPlayer, args, showError)
	xPlayer.triggerEvent('chat:clear')
end, false, {help = _U('chat_clear')})

ESX.RegisterCommand({'clearall', 'clsall'}, 'admin', function(xPlayer, args, showError)
	TriggerClientEvent('chat:clear', -1)
end, false, {help = _U('chat_clear_all')})

ESX.RegisterCommand('clearinventory', 'admin', function(xPlayer, args, showError)
	for k,v in ipairs(args.playerId.inventory) do
		if v.count > 0 then
			args.playerId.setInventoryItem(v.name, 0)
		end
	end
end, true, {help = _U('command_clearinventory'), validate = true, arguments = {
	{name = 'playerId', help = _U('id_param'), type = 'player'}
}})

ESX.RegisterCommand('clearloadout', 'admin', function(xPlayer, args, showError)
	for k,v in ipairs(args.playerId.loadout) do
		args.playerId.removeWeapon(v.name)
	end
end, true, {help = _U('command_clearloadout'), validate = true, arguments = {
	{name = 'playerId', help = _U('id_param'), type = 'player'}
}})
