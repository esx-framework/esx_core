ESX                           = {}
ESX.PlayerData                = {}
ESX.PlayerLoaded              = false
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
ESX.Game.Utils                = {}

ESX.Scaleform                 = {}
ESX.Scaleform.Utils           = {}

ESX.Streaming                 = {}

ESX.SetTimeout = function(msec, cb)
	table.insert(ESX.TimeoutCallbacks, {
		time = GetGameTimer() + msec,
		cb   = cb
	})
	return #ESX.TimeoutCallbacks
end

ESX.ClearTimeout = function(i)
	ESX.TimeoutCallbacks[i] = nil
end

ESX.IsPlayerLoaded = function()
	return ESX.PlayerLoaded
end

ESX.GetPlayerData = function()
	return ESX.PlayerData
end

ESX.SetPlayerData = function(key, val)
	ESX.PlayerData[key] = val
end

ESX.ShowNotification = function(msg)
	AddTextEntry('esxNotification', msg)
	SetNotificationTextEntry('esxNotification')
	DrawNotification(false, true)
end

ESX.ShowAdvancedNotification = function(title, subject, msg, icon, iconType)
	AddTextEntry('esxAdvancedNotification', msg)
	SetNotificationTextEntry('esxAdvancedNotification')
	SetNotificationMessage(icon, icon, false, iconType, title, subject)
	DrawNotification(false, false)
end

ESX.ShowHelpNotification = function(msg)
	--if not IsHelpMessageBeingDisplayed() then
		AddTextEntry('esxHelpNotification', msg)
		BeginTextCommandDisplayHelp('esxHelpNotification')
		EndTextCommandDisplayHelp(0, false, true, -1)
	--end
end

ESX.TriggerServerCallback = function(name, cb, ...)
	ESX.ServerCallbacks[ESX.CurrentRequestId] = cb

	TriggerServerEvent('esx:triggerServerCallback', name, ESX.CurrentRequestId, ...)

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
		data      = data
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
		data   = data
	})
end

ESX.UI.Menu.RegisterType = function(type, open, close)
	ESX.UI.Menu.RegisteredTypes[type] = {
		open   = open,
		close  = close
	}
end

ESX.UI.Menu.Open = function(type, namespace, name, data, submit, cancel, change, close)
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
			if ESX.UI.Menu.Opened[i] then
				if ESX.UI.Menu.Opened[i].type == type and ESX.UI.Menu.Opened[i].namespace == namespace and ESX.UI.Menu.Opened[i].name == name then
					ESX.UI.Menu.Opened[i] = nil
				end
			end
		end

		if close then
			close()
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
		end

	end

	menu.refresh = function()
		ESX.UI.Menu.RegisteredTypes[type].open(namespace, name, menu.data)
	end

	menu.setElement = function(i, key, val)
		menu.data.elements[i][key] = val
	end

	menu.setTitle = function(val)
		menu.data.title = val
	end

	menu.removeElement = function(query)
		for i=1, #menu.data.elements, 1 do
			for k,v in pairs(query) do
				if menu.data.elements[i] then
					if menu.data.elements[i][k] == v then
						table.remove(menu.data.elements, i)
						break
					end
				end

			end
		end
	end

	table.insert(ESX.UI.Menu.Opened, menu)
	ESX.UI.Menu.RegisteredTypes[type].open(namespace, name, data)

	return menu
end

ESX.UI.Menu.Close = function(type, namespace, name)
	for i=1, #ESX.UI.Menu.Opened, 1 do
		if ESX.UI.Menu.Opened[i] then
			if ESX.UI.Menu.Opened[i].type == type and ESX.UI.Menu.Opened[i].namespace == namespace and ESX.UI.Menu.Opened[i].name == name then
				ESX.UI.Menu.Opened[i].close()
				ESX.UI.Menu.Opened[i] = nil
			end
		end
	end
end

ESX.UI.Menu.CloseAll = function()
	for i=1, #ESX.UI.Menu.Opened, 1 do
		if ESX.UI.Menu.Opened[i] then
			ESX.UI.Menu.Opened[i].close()
			ESX.UI.Menu.Opened[i] = nil
		end
	end
