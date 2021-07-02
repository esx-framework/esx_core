ESX.RegisterCommand('setcoords', 'admin', function(xPlayer, args, showError)
	xPlayer.setCoords({x = args.x, y = args.y, z = args.z})
end, false, {help = _U('command_setcoords'), validate = true, arguments = {
	{name = 'x', help = _U('command_setcoords_x'), type = 'number'},
	{name = 'y', help = _U('command_setcoords_y'), type = 'number'},
	{name = 'z', help = _U('command_setcoords_z'), type = 'number'}
}})

ESX.RegisterCommand('setjob', 'admin', function(xPlayer, args, showError)
	if ESX.DoesJobExist(args.job, args.grade) then
		args.playerId.setJob(args.job, args.grade)
	else
		showError(_U('command_setjob_invalid'))
	end
end, true, {help = _U('command_setjob'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'job', help = _U('command_setjob_job'), type = 'string'},
	{name = 'grade', help = _U('command_setjob_grade'), type = 'number'}
}})

ESX.RegisterCommand('car', 'admin', function(xPlayer, args, showError)
	if not args.car then args.car = "baller2" end
	xPlayer.triggerEvent('esx:spawnVehicle', args.car)
end, false, {help = _U('command_car'), validate = false, arguments = {
	{name = 'car', help = _U('command_car_car'), type = 'any'}
}})

ESX.RegisterCommand({'cardel', 'dv'}, 'admin', function(xPlayer, args, showError)
	if not args.radius then args.radius = 4 end
	xPlayer.triggerEvent('esx:deleteVehicle', args.radius)
end, false, {help = _U('command_cardel'), validate = false, arguments = {
	{name = 'radius', help = _U('command_cardel_radius'), type = 'any'}
}})

ESX.RegisterCommand('setaccountmoney', 'admin', function(xPlayer, args, showError)
	if args.playerId.getAccount(args.account) then
		args.playerId.setAccountMoney(args.account, args.amount)
	else
		showError(_U('command_giveaccountmoney_invalid'))
	end
end, true, {help = _U('command_setaccountmoney'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'account', help = _U('command_giveaccountmoney_account'), type = 'string'},
	{name = 'amount', help = _U('command_setaccountmoney_amount'), type = 'number'}
}})

ESX.RegisterCommand('giveaccountmoney', 'admin', function(xPlayer, args, showError)
	if args.playerId.getAccount(args.account) then
		args.playerId.addAccountMoney(args.account, args.amount)
	else
		showError(_U('command_giveaccountmoney_invalid'))
	end
end, true, {help = _U('command_giveaccountmoney'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'account', help = _U('command_giveaccountmoney_account'), type = 'string'},
	{name = 'amount', help = _U('command_giveaccountmoney_amount'), type = 'number'}
}})

ESX.RegisterCommand('giveitem', 'admin', function(xPlayer, args, showError)
	args.playerId.addInventoryItem(args.item, args.count)
end, true, {help = _U('command_giveitem'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'item', help = _U('command_giveitem_item'), type = 'item'},
	{name = 'count', help = _U('command_giveitem_count'), type = 'number'}
}})

ESX.RegisterCommand('giveweapon', 'admin', function(xPlayer, args, showError)
	if args.playerId.hasWeapon(args.weapon) then
		showError(_U('command_giveweapon_hasalready'))
	else
		args.playerId.addWeapon(args.weapon, args.ammo)
	end
end, true, {help = _U('command_giveweapon'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'weapon', help = _U('command_giveweapon_weapon'), type = 'weapon'},
	{name = 'ammo', help = _U('command_giveweapon_ammo'), type = 'number'}
}})

ESX.RegisterCommand('giveweaponcomponent', 'admin', function(xPlayer, args, showError)
	if args.playerId.hasWeapon(args.weaponName) then
		local component = ESX.GetWeaponComponent(args.weaponName, args.componentName)

		if component then
			if args.playerId.hasWeaponComponent(args.weaponName, args.componentName) then
				showError(_U('command_giveweaponcomponent_hasalready'))
			else
				args.playerId.addWeaponComponent(args.weaponName, args.componentName)
			end
		else
			showError(_U('command_giveweaponcomponent_invalid'))
		end
	else
		showError(_U('command_giveweaponcomponent_missingweapon'))
	end
end, true, {help = _U('command_giveweaponcomponent'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'weaponName', help = _U('command_giveweapon_weapon'), type = 'weapon'},
	{name = 'componentName', help = _U('command_giveweaponcomponent_component'), type = 'string'}
}})

ESX.RegisterCommand({'clear', 'cls'}, 'user', function(xPlayer, args, showError)
	xPlayer.triggerEvent('chat:clear')
end, false, {help = _U('command_clear')})

