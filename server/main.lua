ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_billing:sendBill')
AddEventHandler('esx_billing:sendBill', function(playerId, sharedAccountName, label, amount)

	local xPlayer  = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()

	TriggerEvent('esx_addonaccount:getSharedAccount', sharedAccountName, function(account)

		if account == nil then

			for k, v in pairs(xPlayers) do
				if v.source == playerId then

						MySQL.Async.execute(
							'INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)',
							{
								['@identifier']  = v.identifier,
								['@sender']      = xPlayer.identifier,
								['@target_type'] = 'player',
								['@target']      = xPlayer.identifier,
								['@label']       = label,
								['@amount']      = amount
							},
							function(rowsChanged)
								TriggerClientEvent('esx:showNotification', v.source, _U('received_invoice'))
							end
						)

					break
				end
			end

		else

			for k, v in pairs(xPlayers) do

				if v.source == playerId then

						MySQL.Async.execute(
							'INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)',
							{
								['@identifier']  = v.identifier,
								['@sender']      = xPlayer.identifier,
								['@target_type'] = 'society',
								['@target']      = sharedAccountName,
								['@label']       = label,
								['@amount']      = amount
							},
							function(rowsChanged)
								TriggerClientEvent('esx:showNotification', v.source, _U('received_invoice'))
							end
						)

					break
				end
			end

		end

	end)

end)

ESX.RegisterServerCallback('esx_billing:getBills', function(source, cb)

	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll(
		'SELECT * FROM billing WHERE identifier = @identifier',
		{
			['@identifier'] = xPlayer.identifier
		},
		function(result)

			local bills = {}

			for i=1, #result, 1 do
				table.insert(bills, {
					id         = result[i].id,
					identifier = result[i].identifier,
					sender     = result[i].sender,
					targetType = result[i].target_type,
					target     = result[i].target,
					label      = result[i].label,
					amount     = result[i].amount
				})
			end

			cb(bills)

		end
	)

end)


ESX.RegisterServerCallback('esx_billing:payBill', function(source, cb, id)

	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll(
		'SELECT * FROM billing WHERE id = @id',
		{
			['@id'] = id
		},
		function(result)

			local sender      = result[1].sender
			local targetType  = result[1].target_type
			local target      = result[1].target
			local amount      = result[1].amount
			local xPlayers    = ESX.GetPlayers()
			local foundPlayer = nil

			for k,v in pairs(xPlayers) do
				if v.identifier == sender then
					foundPlayer = v
					break
				end
			end

			if targetType == 'player' then

				if foundPlayer ~= nil then

					if xPlayer.get('money') >= amount then

						MySQL.Async.execute(
							'DELETE from billing WHERE id = @id',
							{
								['@id'] = id
							},
							function(rowsChanged)

								xPlayer.removeMoney(amount)
								foundPlayer.addMoney(amount)

								TriggerClientEvent('esx:showNotification', xPlayer.source, _U('paid_invoice') .. amount)
								TriggerClientEvent('esx:showNotification', foundPlayer.source, _U('received_payment') .. amount)

								cb()

							end
						)

					else
						TriggerClientEvent('esx:showNotification', _source, _U('player_not_logged'))
						cb()
					end

				end

			else

				TriggerEvent('esx_addonaccount:getSharedAccount', target, function(account)

					MySQL.Async.execute(
						'DELETE from billing WHERE id = @id',
						{
							['@id'] = id
						},
						function(rowsChanged)

							xPlayer.removeMoney(amount)
							account.addMoney(amount)

							TriggerClientEvent('esx:showNotification', xPlayer.source, _U('paid_invoice') .. amount)

							if foundPlayer ~= nil then
								TriggerClientEvent('esx:showNotification', foundPlayer.source, _U('received_payment') .. amount)
							end

							cb()

						end
					)

				end)

			end

		end
	)

end)
