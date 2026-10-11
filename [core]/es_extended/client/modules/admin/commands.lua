-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

RegisterNetEvent("esx:killPlayer", function()
    SetEntityHealth(ESX.PlayerData.ped, 0)
end)

RegisterNetEvent("esx:repairPedVehicle", function()
    local ped = ESX.PlayerData.ped

    if not ped or ped == 0 or not DoesEntityExist(ped) then
        return
    end

    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end

    SetVehicleEngineHealth(vehicle, 1000)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleFixed(vehicle)
    SetVehicleDirtLevel(vehicle, 0)
end)

RegisterNetEvent("esx:freezePlayer", function(input)
    if input == "freeze" then
        SetEntityCollision(ESX.PlayerData.ped, false, false)
        FreezeEntityPosition(ESX.PlayerData.ped, true)
        SetPlayerInvincible(ESX.playerId, true)
    elseif input == "unfreeze" then
        SetEntityCollision(ESX.PlayerData.ped, true, true)
        FreezeEntityPosition(ESX.PlayerData.ped, false)
        SetPlayerInvincible(ESX.playerId, false)
    end
end)

---@param command string
ESX.SecureNetEvent("esx:executeCommand", function(command)
    if type(command) ~= "string" or not command:find("%S") then
        return
    end

    ExecuteCommand(command)
end)