end

ESX.UI.Menu.GetOpened = function(type, namespace, name)
	for i=1, #ESX.UI.Menu.Opened, 1 do
		if ESX.UI.Menu.Opened[i] then
			if ESX.UI.Menu.Opened[i].type == type and ESX.UI.Menu.Opened[i].namespace == namespace and ESX.UI.Menu.Opened[i].name == name then
				return ESX.UI.Menu.Opened[i]
			end
		end
	end
end

ESX.UI.Menu.GetOpenedMenus = function()
	return ESX.UI.Menu.Opened
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

ESX.Game.GetPedMugshot = function(ped)
	local mugshot = RegisterPedheadshot(ped)

	while not IsPedheadshotReady(mugshot) do
		Citizen.Wait(0)
	end

	return mugshot, GetPedheadshotTxdString(mugshot)
end

ESX.Game.Teleport = function(entity, coords, cb)
	RequestCollisionAtCoord(coords.x, coords.y, coords.z)

	while not HasCollisionLoadedAroundEntity(entity) do
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)
		Citizen.Wait(0)
	end

	SetEntityCoords(entity, coords.x, coords.y, coords.z)

	if cb then
		cb()
	end
end

ESX.Game.SpawnObject = function(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))

	Citizen.CreateThread(function()
		ESX.Streaming.RequestModel(model)

		local obj = CreateObject(model, coords.x, coords.y, coords.z, true, false, true)

		if cb then
			cb(obj)
		end
	end)
end

ESX.Game.SpawnLocalObject = function(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))

	Citizen.CreateThread(function()
		ESX.Streaming.RequestModel(model)

		local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, true)

		if cb then
			cb(obj)
		end
	end)
end

ESX.Game.DeleteVehicle = function(vehicle)
	SetEntityAsMissionEntity(vehicle, false, true)
	DeleteVehicle(vehicle)
end

ESX.Game.DeleteObject = function(object)
	SetEntityAsMissionEntity(object, false, true)
	DeleteObject(object)
end

ESX.Game.SpawnVehicle = function(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	Citizen.CreateThread(function()
		ESX.Streaming.RequestModel(model)

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
		local id      = NetworkGetNetworkIdFromEntity(vehicle)

		SetNetworkIdCanMigrate(id, true)
		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetModelAsNoLongerNeeded(model)

		RequestCollisionAtCoord(coords.x, coords.y, coords.z)

		while not HasCollisionLoadedAroundEntity(vehicle) do
			RequestCollisionAtCoord(coords.x, coords.y, coords.z)
			Citizen.Wait(0)
		end

		SetVehRadioStation(vehicle, 'OFF')

		if cb then
			cb(vehicle)
		end
	end)
end

ESX.Game.SpawnLocalVehicle = function(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	Citizen.CreateThread(function()
		ESX.Streaming.RequestModel(model)

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, false, false)

		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetModelAsNoLongerNeeded(model)
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)

		while not HasCollisionLoadedAroundEntity(vehicle) do
			RequestCollisionAtCoord(coords.x, coords.y, coords.z)
			Citizen.Wait(0)
		end

		SetVehRadioStation(vehicle, 'OFF')

		if cb then
			cb(vehicle)
		end
	end)
end

ESX.Game.IsVehicleEmpty = function(vehicle)
	local passengers = GetVehicleNumberOfPassengers(vehicle)
	local driverSeatFree = IsVehicleSeatFree(vehicle, -1)

	return passengers == 0 and driverSeatFree
end

ESX.Game.GetObjects = function()
	local objects = {}

	for object in EnumerateObjects() do
		table.insert(objects, object)
	end

	return objects
end

