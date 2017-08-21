ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_bankerjob:customerDeposit')
AddEventHandler('esx_bankerjob:customerDeposit', function(target, amount)

	local xPlayer = ESX.GetPlayerFromId(target)

	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function(account)
		account.removeMoney(amount)
	end)

	TriggerEvent('esx_addonaccount:getAccount', 'bank_savings', xPlayer.identifier, function(account)
		account.addMoney(amount)
	end)

end)

RegisterServerEvent('esx_bankerjob:customerWithdraw')
AddEventHandler('esx_bankerjob:customerWithdraw', function(target, amount)

	local xPlayer = ESX.GetPlayerFromId(target)

	TriggerEvent('esx_addonaccount:getAccount', 'bank_savings', xPlayer.identifier, function(account)
		account.removeMoney(amount)
	end)

	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function(account)
		account.addMoney(amount)
	end)

end)

ESX.RegisterServerCallback('esx_bankerjob:getCustomers', function(source, cb)

	local xPlayers  = ESX.GetPlayers()
	local customers = {}

	for i=1, #xPlayers, 1 do

		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

		TriggerEvent('esx_addonaccount:getAccount', 'bank_savings', xPlayer.identifier, function(account)
			table.insert(customers, {
				source      = xPlayer.source,
				name        = GetPlayerName(xPlayer.source),
				bankSavings = account.money
			})
		end)

	end

	cb(customers)

end)

TriggerEvent('esx_phone:registerCallback', function(source, phoneNumber, message, anon)

	local xPlayer  = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()

	if phoneNumber == 'banker' then
		for i=1, #xPlayers, 1 do
			local xPlayer2 = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer2.job.name == 'banker' then
				TriggerEvent('esx_phone:getDistpatchRequestId', function(requestId)
					TriggerClientEvent('esx_phone:onMessage', xPlayer2.source, xPlayer.get('phoneNumber'), message, xPlayer.get('coords'), anon, 'Client Banque')
				end)
			end
		end
	end
	
end)

function CalculateBankSavings(d, h, m)

	MySQL.Async.fetchAll(
		'SELECT * FROM addon_account_data WHERE account_name = @account_name',
		{
			['@account_name'] = 'bank_savings'
		},
		function(result)

			local bankInterests = 0
			local xPlayers      = ESX.GetPlayers()

			for i=1, #result, 1 do

				local foundPlayer = false
				local xPlayer     = nil

				for i=1, #xPlayers, 1 do
					local xPlayer2 = ESX.GetPlayerFromId(xPlayers[i])
					if xPlayer2.identifier == result[i].owner then
						foundPlayer = true
						xPlayer     = xPlayer2
					end
				end

				if foundPlayer then

					TriggerEvent('esx_addonaccount:getAccount', 'bank_savings', xPlayer.identifier, function(account)
						
						local interests = math.floor(account.money / 100 * Config.BankSavingPercentage)
						bankInterests   = bankInterests + interests

						account.addMoney(interests)

					end)
				
				else

					local interests = math.floor(result[i].money / 100 * Config.BankSavingPercentage)
					local newMoney  = result[i].money + interests;
					bankInterests   = bankInterests + interests

					MySQL.Async.execute(
						'UPDATE addon_account_data SET money = @money WHERE owner = @owner AND account_name = @account_name',
						{
							['@money']        = newMoney,
							['@owner']        = result[i].owner,
							['@account_name'] = 'bank_savings'
						}
					)

				end

			end

			TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function(account)
				account.addMoney(bankInterests)
			end)

		end
	)

end

TriggerEvent('cron:runAt', 22, 00, CalculateBankSavings)
