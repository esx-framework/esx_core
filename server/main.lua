ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
	ESX = obj
end)

RegisterServerEvent('esx_realestateagentjob:revoke')
AddEventHandler('esx_realestateagentjob:revoke', function(property, owner)
	TriggerEvent('esx_property:removeOwnedPropertyIdentifier', property, owner)
end)

AddEventHandler('esx_phone:ready', function()

	TriggerEvent('esx_phone:registerCallback', function(source, phoneNumber, message, anon)
		
		local xPlayer  = ESX.GetPlayerFromId(source)
		local xPlayers = ESX.GetPlayers()
		local job      = 'Client immobilier'

		if phoneNumber == "realestateagent" then

			for i=1, #xPlayers, 1 do

				local xPlayer2 = ESX.GetPlayerFromId(xPlayers[i])
				
				if xPlayer2.job.name == 'realestateagent' then
					TriggerClientEvent('esx_phone:onMessage', xPlayer2.source, xPlayer.get('phoneNumber'), message, xPlayer.get('coords'), anon, job, false)
				end
			end

		end
		
	end)

end)

RegisterServerEvent('esx_realestateagentjob:sell')
AddEventHandler('esx_realestateagentjob:sell', function(target, property, price)
	
	local xPlayer = ESX.GetPlayerFromId(target)

	xPlayer.removeMoney(price)

	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_realestateagent', function(account)
		account.addMoney(price)
	end)

	TriggerEvent('esx_property:setPropertyOwned', property, price, false, xPlayer.identifier)
end)

RegisterServerEvent('esx_realestateagentjob:rent')
AddEventHandler('esx_realestateagentjob:rent', function(target, property, price)
	
	local xPlayer = ESX.GetPlayerFromId(target)

	TriggerEvent('esx_property:setPropertyOwned', property, price, true, xPlayer.identifier)
end)

TriggerEvent('esx_phone:registerCallback', function(source, phoneNumber, message, anon)

	local xPlayer  = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()

	if phoneNumber == 'realestateagent' then
		for i=1, #xPlayers, 1 do

			local xPlayer2 = ESX.GetPlayerFromId(xPlayers[i])
			
			if xPlayer2.job.name == 'realestateagent' then
				TriggerClientEvent('esx_phone:onMessage', xPlayer2.source, xPlayer.get('phoneNumber'), message, xPlayer.get('coords'), anon, 'player')
			end
		end
	end
	
end)

ESX.RegisterServerCallback('esx_realestateagentjob:getCustomers', function(source, cb)

	TriggerEvent('esx_ownedproperty:getOwnedProperties', function(properties)
		
		local xPlayers  = ESX.GetPlayers()
		local customers = {}

		for i=1, #properties, 1 do
			for j=1, #xPlayers, 1 do

				local xPlayer = ESX.GetPlayerFromId(xPlayers[j])
				
				if xPlayer.identifier == properties[i].owner then
					table.insert(customers, {
						name           = xPlayer.name,
						propertyOwner  = properties[i].owner,
						propertyRented = properties[i].rented,
						propertyId     = properties[i].id,
						propertyPrice  = properties[i].price,
						propertyName   = properties[i].name
					})
				end
			end
		end

		cb(customers)

	end)

end)