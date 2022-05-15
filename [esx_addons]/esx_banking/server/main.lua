RegisterServerEvent('esx_banking:deposit')
AddEventHandler('esx_banking:deposit', function(amount)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.getIdentifier()
	amount = tonumber(amount)

	if not tonumber(amount) then return end
	amount = ESX.Math.Round(amount)

	if amount == nil or amount <= 0 or amount > xPlayer.getMoney() then
		xPlayer.showNotification(_U('invalid_amount'))
	else
		xPlayer.removeMoney(amount)
		xPlayer.addAccountMoney('bank', amount)
		xPlayer.showNotification(_U('deposit_money', amount))
		MySQL.update('INSERT INTO banking (identifier, type, amount, time) VALUES (@identifier, @type, @amount, @time)', {
			['@identifier'] = identifier,
			['@type']  = "deposit",
			['@amount'] = amount,
			['@time']  = os.date('%Y-%m-%d')
		})
	end
end)

ESX.RegisterServerCallback("esx_banking:BenzoFP", function(source, cb) 
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.getIdentifier()
	local history = MySQL.Sync.prepare('SELECT * FROM banking WHERE identifier = ?', {identifier})
	cb(history)
end)




RegisterServerEvent('esx_banking:withdraw')
AddEventHandler('esx_banking:withdraw', function(amount)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.getIdentifier()
	local time = os.date('%Y-%m-%d')
	amount = tonumber(amount)
	local accountMoney = xPlayer.getAccount('bank').money

	if not tonumber(amount) then return end
	amount = ESX.Math.Round(amount)

	if amount == nil or amount <= 0 or amount > accountMoney then
		xPlayer.showNotification(_U('invalid_amount'))
	else
		xPlayer.removeAccountMoney('bank', amount)
		xPlayer.addMoney(amount)
		xPlayer.showNotification(_U('withdraw_money', amount))
		MySQL.update('INSERT INTO banking (identifier, type, amount, time) VALUES (@identifier, @type, @amount, @time)', {
			['@identifier'] = identifier,
			['@type']  = "withdraw",
			['@amount'] = amount,
			['@time']  = os.date('%Y-%m-%d')
		})
	end
end)
