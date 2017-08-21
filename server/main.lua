ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function(target)
	TriggerClientEvent('esx_ambulancejob:revive', target)
end)

ESX.RegisterServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function(source, cb)

	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.RemoveCashAfterRPDeath then
		xPlayer.set('money', 0)
		xPlayer.setAccountMoney('black_money', 0)
	end

	if Config.RemoveItemsAfterRPDeath then
		for i=1, #xPlayer.inventory, 1 do
			if xPlayer.inventory[i].count > 0 then
				xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
			end
		end
	end

	if Config.RemoveWeaponsAfterRPDeath then
		for i=1, #xPlayer.loadout, 1 do
			xPlayer.removeWeapon(xPlayer.loadout[i].name)
		end
	end

	cb()

end)

ESX.RegisterServerCallback('esx_ambulancejob:removeItemsAfterRPDeathRemoveMoney', function(source, cb)

	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.RemoveCashAfterRPDeath then
		xPlayer.set('money', 0)
		xPlayer.setAccountMoney('black_money', 0)
	end

	if Config.EarlyRespawn and Config.EarlyRespawnFine then
		xPlayer.removeAccountMoney('bank', Config.EarlyRespawnFineAmount)
	end

	if Config.RemoveItemsAfterRPDeath then
		for i=1, #xPlayer.inventory, 1 do
			if xPlayer.inventory[i].count > 0 then
				xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
			end
		end
	end

	if Config.RemoveWeaponsAfterRPDeath then
		for i=1, #xPlayer.loadout, 1 do
			xPlayer.removeWeapon(xPlayer.loadout[i].name)
		end
	end

	cb()

end)

ESX.RegisterServerCallback('esx_ambulancejob:getBankMoney', function(source, cb)

    local xPlayer = ESX.GetPlayerFromId(source)
    local money = xPlayer.getAccount('bank').money

    cb(money)
end)

TriggerEvent('esx_phone:registerCallback', function(source, phoneNumber, message, anon)

	local xPlayer  = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()

	if phoneNumber == 'ambulance' then
		for i=1, #xPlayers, 1 do

			local xPlayer2 = ESX.GetPlayerFromId(xPlayer[i])

			if xPlayer2.job.name == 'ambulance' then
				TriggerEvent('esx_phone:getDistpatchRequestId', function(requestId)
					TriggerClientEvent('esx_phone:onMessage', xPlayer2.source, xPlayer.get('phoneNumber'), message, xPlayer.get('coords'), anon, _U('alert_ambulance'), requestId)
				end)
			end
		end
	end

end)

TriggerEvent('es:addGroupCommand', 'revive', 'admin', function(source, args, user)

	if args[2] ~= nil then
		TriggerClientEvent('esx_ambulancejob:revive', tonumber(args[2]))
	else
		TriggerClientEvent('esx_ambulancejob:revive', source)
	end

end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = _U('revive_help'), params = {{name = 'id'}}})
