ESX               = nil
local ItemsLabels = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Load item labels
Citizen.CreateThread(function()
	Citizen.Wait(5000)
	
	MySQL.Async.fetchAll(
	'SELECT * FROM items',
	{},
	function(result)
		for i=1, #result, 1 do
			ItemsLabels[result[i].name] = result[i].label
		end
	end)
end)

ESX.RegisterServerCallback('esx_shops:requestDBItems', function(source, cb)

	MySQL.Async.fetchAll(
	'SELECT * FROM shops',
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
				label = ItemsLabels[result[i].item]
			})
		end
		cb(shopItems)
	end)
end)

RegisterServerEvent('esx_shops:buyItem')
AddEventHandler('esx_shops:buyItem', function(itemName, price)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)
	
	-- is the player trying to cheat?
	if price < 0 then
		print('esx_shops: ' .. xPlayer.identifier .. ' attempted to cheat money!')
		return
	end

	-- can the player afford this item?
	if xPlayer.getMoney() >= price then
		
		-- can the player carry the said amount of x item?
		if sourceItem.limit ~= -1 and (sourceItem.count + 1) > sourceItem.limit then
			TriggerClientEvent('esx:showNotification', _source, _U('player_cannot_hold'))
		else
			xPlayer.removeMoney(price)
			xPlayer.addInventoryItem(itemName, 1)
			TriggerClientEvent('esx:showNotification', _source, _U('bought', ItemsLabels[itemName], price))
		end
	else
		local missingMoney = price - xPlayer.getMoney()
		TriggerClientEvent('esx:showNotification', _source, _U('not_enough', missingMoney))
	end

end)