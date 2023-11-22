---@diagnostic disable: param-type-mismatch, cast-local-type, duplicate-set-field, missing-fields, redundant-parameter, undefined-field
local AddTextEntry = AddTextEntry
local BeginTextCommandThefeedPost = BeginTextCommandThefeedPost
local ThefeedSetNextPostBackgroundColor = ThefeedSetNextPostBackgroundColor
local EndTextCommandThefeedPostMessagetext = EndTextCommandThefeedPostMessagetext
local EndTextCommandThefeedPostTicker = EndTextCommandThefeedPostTicker
local DisplayHelpTextThisFrame = DisplayHelpTextThisFrame
local BeginTextCommandDisplayHelp = BeginTextCommandDisplayHelp
local EndTextCommandDisplayHelp = EndTextCommandDisplayHelp
local SetFloatingHelpTextWorldPosition = SetFloatingHelpTextWorldPosition
local SetFloatingHelpTextStyle = SetFloatingHelpTextStyle
local format = string.format
local upper = string.upper
local gsub = string.gsub
local GetResourceState = GetResourceState
local GetInvokingResource = GetInvokingResource
local RegisterCommand = RegisterCommand
local RegisterKeyMapping = RegisterKeyMapping
local DoesEntityExist = DoesEntityExist
local RegisterPedheadshotTransparent = RegisterPedheadshotTransparent
local RegisterPedheadshot = RegisterPedheadshot
local IsPedheadshotReady = IsPedheadshotReady
local GetPedheadshotTxdString = GetPedheadshotTxdString
local RequestCollisionAtCoord = RequestCollisionAtCoord
local HasCollisionLoadedAroundEntity = HasCollisionLoadedAroundEntity
local SetEntityCoords = SetEntityCoords
local SetEntityHeading = SetEntityHeading
local NetworkGetEntityFromNetworkId = NetworkGetEntityFromNetworkId
local CreateObject = CreateObject
local SetEntityAsMissionEntity = SetEntityAsMissionEntity
local DeleteVehicle = DeleteVehicle
local DeleteObject = DeleteObject
local GetEntityCoords = GetEntityCoords
local CreateVehicle = CreateVehicle
local SetNetworkIdCanMigrate = SetNetworkIdCanMigrate
local SetVehicleHasBeenOwnedByPlayer = SetVehicleHasBeenOwnedByPlayer
local SetVehicleNeedsToBeHotwired = SetVehicleNeedsToBeHotwired
local SetModelAsNoLongerNeeded = SetModelAsNoLongerNeeded
local SetVehRadioStation = SetVehRadioStation
local GetVehicleNumberOfPassengers = GetVehicleNumberOfPassengers
local IsVehicleSeatFree = IsVehicleSeatFree
local GetGamePool = GetGamePool
local GetPlayerPed = GetPlayerPed
local GetEntityModel = GetEntityModel
local GetOffsetFromEntityInWorldCoords = GetOffsetFromEntityInWorldCoords
local GetVehicleColours = GetVehicleColours
local GetVehicleExtraColours = GetVehicleExtraColours
local GetIsVehiclePrimaryColourCustom = GetIsVehiclePrimaryColourCustom
local GetVehicleDashboardColor = GetVehicleDashboardColor
local GetVehicleInteriorColour = GetVehicleInteriorColour
local GetVehicleCustomPrimaryColour = GetVehicleCustomPrimaryColour
local GetVehicleXenonLightsCustomColor = GetVehicleXenonLightsCustomColor
local GetIsVehicleSecondaryColourCustom = GetIsVehicleSecondaryColourCustom
local GetVehicleCustomSecondaryColour = GetVehicleCustomSecondaryColour
local DoesExtraExist = DoesExtraExist
local IsVehicleExtraTurnedOn = IsVehicleExtraTurnedOn
local GetVehicleNumberOfWheels = GetVehicleNumberOfWheels
local IsVehicleTyreBurst = IsVehicleTyreBurst
local RollUpWindow = RollUpWindow
local IsVehicleWindowIntact = IsVehicleWindowIntact
local GetNumberOfVehicleDoors = GetNumberOfVehicleDoors
local IsVehicleDoorDamaged = IsVehicleDoorDamaged
local GetVehicleTyresCanBurst = GetVehicleTyresCanBurst
local GetVehicleNumberPlateText = GetVehicleNumberPlateText
local GetVehicleBodyHealth = GetVehicleBodyHealth
local GetVehicleEngineHealth = GetVehicleEngineHealth
local GetVehiclePetrolTankHealth = GetVehiclePetrolTankHealth
local GetVehicleFuelLevel = GetVehicleFuelLevel
local GetVehicleDirtLevel = GetVehicleDirtLevel
local GetVehicleWheelType = GetVehicleWheelType
local GetVehicleWindowTint = GetVehicleWindowTint
local GetVehicleXenonLightsColor = GetVehicleXenonLightsColor
local IsVehicleNeonLightEnabled = IsVehicleNeonLightEnabled
local GetVehicleNeonLightsColour = GetVehicleNeonLightsColour
local GetVehicleTyreSmokeColor = GetVehicleTyreSmokeColor
local GetVehicleMod = GetVehicleMod
local GetVehicleRoofLivery = GetVehicleRoofLivery
local IsToggleModOn = IsToggleModOn
local GetVehicleModVariation = GetVehicleModVariation
local GetVehicleLivery = GetVehicleLivery
local SetVehicleModKit = SetVehicleModKit
local SetVehicleTyresCanBurst = SetVehicleTyresCanBurst
local SetVehicleNumberPlateText = SetVehicleNumberPlateText
local SetVehicleNumberPlateTextIndex = SetVehicleNumberPlateTextIndex
local SetVehicleBodyHealth = SetVehicleBodyHealth
local SetVehicleEngineHealth = SetVehicleEngineHealth
local SetVehiclePetrolTankHealth = SetVehiclePetrolTankHealth
local SetVehicleFuelLevel = SetVehicleFuelLevel
local SetVehicleDirtLevel = SetVehicleDirtLevel
local SetVehicleCustomPrimaryColour = SetVehicleCustomPrimaryColour
local SetVehicleCustomSecondaryColour = SetVehicleCustomSecondaryColour
local SetVehicleColours = SetVehicleColours
local SetVehicleExtraColours = SetVehicleExtraColours
local SetVehicleInteriorColor = SetVehicleInteriorColor
local SetVehicleDashboardColor = SetVehicleDashboardColor
local SetVehicleWheelType = SetVehicleWheelType
local SetVehicleWindowTint = SetVehicleWindowTint
local SetVehicleNeonLightEnabled = SetVehicleNeonLightEnabled
local SetVehicleExtra = SetVehicleExtra
local SetVehicleNeonLightsColour = SetVehicleNeonLightsColour
local SetVehicleXenonLightsColor = SetVehicleXenonLightsColor
local SetVehicleXenonLightsCustomColor = SetVehicleXenonLightsCustomColor
local ToggleVehicleMod = ToggleVehicleMod
local SetVehicleTyreSmokeColor = SetVehicleTyreSmokeColor
local SetVehicleMod = SetVehicleMod
local SetVehicleRoofLivery = SetVehicleRoofLivery
local SetVehicleLivery = SetVehicleLivery
local RemoveVehicleWindow = RemoveVehicleWindow
local SetVehicleDoorBroken = SetVehicleDoorBroken
local SetVehicleTyreBurst = SetVehicleTyreBurst
local GetFinalRenderedCamCoord = GetFinalRenderedCamCoord
local GetGameplayCamFov = GetGameplayCamFov
local SetTextScale = SetTextScale
local SetTextFont = SetTextFont
local SetTextProportional = SetTextProportional
local SetTextColour = SetTextColour
local BeginTextCommandDisplayText = BeginTextCommandDisplayText
local SetTextCentre = SetTextCentre
local AddTextComponentSubstringPlayerName = AddTextComponentSubstringPlayerName
local SetDrawOrigin = SetDrawOrigin
local EndTextCommandDisplayText = EndTextCommandDisplayText
local ClearDrawOrigin = ClearDrawOrigin
local HasPedGotWeapon = HasPedGotWeapon
local GetAmmoInPedWeapon = GetAmmoInPedWeapon
local GetPlayerServerId = GetPlayerServerId
local GetPlayerFromServerId = GetPlayerFromServerId
local IsPedOnFoot = IsPedOnFoot
local IsPedFalling = IsPedFalling
local TriggerServerEvent = TriggerServerEvent
local TaskPlayAnim = TaskPlayAnim
local RemoveAnimDict = RemoveAnimDict
local IsModelInCdimage = IsModelInCdimage
local GetVehicleClassFromName = GetVehicleClassFromName
local Wait = Wait

