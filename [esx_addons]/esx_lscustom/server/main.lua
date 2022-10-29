local Vehicles

ESX.RegisterServerCallback('esx_lscustom:buyMod', function(src, cb, price)
   local xPlayer = ESX.GetPlayerFromId(src)
   	if xPlayer then
		price = tonumber(price)
		if price then
			if Config.IsMechanicJobOnly then
				local societyAccount

				TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
					societyAccount = account
				end)
				
				if societyAccount ~= nil then
					if price < societyAccount.money then
						TriggerClientEvent('esx:showNotification', source, TranslateCap('purchased'))
						societyAccount.removeMoney(price)
						cb(true)
					else
						TriggerClientEvent('esx_lscustom:cancelInstallMod', source)
						TriggerClientEvent('esx:showNotification', source, TranslateCap('not_enough_money'))
						cb(false)
					end
				else
					TriggerClientEvent('esx_lscustom:cancelInstallMod', source)
					TriggerClientEvent('esx:showNotification', source, TranslateCap('missing_society'))
					print("society_mechanic is not register in addonaccount")
					cb(false)
				end
			else
				if price < xPlayer.getMoney() then
					TriggerClientEvent('esx:showNotification', source, TranslateCap('purchased'))
					xPlayer.removeMoney(price, "LSC Purchase")
					cb(true)
				else
					TriggerClientEvent('esx_lscustom:cancelInstallMod', source)
					TriggerClientEvent('esx:showNotification', source, TranslateCap('not_enough_money'))
					cb(false)
				end
			end
		else
			cb(false)
		end
   	else
		cb(false)
   	end
end)

RegisterServerEvent('esx_lscustom:refreshOwnedVehicle')
AddEventHandler('esx_lscustom:refreshOwnedVehicle', function(vehicleProps)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.single('SELECT vehicle FROM owned_vehicles WHERE plate = ?', {vehicleProps.plate},
	function(result)
		if result then
			local vehicle = json.decode(result.vehicle)

			if vehicleProps.model == vehicle.model then
				MySQL.update('UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?', {json.encode(vehicleProps), vehicleProps.plate})
			else
				print(('[^3WARNING^7] Player ^5%s^7 Attempted To upgrade with mismatching vehicle model'):format(xPlayer.source))
			end
		end
	end)
end)

ESX.RegisterServerCallback('esx_lscustom:getVehiclesPrices', function(source, cb)
	if not Vehicles then
		Vehicles = MySQL.query.await('SELECT model, price FROM vehicles')
	end
	cb(Vehicles)
end)