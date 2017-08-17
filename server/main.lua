ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_lscustom:buyMod')
AddEventHandler('esx_lscustom:buyMod', function(price)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	price = tonumber(price)
	if price > xPlayer.getMoney() then
		TriggerClientEvent('esx_lscustom:cancelInstallMod', _source)
		TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas assez d'argent !")
	else
		xPlayer.removeMoney(price)
		TriggerClientEvent('esx_lscustom:installMod', _source)
		TriggerClientEvent('esx:showNotification', _source, "Achat effectué !")
	end
end)
