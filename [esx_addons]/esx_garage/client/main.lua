local LastMarker, LastPart, thisGarage, thisPound = nil, nil, nil, nil
local next = next
local nearMarker, menuIsShowed = false, false
local vehiclesList, vehiclesImpoundedList = {}, {}

RegisterNetEvent('esx_garage:closemenu')
AddEventHandler('esx_garage:closemenu', function()
    menuIsShowed = false
    vehiclesList, vehiclesImpoundedList = {}, {}

    SetNuiFocus(false)
    SendNUIMessage({
        hideAll = true
    })

    if not menuIsShowed and thisGarage then
        ESX.TextUI(TranslateCap('access_parking'))
    end
    if not menuIsShowed and thisPound then
        ESX.TextUI(TranslateCap('access_Impound'))
    end
end)

RegisterNUICallback('escape', function(data, cb)
    TriggerEvent('esx_garage:closemenu')
    cb('ok')
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    local spawnCoords = vector3(data.spawnPoint.x, data.spawnPoint.y, data.spawnPoint.z)
    if thisGarage then

        if ESX.Game.IsSpawnPointClear(spawnCoords, 2.5) then
            thisGarage = nil
            TriggerServerEvent('esx_garage:updateOwnedVehicle', false, nil, nil, data, spawnCoords)
            TriggerEvent('esx_garage:closemenu')

            ESX.ShowNotification(TranslateCap('veh_released'))

        else
            ESX.ShowNotification(TranslateCap('veh_block'), 'error')
        end

    elseif thisPound then

        ESX.TriggerServerCallback('esx_garage:checkMoney', function(hasMoney)
            if hasMoney then
                if ESX.Game.IsSpawnPointClear(spawnCoords, 2.5) then
                    TriggerServerEvent('esx_garage:payPound', data.exitVehicleCost)
                    thisPound = nil

                    TriggerServerEvent('esx_garage:updateOwnedVehicle', false, nil, nil, data, spawnCoords)
                    TriggerEvent('esx_garage:closemenu')

                else
                    ESX.ShowNotification(TranslateCap('veh_block'), 'error')
                end
            else
                ESX.ShowNotification(TranslateCap('missing_money'))
            end
        end, data.exitVehicleCost)

    end

    cb('ok')
end)

RegisterNUICallback('impound', function(data, cb)
    local poundCoords = {
        x = data.poundSpawnPoint.x,
        y = data.poundSpawnPoint.y
    }

    TriggerServerEvent('esx_garage:setImpound', data.poundName, data.vehicleProps)
    TriggerEvent('esx_garage:closemenu')

    SetNewWaypoint(poundCoords.x, poundCoords.y)

    cb('ok')
end)

-- Create Blips
CreateThread(function()
    for k, v in pairs(Config.Garages) do
        local blip = AddBlipForCoord(v.EntryPoint.x, v.EntryPoint.y, v.EntryPoint.z)

        SetBlipSprite(blip, v.Sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, v.Scale)
        SetBlipColour(blip, v.Colour)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(TranslateCap('parking_blip_name'))
        EndTextCommandSetBlipName(blip)
    end

    for k, v in pairs(Config.Impounds) do
        local blip = AddBlipForCoord(v.GetOutPoint.x, v.GetOutPoint.y, v.GetOutPoint.z)

        SetBlipSprite(blip, v.Sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, v.Scale)
        SetBlipColour(blip, v.Colour)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(TranslateCap('Impound_blip_name'))
        EndTextCommandSetBlipName(blip)
    end
end)

AddEventHandler('esx_garage:hasEnteredMarker', function(name, part)
    if part == 'EntryPoint' then
        local isInVehicle = IsPedInAnyVehicle(ESX.PlayerData.ped, false)
        local garage = Config.Garages[name]
        thisGarage = garage

        if isInVehicle then
            ESX.TextUI(TranslateCap('park_veh'))
        else
            ESX.TextUI(TranslateCap('access_parking'))
        end
    end

    if part == 'GetOutPoint' then
        local pound = Config.Impounds[name]
        thisPound = pound

        ESX.TextUI(TranslateCap('access_Impound'))
    end
end)

