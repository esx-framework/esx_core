AddEventHandler('chatMessage', function(source, author, message)
	if string.sub(message, 1, 1) == "/" then
		CancelEvent()
		TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', _U('ooc_unknown_command', message:match("^(%S+)")) } })
	end
end)

RegisterCommand('ooc', function(source, args, rawCommand)
	if source == 0 then
		print('esx_rpchat: you can\'t use this command from rcon!')
		return
	end

	rawCommand = string.sub(rawCommand, 4)
	local name = GetPlayerName(source)
	if Config.EnableESXIdentity then name = GetCharacterName(source) end

	TriggerClientEvent('chat:addMessage', -1, { args = { _U('ooc_prefix', name), rawCommand }, color = { 128, 128, 128 } })
end, false)

RegisterCommand('twt', function(source, args, rawCommand)
	if source == 0 then
		print('esx_rpchat: you can\'t use this command from rcon!')
		return
	end

	rawCommand = string.sub(rawCommand, 4)
	local name = GetPlayerName(source)
	if Config.EnableESXIdentity then name = GetCharacterName(source) end

	TriggerClientEvent('chat:addMessage', -1, { args = { _U('twt_prefix', name), rawCommand }, color = { 0, 153, 204 } })
end, false)

RegisterCommand('me', function(source, args, rawCommand)
	if source == 0 then
		print('esx_rpchat: you can\'t use this command from rcon!')
		return
	end

	rawCommand = string.sub(rawCommand, 3)
	local name = GetPlayerName(source)
	if Config.EnableESXIdentity then name = GetCharacterName(source) end

	TriggerClientEvent('esx_rpchat:sendProximityMessage', -1, source, _U('me_prefix', name), rawCommand, { 255, 0, 0 })
end, false)

RegisterCommand('do', function(source, args, rawCommand)
	if source == 0 then
		print('esx_rpchat: you can\'t use this command from rcon!')
		return
	end

	rawCommand = string.sub(rawCommand, 3)
	local name = GetPlayerName(source)
	if Config.EnableESXIdentity then name = GetCharacterName(source) end

	TriggerClientEvent('esx_rpchat:sendProximityMessage', -1, source, _U('do_prefix', name), rawCommand, { 0, 0, 255 })
end, false)

RegisterCommand('news', function(source, args, rawCommand)
	if source == 0 then
		print('esx_rpchat: you can\'t use this command from rcon!')
		return
	end

	rawCommand = string.sub(rawCommand, 5)
	local name = GetPlayerName(source)
	if Config.EnableESXIdentity then name = GetCharacterName(source) end

	TriggerClientEvent('chat:addMessage', -1, { args = { _U('news_prefix', name), rawCommand }, color = { 249, 166, 0 } })
end, false)

function GetCharacterName(source)
	-- fetch identity in sync
	local result = MySQL.Sync.fetchAll('SELECT * FROM users WHERE identifier = @identifier',
	{
		['@identifier'] = GetPlayerIdentifiers(source)[1]
	})

	if result[1] ~= nil and result[1].firstname ~= nil and result[1].lastname ~= nil then
		if Config.OnlyFirstname then
			return result[1].firstname
		else
			return result[1].firstname .. ' ' .. result[1].lastname
		end
	else
		return GetPlayerName(source)
	end
end
