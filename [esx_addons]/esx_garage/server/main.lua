RegisterServerEvent('esx_garage:updateOwnedVehicle')
AddEventHandler('esx_garage:updateOwnedVehicle', function(stored, parking, pound, vehicleProps)
	local source = source
	local xPlayer  = ESX.GetPlayerFromId(source)

		MySQL.update('UPDATE owned_vehicles SET `stored` = @stored, `parking` = @parking, `pound` = @pound, `vehicle` = @vehicle WHERE `plate` = @plate AND `owner` = @identifier',
		{
			['@identifier'] = xPlayer.identifier,
			['@vehicle'] 	= json.encode(vehicleProps),
			['@plate'] 		= vehicleProps.plate,
			['@stored']     = stored,
			['@parking']    = parking,
			['@pound']    	= pound
		})

		if stored then
			xPlayer.showNotification(_U('veh_stored'))
		end
end)

RegisterServerEvent('esx_garage:setImpound')
AddEventHandler('esx_garage:setImpound', function(pound, vehicleProps)
	local source = source
	local xPlayer  = ESX.GetPlayerFromId(source)

		MySQL.update('UPDATE owned_vehicles SET `stored` = @stored, `pound` = @pound, `vehicle` = @vehicle WHERE `plate` = @plate AND `owner` = @identifier',
		{
			['@identifier'] = xPlayer.identifier,
			['@vehicle'] 	= json.encode(vehicleProps),
			['@plate'] 		= vehicleProps.plate,
			['@stored']     = 2,
			['@pound']    	= pound
		})

		xPlayer.showNotification(_U('veh_impounded'))
	
end)


ESX.RegisterServerCallback('esx_garage:getVehiclesInParking', function(source, cb, parking)
	local xPlayer  = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier AND `parking` = @parking AND `stored` = 1',
	{
		['@identifier'] 	= xPlayer.identifier,
		['@parking']     	= parking
	}, function(result)

		local vehicles = {}
		for i = 1, #result, 1 do
			table.insert(vehicles, {
				vehicle 	= json.decode(result[i].vehicle),
				plate 		= result[i].plate
			})
		end

		cb(vehicles)
	end)
end)

ESX.RegisterServerCallback('esx_garage:checkVehicleOwner', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT COUNT(*) as count FROM `owned_vehicles` WHERE `owner` = @identifier AND `plate` = @plate',
	{
		['@identifier'] 	= xPlayer.identifier,
		['@plate']     		= plate
	}, function(result)

		if tonumber(result[1].count) > 0 then
			return cb(true)
		else
			return cb(false)
		end
	end)
end)

-- Pounds part
ESX.RegisterServerCallback('esx_garage:getVehiclesImpounded', function(source, cb)
	local xPlayer  = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier AND `stored` = 0',
	{
		['@identifier'] 	= xPlayer.identifier,
	}, function(result)
		local vehicles = {}
		
		for i = 1, #result, 1 do
			table.insert(vehicles, {
				vehicle 	= json.decode(result[i].vehicle),
				plate 		= result[i].plate
			})
		end

		cb(vehicles)
	end)
end)

ESX.RegisterServerCallback('esx_garage:getVehiclesInPound', function(source, cb, pound)
	local xPlayer  = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier AND `pound` = @pound AND `stored` = 2',
	{
		['@identifier'] 	= xPlayer.identifier,
		['@pound']     	    = pound
	}, function(result)
		local vehicles = {}

		for i = 1, #result, 1 do
			table.insert(vehicles, {
				vehicle 	= json.decode(result[i].vehicle),
				plate 		= result[i].plate
			})
		end

		cb(vehicles)
	end)
end)

ESX.RegisterServerCallback('esx_garage:checkMoney', function(source, cb, amount)
	local xPlayer = ESX.GetPlayerFromId(source)

	cb(xPlayer.getMoney() >= amount)
end)

RegisterServerEvent("esx_garage:payPound")
AddEventHandler("esx_garage:payPound", function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)

		xPlayer.showNotification(_U('pay_pound_bill', amount))
    else
		xPlayer.showNotification(_U('missing_money'))
    end
end)