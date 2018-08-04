ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


--[[
AddEventHandler('onMySQLReady', function()
	MySQL.Async.execute('UPDATE owned_vehicles SET stored = true WHERE stored = false', {}, function (rowsChanged)
		if rowsChanged > 0 then
			print('esx_boat: all boats have been stored!')
		end
	end)
end)
]]

ESX.RegisterServerCallback('esx_boat:buyBoat', function (source, cb, vehicleProps)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price   = getPriceFromModel(vehicleProps.modelAlt)

	vehicleProps.modelAlt = nil

	-- vehicle model not found
	if price == 0 then
		print(('esx_boat: %s attempted to exploit the shop! (invalid vehicle model)'):format(xPlayer.identifier))
		cb(false)
	end

	if xPlayer.getMoney() >= price then
		xPlayer.removeMoney(price)

		MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, vehicleType) VALUES (@owner, @plate, @vehicle, @vehicleType)',
		{
			['@owner']       = xPlayer.identifier,
			['@plate']       = vehicleProps.plate,
			['@vehicle']     = json.encode(vehicleProps),
			['@vehicleType'] = 'boat'
		})

		cb(true)
	else
		cb(false)
	end
end)

RegisterServerEvent('esx_boat:takeOutVehicle')
AddEventHandler('esx_boat:takeOutVehicle', function(plate)
		MySQL.Async.execute('UPDATE owned_vehicles SET stored = @stored WHERE owner = @owner AND plate = @plate',
		{
			['@stored'] = false,
			['@owner']  = GetPlayerIdentifiers(source)[1],
			['@plate']  = plate
		}, function (rowsChanged)
			print(rowsChanged)
		end)

end)

ESX.RegisterServerCallback('esx_boat:getGarage', function (source, cb)

	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND vehicleType = @vehicleType AND stored = @stored',
	{
		['@owner']       = GetPlayerIdentifiers(source)[1],
		['@vehicleType'] = 'boat',
		['@stored']      = true
	}, function (result)
		local vehicles = {}

		for i=1, #result, 1 do
			local vehicleProps = json.decode(result[i].vehicle)
			table.insert(vehicles, vehicleProps)
		end

		cb(vehicles)
	end)

end)

function getPriceFromModel(model)
	for i=1, #Config.Vehicles, 1 do
		if Config.Vehicles[i].model == model then
			return Config.Vehicles[i].price
		end
	end

	return 0
end