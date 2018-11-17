ESX = nil
local shopItems = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()

	MySQL.Async.fetchAll('SELECT * FROM weashops', {}, function(result)
		for i=1, #result, 1 do
			if shopItems[result[i].zone] == nil then
				shopItems[result[i].zone] = {}
			end

			table.insert(shopItems[result[i].zone], {
				item  = result[i].item,
				price = result[i].price,
				label = ESX.GetWeaponLabel(result[i].item)
			})
		end

		TriggerClientEvent('esx_weaponshop:sendShop', -1, shopItems)
	end)

end)

ESX.RegisterServerCallback('esx_weaponshop:getShop', function(source, cb)
	cb(shopItems)
end)

ESX.RegisterServerCallback('esx_weaponshop:buyLicense', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getMoney() >= Config.LicensePrice then
		xPlayer.removeMoney(Config.LicensePrice)

		TriggerEvent('esx_license:addLicense', source, 'weapon', function()
			cb(true)
		end)
	else
		cb(false)
		TriggerClientEvent('esx:showNotification', source, _U('not_enough'))
	end
end)

RegisterServerEvent('esx_weaponshop:buyItem')
AddEventHandler('esx_weaponshop:buyItem', function(weaponName, zone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local price = GetPrice(weaponName, zone)

	if xPlayer.hasWeapon(weaponName) then
		TriggerClientEvent('esx:showNotification', _source, _U('already_owned'))
		return
	end

	if zone == 'BlackWeashop' then

		if xPlayer.getAccount('black_money').money >= price then
			xPlayer.removeAccountMoney('black_money', price)
			xPlayer.addWeapon(weaponName, 42)
			TriggerClientEvent('esx:showNotification', _source, _U('buy', ESX.GetWeaponLabel(weaponName), price))
		else
			TriggerClientEvent('esx:showNotification', _source, _U('not_enough_black'))
		end

	else

		if xPlayer.getMoney() >= price then
			xPlayer.removeMoney(price)
			xPlayer.addWeapon(weaponName, 42)
			TriggerClientEvent('esx:showNotification', _source, _U('buy', ESX.GetWeaponLabel(weaponName), price))
		else
			TriggerClientEvent('esx:showNotification', _source, _U('not_enough'))
		end

	end
end)

function GetPrice(weaponName, zone)
	local result = MySQL.Sync.fetchAll('SELECT price FROM weashops WHERE zone = @zone AND item = @item', {
		['@zone'] = zone,
		['@item'] = weaponName
	})

	return result[1].price
end
