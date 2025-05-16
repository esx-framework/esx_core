---@return boolean
function ESX.IsPlayerLoaded()
    return ESX.PlayerLoaded
end

---@return table
function ESX.GetPlayerData()
    return ESX.PlayerData
end

---@param name string
---@param func function
---@return nil
function ESX.SecureNetEvent(name, func)
    local invoker = GetInvokingResource()
    local invokingResource = invoker and invoker ~= 'unknown' and invoker or 'es_extended'
    if not invokingResource then
        return
    end

    if not Core.Events[invokingResource] then
        Core.Events[invokingResource] = {}
    end

    local event = RegisterNetEvent(name, function(...)
        if source == '' then
            return
        end

        local success, result = pcall(func, ...)
        if not success then
            error(("%s"):format(result))
        end
    end)
    local eventIndex = #Core.Events[invokingResource] + 1
    Core.Events[invokingResource][eventIndex] = event
end

local addonResourcesState = {
    ['esx_progressbar'] = GetResourceState('esx_progressbar') ~= 'missing',
    ['esx_notify'] = GetResourceState('esx_notify') ~= 'missing',
    ['esx_textui'] = GetResourceState('esx_textui') ~= 'missing',
    ['esx_context'] = GetResourceState('esx_context') ~= 'missing',
}

local function IsResourceFound(resource)
	return addonResourcesState[resource] or error(('Resource [^5%s^1] is Missing!'):format(resource))
end

function ESX.DisableSpawnManager()
    if GetResourceState("spawnmanager") == "started" then
        exports.spawnmanager:setAutoSpawn(false)
    end
end

---@param items string | table The item(s) to search for
---@param count? boolean Whether to return the count of the item as well
---@return table | number
function ESX.SearchInventory(items, count)
    local item
    if type(items) == 'string' then
        item, items = items, {items}
    end

    local data = {}
    for i = 1, #ESX.PlayerData.inventory do
        local e = ESX.PlayerData.inventory[i]
        for ii = 1, #items do
            if e and e.name == items[ii] then
                data[table.remove(items, ii)] = count and e.count or e
                break
            end
        end
        if #items == 0 then
            break
        end
    end

    return not item and data or data[item]
end

---@param key string Table key to set
---@param val any Value to set
---@return nil
function ESX.SetPlayerData(key, val)
    local current = ESX.PlayerData[key]
    ESX.PlayerData[key] = val
    if key ~= "inventory" and key ~= "loadout" then
        if type(val) == "table" or val ~= current then
            TriggerEvent("esx:setPlayerData", key, val, current)
        end
    end
end

---@param freeze boolean Whether to freeze the player
---@return nil
function Core.FreezePlayer(freeze)
    local ped = PlayerPedId()
    SetPlayerControl(ESX.playerId, not freeze, 0)

    if freeze then
        SetEntityCollision(ped, false, false)
        FreezeEntityPosition(ped, true)
    else
        SetEntityCollision(ped, true, true)
        FreezeEntityPosition(ped, false)
    end
end

---@param skin table Skin data to set
---@param coords table Coords to spawn the player at
---@param cb function Callback function
---@return nil
function ESX.SpawnPlayer(skin, coords, cb)
    local p = promise.new()
    TriggerEvent("skinchanger:loadSkin", skin, function()
        p:resolve()
    end)
    Citizen.Await(p)

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)

    local playerPed = PlayerPedId()
    local timer = GetGameTimer()

    Core.FreezePlayer(true)
    SetEntityCoordsNoOffset(playerPed, coords.x, coords.y, coords.z, false, false, true)
    SetEntityHeading(playerPed, coords.heading)

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    while not HasCollisionLoadedAroundEntity(playerPed) and (GetGameTimer() - timer) < 5000 do
        Wait(0)
    end

    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, 0, true)
    TriggerEvent('playerSpawned', coords)
    cb()
end

---@param message string
---@param length? number Timeout in milliseconds
---@param options? ProgressBarOptions
---@return boolean Success Whether the progress bar was successfully created or not
function ESX.Progressbar(message, length, options)
	return IsResourceFound('esx_progressbar') and exports['esx_progressbar']:Progressbar(message, length, options)
end

function ESX.CancelProgressbar()
    return IsResourceFound('esx_progressbar') and exports['esx_progressbar']:CancelProgressbar()
end

---@param message string The message to show
---@param notifyType? string The type of notification to show
---@param length? number The length of the notification
---@param title? string The title of the notification
---@return nil
function ESX.ShowNotification(message, notifyType, length, title)
	return IsResourceFound('esx_notify') and exports['esx_notify']:Notify(notifyType, length, message, title)
end

function ESX.TextUI(...)
	return IsResourceFound('esx_textui') and exports['esx_textui']:TextUI(...)
end

---@return nil
function ESX.HideUI()
	return IsResourceFound('esx_textui') and exports['esx_textui']:HideUI()
end

---@param sender string
---@param subject string
---@param msg string
---@param textureDict string
---@param iconType integer
---@param flash boolean
---@param saveToBrief? boolean
---@param hudColorIndex? integer
---@return nil
function ESX.ShowAdvancedNotification(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
    AddTextEntry("esxAdvancedNotification", msg)
    BeginTextCommandThefeedPost("esxAdvancedNotification")
    if hudColorIndex then
        ThefeedSetNextPostBackgroundColor(hudColorIndex)
    end
    EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, iconType, sender, subject)
    EndTextCommandThefeedPostTicker(flash, saveToBrief == nil or saveToBrief)
end

---@param msg string The message to show
---@param thisFrame? boolean Whether to show the message this frame
---@param beep? boolean Whether to beep
---@param duration? number The duration of the message
---@return nil
function ESX.ShowHelpNotification(msg, thisFrame, beep, duration)
    AddTextEntry("esxHelpNotification", msg)
    if thisFrame then
        DisplayHelpTextThisFrame("esxHelpNotification", false)
    else
        BeginTextCommandDisplayHelp("esxHelpNotification")
        EndTextCommandDisplayHelp(0, false, beep == nil or beep, duration or -1)
    end
end

---@param msg string The message to show
---@param coords table The coords to show the message at
---@return nil
function ESX.ShowFloatingHelpNotification(msg, coords)
    AddTextEntry("esxFloatingHelpNotification", msg)
    SetFloatingHelpTextWorldPosition(1, coords.x, coords.y, coords.z)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp("esxFloatingHelpNotification")
    EndTextCommandDisplayHelp(2, false, false, -1)
end

