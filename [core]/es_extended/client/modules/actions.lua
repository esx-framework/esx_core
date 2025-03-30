Actions = {}
Actions._index = Actions

Actions.inPauseMenu = false

function Actions:TrackPauseMenu()
    local isActive = IsPauseMenuActive()

    if isActive ~= self.inPauseMenu then
        self.inPauseMenu = isActive
        TriggerEvent("esx:pauseMenuActive", isActive)

        if Config.EnableDebug then
            print("[DEBUG] Pause menu active:", isActive)
        end
    end
end

lib.onCache("ped", function(newPed)
    TriggerEvent("esx:playerPedChanged", newPed)
end)

lib.onCache("vehicle", function(newVeh)
    local veh = newVeh and newVeh or cache.vehicle
    local plate = GetVehicleNumberPlateText(veh)
    local displayName = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
    local netId = NetworkGetNetworkIdFromEntity(veh)

    if not newVeh then
        TriggerEvent("esx:exitedVehicle", veh, plate, cache.seat, displayName, netId)
        TriggerServerEvent("esx:exitedVehicle", plate, cache.seat, displayName, netId)

        if Config.EnableDebug then
            print("[DEBUG] Exited vehicle:", veh, plate, cache.seat, displayName, netId)
        end

        return
    end

    TriggerEvent("esx:enteredVehicle", veh, plate, cache.seat, displayName, netId)
    TriggerServerEvent("esx:enteredVehicle", plate, cache.seat, displayName, netId)
    TriggerEvent("esx:enteringVehicle", veh, plate, cache.seat, netId)
    TriggerServerEvent("esx:enteringVehicle", plate, cache.seat, netId)
end)

lib.onCache("seat", function(newSeat)
    TriggerEvent("esx:vehicleSeatChanged", newSeat)
end)

lib.onCache("weapon", function(newWeapon)
    TriggerEvent("esx:weaponChanged", newWeapon)
end)

function Actions:SlowLoop()
    CreateThread(function()
        while ESX.PlayerLoaded do
            self:TrackPauseMenu()
            Wait(500)
        end
    end)
end

function Actions:Init()
    self:SlowLoop()
end

Actions:Init()