ESX.Game.GetClosestObject = function(filter, coords)
	local objects = ESX.Game.GetObjects()
	local closestDistance, closestObject = -1, -1
	local filter, coords = filter, coords

	if type(filter) == 'string' then
		if filter ~= '' then
			filter = {filter}
		end
	end

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end

	for i=1, #objects, 1 do
		local foundObject = false

		if filter == nil or (type(filter) == 'table' and #filter == 0) then
			foundObject = true
		else
			local objectModel = GetEntityModel(objects[i])

			for j=1, #filter, 1 do
				if objectModel == GetHashKey(filter[j]) then
					foundObject = true
					break
				end
			end
		end

		if foundObject then
			local objectCoords = GetEntityCoords(objects[i])
			local distance = #(objectCoords - coords)

			if closestDistance == -1 or closestDistance > distance then
				closestObject = objects[i]
				closestDistance = distance
			end
		end
	end

	return closestObject, closestDistance
end

ESX.Game.GetPlayers = function()
	local players = {}

	for _,player in ipairs(GetActivePlayers()) do
		local ped = GetPlayerPed(player)

		if DoesEntityExist(ped) then
			table.insert(players, player)
		end
	end

	return players
end

ESX.Game.GetClosestPlayer = function(coords)
	local players, closestDistance, closestPlayer = ESX.Game.GetPlayers(), -1, -1
	local coords, usePlayerPed = coords, false
	local playerPed, playerId = PlayerPedId(), PlayerId()

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		usePlayerPed = true
		coords = GetEntityCoords(playerPed)
	end

	for i=1, #players, 1 do
		local target = GetPlayerPed(players[i])

		if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then
			local targetCoords = GetEntityCoords(target)
			local distance = #(coords - targetCoords)

			if closestDistance == -1 or closestDistance > distance then
				closestPlayer = players[i]
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
		local distance     = GetDistanceBetweenCoords(targetCoords, coords.x, coords.y, coords.z, true)

		if distance <= area then
			table.insert(playersInArea, players[i])
		end
	end

	return playersInArea
end

ESX.Game.GetVehicles = function()
	local vehicles = {}

	for vehicle in EnumerateVehicles() do
		table.insert(vehicles, vehicle)
	end

	return vehicles
end

ESX.Game.GetClosestVehicle = function(coords)
	local vehicles        = ESX.Game.GetVehicles()
	local closestDistance = -1
	local closestVehicle  = -1
	local coords          = coords

	if coords == nil then
		local playerPed = PlayerPedId()
		coords          = GetEntityCoords(playerPed)
	end

	for i=1, #vehicles, 1 do
		local vehicleCoords = GetEntityCoords(vehicles[i])
		local distance      = GetDistanceBetweenCoords(vehicleCoords, coords.x, coords.y, coords.z, true)

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
		local distance      = GetDistanceBetweenCoords(vehicleCoords, coords.x, coords.y, coords.z, true)

		if distance <= area then
			table.insert(vehiclesInArea, vehicles[i])
		end
	end

	return vehiclesInArea
end

ESX.Game.GetVehicleInDirection = function()
	local playerPed    = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
	local inDirection  = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
	local rayHandle    = StartShapeTestRay(playerCoords, inDirection, 10, playerPed, 0)
	local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

	if hit == 1 and GetEntityType(entityHit) == 2 then
		return entityHit
	end

	return nil
end

ESX.Game.IsSpawnPointClear = function(coords, radius)
	local vehicles = ESX.Game.GetVehiclesInArea(coords, radius)

	return #vehicles == 0
end

ESX.Game.GetPeds = function(ignoreList)
	local ignoreList = ignoreList or {}
	local peds       = {}

	for ped in EnumeratePeds() do
		local found = false

		for j=1, #ignoreList, 1 do
			if ignoreList[j] == ped then
				found = true
			end
		end

		if not found then
			table.insert(peds, ped)
		end
	end

	return peds
end

ESX.Game.GetClosestPed = function(coords, ignoreList)
	local ignoreList      = ignoreList or {}
	local peds            = ESX.Game.GetPeds(ignoreList)
	local closestDistance = -1
	local closestPed      = -1

	for i=1, #peds, 1 do
		local pedCoords = GetEntityCoords(peds[i])
		local distance  = GetDistanceBetweenCoords(pedCoords, coords.x, coords.y, coords.z, true)

		if closestDistance == -1 or closestDistance > distance then
			closestPed      = peds[i]
			closestDistance = distance
		end
	end

	return closestPed, closestDistance
end

ESX.Game.GetVehicleProperties = function(vehicle)
	local color1, color2 = GetVehicleColours(vehicle)
	local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
	local extras = {}

	for id=0, 12 do
		if DoesExtraExist(vehicle, id) then
			local state = IsVehicleExtraTurnedOn(vehicle, id) == 1
			extras[tostring(id)] = state
		end
	end

	return {
		model             = GetEntityModel(vehicle),

		plate             = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)),
		plateIndex        = GetVehicleNumberPlateTextIndex(vehicle),

		bodyHealth        = ESX.Math.Round(GetVehicleBodyHealth(vehicle), 1),
		engineHealth      = ESX.Math.Round(GetVehicleEngineHealth(vehicle), 1),

		fuelLevel         = ESX.Math.Round(GetVehicleFuelLevel(vehicle), 1),
		dirtLevel         = ESX.Math.Round(GetVehicleDirtLevel(vehicle), 1),
		color1            = color1,
		color2            = color2,

		pearlescentColor  = pearlescentColor,
		wheelColor        = wheelColor,

		wheels            = GetVehicleWheelType(vehicle),
		windowTint        = GetVehicleWindowTint(vehicle),

		neonEnabled       = {
			IsVehicleNeonLightEnabled(vehicle, 0),
			IsVehicleNeonLightEnabled(vehicle, 1),
			IsVehicleNeonLightEnabled(vehicle, 2),
			IsVehicleNeonLightEnabled(vehicle, 3)
		},

		extras            = extras,

		neonColor         = table.pack(GetVehicleNeonLightsColour(vehicle)),
		tyreSmokeColor    = table.pack(GetVehicleTyreSmokeColor(vehicle)),

		modSpoilers       = GetVehicleMod(vehicle, 0),
		modFrontBumper    = GetVehicleMod(vehicle, 1),
		modRearBumper     = GetVehicleMod(vehicle, 2),
		modSideSkirt      = GetVehicleMod(vehicle, 3),
		modExhaust        = GetVehicleMod(vehicle, 4),
		modFrame          = GetVehicleMod(vehicle, 5),
		modGrille         = GetVehicleMod(vehicle, 6),
		modHood           = GetVehicleMod(vehicle, 7),
		modFender         = GetVehicleMod(vehicle, 8),
		modRightFender    = GetVehicleMod(vehicle, 9),
		modRoof           = GetVehicleMod(vehicle, 10),

		modEngine         = GetVehicleMod(vehicle, 11),
		modBrakes         = GetVehicleMod(vehicle, 12),
		modTransmission   = GetVehicleMod(vehicle, 13),
		modHorns          = GetVehicleMod(vehicle, 14),
		modSuspension     = GetVehicleMod(vehicle, 15),
		modArmor          = GetVehicleMod(vehicle, 16),

		modTurbo          = IsToggleModOn(vehicle, 18),
		modSmokeEnabled   = IsToggleModOn(vehicle, 20),
		modXenon          = IsToggleModOn(vehicle, 22),

		modFrontWheels    = GetVehicleMod(vehicle, 23),
		modBackWheels     = GetVehicleMod(vehicle, 24),

		modPlateHolder    = GetVehicleMod(vehicle, 25),
		modVanityPlate    = GetVehicleMod(vehicle, 26),
		modTrimA          = GetVehicleMod(vehicle, 27),
		modOrnaments      = GetVehicleMod(vehicle, 28),
		modDashboard      = GetVehicleMod(vehicle, 29),
		modDial           = GetVehicleMod(vehicle, 30),
		modDoorSpeaker    = GetVehicleMod(vehicle, 31),
		modSeats          = GetVehicleMod(vehicle, 32),
		modSteeringWheel  = GetVehicleMod(vehicle, 33),
		modShifterLeavers = GetVehicleMod(vehicle, 34),
		modAPlate         = GetVehicleMod(vehicle, 35),
		modSpeakers       = GetVehicleMod(vehicle, 36),
		modTrunk          = GetVehicleMod(vehicle, 37),
		modHydrolic       = GetVehicleMod(vehicle, 38),
		modEngineBlock    = GetVehicleMod(vehicle, 39),
		modAirFilter      = GetVehicleMod(vehicle, 40),
		modStruts         = GetVehicleMod(vehicle, 41),
		modArchCover      = GetVehicleMod(vehicle, 42),
		modAerials        = GetVehicleMod(vehicle, 43),
		modTrimB          = GetVehicleMod(vehicle, 44),
		modTank           = GetVehicleMod(vehicle, 45),
		modWindows        = GetVehicleMod(vehicle, 46),
		modLivery         = GetVehicleLivery(vehicle)
	}