---@param msg string The message to show
---@param time number The duration of the message
---@return nil
function ESX.DrawMissionText(msg, time)
    ClearPrints()
    BeginTextCommandPrint('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandPrint(time, true)
end

---@param str string The string to hash
---@return string The hashed string
function ESX.HashString(str)
    return ('~INPUT_%s~'):format(('%x'):format(joaat(str) & 0x7fffffff + 2 ^ 31):upper())
end

function ESX.OpenContext(...)
    return IsResourceFound('esx_context') and exports['esx_context']:Open(...)
end

function ESX.PreviewContext(...)
    return IsResourceFound('esx_context') and exports['esx_context']:Preview(...)
end

function ESX.CloseContext(...)
    return IsResourceFound('esx_context') and exports['esx_context']:Close(...)
end

function ESX.RefreshContext(...)
    return IsResourceFound('esx_context') and exports['esx_context']:Refresh(...)
end

---@param command_name string The command name
---@param label string The label to show
---@param input_group string The input group
---@param key string The key to bind
---@param on_press function The function to call on press
---@param on_release? function The function to call on release
function ESX.RegisterInput(command_name, label, input_group, key, on_press, on_release)
	local command = on_release and '+' .. command_name or command_name
    RegisterCommand(command, on_press, false)
    Core.Input[command_name] = ESX.HashString(command)
    if on_release then
        RegisterCommand('-' .. command_name, on_release, false)
    end
    RegisterKeyMapping(command, label or '', input_group or 'keyboard', key or '')
end

---@param menuType string
---@param open function The function to call on open
---@param close function The function to call on close
function ESX.UI.Menu.RegisterType(menuType, open, close)
    ESX.UI.Menu.RegisteredTypes[menuType] = {
        open = open,
        close = close,
    }
end

---@class ESXMenu
---@field type string
---@field namespace string
---@field resourceName string
---@field name string
---@field data table
---@field submit? function
---@field cancel? function
---@field change? function
---@field close function
---@field update function
---@field refresh function
---@field setElement function
---@field setElements function
---@field setTitle function
---@field removeElement function

---@param menuType string
---@param namespace string
---@param name string
---@param data table
---@param submit? function
---@param cancel? function
---@param change? function
---@param close? function
---@return ESXMenu
function ESX.UI.Menu.Open(menuType, namespace, name, data, submit, cancel, change, close)
    ---@class ESXMenu
    local menu = {}

    menu.type = menuType
    menu.namespace = namespace
    menu.resourceName = (GetInvokingResource() or "Unknown")
    menu.name = name
    menu.data = data
    menu.submit = submit
    menu.cancel = cancel
    menu.change = change

    menu.close = function()
        ESX.UI.Menu.RegisteredTypes[menuType].close(namespace, name)

        for i = 1, #ESX.UI.Menu.Opened, 1 do
            if ESX.UI.Menu.Opened[i] then
                if ESX.UI.Menu.Opened[i].type == menuType and ESX.UI.Menu.Opened[i].namespace == namespace and ESX.UI.Menu.Opened[i].name == name then
                    ESX.UI.Menu.Opened[i] = nil
                end
            end
        end

        if close then
            close()
        end
    end

    menu.update = function(query, newData)
        for i = 1, #menu.data.elements, 1 do
            local match = true

            for k, v in pairs(query) do
                if menu.data.elements[i][k] ~= v then
                    match = false
                end
            end

            if match then
                for k, v in pairs(newData) do
                    menu.data.elements[i][k] = v
                end
            end
        end
    end

    menu.refresh = function()
        ESX.UI.Menu.RegisteredTypes[menuType].open(namespace, name, menu.data)
    end

    menu.setElement = function(i, key, val)
        menu.data.elements[i][key] = val
    end

    menu.setElements = function(newElements)
        menu.data.elements = newElements
    end

    menu.setTitle = function(val)
        menu.data.title = val
    end

    menu.removeElement = function(query)
        for i = 1, #menu.data.elements, 1 do
            for k, v in pairs(query) do
                if menu.data.elements[i] then
                    if menu.data.elements[i][k] == v then
                        table.remove(menu.data.elements, i)
                        break
                    end
                end
            end
        end
    end

    ESX.UI.Menu.Opened[#ESX.UI.Menu.Opened + 1] = menu
    ESX.UI.Menu.RegisteredTypes[menuType].open(namespace, name, data)

    return menu
end

---@param menuType string
---@param namespace string
---@param name string
---@param cancel? boolean Should the close be classified as a cancel
---@return nil
function ESX.UI.Menu.Close(menuType, namespace, name, cancel)
    for i = 1, #ESX.UI.Menu.Opened, 1 do
        if ESX.UI.Menu.Opened[i] then
            if ESX.UI.Menu.Opened[i].type == menuType and ESX.UI.Menu.Opened[i].namespace == namespace and ESX.UI.Menu.Opened[i].name == name then
                if not cancel then
                    ESX.UI.Menu.Opened[i].close()
                else
                    local menu = ESX.UI.Menu.Opened[i]
                    ESX.UI.Menu.RegisteredTypes[menu.type].close(menu.namespace, menu.name)

                    if type(menu.cancel) ~= "nil" then
                        menu.cancel(menu.data, menu)
                    end
                end
                ESX.UI.Menu.Opened[i] = nil
            end
        end
    end
end

---@param cancel? boolean Should the close be classified as a cancel
---@return nil
function ESX.UI.Menu.CloseAll(cancel)
    for i = 1, #ESX.UI.Menu.Opened, 1 do
        if ESX.UI.Menu.Opened[i] then
            if not cancel then
                ESX.UI.Menu.Opened[i].close()
            else
                local menu = ESX.UI.Menu.Opened[i]
                ESX.UI.Menu.RegisteredTypes[menu.type].close(menu.namespace, menu.name)

                if type(menu.cancel) ~= "nil" then
                    menu.cancel(menu.data, menu)
                end
            end
            ESX.UI.Menu.Opened[i] = nil
        end
    end
end

---@param menuType string
---@param namespace string
---@param name string
---@return ESXMenu | nil
function ESX.UI.Menu.GetOpened(menuType, namespace, name)
    for i = 1, #ESX.UI.Menu.Opened, 1 do
        if ESX.UI.Menu.Opened[i] then
            if ESX.UI.Menu.Opened[i].type == menuType and ESX.UI.Menu.Opened[i].namespace == namespace and ESX.UI.Menu.Opened[i].name == name then
                return ESX.UI.Menu.Opened[i]
            end
        end
    end
end

---@return ESXMenu[]
function ESX.UI.Menu.GetOpenedMenus()
    return ESX.UI.Menu.Opened
end

ESX.UI.Menu.IsOpen = ESX.UI.Menu.GetOpened

---@param add boolean Whether the item is being added or removed
---@param item string The item to show
---@param count number How many of the item to show
---@return nil
function ESX.UI.ShowInventoryItemNotification(add, item, count)
    SendNUIMessage({
        action = "inventoryNotification",
        add = add,
        item = item,
        count = count,
    })
end

---@param ped integer The ped to get the mugshot of
---@param transparent? boolean Whether the mugshot should be transparent
function ESX.Game.GetPedMugshot(ped, transparent)
    if not DoesEntityExist(ped) then
        return
    end
    local mugshot = transparent and RegisterPedheadshotTransparent(ped) or RegisterPedheadshot(ped)

    while not IsPedheadshotReady(mugshot) do
        Wait(0)
    end

    return mugshot, GetPedheadshotTxdString(mugshot)
end

---@param entity integer The entity to get the coords of
---@param coords table | vector3 | vector4 The coords to teleport the entity to
---@param cb? function The callback function
function ESX.Game.Teleport(entity, coords, cb)

    if DoesEntityExist(entity) then
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        while not HasCollisionLoadedAroundEntity(entity) do
            Wait(0)
        end

        SetEntityCoords(entity, coords.x, coords.y, coords.z, false, false, false, false)
        SetEntityHeading(entity, coords.w or coords.heading or 0.0)
    end

    if cb then
        cb()
    end
end

---@param object integer | string The object to spawn
---@param coords table | vector3 The coords to spawn the object at
---@param cb? function The callback function
---@param networked? boolean Whether the object should be networked
---@return integer | nil
function ESX.Game.SpawnObject(object, coords, cb, networked)
    local model = type(object) == "number" and object or joaat(object)

    ESX.Streaming.RequestModel(model)

	local obj = CreateObject(model, coords.x, coords.y, coords.z, networked == nil or networked, false, true)
	return cb and cb(obj) or obj
end

---@param object integer | string The object to spawn
---@param coords table | vector3 The coords to spawn the object at
---@param cb? function The callback function
---@return nil
function ESX.Game.SpawnLocalObject(object, coords, cb)
    ESX.Game.SpawnObject(object, coords, cb, false)
end

---@param vehicle integer The vehicle to delete
---@return nil
function ESX.Game.DeleteVehicle(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

---@param object integer The object to delete
---@return nil
function ESX.Game.DeleteObject(object)
    SetEntityAsMissionEntity(object, false, true)
    DeleteObject(object)
end

---@param vehicleModel integer | string The vehicle to spawn
---@param coords table | vector3 The coords to spawn the vehicle at
---@param heading number The heading of the vehicle
---@param cb? fun(vehicle: number) The callback function
---@param networked? boolean Whether the vehicle should be networked
---@return number? vehicle
function ESX.Game.SpawnVehicle(vehicleModel, coords, heading, cb, networked)
    if cb and not ESX.IsFunctionReference(cb) then
        error("Invalid callback function")
    end

    local model = type(vehicleModel) == "number" and vehicleModel or joaat(vehicleModel)
    local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
    local isNetworked = networked == nil or networked

    local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
    if not vector or not playerCoords then
        return
    end

    local dist = #(playerCoords - vector)
    if dist > 424 then -- Onesync infinity Range (https://docs.fivem.net/docs/scripting-reference/onesync/)
        local executingResource = GetInvokingResource() or "Unknown"
        return error(("Resource ^5%s^1 Tried to spawn vehicle on the client but the position is too far away (Out of onesync range)."):format(executingResource))
    end

    local promise = not cb and promise.new()
    CreateThread(function()
        local modelHash = ESX.Streaming.RequestModel(model)
        if not modelHash then
            if promise then
                return promise:reject(("Tried to spawn invalid vehicle - ^5%s^7!"):format(model))
            end
           error(("Tried to spawn invalid vehicle - ^5%s^7!"):format(model))
        end

        local vehicle = CreateVehicle(model, vector.x, vector.y, vector.z, heading, isNetworked, true)

        if networked then
            local id = NetworkGetNetworkIdFromEntity(vehicle)
            SetNetworkIdCanMigrate(id, true)
            SetEntityAsMissionEntity(vehicle, true, true)
        end
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetVehicleNeedsToBeHotwired(vehicle, false)
        SetModelAsNoLongerNeeded(model)
        SetVehRadioStation(vehicle, "OFF")

        RequestCollisionAtCoord(vector.x, vector.y, vector.z)
        while not HasCollisionLoadedAroundEntity(vehicle) do
            Wait(0)
        end

        if promise then
            promise:resolve(vehicle)
        elseif cb then
            cb(vehicle)
        end
    end)

    if promise then
        return Citizen.Await(promise)
    end
end

---@param vehicle integer The vehicle to spawn
---@param coords table | vector3 The coords to spawn the vehicle at
---@param heading number The heading of the vehicle
---@param cb? function The callback function
---@return nil
function ESX.Game.SpawnLocalVehicle(vehicle, coords, heading, cb)
    ESX.Game.SpawnVehicle(vehicle, coords, heading, cb, false)
end

---@param vehicle integer The vehicle to check
---@return boolean
function ESX.Game.IsVehicleEmpty(vehicle)
    return GetVehicleNumberOfPassengers(vehicle) == 0 and IsVehicleSeatFree(vehicle, -1)
end

---@return table
function ESX.Game.GetObjects() -- Leave the function for compatibility
    return GetGamePool("CObject")
end

---@param onlyOtherPeds? boolean Whether to exlude the player ped
---@return table
function ESX.Game.GetPeds(onlyOtherPeds)
    local pool = GetGamePool("CPed")

    if onlyOtherPeds then
        local myPed = ESX.PlayerData.ped
        for i = 1, #pool do
            if pool[i] == myPed then
                table.remove(pool, i)
                break
            end
        end
    end

    return pool
end

---@return table
function ESX.Game.GetVehicles() -- Leave the function for compatibility
    return GetGamePool("CVehicle")
end

---@param onlyOtherPlayers? boolean Whether to exclude the player
---@param returnKeyValue? boolean Whether to return the key value pair
---@param returnPeds? boolean Whether to return the peds
---@return table
function ESX.Game.GetPlayers(onlyOtherPlayers, returnKeyValue, returnPeds)
    local players = {}
    local active = GetActivePlayers()

    for i = 1, #active do
        local currentPlayer = active[i]
        local ped = GetPlayerPed(currentPlayer)

        if DoesEntityExist(ped) and ((onlyOtherPlayers and currentPlayer ~= ESX.playerId) or not onlyOtherPlayers) then
            if returnKeyValue then
                players[currentPlayer] = ped
            else
                players[#players + 1] = returnPeds and ped or currentPlayer
            end
        end
    end

    return players
end

---@param coords? table | vector3 The coords to get the closest object to
---@param modelFilter? table The model filter
---@return integer, integer
function ESX.Game.GetClosestObject(coords, modelFilter)
    return ESX.Game.GetClosestEntity(ESX.Game.GetObjects(), false, coords, modelFilter)
end

---@param coords? table | vector3 The coords to get the closest ped to
---@param modelFilter? table The model filter
---@return integer, integer
function ESX.Game.GetClosestPed(coords, modelFilter)
    return ESX.Game.GetClosestEntity(ESX.Game.GetPeds(true), false, coords, modelFilter)
end

---@param coords? table | vector3 The coords to get the closest player to
---@return integer, integer
function ESX.Game.GetClosestPlayer(coords)
    return ESX.Game.GetClosestEntity(ESX.Game.GetPlayers(true, true), true, coords, nil)
end

---@param coords? table | vector3 The coords to get the closest vehicle to
---@param modelFilter? table The model filter
---@return integer, integer
function ESX.Game.GetClosestVehicle(coords, modelFilter)
    return ESX.Game.GetClosestEntity(ESX.Game.GetVehicles(), false, coords, modelFilter)
end

---@param entities table The entities to search through
---@param isPlayerEntities boolean Whether the entities are players
---@param coords table | vector3 The coords to search from
---@param maxDistance number The max distance to search within
---@return table
local function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
    local nearbyEntities = {}

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        local playerPed = ESX.PlayerData.ped
        coords = GetEntityCoords(playerPed)
    end

    for k, entity in pairs(entities) do
        local distance = #(coords - GetEntityCoords(entity))

        if distance <= maxDistance then
            nearbyEntities[#nearbyEntities + 1] = isPlayerEntities and k or entity
        end
    end

    return nearbyEntities
end

---@param coords table | vector3 The coords to search from
---@param maxDistance number The max distance to search within
---@return table
function ESX.Game.GetPlayersInArea(coords, maxDistance)
    return EnumerateEntitiesWithinDistance(ESX.Game.GetPlayers(true, true), true, coords, maxDistance)
end

---@param coords table | vector3 The coords to search from
---@param maxDistance number The max distance to search within
---@return table
function ESX.Game.GetVehiclesInArea(coords, maxDistance)
    return EnumerateEntitiesWithinDistance(ESX.Game.GetVehicles(), false, coords, maxDistance)
end

---@param coords table | vector3 The coords to search from
---@param maxDistance number The max distance to search within
---@return boolean
function ESX.Game.IsSpawnPointClear(coords, maxDistance)
    return #ESX.Game.GetVehiclesInArea(coords, maxDistance) == 0
end

---@param shape integer The shape to get the test result from
---@return boolean, table, table, integer, integer
function ESX.Game.GetShapeTestResultSync(shape)
	local handle, hit, coords, normal, material, entity
	repeat
        handle, hit, coords, normal, material, entity = GetShapeTestResultIncludingMaterial(shape)
        Wait(0)
	until handle ~= 1
	return hit, coords, normal, material, entity
end

---@param depth number The depth to raycast
---@vararg any The arguments to pass to the shape test
---@return table, boolean, table, table, integer, integer
function ESX.Game.RaycastScreen(depth, ...)
	local world, normal = GetWorldCoordFromScreenCoord(.5, .5)
	local origin = world + normal
	local target = world + normal * depth
	return target, ESX.Game.GetShapeTestResultSync(StartShapeTestLosProbe(origin.x, origin.y, origin.z, target.x, target.y, target.z, ...))
end

---@param entities table The entities to search through
---@param isPlayerEntities boolean Whether the entities are players
---@param coords? table | vector3 The coords to search from
---@param modelFilter? table The model filter
---@return integer, integer
function ESX.Game.GetClosestEntity(entities, isPlayerEntities, coords, modelFilter)
    local closestEntity, closestEntityDistance, filteredEntities = -1, -1, nil

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        local playerPed = ESX.PlayerData.ped
        coords = GetEntityCoords(playerPed)
    end

    if modelFilter then
        filteredEntities = {}

        for currentEntityIndex = 1, #entities do
            if modelFilter[GetEntityModel(entities[currentEntityIndex])] then
                filteredEntities[#filteredEntities + 1] = entities[currentEntityIndex]
            end
        end
    end

    for k, entity in pairs(filteredEntities or entities) do
        local distance = #(coords - GetEntityCoords(entity))

        if closestEntityDistance == -1 or distance < closestEntityDistance then
            closestEntity, closestEntityDistance = isPlayerEntities and k or entity, distance
        end
    end

    return closestEntity, closestEntityDistance
end

---@return integer | nil, vector3 | nil
function ESX.Game.GetVehicleInDirection()
    local _, hit, coords, _, _, entity = ESX.Game.RaycastScreen(5, 10, ESX.PlayerData.ped)
    if hit and IsEntityAVehicle(entity) then
        return entity, coords
    end
end

---@param vehicle integer The vehicle to get the properties of
---@return table | nil
function ESX.Game.GetVehicleProperties(vehicle)
    if not DoesEntityExist(vehicle) then
        return
    end

    local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    local hasCustomPrimaryColor = GetIsVehiclePrimaryColourCustom(vehicle)
    local dashboardColor = GetVehicleDashboardColor(vehicle)
    local interiorColor = GetVehicleInteriorColour(vehicle)
    local customPrimaryColor = nil
    if hasCustomPrimaryColor then
        customPrimaryColor = { GetVehicleCustomPrimaryColour(vehicle) }
    end

    local hasCustomXenonColor, customXenonColorR, customXenonColorG, customXenonColorB = GetVehicleXenonLightsCustomColor(vehicle)
    local customXenonColor = nil
    if hasCustomXenonColor then
        customXenonColor = { customXenonColorR, customXenonColorG, customXenonColorB }
    end

    local hasCustomSecondaryColor = GetIsVehicleSecondaryColourCustom(vehicle)
    local customSecondaryColor = nil
    if hasCustomSecondaryColor then
        customSecondaryColor = { GetVehicleCustomSecondaryColour(vehicle) }
    end

    local extras = {}
    for extraId = 0, 20 do
        if DoesExtraExist(vehicle, extraId) then
            extras[tostring(extraId)] = IsVehicleExtraTurnedOn(vehicle, extraId)
        end
    end

    local doorsBroken, windowsBroken, tyreBurst = {}, {}, {}
    local numWheels = tostring(GetVehicleNumberOfWheels(vehicle))

    local TyresIndex = { -- Wheel index list according to the number of vehicle wheels.
        ["2"] = { 0, 4 }, -- Bike and cycle.
        ["3"] = { 0, 1, 4, 5 }, -- Vehicle with 3 wheels (get for wheels because some 3 wheels vehicles have 2 wheels on front and one rear or the reverse).
        ["4"] = { 0, 1, 4, 5 }, -- Vehicle with 4 wheels.
        ["6"] = { 0, 1, 2, 3, 4, 5 }, -- Vehicle with 6 wheels.
    }

    if TyresIndex[numWheels] then
        for _, idx in pairs(TyresIndex[numWheels]) do
            tyreBurst[tostring(idx)] = IsVehicleTyreBurst(vehicle, idx, false)
        end
    end

    for windowId = 0, 7 do -- 13
        RollUpWindow(vehicle, windowId) --fix when you put the car away with the window down
        windowsBroken[tostring(windowId)] = not IsVehicleWindowIntact(vehicle, windowId)
    end

    local numDoors = GetNumberOfVehicleDoors(vehicle)
    if numDoors and numDoors > 0 then
        for doorsId = 0, numDoors do
            doorsBroken[tostring(doorsId)] = IsVehicleDoorDamaged(vehicle, doorsId)
        end
    end

    return {
        model = GetEntityModel(vehicle),
        doorsBroken = doorsBroken,
        windowsBroken = windowsBroken,
        tyreBurst = tyreBurst,
        tyresCanBurst = GetVehicleTyresCanBurst(vehicle),
        plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)),
        plateIndex = GetVehicleNumberPlateTextIndex(vehicle),

        bodyHealth = ESX.Math.Round(GetVehicleBodyHealth(vehicle), 1),
        engineHealth = ESX.Math.Round(GetVehicleEngineHealth(vehicle), 1),
        tankHealth = ESX.Math.Round(GetVehiclePetrolTankHealth(vehicle), 1),

        fuelLevel = ESX.Math.Round(GetVehicleFuelLevel(vehicle), 1),
        dirtLevel = ESX.Math.Round(GetVehicleDirtLevel(vehicle), 1),
        color1 = colorPrimary,
        color2 = colorSecondary,
        customPrimaryColor = customPrimaryColor,
        customSecondaryColor = customSecondaryColor,

        pearlescentColor = pearlescentColor,
        wheelColor = wheelColor,

        dashboardColor = dashboardColor,
        interiorColor = interiorColor,

        wheels = GetVehicleWheelType(vehicle),
        windowTint = GetVehicleWindowTint(vehicle),
        xenonColor = GetVehicleXenonLightsColor(vehicle),
        customXenonColor = customXenonColor,

        neonEnabled = { IsVehicleNeonLightEnabled(vehicle, 0), IsVehicleNeonLightEnabled(vehicle, 1), IsVehicleNeonLightEnabled(vehicle, 2), IsVehicleNeonLightEnabled(vehicle, 3) },

        neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
        extras = extras,
        tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),

        modSpoilers = GetVehicleMod(vehicle, 0),
        modFrontBumper = GetVehicleMod(vehicle, 1),
        modRearBumper = GetVehicleMod(vehicle, 2),
        modSideSkirt = GetVehicleMod(vehicle, 3),
        modExhaust = GetVehicleMod(vehicle, 4),
        modFrame = GetVehicleMod(vehicle, 5),
        modGrille = GetVehicleMod(vehicle, 6),
        modHood = GetVehicleMod(vehicle, 7),
        modFender = GetVehicleMod(vehicle, 8),
        modRightFender = GetVehicleMod(vehicle, 9),
        modRoof = GetVehicleMod(vehicle, 10),
        modRoofLivery = GetVehicleRoofLivery(vehicle),

        modEngine = GetVehicleMod(vehicle, 11),
        modBrakes = GetVehicleMod(vehicle, 12),
        modTransmission = GetVehicleMod(vehicle, 13),
        modHorns = GetVehicleMod(vehicle, 14),
        modSuspension = GetVehicleMod(vehicle, 15),
        modArmor = GetVehicleMod(vehicle, 16),

        modTurbo = IsToggleModOn(vehicle, 18),
        modSmokeEnabled = IsToggleModOn(vehicle, 20),
        modXenon = IsToggleModOn(vehicle, 22),

        modFrontWheels = GetVehicleMod(vehicle, 23),
        modCustomFrontWheels = GetVehicleModVariation(vehicle, 23),
        modBackWheels = GetVehicleMod(vehicle, 24),
        modCustomBackWheels = GetVehicleModVariation(vehicle, 24),

        modPlateHolder = GetVehicleMod(vehicle, 25),
        modVanityPlate = GetVehicleMod(vehicle, 26),
        modTrimA = GetVehicleMod(vehicle, 27),
        modOrnaments = GetVehicleMod(vehicle, 28),
        modDashboard = GetVehicleMod(vehicle, 29),
        modDial = GetVehicleMod(vehicle, 30),
        modDoorSpeaker = GetVehicleMod(vehicle, 31),
        modSeats = GetVehicleMod(vehicle, 32),
        modSteeringWheel = GetVehicleMod(vehicle, 33),
        modShifterLeavers = GetVehicleMod(vehicle, 34),
        modAPlate = GetVehicleMod(vehicle, 35),
        modSpeakers = GetVehicleMod(vehicle, 36),
        modTrunk = GetVehicleMod(vehicle, 37),
        modHydrolic = GetVehicleMod(vehicle, 38),
        modEngineBlock = GetVehicleMod(vehicle, 39),
        modAirFilter = GetVehicleMod(vehicle, 40),
        modStruts = GetVehicleMod(vehicle, 41),
        modArchCover = GetVehicleMod(vehicle, 42),
        modAerials = GetVehicleMod(vehicle, 43),
        modTrimB = GetVehicleMod(vehicle, 44),
        modTank = GetVehicleMod(vehicle, 45),
        modWindows = GetVehicleMod(vehicle, 46),
        modLivery = GetVehicleMod(vehicle, 48) == -1 and GetVehicleLivery(vehicle) or GetVehicleMod(vehicle, 48),
        modLightbar = GetVehicleMod(vehicle, 49),
    }
end

---@param vehicle integer The vehicle to set the properties of
---@param props table The properties to set
---@return nil
function ESX.Game.SetVehicleProperties(vehicle, props)
    if not DoesEntityExist(vehicle) then
        return
    end
    local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    SetVehicleModKit(vehicle, 0)

    if props.tyresCanBurst ~= nil then
        SetVehicleTyresCanBurst(vehicle, props.tyresCanBurst)
    end

    if props.plate ~= nil then
        SetVehicleNumberPlateText(vehicle, props.plate)
    end
    if props.plateIndex ~= nil then
        SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
    end
    if props.bodyHealth ~= nil then
        SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
    end
    if props.engineHealth ~= nil then
        SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
    end
    if props.tankHealth ~= nil then
        SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0)
    end
    if props.fuelLevel ~= nil then
        SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
    end
    if props.dirtLevel ~= nil then
        SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
    end
    if props.customPrimaryColor ~= nil then
        SetVehicleCustomPrimaryColour(vehicle, props.customPrimaryColor[1], props.customPrimaryColor[2], props.customPrimaryColor[3])
    end
    if props.customSecondaryColor ~= nil then
        SetVehicleCustomSecondaryColour(vehicle, props.customSecondaryColor[1], props.customSecondaryColor[2], props.customSecondaryColor[3])
    end
    if props.color1 ~= nil then
        SetVehicleColours(vehicle, props.color1, colorSecondary)
    end
    if props.color2 ~= nil then
        SetVehicleColours(vehicle, props.color1 or colorPrimary, props.color2)
    end
    if props.pearlescentColor ~= nil then
        SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
    end

    if props.interiorColor ~= nil then
        SetVehicleInteriorColor(vehicle, props.interiorColor)
    end

    if props.dashboardColor ~= nil then
        SetVehicleDashboardColor(vehicle, props.dashboardColor)
    end

    if props.wheelColor ~= nil then
        SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor)
    end
    if props.wheels ~= nil then
        SetVehicleWheelType(vehicle, props.wheels)
    end
    if props.windowTint ~= nil then
        SetVehicleWindowTint(vehicle, props.windowTint)
    end

    if props.neonEnabled ~= nil then
        SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
        SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
        SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
        SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
    end

    if props.extras ~= nil then
        for extraId, enabled in pairs(props.extras) do
            extraId = tonumber(extraId)
            if extraId then
                SetVehicleExtra(vehicle, extraId, not enabled)
            end
        end
    end

    if props.neonColor ~= nil then
        SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
    end
    if props.xenonColor ~= nil then
        SetVehicleXenonLightsColor(vehicle, props.xenonColor)
    end
    if props.customXenonColor ~= nil then
        SetVehicleXenonLightsCustomColor(vehicle, props.customXenonColor[1], props.customXenonColor[2], props.customXenonColor[3])
    end
    if props.modSmokeEnabled ~= nil then
        ToggleVehicleMod(vehicle, 20, true)
    end
    if props.tyreSmokeColor ~= nil then
        SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
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

    if props.modRoofLivery ~= nil then
        SetVehicleRoofLivery(vehicle, props.modRoofLivery)
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
        ToggleVehicleMod(vehicle, 18, props.modTurbo)
    end
    if props.modXenon ~= nil then
        ToggleVehicleMod(vehicle, 22, props.modXenon)
    end
    if props.modFrontWheels ~= nil then
        SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomFrontWheels)
    end
    if props.modBackWheels ~= nil then
        SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomBackWheels)
    end
    if props.modPlateHolder ~= nil then
        SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
    end
    if props.modVanityPlate ~= nil then
        SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
    end
    if props.modTrimA ~= nil then
        SetVehicleMod(vehicle, 27, props.modTrimA, false)
    end
    if props.modOrnaments ~= nil then
        SetVehicleMod(vehicle, 28, props.modOrnaments, false)
    end
    if props.modDashboard ~= nil then
        SetVehicleMod(vehicle, 29, props.modDashboard, false)
    end
    if props.modDial ~= nil then
        SetVehicleMod(vehicle, 30, props.modDial, false)
    end
    if props.modDoorSpeaker ~= nil then
        SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
    end
    if props.modSeats ~= nil then
        SetVehicleMod(vehicle, 32, props.modSeats, false)
    end
    if props.modSteeringWheel ~= nil then
        SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
    end
    if props.modShifterLeavers ~= nil then
        SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
    end
    if props.modAPlate ~= nil then
        SetVehicleMod(vehicle, 35, props.modAPlate, false)
    end
    if props.modSpeakers ~= nil then
        SetVehicleMod(vehicle, 36, props.modSpeakers, false)
    end
    if props.modTrunk ~= nil then
        SetVehicleMod(vehicle, 37, props.modTrunk, false)
    end
    if props.modHydrolic ~= nil then
        SetVehicleMod(vehicle, 38, props.modHydrolic, false)
    end
    if props.modEngineBlock ~= nil then
        SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
    end
    if props.modAirFilter ~= nil then
        SetVehicleMod(vehicle, 40, props.modAirFilter, false)
    end
    if props.modStruts ~= nil then
        SetVehicleMod(vehicle, 41, props.modStruts, false)
    end
    if props.modArchCover ~= nil then
        SetVehicleMod(vehicle, 42, props.modArchCover, false)
    end
    if props.modAerials ~= nil then
        SetVehicleMod(vehicle, 43, props.modAerials, false)
    end
    if props.modTrimB ~= nil then
        SetVehicleMod(vehicle, 44, props.modTrimB, false)
    end
    if props.modTank ~= nil then
        SetVehicleMod(vehicle, 45, props.modTank, false)
    end
    if props.modWindows ~= nil then
        SetVehicleMod(vehicle, 46, props.modWindows, false)
    end

    if props.modLivery ~= nil then
        SetVehicleMod(vehicle, 48, props.modLivery, false)
        SetVehicleLivery(vehicle, props.modLivery)
    end

    if props.windowsBroken ~= nil then
        for k, v in pairs(props.windowsBroken) do
            if v then
                k = tonumber(k)
                if k then
                    RemoveVehicleWindow(vehicle, k)
                end
            end
        end
    end

    if props.doorsBroken ~= nil then
        for k, v in pairs(props.doorsBroken) do
            if v then
                k = tonumber(k)
                if k then
                    SetVehicleDoorBroken(vehicle, k, true)
                end
            end
        end
    end

    if props.tyreBurst ~= nil then
        for k, v in pairs(props.tyreBurst) do
            if v then
                k = tonumber(k)
                if k then
                    SetVehicleTyreBurst(vehicle, k, true, 1000.0)
                end
            end
        end
    end
