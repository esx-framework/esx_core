RegisterNetEvent('esx_rpchat:sendProximityMessage')
AddEventHandler('esx_rpchat:sendProximityMessage', function(id, title, message, color)
	local source = PlayerId()
	local target = GetPlayerFromServerId(id)

	if target == source then
		TriggerEvent('chat:addMessage', { args = { title, message }, color = color })
	elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(source)), GetEntityCoords(GetPlayerPed(target)), true) < 19 then
		TriggerEvent('chat:addMessage', { args = { title, message }, color = color })
	end
end)

Citizen.CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/ooc',  _U('ooc_help'),  { { name = _U('ooc_argument_name'), help = _U('ooc_argument_help') } } )
	TriggerEvent('chat:addSuggestion', '/twt',  _U('twt_help'),  { { name = _U('ooc_argument_name'), help = _U('ooc_argument_help') } } )
	TriggerEvent('chat:addSuggestion', '/me',   _U('me_help'),   { { name = _U('ooc_argument_name'), help = _U('ooc_argument_help') } } )
	TriggerEvent('chat:addSuggestion', '/do',   _U('do_help'),   { { name = _U('ooc_argument_name'), help = _U('ooc_argument_help') } } )
	TriggerEvent('chat:addSuggestion', '/news', _U('news_help'), { { name = _U('ooc_argument_name'), help = _U('ooc_argument_help') } } )
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('chat:removeSuggestion', '/ooc')
		TriggerEvent('chat:removeSuggestion', '/twt')
		TriggerEvent('chat:removeSuggestion', '/me')
		TriggerEvent('chat:removeSuggestion', '/do')
		TriggerEvent('chat:removeSuggestion', '/news')
	end
end)
