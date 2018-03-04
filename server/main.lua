ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_garage:setParking')
AddEventHandler('esx_garage:setParking', function(garage, zone, vehicleProps)

	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(_source)

	if vehicleProps == false then

		MySQL.Async.execute(
			'DELETE FROM `user_parkings` WHERE `identifier` = @identifier AND `garage` = @garage AND zone = @zone',
			{
				['@identifier'] = xPlayer.identifier,
				['@garage']     = garage;
				['@zone']       = zone
			}, function(rowsChanged)
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('veh_released'))
			end
		)

	else

		MySQL.Async.execute(
			'INSERT INTO `user_parkings` (`identifier`, `garage`, `zone`, `vehicle`) VALUES (@identifier, @garage, @zone, @vehicle)',
			{
				['@identifier'] = xPlayer.identifier,
				['@garage']     = garage;
				['@zone']       = zone,
				['vehicle']     = json.encode(vehicleProps)
			}, function(rowsChanged)
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('veh_stored'))
			end
		)

	end

end)

RegisterServerEvent('esx_garage:updateOwnedVehicle')
 AddEventHandler('esx_garage:updateOwnedVehicle', function(vehicleProps)
 
 	local _source = source
 	local xPlayer = ESX.GetPlayerFromId(source)
 
 	MySQL.Async.fetchAll(
 		'SELECT * FROM owned_vehicles WHERE owner = @owner',
 		{
 			['@owner'] = xPlayer.identifier
 		},
 		function(result)
 
 			local foundVehicleId = nil
 
 			for i=1, #result, 1 do
 				
 				local vehicle = json.decode(result[i].vehicle)
 				
 				if vehicle.plate == vehicleProps.plate then
 					foundVehicleId = result[i].id
 					break
 				end
 
 			end
 
 			if foundVehicleId ~= nil then

 				MySQL.Async.execute(
 					'UPDATE owned_vehicles SET vehicle = @vehicle WHERE id = @id',
 					{
						['@vehicle'] = json.encode(vehicleProps),
						['@id']      = foundVehicleId
 					}
 				)
 
 			end
 
 		end
 	)
 
 end)

ESX.RegisterServerCallback('esx_vehicleshop:getVehiclesInGarage', function(source, cb, garage)

	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(_source)

	MySQL.Async.fetchAll(
		'SELECT * FROM `user_parkings` WHERE `identifier` = @identifier AND garage = @garage',
		{
			['@identifier'] = xPlayer.identifier,
			['@garage']     = garage
		},
		function(result)

			local vehicles = {}

			for i=1, #result, 1 do
				table.insert(vehicles, {
					zone    = result[i].zone,
					vehicle = json.decode(result[i].vehicle)
				})
			end

			cb(vehicles)

		end
	)

end)