end

---@param coords vector3 | table coords to get the closest pickup to
---@param text string The text to display
---@param size? number The size of the text
---@param font? number The font of the text
---@return nil
function ESX.Game.Utils.DrawText3D(coords, text, size, font)
    local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)

    local camCoords = GetFinalRenderedCamCoord()
    local distance = #(vector - camCoords)

    size = size or 1
    font = font or 0

    local scale = (size / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(0.0, 0.55 * scale)
    SetTextFont(font)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText("STRING")
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(vector.x, vector.y, vector.z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

---@param account string Account name (money/bank/black_money)
---@return table|nil
function ESX.GetAccount(account)
    for i = 1, #ESX.PlayerData.accounts, 1 do
        if ESX.PlayerData.accounts[i].name == account then
            return ESX.PlayerData.accounts[i]
        end
    end
    return nil
end

---@return nil
function ESX.ShowInventory()
    if not Config.EnableDefaultInventory then
        return
    end

    local playerPed = ESX.PlayerData.ped
    local elements = {
        { unselectable = true, icon = "fas fa-box" },
    }
    local currentWeight = 0

    for i = 1, #ESX.PlayerData.accounts do
        if ESX.PlayerData.accounts[i].money > 0 then
            local formattedMoney = TranslateCap("locale_currency", ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money))
            local canDrop = ESX.PlayerData.accounts[i].name ~= "bank"

            elements[#elements + 1] = {
                icon = "fas fa-money-bill-wave",
                title = ('%s: <span style="color:green;">%s</span>'):format(ESX.PlayerData.accounts[i].label, formattedMoney),
                count = ESX.PlayerData.accounts[i].money,
                type = "item_account",
                value = ESX.PlayerData.accounts[i].name,
                usable = false,
                rare = false,
                canRemove = canDrop,
            }
        end
    end

    for i = 1, #ESX.PlayerData.inventory do
        local v = ESX.PlayerData.inventory[i]
        if v.count > 0 then
            currentWeight = currentWeight + (v.weight * v.count)

            elements[#elements + 1] = {
                icon = "fas fa-box",
                title = ("%s x%s"):format(v.label, v.count),
                count = v.count,
                type = "item_standard",
                value = v.name,
                usable = v.usable,
                rare = v.rare,
                canRemove = v.canRemove,
            }
        end
    end

    elements[1].title = TranslateCap("inventory", currentWeight, Config.MaxWeight)

    for i = 1, #Config.Weapons do
        local v = Config.Weapons[i]
        local weaponHash = joaat(v.name)

        if HasPedGotWeapon(playerPed, weaponHash, false) then
            local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)

            elements[#elements + 1] = {
                icon = "fas fa-gun",
                title = v.ammo and ("%s - %s %s"):format(v.label, ammo, v.ammo.label) or v.label,
                count = 1,
                type = "item_weapon",
                value = v.name,
                usable = false,
                rare = false,
                ammo = ammo,
                canGiveAmmo = (v.ammo ~= nil),
                canRemove = true,
            }
        end
    end

    ESX.CloseContext()

    ESX.OpenContext("right", elements, function(_, element)
        local player, distance = ESX.Game.GetClosestPlayer()

        local elements2 = {}

        if element.usable then
            elements2[#elements2 + 1] = {
                icon = "fas fa-utensils",
                title = TranslateCap("use"),
                action = "use",
                type = element.type,
                value = element.value,
            }
        end

        if element.canRemove then
            if player ~= -1 and distance <= 3.0 then
                elements2[#elements2 + 1] = {
                    icon = "fas fa-hands",
                    title = TranslateCap("give"),
                    action = "give",
                    type = element.type,
                    value = element.value,
                }
            end

            elements2[#elements2 + 1] = {
                icon = "fas fa-trash",
                title = TranslateCap("remove"),
                action = "remove",
                type = element.type,
                value = element.value,
            }
        end

        if element.type == "item_weapon" and element.canGiveAmmo and element.ammo > 0 and player ~= -1 and distance <= 3.0 then
            elements2[#elements2 + 1] = {
                icon = "fas fa-gun",
                title = TranslateCap("giveammo"),
                action = "give_ammo",
                type = element.type,
                value = element.value,
            }
        end

        elements2[#elements2 + 1] = {
            icon = "fas fa-arrow-left",
            title = TranslateCap("return"),
            action = "return",
        }

        ESX.OpenContext("right", elements2, function(_, element2)
            local item, itemType = element2.value, element2.type

            if element2.action == "give" then
                local playersNearby = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)

                if #playersNearby > 0 then
                    local players = {}
                    local elements3 = {
                        { unselectable = true, icon = "fas fa-users", title = "Nearby Players" },
                    }

                    for currentNearbyPlayerIndex = 1, #playersNearby do
                        players[GetPlayerServerId(playersNearby[currentNearbyPlayerIndex])] = true
                    end

                    ESX.TriggerServerCallback("esx:getPlayerNames", function(returnedPlayers)
                        for playerId, playerName in pairs(returnedPlayers) do
                            elements3[#elements3 + 1] = {
                                icon = "fas fa-user",
                                title = playerName,
                                playerId = playerId,
                            }
                        end

                        ESX.OpenContext("right", elements3, function(_, element3)
                            local selectedPlayer, selectedPlayerId = GetPlayerFromServerId(element3.playerId), element3.playerId
                            playersNearby = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
                            playersNearby = ESX.Table.Set(playersNearby)

                            if playersNearby[selectedPlayer] then
                                local selectedPlayerPed = GetPlayerPed(selectedPlayer)

                                if IsPedOnFoot(selectedPlayerPed) and not IsPedFalling(selectedPlayerPed) then
                                    if itemType == "item_weapon" then
                                        TriggerServerEvent("esx:giveInventoryItem", selectedPlayerId, itemType, item, nil)
                                        ESX.CloseContext()
                                    else
                                        local elementsG = {
                                            { unselectable = true, icon = "fas fa-trash", title = element.title },
                                            { icon = "fas fa-tally", title = "Amount.", input = true, inputType = "number", inputPlaceholder = "Amount to give..", inputMin = 1, inputMax = 1000 },
                                            { icon = "fas fa-check-double", title = "Confirm", val = "confirm" },
                                        }

                                        ESX.OpenContext("right", elementsG, function(menuG, _)
                                            local quantity = tonumber(menuG.eles[2].inputValue)

                                            if quantity and quantity > 0 and element.count >= quantity then
                                                TriggerServerEvent("esx:giveInventoryItem", selectedPlayerId, itemType, item, quantity)
                                                ESX.CloseContext()
                                            else
                                                ESX.ShowNotification(TranslateCap("amount_invalid"))
                                            end
                                        end)
                                    end
                                else
                                    ESX.ShowNotification(TranslateCap("in_vehicle"))
                                end
                            else
                                ESX.ShowNotification(TranslateCap("players_nearby"))
                                ESX.CloseContext()
                            end
                        end)
                    end, players)
                end
            elseif element2.action == "remove" then
                if IsPedOnFoot(playerPed) and not IsPedFalling(playerPed) then
                    local dict, anim = "weapons@first_person@aim_rng@generic@projectile@sticky_bomb@", "plant_floor"
                    ESX.Streaming.RequestAnimDict(dict)

                    if itemType == "item_weapon" then
                        ESX.CloseContext()
                        TaskPlayAnim(playerPed, dict, anim, 8.0, 1.0, 1000, 16, 0.0, false, false, false)
                        RemoveAnimDict(dict)
                        Wait(1000)
                        TriggerServerEvent("esx:removeInventoryItem", itemType, item)
                    else
                        local elementsR = {
                            { unselectable = true, icon = "fas fa-trash", title = element.title },
                            { icon = "fas fa-tally", title = "Amount.", input = true, inputType = "number", inputPlaceholder = "Amount to remove..", inputMin = 1, inputMax = 1000 },
                            { icon = "fas fa-check-double", title = "Confirm", val = "confirm" },
                        }

                        ESX.OpenContext("right", elementsR, function(menuR, _)
                            local quantity = tonumber(menuR.eles[2].inputValue)

                            if quantity and quantity > 0 and element.count >= quantity then
                                ESX.CloseContext()
                                TaskPlayAnim(playerPed, dict, anim, 8.0, 1.0, 1000, 16, 0.0, false, false, false)
                                RemoveAnimDict(dict)
                                Wait(1000)
                                TriggerServerEvent("esx:removeInventoryItem", itemType, item, quantity)
                            else
                                ESX.ShowNotification(TranslateCap("amount_invalid"))
                            end
                        end)
                    end
                end
            elseif element2.action == "use" then
                ESX.CloseContext()
                TriggerServerEvent("esx:useItem", item)
            elseif element2.action == "return" then
                ESX.CloseContext()
                ESX.ShowInventory()
            elseif element2.action == "give_ammo" then
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                local closestPed = GetPlayerPed(closestPlayer)
                local pedAmmo = GetAmmoInPedWeapon(playerPed, joaat(item))

                if IsPedOnFoot(closestPed) and not IsPedFalling(closestPed) then
                    if closestPlayer ~= -1 and closestDistance < 3.0 then
                        if pedAmmo > 0 then
                            local elementsGA = {
                                { unselectable = true, icon = "fas fa-trash", title = element.title },
                                { icon = "fas fa-tally", title = "Amount.", input = true, inputType = "number", inputPlaceholder = "Amount to give..", inputMin = 1, inputMax = 1000 },
                                { icon = "fas fa-check-double", title = "Confirm", val = "confirm" },
                            }

                            ESX.OpenContext("right", elementsGA, function(menuGA, _)
                                local quantity = tonumber(menuGA.eles[2].inputValue)

                                if quantity and quantity > 0 then
                                    if pedAmmo >= quantity then
                                        TriggerServerEvent("esx:giveInventoryItem", GetPlayerServerId(closestPlayer), "item_ammo", item, quantity)
                                        ESX.CloseContext()
                                    else
                                        ESX.ShowNotification(TranslateCap("noammo"))
                                    end
                                else
                                    ESX.ShowNotification(TranslateCap("amount_invalid"))
                                end
                            end)
                        else
                            ESX.ShowNotification(TranslateCap("noammo"))
                        end
                    else
                        ESX.ShowNotification(TranslateCap("players_nearby"))
                    end
                else
                    ESX.ShowNotification(TranslateCap("in_vehicle"))
                end
            end
        end)
    end)