end

ESX.Game.SetVehicleProperties = function(vehicle, props)
	SetVehicleModKit(vehicle, 0)

	if props.plate then
		SetVehicleNumberPlateText(vehicle, props.plate)
	end

	if props.plateIndex then
		SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
	end

	if props.bodyHealth then
		SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
	end

	if props.engineHealth then
		SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
	end

	if props.fuelLevel then
		SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
	end

	if props.dirtLevel then
		SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
	end

	if props.color1 then
		local color1, color2 = GetVehicleColours(vehicle)
		SetVehicleColours(vehicle, props.color1, color2)
	end

	if props.color2 then
		local color1, color2 = GetVehicleColours(vehicle)
		SetVehicleColours(vehicle, color1, props.color2)
	end

	if props.pearlescentColor then
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
	end

	if props.wheelColor then
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleExtraColours(vehicle, pearlescentColor, props.wheelColor)
	end

	if props.wheels then
		SetVehicleWheelType(vehicle, props.wheels)
	end

	if props.windowTint then
		SetVehicleWindowTint(vehicle, props.windowTint)
	end

	if props.neonEnabled then
		SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
		SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
		SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
		SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
	end

	if props.extras then
		for id,enabled in pairs(props.extras) do
			if enabled then
				SetVehicleExtra(vehicle, tonumber(id), 0)
			else
				SetVehicleExtra(vehicle, tonumber(id), 1)
			end
		end
	end

	if props.neonColor then
		SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
	end

	if props.modSmokeEnabled then
		ToggleVehicleMod(vehicle, 20, true)
	end

	if props.tyreSmokeColor then
		SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
	end

	if props.modSpoilers then
		SetVehicleMod(vehicle, 0, props.modSpoilers, false)
	end

	if props.modFrontBumper then
		SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
	end

	if props.modRearBumper then
		SetVehicleMod(vehicle, 2, props.modRearBumper, false)
	end

	if props.modSideSkirt then
		SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
	end

	if props.modExhaust then
		SetVehicleMod(vehicle, 4, props.modExhaust, false)
	end

	if props.modFrame then
		SetVehicleMod(vehicle, 5, props.modFrame, false)
	end

	if props.modGrille then
		SetVehicleMod(vehicle, 6, props.modGrille, false)
	end

	if props.modHood then
		SetVehicleMod(vehicle, 7, props.modHood, false)
	end

	if props.modFender then
		SetVehicleMod(vehicle, 8, props.modFender, false)
	end

	if props.modRightFender then
		SetVehicleMod(vehicle, 9, props.modRightFender, false)
	end

	if props.modRoof then
		SetVehicleMod(vehicle, 10, props.modRoof, false)
	end

	if props.modEngine then
		SetVehicleMod(vehicle, 11, props.modEngine, false)
	end

	if props.modBrakes then
		SetVehicleMod(vehicle, 12, props.modBrakes, false)
	end

	if props.modTransmission then
		SetVehicleMod(vehicle, 13, props.modTransmission, false)
	end

	if props.modHorns then
		SetVehicleMod(vehicle, 14, props.modHorns, false)
	end

	if props.modSuspension then
		SetVehicleMod(vehicle, 15, props.modSuspension, false)
	end

	if props.modArmor then
		SetVehicleMod(vehicle, 16, props.modArmor, false)
	end

	if props.modTurbo then
		ToggleVehicleMod(vehicle,  18, props.modTurbo)
	end

	if props.modXenon then
		ToggleVehicleMod(vehicle,  22, props.modXenon)
	end

	if props.modFrontWheels then
		SetVehicleMod(vehicle, 23, props.modFrontWheels, false)
	end

	if props.modBackWheels then
		SetVehicleMod(vehicle, 24, props.modBackWheels, false)
	end

	if props.modPlateHolder then
		SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
	end

	if props.modVanityPlate then
		SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
	end

	if props.modTrimA then
		SetVehicleMod(vehicle, 27, props.modTrimA, false)
	end

	if props.modOrnaments then
		SetVehicleMod(vehicle, 28, props.modOrnaments, false)
	end

	if props.modDashboard then
		SetVehicleMod(vehicle, 29, props.modDashboard, false)
	end

	if props.modDial then
		SetVehicleMod(vehicle, 30, props.modDial, false)
	end

	if props.modDoorSpeaker then
		SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
	end

	if props.modSeats then
		SetVehicleMod(vehicle, 32, props.modSeats, false)
	end

	if props.modSteeringWheel then
		SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
	end

	if props.modShifterLeavers then
		SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
	end

	if props.modAPlate then
		SetVehicleMod(vehicle, 35, props.modAPlate, false)
	end

	if props.modSpeakers then
		SetVehicleMod(vehicle, 36, props.modSpeakers, false)
	end

	if props.modTrunk then
		SetVehicleMod(vehicle, 37, props.modTrunk, false)
	end

	if props.modHydrolic then
		SetVehicleMod(vehicle, 38, props.modHydrolic, false)
	end

	if props.modEngineBlock then
		SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
	end

	if props.modAirFilter then
		SetVehicleMod(vehicle, 40, props.modAirFilter, false)
	end

	if props.modStruts then
		SetVehicleMod(vehicle, 41, props.modStruts, false)
	end

	if props.modArchCover then
		SetVehicleMod(vehicle, 42, props.modArchCover, false)
	end

	if props.modAerials then
		SetVehicleMod(vehicle, 43, props.modAerials, false)
	end

	if props.modTrimB then
		SetVehicleMod(vehicle, 44, props.modTrimB, false)
	end

	if props.modTank then
		SetVehicleMod(vehicle, 45, props.modTank, false)
	end

	if props.modWindows then
		SetVehicleMod(vehicle, 46, props.modWindows, false)
	end

	if props.modLivery then
		SetVehicleMod(vehicle, 48, props.modLivery, false)
		SetVehicleLivery(vehicle, props.modLivery)
	end
