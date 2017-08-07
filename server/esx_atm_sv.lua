ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_atm:deposit')
AddEventHandler('esx_atm:deposit', function(amount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	amount = tonumber(amount)
	if amount == nil or amount <= 0 or amount > xPlayer.getMoney() then
		TriggerClientEvent('esx:showNotification', _source, '~r~Montant invalide')
	else
		xPlayer.removeMoney(amount)
		xPlayer.addAccountMoney('bank', amount)
		TriggerClientEvent('esx:showNotification', _source, 'Vous avez déposé ~g~' .. amount .. '$~s~.')
		TriggerClientEvent('esx_atm:closeATM', _source)
	end
end)


RegisterServerEvent('esx_atm:withdraw')
AddEventHandler('esx_atm:withdraw', function(amount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	amount = tonumber(amount)
	local accountMoney = 0
	accountMoney = xPlayer.getAccount('bank').money
	if amount == nil or amount <= 0 or amount > accountMoney then
		TriggerClientEvent('esx:showNotification', _source, '~r~Montant invalide')
	else
		xPlayer.removeAccountMoney('bank', amount)
		xPlayer.addMoney(amount)
		TriggerClientEvent('esx:showNotification', _source, 'Vous avez retiré ~g~' .. amount .. '$~s~.')
		TriggerClientEvent('esx_atm:closeATM', _source)
	end
end)