ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_boat:buyBoat', function (source, cb, vehicleProps, model)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price   = getPriceFromModel(model)

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

ESX.RegisterServerCallback('esx_boat:getGarage', function (source, cb)

	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner, vehicleType = @vehicleType, stored = 1',
	{
		['@owner']      = GetPlayerIdentifiers(source)[1],
		['vehicleType'] = 'boat'
	}, function (result)
		local vehicles = {}

		for i=1, #result, 1 do
			table.insert(vehicles, json.decode(result[i].vehicle))
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