ESX = {}
Core = {}
ESX.PlayerData = {}
ESX.PlayerLoaded = false
Core.Input = {}
ESX.UI = {}
ESX.UI.Menu = {}
ESX.UI.Menu.RegisteredTypes = {}
ESX.UI.Menu.Opened = {}

ESX.Game = {}
ESX.Game.Utils = {}

ESX.Scaleform = {}
ESX.Scaleform.Utils = {}

ESX.Streaming = {}

function ESX.IsPlayerLoaded()
    return ESX.PlayerLoaded
end

function ESX.GetPlayerData()
    return ESX.PlayerData
end

function ESX.SearchInventory(items, count)
    if type(items) == 'string' then
        items = { items }
    end

    local returnData = {}
    local itemCount = #items
    local itemName

    for i = 1, itemCount do
        itemName = items[i]
        returnData[itemName] = count and 0

        for _, item in pairs(ESX.PlayerData.inventory) do
            if item.name == itemName then
                if count then
                    returnData[itemName] = returnData[itemName] + item.count
                else
                    returnData[itemName] = item
                end
            end
        end
    end

    if next(returnData) then
        return itemCount == 1 and returnData[items[1]] or returnData
    end
end

function ESX.SetPlayerData(key, val)
    local current = ESX.PlayerData[key]
    ESX.PlayerData[key] = val

    if key ~= 'inventory' and key ~= 'loadout' then
        if type(val) == 'table' or val ~= current then
            TriggerEvent('esx:setPlayerData', key, val, current)
        end
    end
end

function ESX.Progressbar(message, length, Options)
    if GetResourceState('esx_progressbar') ~= 'missing' then
        return exports.esx_progressbar:Progressbar(message, length, Options)
    end

    print('[^1ERROR^7] ^5ESX Progressbar^7 is Missing!')
end

function ESX.ShowNotification(message, notifyType, length)
    if GetResourceState('esx_notify') ~= 'missing' then
        return exports.esx_notify:Notify(notifyType, length, message)
    end

    print('[^1ERROR^7] ^5ESX Notify^7 is Missing!')
end

function ESX.TextUI(message, notifyType)
    if GetResourceState('esx_textui') ~= 'missing' then
        return exports.esx_textui:TextUI(message, notifyType)
    end

    print('[^1ERROR^7] ^5ESX TextUI^7 is Missing!')
end

function ESX.HideUI()
    if GetResourceState('esx_textui') ~= 'missing' then
        return exports.esx_textui:HideUI()
    end

    print('[^1ERROR^7] ^5ESX TextUI^7 is Missing!')
end

function ESX.ShowAdvancedNotification(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
    if not saveToBrief then
        saveToBrief = true
    end

    AddTextEntry('esxAdvancedNotification', msg)
    BeginTextCommandThefeedPost('esxAdvancedNotification')

    if hudColorIndex then
        ThefeedSetNextPostBackgroundColor(hudColorIndex)
    end

    EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, iconType, sender, subject)
    EndTextCommandThefeedPostTicker(flash or false, saveToBrief)
end