ESX.RegisterCommand({'clearall', 'clsall'}, 'admin', function(xPlayer, args, showError)
	TriggerClientEvent('chat:clear', -1)
end, false, {help = _U('command_clearall')})

ESX.RegisterCommand('clearinventory', 'admin', function(xPlayer, args, showError)
	for k,v in ipairs(args.playerId.inventory) do
		if v.count > 0 then
			args.playerId.setInventoryItem(v.name, 0)
		end
	end
end, true, {help = _U('command_clearinventory'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('clearloadout', 'admin', function(xPlayer, args, showError)
	for i=#args.playerId.loadout, 1, -1 do
		args.playerId.removeWeapon(args.playerId.loadout[i].name)
	end
end, true, {help = _U('command_clearloadout'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('setgroup', 'admin', function(xPlayer, args, showError)
	if not args.playerId then args.playerId = xPlayer.source end
	if args.group == "superadmin" then args.group = "admin" end
	args.playerId.setGroup(args.group)
end, true, {help = _U('command_setgroup'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'group', help = _U('command_setgroup_group'), type = 'string'},
}})

ESX.RegisterCommand('save', 'admin', function(xPlayer, args, showError)
	ESX.SavePlayer(args.playerId)
end, true, {help = _U('command_save'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('saveall', 'admin', function(xPlayer, args, showError)
	ESX.SavePlayers()
end, true, {help = _U('command_saveall')})

ESX.RegisterCommand('group', {"user", "admin"}, function(xPlayer, args, showError)
	print(xPlayer.getName()..", You are currently: ^5".. xPlayer.getGroup())
end, true)

ESX.RegisterCommand('job', {"user", "admin"}, function(xPlayer, args, showError)
print(xPlayer.getName()..", You are currently: ^5".. xPlayer.getJob().name.. "^0 - ^5".. xPlayer.getJob().grade_label)
end, true)

ESX.RegisterCommand('info', {"user", "admin"}, function(xPlayer, args, showError)
	local job = xPlayer.getJob().name
	local jobgrade = xPlayer.getJob().grade_name
	print("^2ID : ^5"..xPlayer.source.." ^0| ^2Name:^5"..xPlayer.getName().." ^0 | ^2Group:^5"..xPlayer.getGroup().."^0 | ^2Job:^5".. job.."")
	end, true)

ESX.RegisterCommand('coords', "admin", function(xPlayer, args, showError)
	print("".. xPlayer.getName().. ": ^5".. xPlayer.getCoords(true))
end, true)

ESX.RegisterCommand('tpm', "admin", function(xPlayer, args, showError)
	xPlayer.triggerEvent("esx:tpm")
end, true)

ESX.RegisterCommand('goto', "admin", function(xPlayer, args, showError)
		local targetCoords = args.playerId.getCoords()
		xPlayer.setCoords(targetCoords)
end, true, {help = _U('goto'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('bring', "admin", function(xPlayer, args, showError)
		local playerCoords = xPlayer.getCoords()
		args.playerId.setCoords(playerCoords)
end, true, {help = _U('bring'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('kill', "admin", function(xPlayer, args, showError)
	args.playerId.triggerEvent('esx:killPlayer')
end, true, {help = _U('kill'), validate = true, arguments = {
{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('freeze', "admin", function(xPlayer, args, showError)
	args.playerId.triggerEvent('esx:freezePlayer', "freeze")
end, true, {help = _U('kill'), validate = true, arguments = {
{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('unfreeze', "admin", function(xPlayer, args, showError)
	args.playerId.triggerEvent('esx:freezePlayer', "unfreeze")
end, true, {help = _U('kill'), validate = true, arguments = {
{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('reviveall', "admin", function(xPlayer, args, showError)
	for _, playerId in ipairs(GetPlayers()) do
		TriggerClientEvent('esx_ambulancejob:revive', playerId)
	end
end, false)

ESX.RegisterCommand("noclip", 'admin', function(xPlayer, args, showError)
	xPlayer.triggerEvent('esx:noclip')
end, false)

ESX.RegisterCommand('players', "admin", function(xPlayer, args, showError)
	local xAll = ESX.GetPlayers()
	print("^5"..#xAll.." ^2online player(s)^0")
	for i=1, #xAll, 1 do
		local xPlayer = ESX.GetPlayerFromId(xAll[i])
		print("^1[ ^2ID : ^5"..xPlayer.source.." ^0| ^2Name : ^5"..xPlayer.getName().." ^0 | ^2Group : ^5"..xPlayer.getGroup().." ^0 | ^2Identifier : ^5".. xPlayer.identifier .."^1]^0\n")
	end
end, true)
