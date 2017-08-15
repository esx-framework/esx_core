ESX               = nil
local ItemsLabels = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('onMySQLReady', function()

	MySQL.Async.fetchAll(
		'SELECT * FROM items',
		{},
		function(result)
			
			for i=1, #result, 1 do
				ItemsLabels[result[i].name] = result[i].label
			end-- 

		end
	)

end)

ESX.RegisterServerCallback('esx_weashop:requestDBItems', function(source, cb)

	MySQL.Async.fetchAll(
		'SELECT * FROM weashops',
		{},
		function(result)
			
			local shopItems  = {}

			for i=1, #result, 1 do

				if shopItems[result[i].name] == nil then
					shopItems[result[i].name] = {}
				end

				table.insert(shopItems[result[i].name], {
					name  = result[i].item,
					price = result[i].price,
					label = ESX.GetWeaponLabel(result[i].item)
				})

			end

			cb(shopItems)

		end
	)

end)

RegisterServerEvent('esx_weashop:buyItem')
AddEventHandler('esx_weashop:buyItem', function(itemName, price, zone)
	
	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(source)
	local account = xPlayer.getAccount('black_money')
	
	if zone=="blackweashop" then 
		if account.money >= price then

		xPlayer.removeAccountMoney('black_money', price)
		xPlayer.addWeapon(itemName, 42)
		TriggerClientEvent('esx:showNotification', _source, _U('buy') .. ItemsLabels[itemName])

	else
		TriggerClientEvent('esx:showNotification', _source, _U('not_enough_black'))
	end	

	else if xPlayer.get('money') >= price then

		xPlayer.removeMoney(price)
		xPlayer.addWeapon(itemName, 42)

		TriggerClientEvent('esx:showNotification', _source, _U('buy') .. ItemsLabels[itemName])

	else
		TriggerClientEvent('esx:showNotification', _source, _U('not_enough'))
	end
	end

end)
