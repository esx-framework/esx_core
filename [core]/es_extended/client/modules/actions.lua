local isInVehicle, isEnteringVehicle, isJumping, inPauseMenu = false, false, false, false
local playerPed = PlayerPedId()
local current = {}

local function GetPedVehicleSeat(ped, vehicle)
    for i = -1, 16 do
        if GetPedInVehicleSeat(vehicle, i) == ped then
            return i
        end
    end
    return -1
end

local function GetData(vehicle)
    if not DoesEntityExist(vehicle) then
        return
    end
    local model = GetEntityModel(vehicle)
    local displayName = GetDisplayNameFromVehicleModel(model)
    local netId = vehicle
    if NetworkGetEntityIsNetworked(vehicle) then
        netId = VehToNet(vehicle)
    end
    return displayName, netId
end

local function ToggleVehicleStatus(inVehicle, seat)
    ESX.SetPlayerData("vehicle", inVehicle)
    ESX.SetPlayerData("seat", seat)
end

CreateThread(function()
    while not ESX.PlayerLoaded do Wait(200) end
    while true do
        ESX.SetPlayerData("coords", GetEntityCoords(playerPed))
        if playerPed ~= PlayerPedId() then
            playerPed = PlayerPedId()
            ESX.SetPlayerData("ped", playerPed)
            TriggerEvent("esx:playerPedChanged", playerPed)
            TriggerServerEvent("esx:playerPedChanged", PedToNet(playerPed))
            if Config.DisableHealthRegeneration then
                SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
            end
        end

        if IsPedJumping(playerPed) and not isJumping then
            isJumping = true
            TriggerEvent("esx:playerJumping")
            TriggerServerEvent("esx:playerJumping")
        elseif not IsPedJumping(playerPed) and isJumping then
            isJumping = false
        end

        if IsPauseMenuActive() and not inPauseMenu then
            inPauseMenu = true
            TriggerEvent("esx:pauseMenuActive", inPauseMenu)
        elseif not IsPauseMenuActive() and inPauseMenu then
            inPauseMenu = false
            TriggerEvent("esx:pauseMenuActive", inPauseMenu)
        end

        if not isInVehicle and not IsPlayerDead(PlayerId()) then
            if DoesEntityExist(GetVehiclePedIsTryingToEnter(playerPed)) and not isEnteringVehicle then
                -- trying to enter a vehicle!
                local vehicle = GetVehiclePedIsTryingToEnter(playerPed)
                local plate = GetVehicleNumberPlateText(vehicle)
                local seat = GetSeatPedIsTryingToEnter(playerPed)
                local _, netId = GetData(vehicle)
                isEnteringVehicle = true
                TriggerEvent("esx:enteringVehicle", vehicle, plate, seat, netId)
                TriggerServerEvent("esx:enteringVehicle", plate, seat, netId)
                ToggleVehicleStatus(vehicle, seat)
            elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(playerPed)) and not IsPedInAnyVehicle(playerPed, true) and isEnteringVehicle then
                -- vehicle entering aborted
                TriggerEvent("esx:enteringVehicleAborted")
                TriggerServerEvent("esx:enteringVehicleAborted")
                isEnteringVehicle = false
                ToggleVehicleStatus(false, false)
            elseif IsPedInAnyVehicle(playerPed, false) then
                -- suddenly appeared in a vehicle, possible teleport
                isEnteringVehicle = false
                isInVehicle = true
                current.vehicle = GetVehiclePedIsUsing(playerPed)
                current.seat = GetPedVehicleSeat(playerPed, current.vehicle)
                current.plate = GetVehicleNumberPlateText(current.vehicle)
                current.displayName, current.netId = GetData(current.vehicle)
                TriggerEvent("esx:enteredVehicle", current.vehicle, current.plate, current.seat, current.displayName, current.netId)
                TriggerServerEvent("esx:enteredVehicle", current.plate, current.seat, current.displayName, current.netId)
                ToggleVehicleStatus(current.vehicle, current.seat)
            end
        elseif isInVehicle then
            if not IsPedInAnyVehicle(playerPed, false) or IsPlayerDead(PlayerId()) then
                -- bye, vehicle
                TriggerEvent("esx:exitedVehicle", current.vehicle, current.plate, current.seat, current.displayName, current.netId)
                TriggerServerEvent("esx:exitedVehicle", current.plate, current.seat, current.displayName, current.netId)
                isInVehicle = false
                current = {}
                ToggleVehicleStatus(false,false)
            end
        end
        Wait(200)
    end
end)

if Config.EnableDebug then
    AddEventHandler("esx:playerPedChanged", function(netId)
        print("esx:playerPedChanged", netId)
    end)

    AddEventHandler("esx:playerJumping", function()
        print("esx:playerJumping")
    end)

    AddEventHandler("esx:enteringVehicle", function(vehicle, plate, seat, netId)
        print("esx:enteringVehicle", "vehicle", vehicle, "plate", plate, "seat", seat, "netId", netId)
    end)

    AddEventHandler("esx:enteringVehicleAborted", function()
        print("esx:enteringVehicleAborted")
    end)

    AddEventHandler("esx:enteredVehicle", function(vehicle, plate, seat, displayName, netId)
        print("esx:enteredVehicle", "vehicle", vehicle, "plate", plate, "seat", seat, "displayName", displayName, "netId", netId)
    end)

    AddEventHandler("esx:exitedVehicle", function(vehicle, plate, seat, displayName, netId)
        print("esx:exitedVehicle", "vehicle", vehicle, "plate", plate, "seat", seat, "displayName", displayName, "netId", netId)
    end)
end
