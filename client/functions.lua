local Charset = {}

for i = 48,  57 do table.insert(Charset, string.char(i)) end
for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

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

ESX.GetConfig = function()
  return Config
end

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
  SetNotificationTextEntry('STRING')
  AddTextComponentString(msg)
  DrawNotification(0,1)
end

ESX.ShowAdvancedNotification = function(title, subject, msg, icon, iconType)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	SetNotificationMessage(icon, icon, false, iconType, title, subject)
	DrawNotification(false, false)
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

local _type = type

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

      if ESX.UI.Menu.Opened[i] ~= nil then
        if ESX.UI.Menu.Opened[i].type == type and ESX.UI.Menu.Opened[i].namespace == namespace and ESX.UI.Menu.Opened[i].name == name then
          ESX.UI.Menu.Opened[i] = nil
        end
      end

    end

    if close ~= nil then
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

  table.insert(ESX.UI.Menu.Opened, menu)

  ESX.UI.Menu.RegisteredTypes[type].open(namespace, name, data)

  return menu

end

ESX.UI.Menu.Close = function(type, namespace, name)

  for i=1, #ESX.UI.Menu.Opened, 1 do
    if ESX.UI.Menu.Opened[i] ~= nil then
      if ESX.UI.Menu.Opened[i].type == type and ESX.UI.Menu.Opened[i].namespace == namespace and ESX.UI.Menu.Opened[i].name == name then
        ESX.UI.Menu.Opened[i].close()
        ESX.UI.Menu.Opened[i] = nil
      end
    end
  end

end

ESX.UI.Menu.CloseAll = function()

  for i=1, #ESX.UI.Menu.Opened, 1 do
    if ESX.UI.Menu.Opened[i] ~= nil then
      ESX.UI.Menu.Opened[i].close()
      ESX.UI.Menu.Opened[i] = nil
    end
  end

end

ESX.UI.Menu.GetOpened = function(type, namespace, name)

  for i=1, #ESX.UI.Menu.Opened, 1 do
    if ESX.UI.Menu.Opened[i] ~= nil then
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

ESX.Game.GetPedMugshot = function(ped)
  mugshot = RegisterPedheadshot(ped)
  while not IsPedheadshotReady(mugshot) do
    Wait(0)
  end
  return mugshot, GetPedheadshotTxdString(mugshot)
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

ESX.Game.SpawnObject = function(model, coords, cb)

  local model = (type(model) == 'number' and model or GetHashKey(model))

  Citizen.CreateThread(function()

    RequestModel(model)

    while not HasModelLoaded(model) do
      Citizen.Wait(0)
    end

    local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)

    if cb ~= nil then
      cb(obj)
    end

  end)

end

ESX.Game.SpawnLocalObject = function(model, coords, cb)

  local model = (type(model) == 'number' and model or GetHashKey(model))

  Citizen.CreateThread(function()

    RequestModel(model)

    while not HasModelLoaded(model) do
      Citizen.Wait(0)
    end

    local obj = CreateObject(model, coords.x, coords.y, coords.z, false, true, true)

    if cb ~= nil then
      cb(obj)
    end

  end)

end

ESX.Game.DeleteVehicle = function(vehicle)
  SetEntityAsMissionEntity(vehicle,  false,  true)
  DeleteVehicle(vehicle)
end

ESX.Game.DeleteObject = function(object)
  SetEntityAsMissionEntity(object,  false,  true)
  DeleteObject(object)
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
    SetVehicleHasBeenOwnedByPlayer(vehicle,  true)
    SetModelAsNoLongerNeeded(model)

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)

    while not HasCollisionLoadedAroundEntity(vehicle) do
      RequestCollisionAtCoord(coords.x, coords.y, coords.z)
      Citizen.Wait(0)
    end

    SetVehRadioStation(vehicle, 'OFF')

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

    SetVehicleHasBeenOwnedByPlayer(vehicle,  true)
    SetModelAsNoLongerNeeded(model)

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)

    while not HasCollisionLoadedAroundEntity(vehicle) do
      RequestCollisionAtCoord(coords.x, coords.y, coords.z)
      Citizen.Wait(0)
    end

    SetVehRadioStation(vehicle, 'OFF')

    if cb ~= nil then
      cb(vehicle)
    end

  end)

