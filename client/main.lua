RegisterNetEvent('esx_rpchat:sendProximityMessage')
AddEventHandler('esx_rpchat:sendProximityMessage', function(playerId, title, message, color)
	local source = PlayerId()
	local target = GetPlayerFromServerId(playerId)

	local sourcePed, targetPed = PlayerPedId(), GetPlayerPed(target)
	local sourceCoords, targetCoords = GetEntityCoords(sourcePed), GetEntityCoords(targetPed)

	if target == source then
		TriggerEvent('chat:addMessage', { args = { title, message }, color = color })
	elseif GetDistanceBetweenCoords(sourceCoords, targetCoords, true) < 20 then
		TriggerEvent('chat:addMessage', { args = { title, message }, color = color })
	end
end)

Citizen.CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/twt',  _U('twt_help'),  { { name = _U('generic_argument_name'), help = _U('generic_argument_help') } } )
	TriggerEvent('chat:addSuggestion', '/me',   _U('me_help'),   { { name = _U('generic_argument_name'), help = _U('generic_argument_help') } } )
	TriggerEvent('chat:addSuggestion', '/do',   _U('do_help'),   { { name = _U('generic_argument_name'), help = _U('generic_argument_help') } } )
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('chat:removeSuggestion', '/twt')
		TriggerEvent('chat:removeSuggestion', '/me')
		TriggerEvent('chat:removeSuggestion', '/do')
	end
end)
