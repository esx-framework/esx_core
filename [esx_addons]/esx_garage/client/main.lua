local LastGarage, LastPart, thisGarage  = nil, nil, nil
local next                              = next
local nearMarker, menuIsShowed          = false, false
local vehiclesList                      = {}

RegisterNetEvent('esx_garage:closemenu')
AddEventHandler('esx_garage:closemenu', function()
    menuIsShowed = false
    vehiclesList = {}

    SetNuiFocus(false)
    SendNUIMessage({hideAll = true})

    if not menuIsShowed and thisGarage then ESX.TextUI(_U('access_parking')) end
end)

RegisterNUICallback('escape', function(data, cb)
    TriggerEvent('esx_garage:closemenu')
    cb('ok')
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    local spawnCoords = {
        x = data.spawnPoint.x,
        y = data.spawnPoint.y,
        z = data.spawnPoint.z
    }

    if ESX.Game.IsSpawnPointClear(spawnCoords, 2.5) then
        ESX.Game.SpawnVehicle(data.vehicleProps.model, spawnCoords,
                              data.spawnPoint.heading, function(vehicle)
            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
            ESX.Game.SetVehicleProperties(vehicle, data.vehicleProps)
            SetVehicleEngineOn(vehicle, (not GetIsVehicleEngineRunning(vehicle)), true, true)
        end)

        thisGarage = nil

        TriggerServerEvent('esx_garage:updateOwnedVehicle', false, nil, data.vehicleProps)
        TriggerEvent('esx_garage:closemenu')
        
    else
        ESX.ShowNotification(_U('veh_block'), 'error')
    end
    cb('ok')
end)

-- Create Blips
CreateThread(function()
    for k, v in pairs(Config.Garages) do
        local blip = AddBlipForCoord(v.EntryPoint.x, v.EntryPoint.y, v.EntryPoint.z)

        SetBlipSprite(blip, Config.Blips.Sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.Blips.Scale)
        SetBlipColour(blip, Config.Blips.Colour)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(_U('blip_name'))
        EndTextCommandSetBlipName(blip)
    end
end)

AddEventHandler('esx_garage:hasEnteredMarker', function(name, part)
    if part == 'EntryPoint' then
        local garage = Config.Garages[name]
        thisGarage              = garage

        ESX.TextUI(_U('access_parking'))
    end

    if part == 'StorePoint' then
        local garage = Config.Garages[name]
        thisGarage              = garage

        local isInVehicle = IsPedInAnyVehicle(PlayerPedId(), false)

        if isInVehicle then ESX.TextUI(_U('park_veh')) end
    end
end)

AddEventHandler('esx_garage:hasExitedMarker', function()
    thisGarage                  = nil
    ESX.HideUI()
    TriggerEvent('esx_garage:closemenu')
end)

-- Display markers
CreateThread(function()
    while true do
        local sleep             = 500

        local playerPed         = PlayerPedId()
        local coords            = GetEntityCoords(playerPed)
        local inVehicle         = IsPedInAnyVehicle(playerPed, false)

        for k, v in pairs(Config.Garages) do
            if (#(coords - vector3(v.EntryPoint.x, v.EntryPoint.y, v.EntryPoint.z)) < Config.DrawDistance) then
                DrawMarker(Config.Markers.EntryPoint.Type, v.EntryPoint.x, v.EntryPoint.y, v.EntryPoint.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Markers.EntryPoint.Size.x, Config.Markers.EntryPoint.Size.y, Config.Markers.EntryPoint.Size.z, Config.Markers.EntryPoint.Color.r, Config.Markers.EntryPoint.Color.g, Config.Markers.EntryPoint.Color.b, 100, false, true, 2, false, false, false, false)
                sleep           = 0
                break
            end
            if IsPedInAnyVehicle(playerPed, true) then
            if (#(coords -
                vector3(v.StorePoint.x, v.StorePoint.y, v.StorePoint.z)) < Config.DrawDistance) then
                DrawMarker(Config.Markers.StorePoint.Type, v.StorePoint.x, v.StorePoint.y, v.StorePoint.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Markers.StorePoint.Size.x, Config.Markers.StorePoint.Size.y, Config.Markers.StorePoint.Size.z, Config.Markers.StorePoint.Color.r, Config.Markers.StorePoint.Color.g, Config.Markers.StorePoint.Color.b, 100, false, true, 2, false, false, false, false)
                sleep           = 0
                end
            end
        end

        if sleep == 0 then
            nearMarker          = true
        else
            nearMarker          = false
        end
        Wait(sleep)
    end
end)

