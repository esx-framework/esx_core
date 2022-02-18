local LastGarage, LastPart, LastParking, thisGarage = nil, nil, nil, nil

AddEventHandler('instance:loaded', function()
	TriggerEvent('instance:registerType', 'garage')
end)

RegisterNetEvent('instance:onCreate')
AddEventHandler('instance:onCreate', function(instance)
	if instance.type == 'garage' then
		TriggerEvent('instance:enter', instance)
	end
end)

AddEventHandler('esx_garage:hasEnteredMarker', function(name, part, parking)
	if part == 'ExteriorEntryPoint' then
		local playerPed = PlayerPedId()
		local coords    = GetEntityCoords(playerPed)
		local garage    = Config.Garages[name]
		thisGarage 		= garage
		
		for i=1, #Config.Garages, 1 do
			if Config.Garages[i].name ~= name then
				Config.Garages[i].disabled = true
			end
		end

		if IsPedInAnyVehicle(playerPed,  false) then
			local vehicle       = GetVehiclePedIsIn(playerPed,  false)
			local maxHealth     = GetEntityMaxHealth(vehicle)
			local health        = GetEntityHealth(vehicle)
			local healthPercent = (health / maxHealth) * 100

			if healthPercent < Config.MinimumHealthPercent then
				ESX.ShowNotification(_U('veh_health'))
			else
				if GetPedInVehicleSeat(vehicle,  -1) == playerPed then

					local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

					local spawnCoords  = {
						x = garage.InteriorSpawnPoint.Pos.x,
						y = garage.InteriorSpawnPoint.Pos.y,
						z = garage.InteriorSpawnPoint.Pos.z + Config.ZDiff
					}

					ESX.Game.DeleteVehicle(vehicle)

					ESX.Game.Teleport(playerPed, spawnCoords, function()

						TriggerEvent('instance:create', 'garage')

						ESX.Game.SpawnLocalVehicle(vehicleProps.model, spawnCoords, garage.InteriorSpawnPoint.Heading, function(vehicle)
							TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
							ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
							SetVehicleEngineOn(vehicle, (not GetIsVehicleEngineRunning(vehicle)), true, true)
						end)

						ESX.TriggerServerCallback('esx_vehicleshop:getVehiclesInGarage', function(vehicles)

							for i=1, #garage.Parkings, 1 do
								for j=1, #vehicles, 1 do

									if i == vehicles[j].zone then
										local function spawn(j)

											local vehicle = GetClosestVehicle(garage.Parkings[i].Pos.x,  garage.Parkings[i].Pos.y,  garage.Parkings[i].Pos.z,  2.0,  0,  71)

											if DoesEntityExist(vehicle) then
												ESX.Game.DeleteVehicle(vehicle)
											end

											ESX.Game.SpawnLocalVehicle(vehicles[j].vehicle.model, {
												x = garage.Parkings[i].Pos.x,
												y = garage.Parkings[i].Pos.y,
												z = garage.Parkings[i].Pos.z + Config.ZDiff
											}, garage.Parkings[i].Heading, function(vehicle)
												ESX.Game.SetVehicleProperties(vehicle, vehicles[j].vehicle)
											end)
										end

										spawn(j)
									end
								end
							end
						end, name)
					end)
				else
					ESX.Game.Teleport(playerPed, {
						x = garage.InteriorSpawnPoint.Pos.x,
						y = garage.InteriorSpawnPoint.Pos.y,
						z = garage.InteriorSpawnPoint.Pos.z + Config.ZDiff
					}, function()

						TriggerEvent('instance:create', 'garage')

						ESX.TriggerServerCallback('esx_vehicleshop:getVehiclesInGarage', function(vehicles)

							for i=1, #garage.Parkings, 1 do
								for j=1, #vehicles, 1 do

									if i == vehicles[j].zone then
										local function spawn(j)

											local vehicle = GetClosestVehicle(garage.Parkings[i].Pos.x,  garage.Parkings[i].Pos.garage.Parkings[i].Pos.y,  garage.Parkings[i].Pos.z,  2.0,  0,  71)

											if DoesEntityExist(vehicle) then
												ESX.Game.DeleteVehicle(vehicle)
											end

											ESX.Game.SpawnLocalVehicle(vehicles[j].vehicle.model, {
												x = garage.Parkings[i].Pos.x,
												y = garage.Parkings[i].Pos.y,
												z = garage.Parkings[i].Pos.z + Config.ZDiff
											}, garage.Parkings[i].Heading, function(vehicle)
												ESX.Game.SetVehicleProperties(vehicle, vehicles[j].vehicle)
											end)

										end

										spawn(j)
									end
								end
							end
						end, name)
					end)
				end
			end
		else
			ESX.Game.Teleport(playerPed, {
				x = garage.InteriorSpawnPoint.Pos.x,
				y = garage.InteriorSpawnPoint.Pos.y,
				z = garage.InteriorSpawnPoint.Pos.z + Config.ZDiff
			}, function()

				TriggerEvent('instance:create', 'garage')

				ESX.TriggerServerCallback('esx_vehicleshop:getVehiclesInGarage', function(vehicles)

					for i=1, #garage.Parkings, 1 do
						for j=1, #vehicles, 1 do

							if i == vehicles[j].zone then
								local function spawn(j)

									local vehicle = GetClosestVehicle(garage.Parkings[i].Pos.x,  garage.Parkings[i].Pos.y,  garage.Parkings[i].Pos.z,  2.0,  0,  71)

									if DoesEntityExist(vehicle) then
										ESX.Game.DeleteVehicle(vehicle)
									end

									ESX.Game.SpawnLocalVehicle(vehicles[j].vehicle.model, {
										x = garage.Parkings[i].Pos.x,
										y = garage.Parkings[i].Pos.y,
										z = garage.Parkings[i].Pos.z + Config.ZDiff
									}, garage.Parkings[i].Heading, function(vehicle)
										ESX.Game.SetVehicleProperties(vehicle, vehicles[j].vehicle)
									end)
								end

								spawn(j)
							end
						end
					end
				end, name)
			end)
		end
	end

	if part == 'InteriorExitPoint' then
		local playerPed = PlayerPedId()
		local coords    = GetEntityCoords(playerPed)
		local garage = thisGarage

		if IsPedInAnyVehicle(playerPed,  false) then

			local vehicle      = GetVehiclePedIsIn(playerPed,  false)
			local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
			
			local spawnCoords  = {
				x = garage.ExteriorSpawnPoint.Pos.x,
				y = garage.ExteriorSpawnPoint.Pos.y,
				z = garage.ExteriorSpawnPoint.Pos.z
			}

			ESX.Game.DeleteVehicle(vehicle)

			ESX.Game.Teleport(playerPed, spawnCoords, function()

				TriggerEvent('instance:close')

				ESX.Game.SpawnVehicle(vehicleProps.model, spawnCoords, garage.ExteriorSpawnPoint.Heading, function(vehicle)
					TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
					ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
					SetVehicleEngineOn(vehicle, (not GetIsVehicleEngineRunning(vehicle)), true, true)
				end)
			end)

		else

			ESX.Game.Teleport(playerPed,{
						x = garage.ExteriorSpawnPoint.Pos.x,
						y = garage.ExteriorSpawnPoint.Pos.y,
						z = garage.ExteriorSpawnPoint.Pos.z
					}, function()
				TriggerEvent('instance:close')
			end)
		end

		for i=1, #garage.Parkings, 1 do

			local vehicle = GetClosestVehicle(garage.Parkings[i].Pos.x,  garage.Parkings[i].Pos.y,  garage.Parkings[i].Pos.z,  2.0,  0,  71)

			if DoesEntityExist(vehicle) then
				ESX.Game.DeleteVehicle(vehicle)
			end

		end
		
		for i=1, #Config.Garages, 1 do
			if Config.Garages[i].name ~= name then
				Config.Garages[i].disabled = false
			end
		end
		
		thisGarage = nil
	end

	if part == 'Parking' then

		local playerPed = PlayerPedId()
		local garage = thisGarage
		local parkingPos = garage.Parkings[parking].Pos
		local vehicle = GetVehiclePedIsIn(playerPed, false)

		if vehicle > 0 and not IsAnyVehicleNearPoint(parkingPos.x,  parkingPos.y,  parkingPos.z,  1.0)  then

			local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)

			TriggerServerEvent('esx_garage:setParking', name, parking, vehicleProps)

			if Config.EnableOwnedVehicles then
				TriggerServerEvent('esx_garage:updateOwnedVehicle', vehicleProps)
			end
		end
	end
