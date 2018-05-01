RegisterNetEvent('esx_rpchat:sendProximityMessage')
AddEventHandler('esx_rpchat:sendProximityMessage', function(id, prefix, message, color)
	local _source = PlayerId()
	local target = GetPlayerFromServerId(id)
	
	if target == _source then
		TriggerEvent('chatMessage', prefix, color, message)
	elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(_source)), GetEntityCoords(GetPlayerPed(target)), true) < 19.999 then
		TriggerEvent('chatMessage', prefix, color, message)
	end
end)

Citizen.CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/ooc',  _U('ooc_help'),  {{name=_U('ooc_argument_name'), help=_U('ooc_argument_help')}})
	TriggerEvent('chat:addSuggestion', '/twt',  _U('twt_help'),  {{name=_U('ooc_argument_name'), help=_U('ooc_argument_help')}})
	TriggerEvent('chat:addSuggestion', '/me',   _U('me_help'),   {{name=_U('ooc_argument_name'), help=_U('ooc_argument_help')}})
	TriggerEvent('chat:addSuggestion', '/news', _U('news_help'), {{name=_U('ooc_argument_name'), help=_U('ooc_argument_help')}})
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('chat:removeSuggestion', '/ooc')
		TriggerEvent('chat:removeSuggestion', '/twt')
		TriggerEvent('chat:removeSuggestion', '/me')
		TriggerEvent('chat:removeSuggestion', '/news')
	end
end)