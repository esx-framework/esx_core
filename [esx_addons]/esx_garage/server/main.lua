RegisterServerEvent('esx_garage:updateOwnedVehicle')
AddEventHandler('esx_garage:updateOwnedVehicle', function(stored, parking, vehicleProps)
	local source = source
	local xPlayer  = ESX.GetPlayerFromId(source)

		MySQL.update('UPDATE owned_vehicles SET stored = @stored, parking = @parking, vehicle = @vehicle WHERE plate = @plate AND owner = @identifier',
		{
			['@identifier'] = xPlayer.identifier,
			['@vehicle'] 	= json.encode(vehicleProps),
			['@plate'] 		= vehicleProps.plate,
			['@stored']     = stored,
			['@parking']    = parking
		})

		if stored then
			xPlayer.showNotification(_U('veh_stored'))
		else
			xPlayer.showNotification(_U('veh_released'))
		end
end)

ESX.RegisterServerCallback('esx_garage:getVehiclesInParking', function(source, cb, parking)
	local xPlayer  = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier AND parking = @parking AND stored = 1',
	{
		['@identifier'] 	= xPlayer.identifier,
		['@parking']     	= parking
	}, function(result)

		local vehicles = {}
		for i = 1, #result, 1 do
			table.insert(vehicles, {
				vehicle = json.decode(result[i].vehicle),
				plate = result[i].plate
			})
		end

		cb(vehicles)
	end)
end)

ESX.RegisterServerCallback('esx_garage:checkVehicleOwner', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT COUNT(*) as count FROM owned_vehicles WHERE owner = @identifier AND plate = @plate',
	{
		['@identifier'] = xPlayer.identifier,
		['@plate']     	= plate
	}, function(result)

		if tonumber(result[1].count) > 0 then
			return cb(true)
		else
			return cb(false)
		end
	end)
end)