-- Enter / Exit marker events
CreateThread(function()
    while true do
        if nearMarker then
            local playerPed         = PlayerPedId()
            local coords            = GetEntityCoords(playerPed)
            local isInMarker        = false
            local currentGarage     = nil
            local currentPart       = nil

            for k, v in pairs(Config.Garages) do
                if (#(coords - vector3(v.EntryPoint.x, v.EntryPoint.y, v.EntryPoint.z)) < Config.Markers.EntryPoint.Size.x) then
                    isInMarker = true
                    currentGarage = k
                    currentPart = 'EntryPoint'

                    if IsControlJustReleased(0, 38) and not menuIsShowed then
                        ESX.TriggerServerCallback('esx_garage:getVehiclesInParking',
                            function(vehicles)
                                if next(vehicles) ~= nil then
                                    menuIsShowed        = true

                                    -- vehicles[i].vehicle.bodyHealth
                                    -- vehicles[i].vehicle.engineHealth
                                    -- vehicles[i].vehicle.tankHealth

                                    for i = 1, #vehicles, 1 do
                                        table.insert(vehiclesList, {
                                            model       = GetDisplayNameFromVehicleModel(vehicles[i].vehicle.model),
                                            plate       = vehicles[i].plate,
                                            damage      = vehicles[i].damage,
                                            props       = vehicles[i].vehicle
                                        })

                                    end

                                    local spawnPoint = {
                                        x               = v.SpawnPoint.x,
                                        y               = v.SpawnPoint.y,
                                        z               = v.SpawnPoint.z,
                                        heading         = v.SpawnPoint.heading
                                    }

                                    SendNUIMessage({
                                        showMenu = true,
                                        vehiclesList = {
                                            json.encode(vehiclesList)
                                        },
                                        spawnPoint          = spawnPoint,
                                        locales = {
                                            action          = _U('veh_exit'),
                                            veh_model       = _U('veh_model'),
                                            veh_plate       = _U('veh_plate'),
                                            veh_condition   = _U('veh_condition'),
                                            veh_action      = _U('veh_action')
                                        }
                                    })

                                    SetNuiFocus(true, true)

                                    if menuIsShowed then
                                        ESX.HideUI()
                                    end
                                else
                                    ESX.ShowNotification(_U('no_veh_parking'))
                                end
                            end, currentGarage)
                    end
                    break
                end

                if (#(coords -
                    vector3(v.StorePoint.x, v.StorePoint.y, v.StorePoint.z)) < Config.Markers.StorePoint.Size.x) then
                    isInMarker          = true
                    currentGarage       = k
                    currentPart         = 'StorePoint'
                    local isInVehicle   = IsPedInAnyVehicle(playerPed, false)

                    if isInVehicle then
                        if IsControlJustReleased(0, 38) then
                            local vehicle = GetVehiclePedIsIn(playerPed, false)
                            local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
                            
                            ESX.TriggerServerCallback('esx_garage:checkVehicleOwner', function(owner)
                                if owner then
                                    ESX.Game.DeleteVehicle(vehicle)
                                    TriggerServerEvent('esx_garage:updateOwnedVehicle', true, currentGarage, vehicleProps)
                                else
                                    ESX.ShowNotification(_U('not_owning_veh'), 'error')
                                end
                            end, vehicleProps.plate)
                        end
                    end
                end
            end

            if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastGarage ~= currentGarage or LastPart ~= currentPart)) then
                if LastGarage ~= currentGarage or LastPart ~= currentPart then
                    TriggerEvent('esx_garage:hasExitedMarker', LastGarage,
                                 LastPart)
                end

                HasAlreadyEnteredMarker = true
                LastGarage = currentGarage
                LastPart = currentPart

                TriggerEvent('esx_garage:hasEnteredMarker', currentGarage, currentPart)
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