function ESX.ShowHelpNotification(msg, thisFrame, beep, duration)
    AddTextEntry('esxHelpNotification', msg)

    if thisFrame then
        DisplayHelpTextThisFrame('esxHelpNotification', false)
    else
        if not beep then
            beep = true
        end

        BeginTextCommandDisplayHelp('esxHelpNotification')
        EndTextCommandDisplayHelp(0, false, beep, duration or -1)
    end
end

function ESX.ShowFloatingHelpNotification(msg, coords)
    AddTextEntry('esxFloatingHelpNotification', msg)
    SetFloatingHelpTextWorldPosition(1, coords.x, coords.y, coords.z)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp('esxFloatingHelpNotification')
    EndTextCommandDisplayHelp(2, false, false, -1)
end

ESX.HashString = function(str)
    local hash = joaat(str)
    local input_map = format('~INPUT_%s~', upper(format('%x', hash)))
    input_map = gsub(input_map, 'FFFFFFFF', '')

    return input_map
end

local contextAvailable = GetResourceState('esx_context') ~= 'missing'

function ESX.OpenContext(...)
    return contextAvailable and exports.esx_context:Open(...) or print('[^1ERROR^7] Tried to ^5open^7 context menu, but ^5esx_context^7 is missing!')
end

function ESX.PreviewContext(...)
    return contextAvailable and exports.esx_context:Preview(...) or print('[^1ERROR^7] Tried to ^5preview^7 context menu, but ^5esx_context^7 is missing!')
end

function ESX.CloseContext(...)
    return contextAvailable and exports.esx_context:Close(...) or print('[^1ERROR^7] Tried to ^5close^7 context menu, but ^5esx_context^7 is missing!')
end

function ESX.RefreshContext(...)
    return contextAvailable and exports.esx_context:Refresh(...) or print('[^1ERROR^7] Tried to ^5Refresh^7 context menu, but ^5esx_context^7 is missing!')
end

ESX.RegisterInput = function(command_name, label, input_group, key, on_press, on_release)
    Core.Input[command_name] = on_release ~= nil and ESX.HashString('+' .. command_name) or ESX.HashString(command_name)
    RegisterCommand(on_release ~= nil and '+' .. command_name or command_name, on_press)

    if on_release then
        RegisterCommand('-' .. command_name, on_release)
    end

    RegisterKeyMapping(on_release ~= nil and '+' .. command_name or command_name, label, input_group, key)
end

function ESX.UI.Menu.RegisterType(menuType, open, close)
    ESX.UI.Menu.RegisteredTypes[menuType] = {
        open = open,
        close = close
    }
end

function ESX.UI.Menu.Open(menuType, namespace, name, data, submit, cancel, change, close)
    local menu = {}

    menu.type = menuType
    menu.namespace = namespace
    menu.resourceName = (GetInvokingResource() or 'Unknown')
    menu.name = name
    menu.data = data
    menu.submit = submit
    menu.cancel = cancel
    menu.change = change

    menu.close = function()
        ESX.UI.Menu.RegisteredTypes[menuType].close(namespace, name)

        for i = 1, #ESX.UI.Menu.Opened, 1 do
            if ESX.UI.Menu.Opened[i] then
                if ESX.UI.Menu.Opened[i].type == menuType and ESX.UI.Menu.Opened[i].namespace == namespace and
                    ESX.UI.Menu.Opened[i].name == name then
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

function ESX.UI.Menu.Close(menuType, namespace, name)
    for i = 1, #ESX.UI.Menu.Opened, 1 do
        if ESX.UI.Menu.Opened[i] then
            if ESX.UI.Menu.Opened[i].type == menuType and ESX.UI.Menu.Opened[i].namespace == namespace and
                ESX.UI.Menu.Opened[i].name == name then
                ESX.UI.Menu.Opened[i].close()
                ESX.UI.Menu.Opened[i] = nil
            end
        end
    end
end

function ESX.UI.Menu.CloseAll()
    for i = 1, #ESX.UI.Menu.Opened, 1 do
        if ESX.UI.Menu.Opened[i] then
            ESX.UI.Menu.Opened[i].close()
            ESX.UI.Menu.Opened[i] = nil
        end
    end
end

function ESX.UI.Menu.GetOpened(menuType, namespace, name)
    for i = 1, #ESX.UI.Menu.Opened, 1 do
        if ESX.UI.Menu.Opened[i] then
            if ESX.UI.Menu.Opened[i].type == menuType and ESX.UI.Menu.Opened[i].namespace == namespace and
                ESX.UI.Menu.Opened[i].name == name then
                return ESX.UI.Menu.Opened[i]
            end
        end
    end
end

function ESX.UI.Menu.GetOpenedMenus()
    return ESX.UI.Menu.Opened
end

function ESX.UI.Menu.IsOpen(menuType, namespace, name)
    return ESX.UI.Menu.GetOpened(menuType, namespace, name) ~= nil
end

function ESX.UI.ShowInventoryItemNotification(add, item, count)
    SendNUIMessage({
        action = 'inventoryNotification',
        add = add,
        item = item,
        count = count
    })
end

function ESX.Game.GetPedMugshot(ped, transparent)
    if not DoesEntityExist(ped) then return end
    local mugshot = transparent and RegisterPedheadshotTransparent(ped) or RegisterPedheadshot(ped)

    while not IsPedheadshotReady(mugshot) do
        Wait(100)
    end

    return mugshot, GetPedheadshotTxdString(mugshot)
end

function ESX.Game.Teleport(entity, coords, cb)
    local vector = type(coords) == 'vector4' and coords or type(coords) == 'vector3' and vector4(coords, 0.0) or vec(coords.x, coords.y, coords.z, coords.heading or 0.0)

    if DoesEntityExist(entity) then
        RequestCollisionAtCoord(vector.x, vector.y, vector.z)
        while not HasCollisionLoadedAroundEntity(entity) do
            Wait(100)
        end

        SetEntityCoords(entity, vector.x, vector.y, vector.z, false, false, false, false)
        SetEntityHeading(entity, vector.w)
    end

    if cb then
        cb()
    end
