local VehicleData = {}
local Vehicles

RegisterServerEvent('esx_lscustom:buyMod')
AddEventHandler('esx_lscustom:buyMod', function(price)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	price = tonumber(price)

	if Config.IsMechanicJobOnly then
		local societyAccount

		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
			societyAccount = account
		end)

		if price < societyAccount.money then
			TriggerClientEvent('esx_lscustom:installMod', source)
			TriggerClientEvent('esx:showNotification', source, _U('purchased'))
			societyAccount.removeMoney(price)
		else
			TriggerClientEvent('esx_lscustom:cancelInstallMod', source)
			TriggerClientEvent('esx:showNotification', source, _U('not_enough_money'))
		end
	else
		if price < xPlayer.getMoney() then
			TriggerClientEvent('esx_lscustom:installMod', source)
			TriggerClientEvent('esx:showNotification', source, _U('purchased'))
			xPlayer.removeMoney(price)
		else
			TriggerClientEvent('esx_lscustom:cancelInstallMod', source)
			TriggerClientEvent('esx:showNotification', source, _U('not_enough_money'))
		end
	end
end)

RegisterNetEvent('esx_lscustom:changeVehicleData')
AddEventHandler('esx_lscustom:changeVehicleData', function(type, data)
	local source = source
	if type == "add" then
		VehicleData[source] = {plate = data.plate, props = data.props}
	elseif type == "remove" then
		for index, value in ipairs(VehicleData) do
			if value.plate == data.plate then
				table.remove(VehicleData, index)
			end
		end
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
				print(('esx_lscustom: %s attempted to upgrade vehicle with mismatching vehicle model!'):format(xPlayer.identifier))
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

AddEventHandler('esx:playerDropped', function(playerId, reason)
	if VehicleData[playerId] then
		TriggerClientEvent('esx_lscustom:resetCustom', playerId, VehicleData[playerId].props)
		for index, value in ipairs(VehicleData) do
			if value.plate == VehicleData[playerId].plate then
				table.remove(VehicleData, index)
			end
		end
	end
end)
