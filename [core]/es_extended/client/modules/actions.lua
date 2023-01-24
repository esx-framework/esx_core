local isInVehicle, isEnteringVehicle, isJumping = false, false, false
local currentVehicle, currentSeat = 0, 0
local playerPed = PlayerPedId()

local function GetPedVehicleSeat(ped, vehicle)
    for i = -1, 16 do
        if (GetPedInVehicleSeat(vehicle, i) == ped) then return i end
    end
    return -1
end

local function GetData(vehicle)
    local model = GetEntityModel(currentVehicle)
    local displayName = GetDisplayNameFromVehicleModel(model)
    local netId = VehToNet(vehicle)
    return displayName, netId
end

CreateThread(function()
    while true do

        if playerPed ~= PlayerPedId() then
            playerPed = PlayerPedId()
            TriggerEvent('esx:playerPedChanged', playerPed)
            TriggerServerEvent('esx:playerPedChanged', PedToNet(playerPed))
        end

        if IsPedJumping(playerPed) and not isJumping then
            isJumping = true
            TriggerEvent('esx:playerJumping')
            TriggerServerEvent('esx:playerJumping')
        elseif not IsPedJumping(playerPed) and isJumping then
            isJumping = false
        end

        if not isInVehicle and not IsPlayerDead(PlayerId()) then
            if DoesEntityExist(GetVehiclePedIsTryingToEnter(playerPed)) and not isEnteringVehicle then
                -- trying to enter a vehicle!
                local vehicle = GetVehiclePedIsTryingToEnter(playerPed)
                local seat = GetSeatPedIsTryingToEnter(playerPed)
                local displayName, netId = GetData(vehicle)
                isEnteringVehicle = true
                TriggerEvent('esx:playerEnteringVehicle', vehicle, seat, netId)
                TriggerServerEvent('esx:playerEnteringVehicle', vehicle, seat, netId)
            elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(playerPed)) and
                not IsPedInAnyVehicle(playerPed, true) and isEnteringVehicle then
                -- vehicle entering aborted
                TriggerEvent('esx:playerEnteringVehicleAborted')
                TriggerServerEvent('esx:playerEnteringVehicleAborted')
                isEnteringVehicle = false
            elseif IsPedInAnyVehicle(playerPed, false) then
                -- suddenly appeared in a vehicle, possible teleport
                isEnteringVehicle = false
                isInVehicle = true
                currentVehicle = GetVehiclePedIsUsing(playerPed)
                currentSeat = GetPedVehicleSeat(playerPed, currentVehicle)
                local displayName, netId = GetData(currentVehicle)
                TriggerEvent('esx:playerEnteredVehicle', currentVehicle, currentSeat, displayName, netId)
                TriggerServerEvent('esx:playerEnteredVehicle', currentVehicle, currentSeat, displayName, netId)
            end
        elseif isInVehicle then
            if not IsPedInAnyVehicle(playerPed, false) or IsPlayerDead(PlayerId()) then
                -- bye, vehicle
                local displayName, netId = GetData(currentVehicle)
                TriggerEvent('esx:playerExitedVehicle', currentVehicle, currentSeat, displayName, netId)
                TriggerServerEvent('esx:playerExitedVehicle', currentVehicle, currentSeat, displayName, netId)
                isInVehicle = false
                currentVehicle = 0
                currentSeat = 0
            end
        end
        Wait(200)
    end
end)

if Config.EnableDebug then

    AddEventHandler('esx:playerPedChanged', function(netId)
        print('esx:playerPedChanged', netId)
    end)

    AddEventHandler('esx:playerJumping', function()
        print('esx:playerJumping')
    end)

    AddEventHandler('esx:playerEnteringVehicle', function(vehicle, seat, netId)
        print('esx:playerEnteringVehicle', 'vehicle', vehicle, 'seat', seat, 'netId', netId)
    end)

    AddEventHandler('esx:playerEnteringVehicleAborted', function()
        print('esx:playerEnteringVehicleAborted')
    end)

    AddEventHandler('esx:playerEnteredVehicle', function(vehicle, seat, displayName, netId)
        print('esx:playerEnteredVehicle', 'vehicle', vehicle, 'seat', seat, 'displayName', displayName, 'netId', netId)
    end)

    AddEventHandler('esx:playerExitedVehicle', function(vehicle, seat, displayName, netId)
        print('esx:playerExitedVehicle', 'vehicle', vehicle, 'seat', seat, 'displayName', displayName, 'netId', netId)
    end)

end