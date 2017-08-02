ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_society:withdrawMoney')
AddEventHandler('esx_society:withdrawMoney', function(society, amount)

	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. society, function(account)

		if amount > 0 and account.money >= amount then

			account.removeMoney(amount)
			xPlayer.addMoney(amount)

			TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous avez retiré ~g~$' .. amount)

		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, 'Montant invalide')
		end

	end)

end)

RegisterServerEvent('esx_society:depositMoney')
AddEventHandler('esx_society:depositMoney', function(society, amount)

	local xPlayer = ESX.GetPlayerFromId(source)

	if amount > 0 and xPlayer.get('money') >= amount then

		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. society, function(account)
			xPlayer.removeMoney(amount)
			account.addMoney(amount)
		end)

		TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous avez déposé ~r~$' .. amount)

	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, 'Montant invalide')
	end

end)

RegisterServerEvent('esx_society:washMoney')
AddEventHandler('esx_society:washMoney', function(society, amount)

	local xPlayer = ESX.GetPlayerFromId(source)
	local account = xPlayer.getAccount('black_money')

	if amount > 0 and account.money >= amount then

		xPlayer.removeAccountMoney('black_money', amount)

			MySQL.Async.execute(
				'INSERT INTO society_moneywash (identifier, society, amount) VALUES (@identifier, @society, @amount)',
				{
					['@identifier'] = xPlayer.identifier,
					['@society']    = society,
					['@amount']     = amount
				},
				function(rowsChanged)
					TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous avez ~g~$' .. amount .. '~s~ en attente de ~r~blanchiement~s~ (24h)')
				end
			)

	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, 'Montant invalide')
	end

end)

ESX.RegisterServerCallback('esx_society:getAccountMoney', function(source, cb, account)
	TriggerEvent('esx_addonaccount:getSharedAccount', account, function(account)
		cb(account.money)
	end)
end)

function WashMoneyCRON(d, h, m)

	MySQL.Async.fetchAll(
		'SELECT * FROM society_moneywash',
		{},
		function(result)

			local xPlayers = ESX.GetPlayers()

			for i=1, #result, 1 do

				local foundPlayer = false
				local xPlayer     = nil

				for k,v in pairs(xPlayers) do
					if v.identifier == result[i].identifier then
						foundPlayer = true
						xPlayer     = v
					end
				end

				TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. result[i].society, function(account)
					account.addMoney(result[i].amount)
				end)

				if foundPlayer then
					TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous avez ~r~blanchi~s~ votre argent : ~g~$' .. result[i].amount)
				end

				MySQL.Async.execute(
					'DELETE FROM society_moneywash WHERE id = @id',
					{
						['@id'] = result[i].id
					}
				)

			end

		end
	)

end

TriggerEvent('cron:runAt', 3, 0, WashMoneyCRON)