end

function ESX.Game.SpawnObject(object, coords, cb, networked)
    networked = not networked and true or networked

    if networked then
        ESX.TriggerServerCallback('esx:Onesync:SpawnObject', function(NetworkID)
            if cb then
                local obj = NetworkGetEntityFromNetworkId(NetworkID)
                local tries = 0

                while not DoesEntityExist(obj) do
                    obj = NetworkGetEntityFromNetworkId(NetworkID)
                    Wait(0)
                    tries = tries + 1

                    if tries > 250 then
                        break
                    end
                end

                cb(obj)
            end
        end, object, coords, 0.0)
    else
        local model = type(object) == 'number' and object or joaat(object)
        local vector = type(coords) == 'vector3' and coords or vec(coords.x, coords.y, coords.z)

        CreateThread(function()
            ESX.Streaming.RequestModel(model)

            local obj = CreateObject(model, vector.x, vector.y, vector.z, networked, false, true)

            if cb then
                cb(obj)
            end
        end)
    end
end

function ESX.Game.SpawnLocalObject(object, coords, cb)
    ESX.Game.SpawnObject(object, coords, cb, false)
end

function ESX.Game.DeleteVehicle(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

function ESX.Game.DeleteObject(object)
    SetEntityAsMissionEntity(object, false, true)
    DeleteObject(object)
end

function ESX.Game.SpawnVehicle(vehicleModel, coords, heading, cb, networked)
    networked = not networked and true or networked

    local model = type(vehicleModel) == 'number' and vehicleModel or joaat(vehicleModel)
    local vector = type(coords) == 'vector3' and coords or vec(coords.x, coords.y, coords.z)
    local playerCoords = GetEntityCoords(ESX.PlayerData.ped)

    if not vector or not playerCoords then
        return
    end

    if #(playerCoords - vector) > 424 then -- Onesync infinity Range (https://docs.fivem.net/docs/scripting-reference/onesync/)
        return print(('[^1ERROR^7] Resource ^5%s^7 Tried to spawn vehicle on the client but the position is too far away (Out of onesync range).'):format(GetInvokingResource() or 'Unknown'))
    end

    CreateThread(function()
        ESX.Streaming.RequestModel(model)

        local vehicle = CreateVehicle(model, vector.x, vector.y, vector.z, heading, networked, true)

        if networked then
            local id = NetworkGetNetworkIdFromEntity(vehicle)

            SetNetworkIdCanMigrate(id, true)
            SetEntityAsMissionEntity(vehicle, true, true)
        end

        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetVehicleNeedsToBeHotwired(vehicle, false)
        SetModelAsNoLongerNeeded(model)
        SetVehRadioStation(vehicle, 'OFF')
        RequestCollisionAtCoord(vector.x, vector.y, vector.z)

        while not HasCollisionLoadedAroundEntity(vehicle) do
            Wait(100)
        end

        if cb then
            cb(vehicle)
        end
    end)
end

function ESX.Game.SpawnLocalVehicle(vehicle, coords, heading, cb)
    ESX.Game.SpawnVehicle(vehicle, coords, heading, cb, false)
end

function ESX.Game.IsDriverSeatEmpty(vehicle)
    if not DoesEntityExist(vehicle) then
        return false
    end

    return GetVehicleNumberOfPassengers(vehicle) == 0 and IsVehicleSeatFree(vehicle, -1)
end
ESX.Game.IsVehicleEmpty = ESX.Game.IsDriverSeatEmpty

function ESX.Game.GetObjects() -- Leave the function for compatibility
    return GetGamePool('CObject')
end

function ESX.Game.GetPeds(onlyOtherPeds)
    local myPed, pool = ESX.PlayerData.ped, GetGamePool('CPed')

    if not onlyOtherPeds then
        return pool
    end

    local peds = {}
    for i = 1, #pool do
        if pool[i] ~= myPed then
            peds[#peds + 1] = pool[i]
        end
    end

    return peds
end

function ESX.Game.GetVehicles() -- Leave the function for compatibility
    return GetGamePool('CVehicle')
end

function ESX.Game.GetPlayers(onlyOtherPlayers, returnKeyValue, returnPeds)
    local players = {}
    local ped

    for _, player in ipairs(GetActivePlayers()) do
        ped = GetPlayerPed(player)

        if DoesEntityExist(ped) and ((onlyOtherPlayers and player ~= ESX.PlayerData.player) or not onlyOtherPlayers) then
            if returnKeyValue then
                players[player] = ped
            else
                players[#players + 1] = returnPeds and ped or player
            end
        end
    end

    return players
end

function ESX.Game.GetClosestObject(coords, modelFilter)
    return ESX.Game.GetClosestEntity(ESX.Game.GetObjects(), false, coords, modelFilter)
end

function ESX.Game.GetClosestPed(coords, modelFilter)
    return ESX.Game.GetClosestEntity(ESX.Game.GetPeds(true), false, coords, modelFilter)
end

function ESX.Game.GetClosestPlayer(coords)
    return ESX.Game.GetClosestEntity(ESX.Game.GetPlayers(true, true), true, coords, nil)
end

function ESX.Game.GetClosestVehicle(coords, modelFilter)
    return ESX.Game.GetClosestEntity(ESX.Game.GetVehicles(), false, coords, modelFilter)
end

local function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
    local nearbyEntities = {}
    local dist

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        coords = GetEntityCoords(ESX.PlayerData.ped)
    end

    for k, entity in pairs(entities) do
        dist = #(coords - GetEntityCoords(entity))

        if dist <= maxDistance then
            nearbyEntities[#nearbyEntities + 1] = isPlayerEntities and k or entity
        end
    end

    return nearbyEntities
end

function ESX.Game.GetPlayersInArea(coords, maxDistance)
    return EnumerateEntitiesWithinDistance(ESX.Game.GetPlayers(true, true), true, coords, maxDistance)
end

function ESX.Game.GetVehiclesInArea(coords, maxDistance)
    return EnumerateEntitiesWithinDistance(ESX.Game.GetVehicles(), false, coords, maxDistance)
end

function ESX.Game.IsSpawnPointClear(coords, maxDistance)
    return #ESX.Game.GetVehiclesInArea(coords, maxDistance) == 0
end

function ESX.Game.GetClosestEntity(entities, isPlayerEntities, coords, modelFilter)
    local closestEntity, closestEntityDistance, filteredEntities = -1, -1, nil

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        coords = GetEntityCoords(ESX.PlayerData.ped)
    end

    if modelFilter then
        filteredEntities = {}

        for _, entity in pairs(entities) do
            if modelFilter[GetEntityModel(entity)] then
                filteredEntities[#filteredEntities + 1] = entity
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

function ESX.Game.GetVehicleInDirection()
    local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
    local inDirection = GetOffsetFromEntityInWorldCoords(ESX.PlayerData.ped, 0.0, 5.0, 0.0)
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(playerCoords.x, playerCoords.y, playerCoords.z, inDirection.x, inDirection.y, inDirection.z, 10, ESX.PlayerData.ped, 0)
    local _, hit, _, _, entityHit = GetShapeTestResult(rayHandle)

    if hit == 1 and GetEntityType(entityHit) == 2 then
        return entityHit, GetEntityCoords(entityHit)
    end

    return 0
end

function ESX.Game.GetVehicleProperties(vehicle)
    if not DoesEntityExist(vehicle) then
        return {}
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

    local TyresIndex = {             -- Wheel index list according to the number of vehicle wheels.
        ['2'] = { 0, 4 },            -- Bike and cycle.
        ['3'] = { 0, 1, 4, 5 },      -- Vehicle with 3 wheels (get for wheels because some 3 wheels vehicles have 2 wheels on front and one rear or the reverse).
        ['4'] = { 0, 1, 4, 5 },      -- Vehicle with 4 wheels.
        ['6'] = { 0, 1, 2, 3, 4, 5 } -- Vehicle with 6 wheels.
    }

    if TyresIndex[numWheels] then
        for _, idx in pairs(TyresIndex[numWheels]) do
            tyreBurst[tostring(idx)] = IsVehicleTyreBurst(vehicle, idx, false)
        end
    end

    for windowId = 0, 7 do              -- 13
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

        neonEnabled = { IsVehicleNeonLightEnabled(vehicle, 0), IsVehicleNeonLightEnabled(vehicle, 1),
            IsVehicleNeonLightEnabled(vehicle, 2), IsVehicleNeonLightEnabled(vehicle, 3) },

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
        modLightbar = GetVehicleMod(vehicle, 49)
    }
end

function ESX.Game.SetVehicleProperties(vehicle, props)
    if not DoesEntityExist(vehicle) then
        return
    end

    local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)

    SetVehicleModKit(vehicle, 0)
    if props?.tyresCanBurst then
        SetVehicleTyresCanBurst(vehicle, props.tyresCanBurst)
    end

    if props?.plate then
        SetVehicleNumberPlateText(vehicle, props.plate)
    end

    if props?.plateIndex then
        SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
    end

    if props?.bodyHealth then
        SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
    end

    if props?.engineHealth then
        SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
    end

    if props?.tankHealth then
        SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0)
    end

    if props?.fuelLevel then
        SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
    end

    if props?.dirtLevel then
        SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
    end

    if props?.customPrimaryColor then
        SetVehicleCustomPrimaryColour(vehicle, props.customPrimaryColor[1], props.customPrimaryColor[2], props.customPrimaryColor[3])
    end

    if props?.customSecondaryColor then
        SetVehicleCustomSecondaryColour(vehicle, props.customSecondaryColor[1], props.customSecondaryColor[2], props.customSecondaryColor[3])
    end

    if props?.color1 then
        SetVehicleColours(vehicle, props.color1, colorSecondary)
    end

    if props?.color2 then
        SetVehicleColours(vehicle, props.color1 or colorPrimary, props.color2)
    end

    if props?.pearlescentColor then
        SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
    end

    if props?.interiorColor then
        SetVehicleInteriorColor(vehicle, props.interiorColor)
    end

    if props?.dashboardColor then
        SetVehicleDashboardColor(vehicle, props.dashboardColor)
    end

    if props?.wheelColor then
        SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor)
    end

    if props?.wheels then
        SetVehicleWheelType(vehicle, props.wheels)
    end
    if props?.windowTint then
        SetVehicleWindowTint(vehicle, props.windowTint)
    end

    if props?.neonEnabled then
        SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
        SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
        SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
        SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
    end

    if props?.extras then
        for extraId, enabled in pairs(props.extras) do
            SetVehicleExtra(vehicle, tonumber(extraId), enabled and 0 or 1)
        end
    end

    if props?.neonColor then
        SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
    end

    if props?.xenonColor then
        SetVehicleXenonLightsColor(vehicle, props.xenonColor)
    end

    if props?.customXenonColor then
        SetVehicleXenonLightsCustomColor(vehicle, props.customXenonColor[1], props.customXenonColor[2],
            props.customXenonColor[3])
    end

    if props?.modSmokeEnabled then
        ToggleVehicleMod(vehicle, 20, true)
    end

    if props?.tyreSmokeColor then
        SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
    end

    if props?.modSpoilers then
        SetVehicleMod(vehicle, 0, props.modSpoilers, false)
    end

    if props?.modFrontBumper then
        SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
    end

    if props?.modRearBumper then
        SetVehicleMod(vehicle, 2, props.modRearBumper, false)
    end

    if props?.modSideSkirt then
        SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
    end

    if props?.modExhaust then
        SetVehicleMod(vehicle, 4, props.modExhaust, false)
    end

    if props?.modFrame then
        SetVehicleMod(vehicle, 5, props.modFrame, false)
    end

    if props?.modGrille then
        SetVehicleMod(vehicle, 6, props.modGrille, false)
    end

    if props?.modHood then
        SetVehicleMod(vehicle, 7, props.modHood, false)
    end

    if props?.modFender then
        SetVehicleMod(vehicle, 8, props.modFender, false)
    end

    if props?.modRightFender then
        SetVehicleMod(vehicle, 9, props.modRightFender, false)
    end

    if props?.modRoof then
        SetVehicleMod(vehicle, 10, props.modRoof, false)
    end

    if props?.modRoofLivery then
        SetVehicleRoofLivery(vehicle, props.modRoofLivery)
    end

    if props?.modEngine then
        SetVehicleMod(vehicle, 11, props.modEngine, false)
    end

    if props?.modBrakes then
        SetVehicleMod(vehicle, 12, props.modBrakes, false)
    end

    if props?.modTransmission then
        SetVehicleMod(vehicle, 13, props.modTransmission, false)
    end

    if props?.modHorns then
        SetVehicleMod(vehicle, 14, props.modHorns, false)
    end

    if props?.modSuspension then
        SetVehicleMod(vehicle, 15, props.modSuspension, false)
    end

    if props?.modArmor then
        SetVehicleMod(vehicle, 16, props.modArmor, false)
    end

    if props?.modTurbo then
        ToggleVehicleMod(vehicle, 18, props.modTurbo)
    end

    if props?.modXenon then
        ToggleVehicleMod(vehicle, 22, props.modXenon)
    end

    if props?.modFrontWheels then
        SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomFrontWheels)
    end

    if props?.modBackWheels then
        SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomBackWheels)
    end

    if props?.modPlateHolder then
        SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
    end

    if props?.modVanityPlate then
        SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
    end

    if props?.modTrimA then
        SetVehicleMod(vehicle, 27, props.modTrimA, false)
    end

    if props?.modOrnaments then
        SetVehicleMod(vehicle, 28, props.modOrnaments, false)
    end

    if props?.modDashboard then
        SetVehicleMod(vehicle, 29, props.modDashboard, false)
    end

    if props?.modDial then
        SetVehicleMod(vehicle, 30, props.modDial, false)
    end

    if props?.modDoorSpeaker then
        SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
    end

    if props?.modSeats then
        SetVehicleMod(vehicle, 32, props.modSeats, false)
    end

    if props?.modSteeringWheel then
        SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
    end

    if props?.modShifterLeavers then
        SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
    end

    if props?.modAPlate then
        SetVehicleMod(vehicle, 35, props.modAPlate, false)
    end

    if props?.modSpeakers then
        SetVehicleMod(vehicle, 36, props.modSpeakers, false)
    end

    if props?.modTrunk then
        SetVehicleMod(vehicle, 37, props.modTrunk, false)
    end

    if props?.modHydrolic then
        SetVehicleMod(vehicle, 38, props.modHydrolic, false)
    end

    if props?.modEngineBlock then
        SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
    end

    if props?.modAirFilter then
        SetVehicleMod(vehicle, 40, props.modAirFilter, false)
    end

    if props?.modStruts then
        SetVehicleMod(vehicle, 41, props.modStruts, false)
    end

    if props?.modArchCover then
        SetVehicleMod(vehicle, 42, props.modArchCover, false)
    end

    if props?.modAerials then
        SetVehicleMod(vehicle, 43, props.modAerials, false)
    end

    if props?.modTrimB then
        SetVehicleMod(vehicle, 44, props.modTrimB, false)
    end

    if props?.modTank then
        SetVehicleMod(vehicle, 45, props.modTank, false)
    end

    if props?.modWindows then
        SetVehicleMod(vehicle, 46, props.modWindows, false)
    end

    if props?.modLivery then
        SetVehicleMod(vehicle, 48, props.modLivery, false)
        SetVehicleLivery(vehicle, props.modLivery)
    end

    if props?.windowsBroken then
        for k, v in pairs(props.windowsBroken) do
            if v then
                RemoveVehicleWindow(vehicle, tonumber(k))
            end
        end
    end

    if props?.doorsBroken then
        for k, v in pairs(props.doorsBroken) do
            if v then
                SetVehicleDoorBroken(vehicle, tonumber(k), true)
            end
        end
    end

    if props?.tyreBurst then
        for k, v in pairs(props.tyreBurst) do
            if v then
                SetVehicleTyreBurst(vehicle, tonumber(k), true, 1000.0)
            end
        end
    end
