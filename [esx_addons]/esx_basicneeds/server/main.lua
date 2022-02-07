ESX.RegisterCommand('heal', 'admin', function(xPlayer, args, showError)
	args.playerId.triggerEvent('esx_basicneeds:healPlayer')
	args.playerId.triggerEvent('chat:addMessage', {args = {'^5HEAL', 'You have been healed.'}})
end, true, {help = 'Heal a player, or yourself - restores thirst, hunger and health.', validate = true, arguments = {
	{name = 'playerId', help = 'the player id', type = 'player'}
}})

for i,v in pairs(Config.food) do
	ESX.RegisterUsableItem(i, function(source)
		local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.removeInventoryItem(i, 1)
		local action = "esx_basicneeds:"..v.action
		if v.type == "both" then
			TriggerClientEvent('esx_status:add', source, 'thirst', v.valueT)
			TriggerClientEvent('esx_status:add', source, 'hunger', v.valueH)
		elseif v.type == "drunk" then
			TriggerClientEvent('esx_status:add', source, 'drunk', v.value)
			TriggerClientEvent('esx_status:add', source, 'thirst', 50000)
		else
			TriggerClientEvent('esx_status:add', source, v.type, v.value)
		end

		TriggerClientEvent(action, source)
        xPlayer.showNotification(v.notif)

	end)
end