end

ESX.SecureNetEvent('esx:showNotification', ESX.ShowNotification)

ESX.SecureNetEvent('esx:showAdvancedNotification', ESX.ShowAdvancedNotification)

ESX.SecureNetEvent('esx:showHelpNotification', ESX.ShowHelpNotification)

AddEventHandler("onResourceStop", function(resourceName)
    for i = 1, #ESX.UI.Menu.Opened, 1 do
        if ESX.UI.Menu.Opened[i] then
            if ESX.UI.Menu.Opened[i].resourceName == resourceName or ESX.UI.Menu.Opened[i].namespace == resourceName then
                ESX.UI.Menu.Opened[i].close()
                ESX.UI.Menu.Opened[i] = nil
            end
        end
    end
end)
-- Credits to txAdmin for the list.
local mismatchedTypes = {
    [`airtug`] = "automobile", -- trailer
    [`avisa`] = "submarine", -- boat
    [`blimp`] = "heli", -- plane
    [`blimp2`] = "heli", -- plane
    [`blimp3`] = "heli", -- plane
    [`caddy`] = "automobile", -- trailer
    [`caddy2`] = "automobile", -- trailer
    [`caddy3`] = "automobile", -- trailer
    [`chimera`] = "automobile", -- bike
    [`docktug`] = "automobile", -- trailer
    [`forklift`] = "automobile", -- trailer
    [`kosatka`] = "submarine", -- boat
    [`mower`] = "automobile", -- trailer
    [`policeb`] = "bike", -- automobile
    [`ripley`] = "automobile", -- trailer
    [`rrocket`] = "automobile", -- bike
    [`sadler`] = "automobile", -- trailer
    [`sadler2`] = "automobile", -- trailer
    [`scrap`] = "automobile", -- trailer
    [`slamtruck`] = "automobile", -- trailer
    [`Stryder`] = "automobile", -- bike
    [`submersible`] = "submarine", -- boat
    [`submersible2`] = "submarine", -- boat
    [`thruster`] = "heli", -- automobile
    [`towtruck`] = "automobile", -- trailer
    [`towtruck2`] = "automobile", -- trailer
    [`tractor`] = "automobile", -- trailer
    [`tractor2`] = "automobile", -- trailer
    [`tractor3`] = "automobile", -- trailer
    [`trailersmall2`] = "trailer", -- automobile
    [`utillitruck`] = "automobile", -- trailer
    [`utillitruck2`] = "automobile", -- trailer
    [`utillitruck3`] = "automobile", -- trailer
}

---@param model number|string
---@return string | boolean
function ESX.GetVehicleTypeClient(model)
    model = type(model) == "string" and joaat(model) or model
    if not IsModelInCdimage(model) then
        return false
    end

    if not IsModelAVehicle(model) then
        return false
    end

    if mismatchedTypes[model] then
        return mismatchedTypes[model]
    end

    local vehicleType = GetVehicleClassFromName(model)
    local types = {
        [8] = "bike",
        [11] = "trailer",
        [13] = "bike",
        [14] = "boat",
        [15] = "heli",
        [16] = "plane",
        [21] = "train",
    }

    return types[vehicleType] or "automobile"
end

ESX.GetVehicleType = ESX.GetVehicleTypeClient