AddEventHandler('esx_garage:hasExitedMarker', function()
    thisGarage = nil
    thisPound = nil
    ESX.HideUI()
    TriggerEvent('esx_garage:closemenu')
end)

-- Display markers
CreateThread(function()
    while true do
        local sleep = 500

        local playerPed = ESX.PlayerData.ped
        local coords = GetEntityCoords(playerPed)
        local inVehicle = IsPedInAnyVehicle(playerPed, false)

        -- parking
        for k, v in pairs(Config.Garages) do
            if (#(coords - vector3(v.EntryPoint.x, v.EntryPoint.y, v.EntryPoint.z)) < Config.DrawDistance) then
                DrawMarker(Config.Markers.EntryPoint.Type, v.EntryPoint.x, v.EntryPoint.y, v.EntryPoint.z, 0.0, 0.0,
                    0.0, 0, 0.0, 0.0, Config.Markers.EntryPoint.Size.x, Config.Markers.EntryPoint.Size.y,
                    Config.Markers.EntryPoint.Size.z, Config.Markers.EntryPoint.Color.r,
                    Config.Markers.EntryPoint.Color.g, Config.Markers.EntryPoint.Color.b, 100, false, true, 2, false,
                    false, false, false)
                sleep = 0
                break
            end
        end

        -- Impound
        for k, v in pairs(Config.Impounds) do
            if (#(coords - vector3(v.GetOutPoint.x, v.GetOutPoint.y, v.GetOutPoint.z)) < Config.DrawDistance) then
                DrawMarker(Config.Markers.GetOutPoint.Type, v.GetOutPoint.x, v.GetOutPoint.y, v.GetOutPoint.z, 0.0, 0.0,
                    0.0, 0, 0.0, 0.0, Config.Markers.GetOutPoint.Size.x, Config.Markers.GetOutPoint.Size.y,
                    Config.Markers.GetOutPoint.Size.z, Config.Markers.GetOutPoint.Color.r,
                    Config.Markers.GetOutPoint.Color.g, Config.Markers.GetOutPoint.Color.b, 100, false, true, 2, false,
                    false, false, false)
                sleep = 0
                break
            end
        end

        if sleep == 0 then
            nearMarker = true
        else
            nearMarker = false
        end

        Wait(sleep)
    end
end)

-- Enter / Exit marker events (parking)
CreateThread(function()
    while true do
        if nearMarker then
            local playerPed = ESX.PlayerData.ped
            local coords = GetEntityCoords(playerPed)
            local isInMarker = false
            local currentMarker = nil
            local currentPart = nil

            for k, v in pairs(Config.Garages) do
                if (#(coords - vector3(v.EntryPoint.x, v.EntryPoint.y, v.EntryPoint.z)) <
                    Config.Markers.EntryPoint.Size.x) then
                    isInMarker = true
                    currentMarker = k
                    currentPart = 'EntryPoint'
                    local isInVehicle = IsPedInAnyVehicle(playerPed, false)

                    if not isInVehicle then
                        if IsControlJustReleased(0, 38) and not menuIsShowed then
                            ESX.TriggerServerCallback('esx_garage:getVehiclesInParking', function(vehicles)
                                if next(vehicles) then
                                    menuIsShowed = true

                                    for i = 1, #vehicles, 1 do
                                        table.insert(vehiclesList, {
                                            model = GetDisplayNameFromVehicleModel(vehicles[i].vehicle.model),
                                            plate = vehicles[i].plate,
                                            props = vehicles[i].vehicle
                                        })

                                    end

                                    local spawnPoint = {
                                        x = v.SpawnPoint.x,
                                        y = v.SpawnPoint.y,
                                        z = v.SpawnPoint.z,
                                        heading = v.SpawnPoint.heading
                                    }

                                    ESX.TriggerServerCallback('esx_garage:getVehiclesImpounded', function(vehicles)
                                        if next(vehicles) then

                                            for i = 1, #vehicles, 1 do
                                                table.insert(vehiclesImpoundedList, {
                                                    model = GetDisplayNameFromVehicleModel(vehicles[i].vehicle.model),
                                                    plate = vehicles[i].plate,
                                                    props = vehicles[i].vehicle
                                                })
                                            end

                                            local poundSpawnPoint = {
                                                x = Config.Impounds[v.ImpoundedName].GetOutPoint.x,
                                                y = Config.Impounds[v.ImpoundedName].GetOutPoint.y
                                            }

                                            SendNUIMessage({
                                                showMenu = true,
                                                type = 'garage',
                                                vehiclesList = {json.encode(vehiclesList)},
                                                vehiclesImpoundedList = {json.encode(vehiclesImpoundedList)},
                                                poundName = v.ImpoundedName,
                                                poundSpawnPoint = poundSpawnPoint,
                                                spawnPoint = spawnPoint,
                                                locales = {
                                                    action = TranslateCap('veh_exit'),
                                                    veh_model = TranslateCap('veh_model'),
                                                    veh_plate = TranslateCap('veh_plate'),
                                                    veh_condition = TranslateCap('veh_condition'),
                                                    veh_action = TranslateCap('veh_action'),
                                                    impound_action = TranslateCap('impound_action')
                                                }
                                            })
                                        else
                                            SendNUIMessage({
                                                showMenu = true,
                                                type = 'garage',
                                                vehiclesList = {json.encode(vehiclesList)},
                                                spawnPoint = spawnPoint,
                                                locales = {
                                                    action = TranslateCap('veh_exit'),
                                                    veh_model = TranslateCap('veh_model'),
                                                    veh_plate = TranslateCap('veh_plate'),
                                                    veh_condition = TranslateCap('veh_condition'),
                                                    veh_action = TranslateCap('veh_action'),
                                                    no_veh_impounded = TranslateCap('no_veh_impounded')
                                                }
                                            })
                                        end
                                    end)

                                    SetNuiFocus(true, true)

                                    if menuIsShowed then
                                        ESX.HideUI()
                                    end
                                else
                                    menuIsShowed = true

                                    ESX.TriggerServerCallback('esx_garage:getVehiclesImpounded', function(vehicles)
                                        if next(vehicles) then

                                            for i = 1, #vehicles, 1 do
                                                table.insert(vehiclesImpoundedList, {
                                                    model = GetDisplayNameFromVehicleModel(vehicles[i].vehicle.model),
                                                    plate = vehicles[i].plate,
                                                    props = vehicles[i].vehicle
                                                })
                                            end

                                            local poundSpawnPoint = {
                                                x = Config.Impounds[v.ImpoundedName].GetOutPoint.x,
                                                y = Config.Impounds[v.ImpoundedName].GetOutPoint.y
                                            }

                                            SendNUIMessage({
                                                showMenu = true,
                                                type = 'garage',
                                                vehiclesImpoundedList = {json.encode(vehiclesImpoundedList)},
                                                poundName = v.ImpoundedName,
                                                poundSpawnPoint = poundSpawnPoint,
                                                locales = {
                                                    action = TranslateCap('veh_exit'),
                                                    veh_model = TranslateCap('veh_model'),
                                                    veh_plate = TranslateCap('veh_plate'),
                                                    veh_condition = TranslateCap('veh_condition'),
                                                    veh_action = TranslateCap('veh_action'),
                                                    no_veh_parking = TranslateCap('no_veh_parking'),
                                                    no_veh_impounded = TranslateCap('no_veh_impounded'),
                                                    impound_action = TranslateCap('impound_action')
                                                }
                                            })
                                        else
                                            SendNUIMessage({
                                                showMenu = true,
                                                type = 'garage',
                                                locales = {
                                                    action = TranslateCap('veh_exit'),
                                                    veh_model = TranslateCap('veh_model'),
                                                    veh_plate = TranslateCap('veh_plate'),
                                                    veh_condition = TranslateCap('veh_condition'),
                                                    veh_action = TranslateCap('veh_action'),
                                                    no_veh_parking = TranslateCap('no_veh_parking')
                                                }
                                            })
                                        end
                                    end)

                                    SetNuiFocus(true, true)

                                    if menuIsShowed then
                                        ESX.HideUI()
                                    end
                                end
                            end, currentMarker)
                        end
                    end

                    if isInVehicle then
                        if IsControlJustReleased(0, 38) then
                            local vehicle = GetVehiclePedIsIn(playerPed, false)
                            local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
                            ESX.TriggerServerCallback('esx_garage:checkVehicleOwner', function(owner)
                                if owner then
                                    ESX.Game.DeleteVehicle(vehicle)
                                    TriggerServerEvent('esx_garage:updateOwnedVehicle', true, currentMarker, nil,
                                        {vehicleProps = vehicleProps})
                                else
                                    ESX.ShowNotification(TranslateCap('not_owning_veh'), 'error')
                                end
                            end, vehicleProps.plate)
                        end
                    end
                    break
                end
            end

            for k, v in pairs(Config.Impounds) do

                if (#(coords - vector3(v.GetOutPoint.x, v.GetOutPoint.y, v.GetOutPoint.z)) < 2.0) then
                    isInMarker = true
                    currentMarker = k
                    currentPart = 'GetOutPoint'

                    if IsControlJustReleased(0, 38) and not menuIsShowed then
                        ESX.TriggerServerCallback('esx_garage:getVehiclesInPound', function(vehicles)
                            if next(vehicles) then
                                menuIsShowed = true

                                for i = 1, #vehicles, 1 do
                                    table.insert(vehiclesList, {
                                        model = GetDisplayNameFromVehicleModel(vehicles[i].vehicle.model),
                                        plate = vehicles[i].plate,
                                        props = vehicles[i].vehicle
                                    })
                                end

                                local spawnPoint = {
                                    x = v.SpawnPoint.x,
                                    y = v.SpawnPoint.y,
                                    z = v.SpawnPoint.z,
                                    heading = v.SpawnPoint.heading
                                }

                                SendNUIMessage({
                                    showMenu = true,
                                    type = 'impound',
                                    vehiclesList = {json.encode(vehiclesList)},
                                    spawnPoint = spawnPoint,
                                    poundCost = v.Cost,
                                    locales = {
                                        action = TranslateCap('pay_impound'),
                                        veh_model = TranslateCap('veh_model'),
                                        veh_plate = TranslateCap('veh_plate'),
                                        veh_condition = TranslateCap('veh_condition'),
                                        veh_action = TranslateCap('veh_action')
                                    }
                                })

                                SetNuiFocus(true, true)

                                if menuIsShowed then
                                    ESX.HideUI()
                                end
                            else
                                ESX.ShowNotification(TranslateCap('no_veh_Impound'))
                            end
                        end, currentMarker)
                    end
                    break
                end
            end

            if isInMarker and not HasAlreadyEnteredMarker or
                (isInMarker and (LastMarker ~= currentMarker or LastPart ~= currentPart)) then

                if LastMarker ~= currentMarker or LastPart ~= currentPart then
                    TriggerEvent('esx_garage:hasExitedMarker')
                end

                HasAlreadyEnteredMarker = true
                LastMarker = currentMarker
                LastPart = currentPart

                TriggerEvent('esx_garage:hasEnteredMarker', currentMarker, currentPart)
            end

            if not isInMarker and HasAlreadyEnteredMarker then
                HasAlreadyEnteredMarker = false

                TriggerEvent('esx_garage:hasExitedMarker')
            end

            Wait(0)
        else
            Wait(500)
        end
    end
end)