end

function ESX.Game.Utils.DrawText3D(coords, text, size, font)
    size = size or 1
    font = font or 0
    local vector = vec(coords.x, coords.y, coords.z)
    local scale = (size / #(vector - GetFinalRenderedCamCoord())) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(0.0, 0.55 * scale)
    SetTextFont(font)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText('STRING')
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

    return {}
end

function ESX.ShowInventory()
    if not Config.EnableDefaultInventory then
        return
    end

    local elements = {
        { unselectable = true, icon = 'fas fa-box' }
    }
    local currentWeight = 0

    for i = 1, #(ESX.PlayerData.accounts) do
        if ESX.PlayerData.accounts[i]?.money > 0 then
            local formattedMoney = TranslateCap('locale_currency', ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money))

            elements[#elements + 1] = {
                icon = 'fas fa-money-bill-wave',
                title = ('%s: <span style=\'color:green;\'>%s</span>'):format(ESX.PlayerData.accounts[i].label, formattedMoney),
                count = ESX.PlayerData.accounts[i].money,
                type = 'item_account',
                value = ESX.PlayerData.accounts[i].name,
                usable = false,
                rare = false,
                canRemove = ESX.PlayerData.accounts[i].name ~= 'bank'
            }
        end
    end

    for _, v in ipairs(ESX.PlayerData.inventory) do
        if v?.count > 0 then
            currentWeight = currentWeight + (v.weight * v.count)

            elements[#elements + 1] = {
                icon = 'fas fa-box',
                title = ('%s x%s'):format(v.label, v.count),
                count = v.count,
                type = 'item_standard',
                value = v.name,
                usable = v.usable,
                rare = v.rare,
                canRemove = v.canRemove
            }
        end
    end

    elements[1].title = TranslateCap('inventory', currentWeight, Config.MaxWeight)

    for i = 1, #Config.Weapons do
        local v = Config.Weapons[i]
        local weaponHash = joaat(v.name)

        if HasPedGotWeapon(ESX.PlayerData.ped, weaponHash, false) then
            local ammo = GetAmmoInPedWeapon(ESX.PlayerData.ped, weaponHash)

            elements[#elements + 1] = {
                icon = 'fas fa-gun',
                title = v.ammo and ('%s - %s %s'):format(v.label, ammo, v.ammo.label) or v.label,
                count = 1,
                type = 'item_weapon',
                value = v.name,
                usable = false,
                rare = false,
                ammo = ammo,
                canGiveAmmo = (v.ammo ~= nil),
                canRemove = true
            }
        end
    end

    ESX.CloseContext()

    ESX.OpenContext('right', elements, function(_, element)
        local player, distance = ESX.Game.GetClosestPlayer()
        local elements2 = {}

        if element?.usable then
            elements2[#elements2 + 1] = {
                icon = 'fas fa-utensils',
                title = TranslateCap('use'),
                action = 'use',
                type = element.type,
                value = element.value
            }
        end

        if element?.canRemove then
            if player ~= -1 and distance <= 3.0 then
                elements2[#elements2 + 1] = {
                    icon = 'fas fa-hands',
                    title = TranslateCap('give'),
                    action = 'give',
                    type = element.type,
                    value = element.value
                }
            end

            elements2[#elements2 + 1] = {
                icon = 'fas fa-trash',
                title = TranslateCap('remove'),
                action = 'remove',
                type = element.type,
                value = element.value
            }
        end

        if element?.type == 'item_weapon' and element.canGiveAmmo and element.ammo > 0 and player ~= -1 and distance <= 3.0 then
            elements2[#elements2 + 1] = {
                icon = 'fas fa-gun',
                title = TranslateCap('giveammo'),
                action = 'give_ammo',
                type = element.type,
                value = element.value
            }
        end

        elements2[#elements2 + 1] = {
            icon = 'fas fa-arrow-left',
            title = TranslateCap('return'),
            action = 'return'
        }

        ESX.OpenContext('right', elements2, function(_, element2)
            local item, itemType = element2.value, element2.type

            if element2.action == 'give' then
                local playersNearby = ESX.Game.GetPlayersInArea(GetEntityCoords(ESX.PlayerData.ped), 3.0)

                if #playersNearby > 0 then
                    local players = {}
                    local elements3 = {
                        { unselectable = true, icon = 'fas fa-users', title = 'Nearby Players' }
                    }

                    for _, playerNearby in ipairs(playersNearby) do
                        players[GetPlayerServerId(playerNearby)] = true
                    end

                    ESX.TriggerServerCallback('esx:getPlayerNames', function(returnedPlayers)
                        for playerId, playerName in pairs(returnedPlayers) do
                            elements3[#elements3 + 1] = {
                                icon = 'fas fa-user',
                                title = playerName,
                                playerId = playerId
                            }
                        end

                        ESX.OpenContext('right', elements3, function(_, element3)
                            local selectedPlayer, selectedPlayerId = GetPlayerFromServerId(element3.playerId), element3.playerId
                            playersNearby = ESX.Game.GetPlayersInArea(GetEntityCoords(ESX.PlayerData.ped), 3.0)
                            playersNearby = ESX.Table.Set(playersNearby)

                            if playersNearby and playersNearby[selectedPlayer] then
                                local selectedPlayerPed = GetPlayerPed(selectedPlayer)

                                if IsPedOnFoot(selectedPlayerPed) and not IsPedFalling(selectedPlayerPed) then
                                    if itemType == 'item_weapon' then
                                        TriggerServerEvent('esx:giveInventoryItem', selectedPlayerId, itemType, item, nil)
                                        ESX.CloseContext()
                                    else
                                        local elementsG = {
                                            { unselectable = true,          icon = 'fas fa-trash', title = element.title },
                                            { icon = 'fas fa-tally',        title = 'Amount.',     input = true,         inputType = 'number', inputPlaceholder = 'Amount to give..', inputMin = 1, inputMax = 1000 },
                                            { icon = 'fas fa-check-double', title = 'Confirm',     val = 'confirm' }
                                        }

                                        ESX.OpenContext('right', elementsG, function(menuG, _)
                                            local quantity = tonumber(menuG.eles[2].inputValue)

                                            if quantity and quantity > 0 and element.count >= quantity then
                                                TriggerServerEvent('esx:giveInventoryItem', selectedPlayerId, itemType, item, quantity)
                                                ESX.CloseContext()
                                            else
                                                ESX.ShowNotification(TranslateCap('amount_invalid'))
                                            end
                                        end)
                                    end
                                else
                                    ESX.ShowNotification(TranslateCap('in_vehicle'))
                                end
                            else
                                ESX.ShowNotification(TranslateCap('players_nearby'))
                                ESX.CloseContext()
                            end
                        end)
                    end, players)
                end
            elseif element2.action == 'remove' then
                if IsPedOnFoot(ESX.PlayerData.ped) and not IsPedFalling(ESX.PlayerData.ped) then
                    local dict, anim = 'weapons@first_person@aim_rng@generic@projectile@sticky_bomb@', 'plant_floor'
                    ESX.Streaming.RequestAnimDict(dict)

                    if itemType == 'item_weapon' then
                        ESX.CloseContext()
                        TaskPlayAnim(ESX.PlayerData.ped, dict, anim, 8.0, 1.0, 1000, 16, 0.0, false, false, false)
                        RemoveAnimDict(dict)
                        Wait(1000)
                        TriggerServerEvent('esx:removeInventoryItem', itemType, item)
                    else
                        local elementsR = {
                            { unselectable = true,          icon = 'fas fa-trash', title = element.title },
                            { icon = 'fas fa-tally',        title = 'Amount.',     input = true,         inputType = 'number', inputPlaceholder = 'Amount to remove..', inputMin = 1, inputMax = 1000 },
                            { icon = 'fas fa-check-double', title = 'Confirm',     val = 'confirm' }
                        }

                        ESX.OpenContext('right', elementsR, function(menuR, _)
                            local quantity = tonumber(menuR.eles[2].inputValue)

                            if quantity and quantity > 0 and element.count >= quantity then
                                ESX.CloseContext()
                                TaskPlayAnim(ESX.PlayerData.ped, dict, anim, 8.0, 1.0, 1000, 16, 0.0, false, false, false)
                                RemoveAnimDict(dict)
                                Wait(1000)
                                TriggerServerEvent('esx:removeInventoryItem', itemType, item, quantity)
                            else
                                ESX.ShowNotification(TranslateCap('amount_invalid'))
                            end
                        end)
                    end
                end
            elseif element2.action == 'use' then
                ESX.CloseContext()
                TriggerServerEvent('esx:useItem', item)
            elseif element2.action == 'return' then
                ESX.CloseContext()
                ESX.ShowInventory()
            elseif element2.action == 'give_ammo' then
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                local closestPed = GetPlayerPed(closestPlayer)
                local pedAmmo = GetAmmoInPedWeapon(ESX.PlayerData.ped, joaat(item))

                if IsPedOnFoot(closestPed) and not IsPedFalling(closestPed) then
                    if closestPlayer ~= -1 and closestDistance < 3.0 then
                        if pedAmmo > 0 then
                            local elementsGA = {
                                { unselectable = true,          icon = 'fas fa-trash', title = element.title },
                                { icon = 'fas fa-tally',        title = 'Amount.',     input = true,         inputType = 'number', inputPlaceholder = 'Amount to give..', inputMin = 1, inputMax = 1000 },
                                { icon = 'fas fa-check-double', title = 'Confirm',     val = 'confirm' }
                            }

                            ESX.OpenContext('right', elementsGA, function(menuGA, _)
                                local quantity = tonumber(menuGA.eles[2].inputValue)

                                if quantity and quantity > 0 then
                                    if pedAmmo >= quantity then
                                        TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_ammo', item, quantity)
                                        ESX.CloseContext()
                                    else
                                        ESX.ShowNotification(TranslateCap('noammo'))
                                    end
                                else
                                    ESX.ShowNotification(TranslateCap('amount_invalid'))
                                end
                            end)
                        else
                            ESX.ShowNotification(TranslateCap('noammo'))
                        end
                    else
                        ESX.ShowNotification(TranslateCap('players_nearby'))
                    end
                else
                    ESX.ShowNotification(TranslateCap('in_vehicle'))
                end
            end
        end)
    end)