end

ESX.Game.GetObjects = function()

  local objects = {}

  for object in EnumerateObjects() do
    table.insert(objects, object)
  end

  return objects

end

ESX.Game.GetClosestObject = function(filter, coords)

  local objects         = ESX.Game.GetObjects()
  local closestDistance = -1
  local closestObject   = -1
  local filter          = filter
  local coords          = coords

  if type(filter) == 'string' then
    if filter ~= '' then
      filter = {filter}
    end
  end

  if coords == nil then
    local playerPed = GetPlayerPed(-1)
    coords          = GetEntityCoords(playerPed)
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
        end
      end

    end

    if foundObject then

      local objectCoords = GetEntityCoords(objects[i])
      local distance     = GetDistanceBetweenCoords(objectCoords.x, objectCoords.y, objectCoords.z, coords.x, coords.y, coords.z, true)

      if closestDistance == -1 or closestDistance > distance then
        closestObject   = objects[i]
        closestDistance = distance
      end

    end

  end

  return closestObject, closestDistance

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

ESX.Game.GetClosestPlayer = function(coords)

  local players         = ESX.Game.GetPlayers()
  local closestDistance = -1
  local closestPlayer   = -1
  local coords          = coords
  local usePlayerPed    = false
  local playerPed       = GetPlayerPed(-1)
  local playerId        = PlayerId()

  if coords == nil then
    usePlayerPed = true
    coords       = GetEntityCoords(playerPed)
  end

  for i=1, #players, 1 do

    local target = GetPlayerPed(players[i])

    if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then

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

ESX.Game.GetVehicleInDirection = function()
	local playerPed    = GetPlayerPed(-1)
	local playerCoords = GetEntityCoords(playerPed, 1)
	local inDirection  = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
	local rayHandle    = CastRayPointToPoint(playerCoords.x, playerCoords.y, playerCoords.z, inDirection.x, inDirection.y, inDirection.z, 10, playerPed, 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)

	return vehicle
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
    local distance  = GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, coords.x, coords.y, coords.z, true)

    if closestDistance == -1 or closestDistance > distance then
      closestPed      = peds[i]
      closestDistance = distance
    end

  end

  return closestPed, closestDistance

end