end

ESX.Game.Utils.DrawText3D = function(coords, text, size, font)
	coords = vector3(coords.x, coords.y, coords.z)

	local camCoords = GetGameplayCamCoords()
	local distance = #(coords - camCoords)

	if not size then size = 1 end
	if not font then font = 0 end
	
	local scale = (size / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	scale = scale * fov

	SetTextScale(0.0 * scale, 0.55 * scale)
	SetTextFont(font)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)

	SetDrawOrigin(coords, 0)
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(0.0, 0.0)
	ClearDrawOrigin()
end

ESX.ShowInventory = function()
	local playerPed = PlayerPedId()
	local elements, currentWeight = {}, 0

	if ESX.PlayerData.money > 0 then
		local formattedMoney = _U('locale_currency', ESX.Math.GroupDigits(ESX.PlayerData.money))

		table.insert(elements, {
			label     = ('%s: <span style="color:green;">%s</span>'):format(_U('cash'), formattedMoney),
			count     = ESX.PlayerData.money,
			type      = 'item_money',
			value     = 'money',
			usable    = false,
			rare      = false,
			canRemove = true
		})
	end

	for k,v in pairs(ESX.PlayerData.accounts) do
		if v.money > 0 then
			local formattedMoney = _U('locale_currency', ESX.Math.GroupDigits(v.money))
			local canDrop = v.name ~= 'bank'

			table.insert(elements, {
				label     = ('%s: <span style="color:green;">%s</span>'):format(v.label, formattedMoney),
				count     = v.money,
				type      = 'item_account',
				value     = v.name,
				usable    = false,
				rare      = false,
				canRemove = canDrop
			})
		end
	end

	for k,v in ipairs(ESX.PlayerData.inventory) do
		if v.count > 0 then
			currentWeight = currentWeight + (v.weight * v.count)
			table.insert(elements, {
				label     = ('%s x%s'):format(v.label, v.count),
				count     = v.count,
				type      = 'item_standard',
				value     = v.name,
				usable    = v.usable,
				rare      = v.rare,
				canRemove = v.canRemove
			})
		end
	end

	for k,v in ipairs(Config.Weapons) do
		local weaponHash = GetHashKey(v.name)

		if HasPedGotWeapon(playerPed, weaponHash, false) then
			local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)

			table.insert(elements, {
				label     = ('%s [%s]'):format(v.label, ammo),
				count     = 1,
				type      = 'item_weapon',
				value     = v.name,
				ammo      = ammo,
				usable    = false,
				rare      = false,
				canRemove = true
			})
		end
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'inventory', {
		title    = _U('inventory', currentWeight, ESX.PlayerData.maxWeight),
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)
		menu.close()
		local player, distance = ESX.Game.GetClosestPlayer()
		local elements = {}

		if data.current.usable then
			table.insert(elements, {label = _U('use'), action = 'use', type = data.current.type, value = data.current.value})
		end

		if data.current.canRemove then
			if player ~= -1 and distance <= 3.0 then
				table.insert(elements, {label = _U('give'), action = 'give', type = data.current.type, value = data.current.value})
			end

			table.insert(elements, {label = _U('remove'), action = 'remove', type = data.current.type, value = data.current.value})
		end

		if data.current.type == 'item_weapon' and data.current.ammo > 0 and player ~= -1 and distance <= 3.0 then
			table.insert(elements, {label = _U('giveammo'), action = 'give_ammo', type = data.current.type, value = data.current.value})
		end

		table.insert(elements, {label = _U('return'), action = 'return'})

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'inventory_item', {
			title    = data.current.label,
			align    = 'bottom-right',
			elements = elements,
		}, function(data1, menu1)
			local item = data1.current.value
			local type = data1.current.type

			if data1.current.action == 'give' then
				local playersInArea = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
				local foundPlayers, elements = false, {}

				for k,v in ipairs(playersInArea) do
					if v ~= PlayerId() then
						foundPlayers = true

						table.insert(elements, {
							label = GetPlayerName(v),
							player = v
						})
					end
				end

				if foundPlayers then
					foundPlayers = false

					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'give_item_to', {
						title    = _U('give_to'),
						align    = 'bottom-right',
						elements = elements
					}, function(data2, menu2)
						local playersInArea, nearbyPlayer = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
	
						for k,v in ipairs(playersInArea) do
							if v ~= PlayerId() then
	
								if v == data2.current.player then
									foundPlayers = true
									nearbyPlayer = v
									break
								end
							end
						end
	
						if foundPlayers then
							if type == 'item_weapon' then
								local closestPed = GetPlayerPed(nearbyPlayer)
								local sourceAmmo = GetAmmoInPedWeapon(playerPed, GetHashKey(item))
		
								if IsPedOnFoot(closestPed) then
									TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(nearbyPlayer), type, item, sourceAmmo)
									menu2.close()
									menu1.close()
								else
									ESX.ShowNotification(_U('in_vehicle'))
								end
							else
								ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'inventory_item_count_give', {
									title = _U('amount')
								}, function(data3, menu3)
									local quantity = tonumber(data3.value)
									local closestPed = GetPlayerPed(nearbyPlayer)
		
									if IsPedOnFoot(closestPed) then
										if quantity then
											TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(nearbyPlayer), type, item, quantity)
											menu3.close()
											menu2.close()
											menu1.close()
										else
											ESX.ShowNotification(_U('amount_invalid'))
										end
									else
										ESX.ShowNotification(_U('in_vehicle'))
									end
								end, function(data3, menu3)
									menu3.close()
								end)
							end
						else
							ESX.ShowNotification(_U('players_nearby'))
							menu2.close()
						end
					end, function(data2, menu2)
						menu2.close()
					end) -- give end
				else
					ESX.ShowNotification(_U('players_nearby'))
				end
			elseif data1.current.action == 'remove' then
				if IsPedOnFoot(playerPed) then
					if type == 'item_weapon' then
						TriggerServerEvent('esx:removeInventoryItem', type, item)
						menu1.close()
					else -- type: item_standard
						ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'inventory_item_count_remove', {
							title = _U('amount')
						}, function(data2, menu2)
							local quantity = tonumber(data2.value)
	
							if quantity then
								TriggerServerEvent('esx:removeInventoryItem', type, item, quantity)
								menu2.close()
								menu1.close()
							else
								ESX.ShowNotification(_U('amount_invalid'))
							end
						end, function(data2, menu2)
							menu2.close()
						end)
					end
				end
			elseif data1.current.action == 'use' then
				TriggerServerEvent('esx:useItem', item)
			elseif data1.current.action == 'return' then
				ESX.UI.Menu.CloseAll()
				ESX.ShowInventory()
			elseif data1.current.action == 'give_ammo' then
				local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
				local closestPed = GetPlayerPed(closestPlayer)
				local pedAmmo = GetAmmoInPedWeapon(playerPed, GetHashKey(item))

				if IsPedOnFoot(closestPed) then
					if closestPlayer ~= -1 and closestDistance < 3.0 then
						if pedAmmo > 0 then
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'inventory_item_count_give', {
								title = _U('amountammo')
							}, function(data2, menu2)
								local quantity = tonumber(data2.value)
	
								if quantity then
									if pedAmmo >= quantity and quantity > 0 then
										TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_ammo', item, quantity)
										menu2.close()
										menu1.close()
									else
										ESX.ShowNotification(_U('noammo'))
									end
								else
									ESX.ShowNotification(_U('amount_invalid'))
								end
							end, function(data2, menu2)
								menu2.close()
							end)
						else
							ESX.ShowNotification(_U('noammo'))
						end
					else
						ESX.ShowNotification(_U('players_nearby'))
					end
				else
					ESX.ShowNotification(_U('in_vehicle'))
				end
			end
		end, function(data1, menu1)
			ESX.UI.Menu.CloseAll()
			ESX.ShowInventory()
		end)
	end, function(data, menu)
		menu.close()
	end)
end

RegisterNetEvent('esx:serverCallback')
AddEventHandler('esx:serverCallback', function(requestId, ...)
	ESX.ServerCallbacks[requestId](...)
	ESX.ServerCallbacks[requestId] = nil
end)

RegisterNetEvent('esx:showNotification')
AddEventHandler('esx:showNotification', function(msg)
	ESX.ShowNotification(msg)
end)

RegisterNetEvent('esx:showAdvancedNotification')
AddEventHandler('esx:showAdvancedNotification', function(title, subject, msg, icon, iconType)
	ESX.ShowAdvancedNotification(title, subject, msg, icon, iconType)
end)

RegisterNetEvent('esx:showHelpNotification')
AddEventHandler('esx:showHelpNotification', function(msg)
	ESX.ShowHelpNotification(msg)
end)

-- SetTimeout
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local currTime = GetGameTimer()

		for i=1, #ESX.TimeoutCallbacks, 1 do
			if ESX.TimeoutCallbacks[i] then
				if currTime >= ESX.TimeoutCallbacks[i].time then
					ESX.TimeoutCallbacks[i].cb()
					ESX.TimeoutCallbacks[i] = nil
				end
			end
		end
	end
end)
