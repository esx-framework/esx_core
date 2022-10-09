CreateThread(function()
	for k,v in pairs(Config.Food) do
		ESX.RegisterUsableItem(k, function(source)
			local xPlayer = ESX.GetPlayerFromId(source)
			if v.remove then
				xPlayer.removeInventoryItem(k,1)
			end
			TriggerClientEvent("esx_status:add",source,"hunger",v.status)
			TriggerClientEvent('esx_basicneeds:onEat',source)
			xPlayer.showNotification(TranslateCap('used_eat', ESX.GetItemLabel(k)))
		end)
	end
end)

CreateThread(function()
	for k,v in pairs(Config.Drinks) do
		ESX.RegisterUsableItem(k, function(source)
			local xPlayer = ESX.GetPlayerFromId(source)
			if v.remove then
				xPlayer.removeInventoryItem(k,1)
			end
			TriggerClientEvent("esx_status:add",source,"thirst",v.status)
			TriggerClientEvent('esx_basicneeds:onDrink',source)
			xPlayer.showNotification(TranslateCap('used_drink', ESX.GetItemLabel(k)))
		end)
	end
end)

ESX.RegisterCommand('heal', 'admin', function(xPlayer, args, showError)
	args.playerId.triggerEvent('esx_basicneeds:healPlayer')
	args.playerId.showNotification('You have been healed.')
end, true, {help = 'Heal a player, or yourself - restores thirst, hunger and health.', validate = true, arguments = {
	{name = 'playerId', help = 'the player id', type = 'player'}
}})

AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
	if GetInvokingResource() ~= "monitor" or type(eventData) ~= "table" or type(eventData.id) ~= "number" then
		return
	end

	TriggerClientEvent('esx_basicneeds:healPlayer', eventData.id)
end)
