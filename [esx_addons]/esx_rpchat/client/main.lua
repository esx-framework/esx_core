RegisterNetEvent('esx_rpchat:sendProximityMessage')
AddEventHandler('esx_rpchat:sendProximityMessage', function(playerId, title, message, color)
	local player = PlayerId()
	local target = GetPlayerFromServerId(playerId)

	local playerPed = PlayerPedId()
	local targetPed = GetPlayerPed(target)
	local playerCoords = GetEntityCoords(playerPed)
	local targetCoords = GetEntityCoords(targetPed)

	if target ~= -1 then
		if target == player or #(playerCoords - targetCoords) < 20 then
			TriggerEvent('chat:addMessage', {args = {title, message}, color = color})
		end
	end
end)

CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/twt',  TranslateCap('twt_help'),  {{name = TranslateCap('generic_argument_name'), help = TranslateCap('generic_argument_help')}})
	TriggerEvent('chat:addSuggestion', '/anontwt',  TranslateCap('twtanon_help'),  {{name = TranslateCap('generic_argument_name'), help = TranslateCap('generic_argument_help')}})
	TriggerEvent('chat:addSuggestion', '/me',   TranslateCap('me_help'),   {{name = TranslateCap('generic_argument_name'), help = TranslateCap('generic_argument_help')}})
	TriggerEvent('chat:addSuggestion', '/do',   TranslateCap('do_help'),   {{name = TranslateCap('generic_argument_name'), help = TranslateCap('generic_argument_help')}})
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('chat:removeSuggestion', '/twt')
		TriggerEvent('chat:removeSuggestion', '/me')
		TriggerEvent('chat:removeSuggestion', '/do')
	end
end)

