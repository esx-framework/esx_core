ESX.RegisterCommand('setslots', 'admin', function(xPlayer, args, showError)
	local slots = MySQL.scalar('SELECT `slots` FROM `multicharacter_slots` WHERE identifier = ?', {
		args.identifier
	})

	if not slots then
		MySQL.update('INSERT INTO `multicharacter_slots` (`identifier`, `slots`) VALUES (?, ?)', {
			args.identifier,
			args.slots
		})
		xPlayer.triggerEvent('esx:showNotification', _U('slotsadd', args.slots, args.identifier))
	else
		MySQL.update('UPDATE `multicharacter_slots` SET `slots` = ? WHERE `identifier` = ?', {
			args.slots,
			args.identifier
		})
		xPlayer.triggerEvent('esx:showNotification', _U('slotsedit', args.slots, args.identifier))
	end
end, true, {help = _U('command_setslots'), validate = true, arguments = {
	{name = 'identifier', help = _U('command_identifier'), type = 'string'},
	{name = 'slots', help = _U('command_slots'), type = 'number'}
}})

ESX.RegisterCommand('remslots', 'admin', function(xPlayer, args, showError)
	local slots = MySQL.scalar('SELECT `slots` FROM `multicharacter_slots` WHERE identifier = ?', {
		args.identifier
	})

	if slots then
		MySQL.update('DELETE FROM `multicharacter_slots` WHERE `identifier` = ?', {
			args.identifier
		})
		xPlayer.triggerEvent('esx:showNotification', _U('slotsrem', args.identifier))
	end
end, true, {help = _U('command_remslots'), validate = true, arguments = {
	{name = 'identifier', help = _U('command_identifier'), type = 'string'}
}})

ESX.RegisterCommand('enablechar', 'admin', function(xPlayer, args, showError)

	local selectedCharacter = 'char'..args.charslot..':'..args.identifier;
 
	MySQL.update('UPDATE `users` SET `disabled` = 0 WHERE identifier = ?', {
		selectedCharacter
	}, function(result)
		if result > 0 then
			xPlayer.triggerEvent('esx:showNotification', _U('charenabled', args.charslot, args.identifier))
		else
			xPlayer.triggerEvent('esx:showNotification', _U('charnotfound', args.charslot, args.identifier))
		end
	end)

end, true, {help = _U('command_enablechar'), validate = true, arguments = {
	{name = 'identifier', help = _U('command_identifier'), type = 'string'},
	{name = 'charslot', help = _U('command_charslot'), type = 'number'}
}})

ESX.RegisterCommand('disablechar', 'admin', function(xPlayer, args, showError)

	local selectedCharacter = 'char'..args.charslot..':'..args.identifier;
 
	MySQL.update('UPDATE `users` SET `disabled` = 1 WHERE identifier = ?', {
		selectedCharacter
	}, function(result)
		if result > 0 then
			xPlayer.triggerEvent('esx:showNotification', _U('chardisabled', args.charslot, args.identifier))
		else
			xPlayer.triggerEvent('esx:showNotification', _U('charnotfound', args.charslot, args.identifier))
		end
	end)

end, true, {help = _U('command_disablechar'), validate = true, arguments = {
	{name = 'identifier', help = _U('command_identifier'), type = 'string'},
	{name = 'charslot', help = _U('command_charslot'), type = 'number'}
}})

RegisterCommand('forcelog', function(source, args, rawCommand)
	TriggerEvent('esx:playerLogout', source)
end, true)