ESX.Game.GetVehicleProperties = function(vehicle)

  local color1, color2               = GetVehicleColours(vehicle)
  local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)

  return {

    model            = GetEntityModel(vehicle),

    plate            = GetVehicleNumberPlateText(vehicle),
    plateIndex       = GetVehicleNumberPlateTextIndex(vehicle),

    health           = GetEntityHealth(vehicle),
    dirtLevel        = GetVehicleDirtLevel(vehicle),

    color1           = color1,
    color2           = color2,

    pearlescentColor = pearlescentColor,
    wheelColor       = wheelColor,

    wheels           = GetVehicleWheelType(vehicle),
    windowTint       = GetVehicleWindowTint(vehicle),

    neonEnabled      = {
      IsVehicleNeonLightEnabled(vehicle, 0),
      IsVehicleNeonLightEnabled(vehicle, 1),
      IsVehicleNeonLightEnabled(vehicle, 2),
      IsVehicleNeonLightEnabled(vehicle, 3),
    },

    neonColor        = table.pack(GetVehicleNeonLightsColour(vehicle)),
    tyreSmokeColor   = table.pack(GetVehicleTyreSmokeColor(vehicle)),

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
    modSmokeEnabled  = IsToggleModOn(vehicle,  20),
    modXenon         = IsToggleModOn(vehicle,  22),

    modFrontWheels   = GetVehicleMod(vehicle, 23),
    modBackWheels    = GetVehicleMod(vehicle, 24),

    modPlateHolder    = GetVehicleMod(vehicle, 25),
    modVanityPlate    = GetVehicleMod(vehicle, 26),
    modTrimA        = GetVehicleMod(vehicle, 27),
    modOrnaments      = GetVehicleMod(vehicle, 28),
    modDashboard      = GetVehicleMod(vehicle, 29),
    modDial         = GetVehicleMod(vehicle, 30),
    modDoorSpeaker      = GetVehicleMod(vehicle, 31),
    modSeats        = GetVehicleMod(vehicle, 32),
    modSteeringWheel    = GetVehicleMod(vehicle, 33),
    modShifterLeavers   = GetVehicleMod(vehicle, 34),
    modAPlate       = GetVehicleMod(vehicle, 35),
    modSpeakers       = GetVehicleMod(vehicle, 36),
    modTrunk        = GetVehicleMod(vehicle, 37),
    modHydrolic       = GetVehicleMod(vehicle, 38),
    modEngineBlock      = GetVehicleMod(vehicle, 39),
    modAirFilter      = GetVehicleMod(vehicle, 40),
    modStruts       = GetVehicleMod(vehicle, 41),
    modArchCover      = GetVehicleMod(vehicle, 42),
    modAerials        = GetVehicleMod(vehicle, 43),
    modTrimB        = GetVehicleMod(vehicle, 44),
    modTank         = GetVehicleMod(vehicle, 45),
    modWindows        = GetVehicleMod(vehicle, 46),
    modLivery       = GetVehicleMod(vehicle, 48)
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

  if props.color1 ~= nil then
    local color1, color2 = GetVehicleColours(vehicle)
    SetVehicleColours(vehicle, props.color1, color2)
  end

  if props.color2 ~= nil then
    local color1, color2 = GetVehicleColours(vehicle)
    SetVehicleColours(vehicle, color1, props.color2)
  end

  if props.pearlescentColor ~= nil then
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    SetVehicleExtraColours(vehicle,  props.pearlescentColor,  wheelColor)
  end

  if props.wheelColor ~= nil then
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    SetVehicleExtraColours(vehicle,  pearlescentColor,  props.wheelColor)
  end

  if props.wheels ~= nil then
    SetVehicleWheelType(vehicle,  props.wheels)
  end

  if props.windowTint ~= nil then
    SetVehicleWindowTint(vehicle,  props.windowTint)
  end

  if props.neonEnabled ~= nil then
    SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
    SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
    SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
    SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
  end

  if props.neonColor ~= nil then
    SetVehicleNeonLightsColour(vehicle,  props.neonColor[1], props.neonColor[2], props.neonColor[3])
  end

  if props.modSmokeEnabled ~= nil then
    ToggleVehicleMod(vehicle, 20, true)
  end

  if props.tyreSmokeColor ~= nil then
    SetVehicleTyreSmokeColor(vehicle,  props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
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

  if props.modPlateHolder ~= nil then
    SetVehicleMod(vehicle, 25, props.modPlateHolder , false)
  end

  if props.modVanityPlate ~= nil then
    SetVehicleMod(vehicle, 26, props.modVanityPlate , false)
  end

  if props.modTrimA ~= nil then
    SetVehicleMod(vehicle, 27, props.modTrimA , false)
  end

  if props.modOrnaments ~= nil then
    SetVehicleMod(vehicle, 28, props.modOrnaments , false)
  end

  if props.modDashboard ~= nil then
    SetVehicleMod(vehicle, 29, props.modDashboard , false)
  end

  if props.modDial ~= nil then
    SetVehicleMod(vehicle, 30, props.modDial , false)
  end

  if props.modDoorSpeaker ~= nil then
    SetVehicleMod(vehicle, 31, props.modDoorSpeaker , false)
  end

  if props.modSeats ~= nil then
    SetVehicleMod(vehicle, 32, props.modSeats , false)
  end

  if props.modSteeringWheel ~= nil then
    SetVehicleMod(vehicle, 33, props.modSteeringWheel , false)
  end

  if props.modShifterLeavers ~= nil then
    SetVehicleMod(vehicle, 34, props.modShifterLeavers , false)
  end

  if props.modAPlate ~= nil then
    SetVehicleMod(vehicle, 35, props.modAPlate , false)
  end

  if props.modSpeakers ~= nil then
    SetVehicleMod(vehicle, 36, props.modSpeakers , false)
  end

  if props.modTrunk ~= nil then
    SetVehicleMod(vehicle, 37, props.modTrunk , false)
  end

  if props.modHydrolic ~= nil then
    SetVehicleMod(vehicle, 38, props.modHydrolic , false)
  end

  if props.modEngineBlock ~= nil then
    SetVehicleMod(vehicle, 39, props.modEngineBlock , false)
  end

  if props.modAirFilter ~= nil then
    SetVehicleMod(vehicle, 40, props.modAirFilter , false)
  end

  if props.modStruts ~= nil then
    SetVehicleMod(vehicle, 41, props.modStruts , false)
  end

  if props.modArchCover ~= nil then
    SetVehicleMod(vehicle, 42, props.modArchCover , false)
  end

  if props.modAerials ~= nil then
    SetVehicleMod(vehicle, 43, props.modAerials , false)
  end

  if props.modTrimB ~= nil then
    SetVehicleMod(vehicle, 44, props.modTrimB , false)
  end

  if props.modTank ~= nil then
    SetVehicleMod(vehicle, 45, props.modTank , false)
  end

  if props.modWindows ~= nil then
    SetVehicleMod(vehicle, 46, props.modWindows , false)
  end

  if props.modLivery ~= nil then
    SetVehicleMod(vehicle, 48, props.modLivery , false)
  end

end

ESX.Game.Utils.DrawText3D = function(coords, text, size)

  local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
  local camCoords      = GetGameplayCamCoords()
  local dist           = GetDistanceBetweenCoords(camCoords.x, camCoords.y, camCoords.z, coords.x, coords.y, coords.z, 1)
  local size           = size

  if size == nil then
    size = 1
  end

  local scale = (size / dist) * 2
  local fov   = (1 / GetGameplayCamFov()) * 100
  local scale = scale * fov

  if onScreen then

    SetTextScale(0.0 * scale, 0.55 * scale)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry('STRING')
    SetTextCentre(1)

    AddTextComponentString(text)

    DrawText(x, y)
  end

end


ESX.ShowInventory = function()

  local playerPed = GetPlayerPed(-1)
  local elements  = {}

  if ESX.PlayerData.money > 0 then
    table.insert(elements, {
      label     = '[Cash] $' .. ESX.PlayerData.money,
      count     = ESX.PlayerData.money,
      type      = 'item_money',
      value     = 'money',
      usable    = false,
      rare      = false,
      canRemove = true
    })
  end

  for i=1, #ESX.PlayerData.accounts, 1 do
    if ESX.PlayerData.accounts[i].money > 0 then
      table.insert(elements, {
        label     = '[' .. ESX.PlayerData.accounts[i].label .. '] $' .. ESX.PlayerData.accounts[i].money,
        count     = ESX.PlayerData.accounts[i].money,
        type      = 'item_account',
        value     =  ESX.PlayerData.accounts[i].name,
        usable    = false,
        rare      = false,
        canRemove = true
      })
    end
  end

  for i=1, #ESX.PlayerData.inventory, 1 do

    if ESX.PlayerData.inventory[i].count > 0 then
      table.insert(elements, {
        label     = ESX.PlayerData.inventory[i].label .. ' x' .. ESX.PlayerData.inventory[i].count,
        count     = ESX.PlayerData.inventory[i].count,
        type      = 'item_standard',
        value     = ESX.PlayerData.inventory[i].name,
        usable    = ESX.PlayerData.inventory[i].usable,
        rare      = ESX.PlayerData.inventory[i].rare,
        canRemove = ESX.PlayerData.inventory[i].canRemove,
      })
    end

  end

  for i=1, #Config.Weapons, 1 do

    local weaponHash = GetHashKey(Config.Weapons[i].name)

    if HasPedGotWeapon(playerPed,  weaponHash,  false) and Config.Weapons[i].name ~= 'WEAPON_UNARMED' then

      local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)

      table.insert(elements, {
        label     = Config.Weapons[i].label .. ' x1 [' .. ammo .. ']',
        count     = 1,
        type      = 'item_weapon',
        value     = Config.Weapons[i].name,
        ammo      = ammo,
        usable    = false,
        rare      = false,
        canRemove = true
      })

    end
  end

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'inventory',
    {
      title    = _U('inventory'),
      align    = 'bottom-right',
      elements = elements,
    },
    function(data, menu)
      menu.close()

      local player, distance = ESX.Game.GetClosestPlayer()
      local elements = {}

      if data.current.usable then
        table.insert(elements, {label = _U('use'), action = 'use', type = data.current.type, value = data.current.value})
      end

      if data.current.canRemove then
        if player ~= -1 and distance <= 3.0 then
          table.insert(elements, {label = _U('give'),   action = 'give',   type = data.current.type, value = data.current.value})
        end
        table.insert(elements, {label = _U('remove'), action = 'remove', type = data.current.type, value = data.current.value})
      end

      if data.current.type == "item_weapon" and data.current.ammo > 0 and player ~= -1 and distance <= 3.0 then
        table.insert(elements, {label = _U('giveammo'), action = 'giveammo', type = data.current.type, value = data.current.value})
      end

      table.insert(elements, {label = _U('return'), action = 'return'})

      ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'inventory_item',
        {
          title    = data.current.label,
          align    = 'bottom-right',
          elements = elements,
        },
        function(data, menu)

          local item = data.current.value
          local type = data.current.type
          local playerPed = GetPlayerPed(-1)

           if data.current.action == 'give' then

            if type == 'item_weapon' then
              local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
              local closestPed = GetPlayerPed(closestPlayer)
              local pedAmmo = GetAmmoInPedWeapon(GetPlayerPed(-1), GetHashKey(item))
              if not IsPedSittingInAnyVehicle(closestPed) then
                if closestPlayer ~= -1 and closestDistance < 3.0 then
                  if pedAmmo > 0 then
                    ESX.UI.Menu.Open(
                    'dialog', GetCurrentResourceName(), 'inventory_item_count_give',
                    {
                      title = _U('amountammo')
                    },
                    function(data2, menu2)
                      local quantity = tonumber(data2.value)
                      if quantity <= pedAmmo and quantity >= 0 and quantity ~= nil then
                        TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), type, item, quantity)
                        local finalammo = math.floor(pedAmmo - quantity)
                        SetPedAmmo(playerPed, item, finalammo)
                        menu2.close()
                        menu.close()
                      else
                        ESX.ShowNotification(_U('noammo'))
                      end

                    end, function(data2, menu2)
                      menu2.close()
                    end
                  )
                  else
                    TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), type, item, 0)
                    menu.close()
                  end
                else
                  ESX.ShowNotification(_U('players_nearby'))
                end
              else
                ESX.ShowNotification(_U("in_vehicle"))
              end

            else

               ESX.UI.Menu.Open(
                'dialog', GetCurrentResourceName(), 'inventory_item_count_give',
                {
                  title = _U('amount')
                },
                function(data2, menu2)

                  local quantity                       = tonumber(data2.value)
                  local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                  local closestPed = GetPlayerPed(closestPlayer)
                  if not IsPedSittingInAnyVehicle(closestPed) then
                    if closestPlayer ~= -1 and closestDistance < 3.0 then
                      TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), type, item, quantity)
                    else
                      ESX.ShowNotification(_U('players_nearby'))
                    end
                  else
                    ESX.ShowNotification(_U("in_vehicle"))
                  end

                  menu2.close()
                  menu.close()

                end,
                function(data2, menu2)
                  menu2.close()
                end
              )

            end

          elseif data.current.action == 'remove' then

            if type == 'item_weapon' then
				local pedAmmo = GetAmmoInPedWeapon(GetPlayerPed(-1),GetHashKey(item))
				
				-- does the player have any ammo for the weapon?
				if pedAmmo > 0 then
					ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'inventory_item_count_remove',
					{
						title = _U('amount')
					}, function(data2, menu2)
						local quantity = tonumber(data2.value)

						if quantity <= pedAmmo and quantity >= 0 and quantity ~= nil then
							local finalammo = math.floor(pedAmmo - quantity)
							
							SetPedAmmo(playerPed, item, finalammo)
							TriggerServerEvent('esx:removeInventoryItem', type, item, quantity)
						else
							ESX.ShowNotification(_U('noammo'))
						end
						menu2.close()
						menu.close()
					end, function(data2, menu2)
						menu2.close()
					end)
				else
					TriggerServerEvent('esx:removeInventoryItem', type, item, 0)
					menu.close()
				end

            else

              ESX.UI.Menu.Open(
                'dialog', GetCurrentResourceName(), 'inventory_item_count_remove',
                {
                  title = _U('amount')
                },
                function(data2, menu2)

                  local quantity = tonumber(data2.value)

                  if quantity == nil then
                    ESX.ShowNotification(_U('amount_invalid'))
                  else
                    TriggerServerEvent('esx:removeInventoryItem', type, item, quantity)
                  end

                  menu2.close()
                  menu.close()

                end,
                function(data2, menu2)
                  menu2.close()
                end
              )

            end

          elseif data.current.action == 'use' then
            TriggerServerEvent('esx:useItem', data.current.value)

          elseif data.current.action == 'return' then

            ESX.UI.Menu.CloseAll()
            ESX.ShowInventory()
          elseif data.current.action == 'giveammo' then
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            local closestPed = GetPlayerPed(closestPlayer)
            local pedAmmo = GetAmmoInPedWeapon(playerPed,GetHashKey(item))
            if not IsPedSittingInAnyVehicle(closestPed) then
              if closestPlayer ~= -1 and closestDistance < 3.0 then
                if pedAmmo > 0 then
                  ESX.UI.Menu.Open(
                  'dialog', GetCurrentResourceName(), 'inventory_item_count_give',
                  {
                    title = _U('amountammo')
                  },
                  function(data2, menu2)
                    local quantity = tonumber(data2.value)
                    if quantity <= pedAmmo and quantity >= 0 and quantity ~= nil then
                      local finalAmmoSource = math.floor(pedAmmo - quantity)
                      SetPedAmmo(playerPed, item, finalAmmoSource)
                      AddAmmoToPed(closestPed, item, quantity)
                      ESX.ShowNotification(_U('gave_ammo', quantity, GetPlayerName(closestPlayer)))
                      -- todo notify target that he recived ammo
                      menu2.close()
                      menu.close()
                    else
                      ESX.ShowNotification(_U('noammo'))
                    end

                  end,
                  function(data2, menu2)
                    menu2.close()
                  end
                )
                else
                  TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), type, item, 0)
                  menu.close()
                end
              else
                ESX.ShowNotification(_U('players_nearby'))
              end
            else
              ESX.ShowNotification(_U("in_vehicle"))
            end
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

-- SetTimeout
Citizen.CreateThread(function()
  while true do

    Citizen.Wait(0)

    local currTime = GetGameTimer()

    for i=1, #ESX.TimeoutCallbacks, 1 do

      if ESX.TimeoutCallbacks[i] ~= nil then

        if currTime >= ESX.TimeoutCallbacks[i].time then
          ESX.TimeoutCallbacks[i].cb()
          ESX.TimeoutCallbacks[i] = nil
        end

      end

    end

  end
end)
