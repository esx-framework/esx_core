local Charset = {}

for i = 48,  57 do table.insert(Charset, string.char(i)) end
for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

ESX                           = {}
ESX.CurrentRequestId          = 0
ESX.ServerCallbacks           = {}
ESX.TimeoutCallbacks          = {}
ESX.UI                        = {}
ESX.UI.HUD                    = {}
ESX.UI.HUD.RegisteredElements = {}
ESX.UI.Menu                   = {}
ESX.UI.Menu.RegisteredTypes   = {}
ESX.UI.Menu.Opened            = {}
ESX.Game                      = {}

ESX.GetRandomString = function(length)

  math.randomseed(GetGameTimer())

  if length > 0 then
    return ESX.GetRandomString(length - 1) .. Charset[math.random(1, #Charset)]
  else
    return ''
  end
  
end

ESX.SetTimeout = function(msec, cb)
	table.insert(ESX.TimeoutCallbacks, {
		time = GetGameTimer() + msec,
		cb   = cb
	})
end

ESX.ShowNotification = function(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	DrawNotification(0,1)
end

ESX.TriggerServerCallback = function(name, cb, a, b, c, d, e, f, g ,h ,i ,j ,k, l, m, n, o, p, q, r, s, t, u ,v ,w, x ,y ,z)
	
	ESX.ServerCallbacks[ESX.CurrentRequestId] = cb
	
	TriggerServerEvent('esx:triggerServerCallback', name, ESX.CurrentRequestId, a, b, c, d, e, f, g ,h ,i ,j ,k, l, m, n, o, p, q, r, s, t, u ,v ,w, x ,y ,z)
	
	if ESX.CurrentRequestId < 65535 then
		ESX.CurrentRequestId = ESX.CurrentRequestId + 1
	else
		ESX.CurrentRequestId = 0
	end

end

ESX.UI.HUD.SetDisplay = function(opacity)

	SendNUIMessage({
		action  = 'setHUDDisplay',
		opacity = opacity
	})

end

ESX.UI.HUD.RegisterElement = function(name, index, priority, html, data)

	local found = false

	for i=1, #ESX.UI.HUD.RegisteredElements, 1 do
		if ESX.UI.HUD.RegisteredElements[i] == name then
			found = true
			break
		end
	end

	if found then
		return
	end

	table.insert(ESX.UI.HUD.RegisteredElements, name)

	SendNUIMessage({
		action    = 'insertHUDElement',
		name      = name,
		index     = index,
		priority  = priority,
		html      = html,
		data      = data,
	})

	ESX.UI.HUD.UpdateElement(name, data)

end

ESX.UI.HUD.RemoveElement = function(name)

	for i=1, #ESX.UI.HUD.RegisteredElements, 1 do
		if ESX.UI.HUD.RegisteredElements[i] == name then
			table.remove(ESX.UI.HUD.RegisteredElements, i)
			break
		end
	end

	SendNUIMessage({
		action    = 'deleteHUDElement',
		name      = name
	})

end

ESX.UI.HUD.UpdateElement = function(name, data)

	SendNUIMessage({
		action = 'updateHUDElement',
		name   = name,
		data   = data,
	})

end

ESX.UI.Menu.RegisterType = function(type, open, close)
	
	ESX.UI.Menu.RegisteredTypes[type] = {
		open   = open,
		close  = close,
	}

end

ESX.UI.Menu.Open = function(type, namespace, name, data, submit, cancel, change)
	
	local menu = {}

	menu.type      = type
	menu.namespace = namespace
	menu.name      = name
	menu.data      = data
	menu.submit    = submit
	menu.cancel    = cancel
	menu.change    = change
	
	menu.close = function()
			
		ESX.UI.Menu.RegisteredTypes[type].close(namespace, name)
		
		for i=1, #ESX.UI.Menu.Opened, 1 do
			if ESX.UI.Menu.Opened[i].type == type and ESX.UI.Menu.Opened[i].namespace == namespace and ESX.UI.Menu.Opened[i].name == name then
				ESX.UI.Menu.Opened[i] = nil
			end
		end

	end

	menu.update = function(query, newData)

		for i=1, #menu.data.elements, 1 do
			
			local match = true

			for k,v in pairs(query) do
				if menu.data.elements[i][k] ~= v then
					match = false
				end
			end

			if match then
				for k,v in pairs(newData) do
					menu.data.elements[i][k] = v
				end
			end

			ESX.UI.Menu.RegisteredTypes[type].open(namespace, name, menu.data)

		end

	end

	menu.setElement = function(i, key, val)
		menu.data.elements[i][key] = val
	end

	table.insert(ESX.UI.Menu.Opened, menu)

	ESX.UI.Menu.RegisteredTypes[type].open(namespace, name, data)

end

ESX.UI.Menu.Close = function(type, namespace, name)
	
	for i=1, #ESX.UI.Menu.Opened, 1 do
		if ESX.UI.Menu.Opened[i].type == type and ESX.UI.Menu.Opened[i].namespace == namespace and ESX.UI.Menu.Opened[i].name == name then
			ESX.UI.Menu.Opened[i].close()
			ESX.UI.Menu.Opened[i] = nil
		end
	end

end

ESX.UI.Menu.CloseAll = function()
	
	for i=1, #ESX.UI.Menu.Opened, 1 do
		ESX.UI.Menu.Opened[i].close()
		ESX.UI.Menu.Opened[i] = nil
	end

end

ESX.UI.Menu.GetOpened = function(type, namespace, name)

	for i=1, #ESX.UI.Menu.Opened, 1 do
		if ESX.UI.Menu.Opened[i].type == type and ESX.UI.Menu.Opened[i].namespace == namespace and ESX.UI.Menu.Opened[i].name == name then
			return ESX.UI.Menu.Opened[i]
		end
	end

end

ESX.UI.Menu.IsOpen = function(type, namespace, name)
	return ESX.UI.Menu.GetOpened(type, namespace, name) ~= nil
end

ESX.UI.ShowInventoryItemNotification = function(add, item, count)
	SendNUIMessage({
		action = 'inventoryNotification',
		add    = add,
		item   = item,
		count  = count
	})
end

ESX.GetWeaponList = function()
	return Config.Weapons
end

ESX.GetWeaponLabel = function(name)
	
	name          = string.upper(name)
	local weapons = ESX.GetWeaponList()
	
	for i=1, #weapons, 1 do
		if weapons[i].name == name then
			return weapons[i].label
		end
	end

end

ESX.Game.Teleport = function(entity, coords, cb)
	
	RequestCollisionAtCoord(coords.x, coords.y, coords.z)
	
	while not HasCollisionLoadedAroundEntity(entity) do
		RequestCollisionAtCoord(coords.x, coords.x, coords.x)
		Citizen.Wait(0)
	end

	SetEntityCoords(entity,  coords.x,  coords.y,  coords.z)

	if cb ~= nil then
		cb()
	end

end

ESX.Game.GetPlayers = function()
	
	local maxPlayers = Config.MaxPlayers
	local players    = {}

	for i=0, maxPlayers, 1 do

		local ped = GetPlayerPed(i)

		if DoesEntityExist(ped) then
			table.insert(players, i)
		end
	end

	return players

end

ESX.Game.SpawnVehicle = function(modelName, coords, heading, cb)

  local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	Citizen.CreateThread(function()

		RequestModel(model)

		while not HasModelLoaded(model) do
			Citizen.Wait(0)
		end

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
		local id      = NetworkGetNetworkIdFromEntity(vehicle)

		SetNetworkIdCanMigrate(id, true)
		SetEntityAsMissionEntity(vehicle,  true,  false)
		SetVehicleHasBeenOwnedByPlayer(vehicle,  true)
		SetModelAsNoLongerNeeded(model)

		RequestCollisionAtCoord(coords.x, coords.y, coords.z)
		
		while not HasCollisionLoadedAroundEntity(vehicle) do
			RequestCollisionAtCoord(coords.x, coords.x, coords.x)
			Citizen.Wait(0)
		end

		if cb ~= nil then
			cb(vehicle)
		end

	end)

end

ESX.Game.SpawnLocalVehicle = function(modelName, coords, heading, cb)

  local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	Citizen.CreateThread(function()

		RequestModel(model)

		while not HasModelLoaded(model) do
			Citizen.Wait(0)
		end

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, false, false)

		SetEntityAsMissionEntity(vehicle,  true,  false)
		SetVehicleHasBeenOwnedByPlayer(vehicle,  true)
		SetModelAsNoLongerNeeded(model)

		RequestCollisionAtCoord(coords.x, coords.y, coords.z)
		
		while not HasCollisionLoadedAroundEntity(vehicle) do
			RequestCollisionAtCoord(coords.x, coords.x, coords.x)
			Citizen.Wait(0)
		end

		if cb ~= nil then
			cb(vehicle)
		end

	end)

end

ESX.Game.GetClosestPlayer = function(coords)
	
	local players         = ESX.Game.GetPlayers()
	local closestDistance = -1
	local closestPlayer   = -1
	local coords          = coords
	local usePlayerPed    = false
	local playerPed       = nil

	if coords == nil then
		usePlayerPed = true
		playerPed    = GetPlayerPed(-1)
		coords       = GetEntityCoords(playerPed)
	end

	for i=1, #players, 1 do
		
		local target = GetPlayerPed(players[i])
		
		if not usePlayerPed or (usePlayerPed and target ~= playerPed) then
			
			local targetCoords = GetEntityCoords(target)
			local distance     = GetDistanceBetweenCoords(targetCoords.x, targetCoords.y, targetCoords.z, coords.x, coords.y, coords.z, true)
			
			if closestDistance == -1 or closestDistance > distance then
				closestPlayer   = players[i]
				closestDistance = distance
			end

		end

	end
	
	return closestPlayer, closestDistance
end

ESX.Game.GetPlayersInArea = function(coords, area)
	
	local players       = ESX.Game.GetPlayers()
	local playersInArea = {}
	
	for i=1, #players, 1 do
		
		local target       = GetPlayerPed(players[i])
		local targetCoords = GetEntityCoords(target)
		local distance     = GetDistanceBetweenCoords(targetCoords.x, targetCoords.y, targetCoords.z, coords.x, coords.y, coords.z, true)

		if distance <= area then
			table.insert(playersInArea, players[i])
		end

	end
	
	return playersInArea
end

ESX.Game.GetVehicles = function()

	local vehicles        = {}
	local handle, vehicle = FindFirstVehicle()
	local success         = nil

	repeat
		table.insert(vehicles, vehicle)
		success, vehicle = FindNextVehicle(handle)
	until not success

	EndFindVehicle(handle)

	return vehicles

end

ESX.Game.GetClosestVehicle = function(coords)
	
	local vehicles        = ESX.Game.GetVehicles()
	local closestDistance = -1
	local closestPlayer   = -1
	local coords          = coords

	if coords == nil then
		local playerPed = GetPlayerPed(-1)
		coords          = GetEntityCoords(playerPed)
	end

	for i=1, #vehicles, 1 do
		
		local vehicleCoords = GetEntityCoords(vehicles[i])
		local distance      = GetDistanceBetweenCoords(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, coords.x, coords.y, coords.z, true)
		
		if closestDistance == -1 or closestDistance > distance then
			closestVehicle  = vehicles[i]
			closestDistance = distance
		end

	end
	
	return closestVehicle, closestDistance

end

ESX.Game.GetVehiclesInArea = function(coords, area)
	
	local vehicles       = ESX.Game.GetVehicles()
	local vehiclesInArea = {}
	
	for i=1, #vehicles, 1 do
		
		local vehicleCoords = GetEntityCoords(vehicles[i])
		local distance      = GetDistanceBetweenCoords(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, coords.x, coords.y, coords.z, true)

		if distance <= area then
			table.insert(vehiclesInArea, vehicles[i])
		end

	end
	
	return vehiclesInArea
end

ESX.Game.GetVehicleProperties = function(vehicle)

	local colour1, colour2             = GetVehicleColours(vehicle)
	local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
	
	return {
		
		model            = GetEntityModel(vehicle),
		
		plate            = GetVehicleNumberPlateText(vehicle),
		plateIndex       = GetVehicleNumberPlateTextIndex(vehicle),

		health           = GetEntityHealth(vehicle),
		dirtLevel        = GetVehicleDirtLevel(vehicle),

		color1           = colour1,
		color2           = colour2,
		pearlescentColor = pearlescentColor,
		wheelColor       = wheelColor,
		
		wheels           = GetVehicleWheelType(vehicle),
		windowTint       = GetVehicleWindowTint(vehicle),
		
		neonColor        = table.pack(GetVehicleNeonLightsColour(vehicle)),
		
		modSpoilers      = GetVehicleMod(vehicle, 0),
		modFrontBumper   = GetVehicleMod(vehicle, 1),
		modRearBumper    = GetVehicleMod(vehicle, 2),
		modSideSkirt     = GetVehicleMod(vehicle, 3),
		modExhaust       = GetVehicleMod(vehicle, 4),
		modFrame         = GetVehicleMod(vehicle, 5),
		modGrille        = GetVehicleMod(vehicle, 6),
		modHood          = GetVehicleMod(vehicle, 7),
		modFender        = GetVehicleMod(vehicle, 8),
		modRightFender   = GetVehicleMod(vehicle, 9),
		modRoof          = GetVehicleMod(vehicle, 10),

		modEngine        = GetVehicleMod(vehicle, 11),
		modBrakes        = GetVehicleMod(vehicle, 12),
		modTransmission  = GetVehicleMod(vehicle, 13),
		modHorns         = GetVehicleMod(vehicle, 14),
		modSuspension    = GetVehicleMod(vehicle, 15),
		modArmor         = GetVehicleMod(vehicle, 16),

		modTurbo         = IsToggleModOn(vehicle,  18),
		modXenon         = IsToggleModOn(vehicle,  22),

		modFrontWheels   = GetVehicleMod(vehicle, 23),
		modBackWheels    = GetVehicleMod(vehicle, 24)
	}

end

ESX.Game.SetVehicleProperties = function(vehicle, props)

	SetVehicleModKit(vehicle,  0)

	if props.plate ~= nil then
		SetVehicleNumberPlateText(vehicle,  props.plate)
	end

	if props.plateIndex ~= nil then
		SetVehicleNumberPlateTextIndex(vehicle,  props.plateIndex)
	end

	if props.health ~= nil then
		SetEntityHealth(vehicle,  props.health)
	end

	if props.dirtLevel ~= nil then
		SetVehicleDirtLevel(vehicle,  props.dirtLevel)
	end

	if props.color1 ~= nil and props.color2 ~= nil then
		SetVehicleColours(vehicle, props.color1, props.color2)
	end

	if props.pearlescentColor ~= nil and props.wheelColor ~= nil then
		SetVehicleExtraColours(vehicle,  props.pearlescentColor,  props.wheelColor)
	end

	if props.wheels ~= nil then
		SetVehicleWheelType(vehicle,  props.wheels)
	end

	if props.windowTint ~= nil then
		SetVehicleWindowTint(vehicle,  props.windowTint)
	end

	if props.neonColor ~= nil then
		SetVehicleNeonLightsColour(vehicle,  props.neonColor[1], props.neonColor[2], props.neonColor[3])
	end

	if props.modSpoilers ~= nil then
		SetVehicleMod(vehicle, 0, props.modSpoilers, false)
	end

	if props.modFrontBumper ~= nil then
		SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
	end

	if props.modRearBumper ~= nil then
		SetVehicleMod(vehicle, 2, props.modRearBumper, false)
	end

	if props.modSideSkirt ~= nil then
		SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
	end

	if props.modExhaust ~= nil then
		SetVehicleMod(vehicle, 4, props.modExhaust, false)
	end

	if props.modFrame ~= nil then
		SetVehicleMod(vehicle, 5, props.modFrame, false)
	end

	if props.modGrille ~= nil then
		SetVehicleMod(vehicle, 6, props.modGrille, false)
	end

	if props.modHood ~= nil then
		SetVehicleMod(vehicle, 7, props.modHood, false)
	end

	if props.modFender ~= nil then
		SetVehicleMod(vehicle, 8, props.modFender, false)
	end

	if props.modRightFender ~= nil then
		SetVehicleMod(vehicle, 9, props.modRightFender, false)
	end

	if props.modRoof ~= nil then
		SetVehicleMod(vehicle, 10, props.modRoof, false)
	end

	if props.modEngine ~= nil then
		SetVehicleMod(vehicle, 11, props.modEngine, false)
	end

	if props.modBrakes ~= nil then
		SetVehicleMod(vehicle, 12, props.modBrakes, false)
	end

	if props.modTransmission ~= nil then
		SetVehicleMod(vehicle, 13, props.modTransmission, false)
	end

	if props.modHorns ~= nil then
		SetVehicleMod(vehicle, 14, props.modHorns, false)
	end

	if props.modSuspension ~= nil then
		SetVehicleMod(vehicle, 15, props.modSuspension, false)
	end

	if props.modArmor ~= nil then
		SetVehicleMod(vehicle, 16, props.modArmor, false)
	end

	if props.modTurbo ~= nil then
		ToggleVehicleMod(vehicle,  18, props.modTurbo)
	end

	if props.modXenon ~= nil then
		ToggleVehicleMod(vehicle,  22, props.modXenon)
	end

	if props.modFrontWheels ~= nil then
		SetVehicleMod(vehicle, 23, props.modFrontWheels, false)
	end

	if props.modBackWheels ~= nil then
		SetVehicleMod(vehicle, 24, props.modBackWheels, false)
	end

end

ESX.ShowInventory = function()
	
	ESX.TriggerServerCallback('esx:getPlayerData', function(data)

		local playerPed = GetPlayerPed(-1)
		local elements  = {}

		table.insert(elements, {
			label  = '[Cash] $' .. data.money,
			count  = data.money,
			type   = 'item_money',
			value  = 'money',
			usable = false
		})

		for i=1, #data.accounts, 1 do
			table.insert(elements, {
				label  = '[' .. data.accounts[i].label .. '] $' .. data.accounts[i].money,
				count  = data.accounts[i].money,
				type   = 'item_account',
				value  =  data.accounts[i].name,
				usable = false
			})
		end

		for i=1, #data.inventory, 1 do

			if data.inventory[i].count > 0 then
				table.insert(elements, {
					label  = data.inventory[i].label .. ' x' .. data.inventory[i].count,
					count  = data.inventory[i].count,
					type   = 'item_standard',
					value  = data.inventory[i].name,
					usable = data.inventory[i].usable
				})
			end

		end

		for i=1, #Config.Weapons, 1 do
			
			local weaponHash = GetHashKey(Config.Weapons[i].name)

			if HasPedGotWeapon(playerPed,  weaponHash,  false) and Config.Weapons[i].name ~= 'WEAPON_UNARMED' then

				local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
				
				table.insert(elements, {
					label  = Config.Weapons[i].label .. ' x1 [' .. ammo .. ']',
					count  = 1,
					type   = 'item_weapon',
					value  = Config.Weapons[i].name,
					usable = false
				})

			end
		end

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'inventory',
			{
				title    = 'Inventaire',
				align    = 'bottom-right',
				elements = elements,
			},
			function(data, menu)

				menu.close()

				local elements = {}

				if data.current.usable then
					table.insert(elements, {label = 'Utiliser', action = 'use',   type = data.current.type, value = data.current.value})
				end

				table.insert(elements, {label = 'Donner', action = 'give',   type = data.current.type, value = data.current.value})
				table.insert(elements, {label = 'Jeter',  action = 'remove', type = data.current.type, value = data.current.value})
				table.insert(elements, {label = 'Retour', action = 'return'})

				ESX.UI.Menu.Open(
					'default', GetCurrentResourceName(), 'inventory_item',
					{
						title    = 'Inventaire',
						align    = 'bottom-right',
						elements = elements,
					},
					function(data, menu)

						local item = data.current.value
						local type = data.current.type

						if data.current.action == 'give' then

							if type == 'item_weapon' then
								TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), type, item, 1)
							else

								ESX.UI.Menu.Open(
									'dialog', GetCurrentResourceName(), 'inventory_item_count_give',
									{
										title = 'Quantité'
									},
									function(data2, menu)

										local quantity                       = tonumber(data2.value)
										local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

										if closestPlayer == -1 or closestDistance > 3.0 then
											ESX.ShowNotification('Aucun joueur à proximité')
										else
											TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), type, item, quantity)
										end

										menu.close()
									end,
									function(data2, menu)
										menu.close()
									end
								)

							end

						elseif data.current.action == 'remove' then

							if type == 'item_weapon' then
								TriggerServerEvent('esx:removeInventoryItem', type, item, 1)
							else

								ESX.UI.Menu.Open(
									'dialog', GetCurrentResourceName(), 'inventory_item_count_remove',
									{
										title = 'Quantité'
									},
									function(data2, menu)

										local quantity = tonumber(data2.value)

										if quantity == nil then
											ESX.ShowNotification('Montant invalide')
										else
											
											menu.close()
							
											TriggerServerEvent('esx:removeInventoryItem', type, item, quantity)

										end
										
									end,
									function(data2, menu)
										menu.close()
									end
								)

							end

						elseif data.current.action == 'return' then
							ESX.UI.Menu.CloseAll()
							ESX.ShowInventory()
						end
						
					end,
					function(data, menu)
						ESX.UI.Menu.CloseAll()
						ESX.ShowInventory()
					end
				)

			end,
			function(data, menu)
				menu.close()
			end
		)

	end)

end

AddEventHandler('esx:getSharedObject', function(cb)
	cb(ESX)
end)

RegisterNetEvent('esx:serverCallback')
AddEventHandler('esx:serverCallback', function(requestId, a, b, c, d, e, f, g ,h ,i ,j ,k, l, m, n, o, p, q, r, s, t, u ,v ,w, x ,y ,z)
	ESX.ServerCallbacks[requestId](a, b, c, d, e, f, g ,h ,i ,j ,k, l, m, n, o, p, q, r, s, t, u ,v ,w, x ,y ,z)
	ESX.ServerCallbacks[requestId] = nil
end)

RegisterNetEvent('esx:showNotification')
AddEventHandler('esx:showNotification', function(msg)
	ESX.ShowNotification(msg)
end)

-- SetTimeout
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		local currTime = GetGameTimer()

		for i=1, #ESX.TimeoutCallbacks, 1 do

			if currTime >= ESX.TimeoutCallbacks[i].time then
				ESX.TimeoutCallbacks[i].cb()
				ESX.TimeoutCallbacks[i] = nil
			end

		end

	end
end)