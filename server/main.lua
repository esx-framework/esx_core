ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_atm:deposit')
AddEventHandler('esx_atm:deposit', function(amount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	amount = tonumber(amount)

	if not tonumber(amount) then return end
	amount = round(amount)
	if amount == nil or amount <= 0 or amount > xPlayer.getMoney() then
		TriggerClientEvent('esx:showNotification', _source, _U('invalid_amount'))
	else
		xPlayer.removeMoney(amount)
		xPlayer.addAccountMoney('bank', amount)
		TriggerClientEvent('esx:showNotification', _source, _U('deposit_money', amount))
	end
end)

RegisterServerEvent('esx_atm:withdraw')
AddEventHandler('esx_atm:withdraw', function(amount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	amount = tonumber(amount)

	if not tonumber(amount) then return end
	amount = round(amount)
	local accountMoney = 0
	accountMoney = xPlayer.getAccount('bank').money
	if amount == nil or amount <= 0 or amount > accountMoney then
		TriggerClientEvent('esx:showNotification', _source, _U('invalid_amount'))
	else
		xPlayer.removeAccountMoney('bank', amount)
		xPlayer.addMoney(amount)
		TriggerClientEvent('esx:showNotification', _source, _U('withdraw_money', amount))
	end
end)

function round(x)
	return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end