end)

AddEventHandler('esx_property:hasExitedMarker', function(name, part, parking)

	if part == 'Parking' then

		local playerPed = PlayerPedId()
		local garage = thisGarage
		local parkingPos = garage.Parkings[parking].Pos

		if IsPedInAnyVehicle(playerPed, false) and not IsAnyVehicleNearPoint(parkingPos.x, parkingPos.y, parkingPos.z, 1.0) then
			TriggerServerEvent('esx_garage:setParking', name, parking, false)
		end
	end
end)

-- Create Blips
CreateThread(function()
		
	for k,v in pairs(Config.Garages) do

		if v.IsClosed then

			local blip = AddBlipForCoord(v.ExteriorEntryPoint.Pos.x, v.ExteriorEntryPoint.Pos.y, v.ExteriorEntryPoint.Pos.z)

			SetBlipSprite (blip, 357)
			SetBlipDisplay(blip, 4)
			SetBlipScale  (blip, 1.2)
			SetBlipColour (blip, 3)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentSubstringPlayerName("Garage")
			EndTextCommandSetBlipName(blip)

		end

	end

end)

local nearMarker = false
-- Display markers
CreateThread(function()
	while true do
		local sleep = 500
		
		
		local playerPed = PlayerPedId()
		local coords    = GetEntityCoords(playerPed)
		local inVehicle = IsPedInAnyVehicle(playerPed, false)
		
		for k,v in pairs(Config.Garages) do

			if v.IsClosed then

				if(not v.disabled and #(coords - vector3(v.ExteriorEntryPoint.Pos.x, v.ExteriorEntryPoint.Pos.y, v.ExteriorEntryPoint.Pos.z)) < Config.DrawDistance) then
					DrawMarker(Config.MarkerType, v.ExteriorEntryPoint.Pos.x, v.ExteriorEntryPoint.Pos.y, v.ExteriorEntryPoint.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
					sleep = 0
					break
				end
				
				if thisGarage and (not v.disabled and #(coords - vector3(v.InteriorExitPoint.Pos.x, v.InteriorExitPoint.Pos.y, v.InteriorExitPoint.Pos.z)) < Config.DrawDistance) then
					DrawMarker(Config.MarkerType, v.InteriorExitPoint.Pos.x, v.InteriorExitPoint.Pos.y, v.InteriorExitPoint.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
					sleep = 0
				end

			end

			if inVehicle then

				for i=1, #v.Parkings, 1 do

					local parking = vector3(v.Parkings[i].Pos.x, v.Parkings[i].Pos.y, v.Parkings[i].Pos.z)

					if(not v.disabled and #(coords - parking) < Config.DrawDistance) then
						DrawMarker(Config.MarkerType, parking.x, parking.y, parking.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ParkingMarkerSize.x, Config.ParkingMarkerSize.y, Config.ParkingMarkerSize.z, Config.ParkingMarkerColor.r, Config.ParkingMarkerColor.g, Config.ParkingMarkerColor.b, 100, false, true, 2, false, false, false, false)
						sleep = 0
					end

				end

			end

		end
		if sleep == 0 then nearMarker = true else nearMarker = false end
		Wait(sleep)
	end
end)

-- Enter / Exit marker events
CreateThread(function()
	while true do
		if nearMarker then
			local playerPed      = PlayerPedId()
			local coords         = GetEntityCoords(playerPed)
			local isInMarker     = false
			local currentGarage  = nil
			local currentPart    = nil
			local currentParking = nil
			
			for k,v in pairs(Config.Garages) do
								if v.IsClosed then

									if (not v.disabled and #(coords - vector3(v.ExteriorEntryPoint.Pos.x, v.ExteriorEntryPoint.Pos.y, v.ExteriorEntryPoint.Pos.z)) < Config.MarkerSize.x) then
										isInMarker    = true
										currentGarage = k
										currentPart   = 'ExteriorEntryPoint'
										break
									end

									if (not v.disabled and #(coords - vector3(v.InteriorExitPoint.Pos.x, v.InteriorExitPoint.Pos.y, v.InteriorExitPoint.Pos.z)) < Config.MarkerSize.x) then
										isInMarker    = true
										currentGarage = k
										currentPart   = 'InteriorExitPoint'
									end
							
									for i=1, #v.Parkings, 1 do
										local parking = v.Parkings[i]

										if (not v.disabled and #(coords - vector3(parking.Pos.x, parking.Pos.y, parking.Pos.z)) < Config.ParkingMarkerSize.x) then
											isInMarker     = true
											currentGarage  = k
											currentPart    = 'Parking'
											currentParking = i
										end
									end
								end
			end

			if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastGarage ~= currentGarage or LastPart ~= currentPart or LastParking ~= currentParking) ) then
				
				if LastGarage ~= currentGarage or LastPart ~= currentPart or LastParking ~= currentParking then
					TriggerEvent('esx_property:hasExitedMarker', LastGarage, LastPart, LastParking)
				end

				HasAlreadyEnteredMarker = true
				LastGarage              = currentGarage
				LastPart                = currentPart
				LastParking             = currentParking
				
				TriggerEvent('esx_garage:hasEnteredMarker', currentGarage, currentPart, currentParking)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false

				TriggerEvent('esx_property:hasExitedMarker', LastGarage, LastPart, LastParking)
			end
			Wait(0)
		else Wait(500) end
	end
end)