end

RegisterNetEvent('esx:showNotification', function(msg, notifyType, length)
    ESX.ShowNotification(msg, notifyType, length)
end)

RegisterNetEvent('esx:showAdvancedNotification', function(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
    ESX.ShowAdvancedNotification(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
end)

RegisterNetEvent('esx:showHelpNotification', function(msg, thisFrame, beep, duration)
    ESX.ShowHelpNotification(msg, thisFrame, beep, duration)
end)

AddEventHandler('onResourceStop', function(resourceName)
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
    [`airtug`] = 'automobile',       -- trailer
    [`avisa`] = 'submarine',         -- boat
    [`blimp`] = 'heli',              -- plane
    [`blimp2`] = 'heli',             -- plane
    [`blimp3`] = 'heli',             -- plane
    [`caddy`] = 'automobile',        -- trailer
    [`caddy2`] = 'automobile',       -- trailer
    [`caddy3`] = 'automobile',       -- trailer
    [`chimera`] = 'automobile',      -- bike
    [`docktug`] = 'automobile',      -- trailer
    [`forklift`] = 'automobile',     -- trailer
    [`kosatka`] = 'submarine',       -- boat
    [`mower`] = 'automobile',        -- trailer
    [`policeb`] = 'bike',            -- automobile
    [`ripley`] = 'automobile',       -- trailer
    [`rrocket`] = 'automobile',      -- bike
    [`sadler`] = 'automobile',       -- trailer
    [`sadler2`] = 'automobile',      -- trailer
    [`scrap`] = 'automobile',        -- trailer
    [`slamtruck`] = 'automobile',    -- trailer
    [`Stryder`] = 'automobile',      -- bike
    [`submersible`] = 'submarine',   -- boat
    [`submersible2`] = 'submarine',  -- boat
    [`thruster`] = 'heli',           -- automobile
    [`towtruck`] = 'automobile',     -- trailer
    [`towtruck2`] = 'automobile',    -- trailer
    [`tractor`] = 'automobile',      -- trailer
    [`tractor2`] = 'automobile',     -- trailer
    [`tractor3`] = 'automobile',     -- trailer
    [`trailersmall2`] = 'trailer',   -- automobile
    [`utillitruck`] = 'automobile',  -- trailer
    [`utillitruck2`] = 'automobile', -- trailer
    [`utillitruck3`] = 'automobile', -- trailer
}

---@param model number|string
---@return string
function ESX.GetVehicleType(model)
    model = type(model) == 'string' and joaat(model) or model

    if not IsModelInCdimage(model) then
        return ''
    end

    if mismatchedTypes[model] then
        return mismatchedTypes[model]
    end

    local vehicleType = GetVehicleClassFromName(model)
    local types = {
        [8] = 'bike',
        [11] = 'trailer',
        [13] = 'bike',
        [14] = 'boat',
        [15] = 'heli',
        [16] = 'plane',
        [21] = 'train',
    }

    return types[vehicleType] or 'automobile'
end
