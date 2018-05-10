AddEventHandler('chatMessage', function(source, name, msg)
	local command = stringsplit(msg, " ")[1];

	if command == "/ooc" then
		CancelEvent()
		if Config.EnableESXIdentity then name = GetCharacterName(source) end
		TriggerClientEvent('chatMessage', -1, _U('ooc_prefix', name), { 128, 128, 128 }, string.sub(msg, 5))
	elseif command == "/twt" then
		CancelEvent()
		if Config.EnableESXIdentity then name = GetCharacterName(source) end
		TriggerClientEvent('chatMessage', -1, _U('twt_prefix', name), { 0, 153, 204 }, string.sub(msg, 5))
	elseif command == "/me" then
		CancelEvent()
		if Config.EnableESXIdentity then name = GetCharacterName(source) end
		TriggerClientEvent('esx_rpchat:sendProximityMessage', -1, source, _U('me_prefix', name), string.sub(msg, 4), { 255, 0, 0 })
	elseif command == "/news" then
		CancelEvent()
		if Config.EnableESXIdentity then name = GetCharacterName(source) end
		TriggerClientEvent('chatMessage', -1, _U('news_prefix', name), { 249, 166, 0 }, string.sub(msg, 6))
	elseif string.sub(command, 1, 1) == "/" then
		CancelEvent()
		TriggerClientEvent('chatMessage', source, '', {132, 13, 37}, _U('ooc_unknown_command', command))
	end
end)

function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

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