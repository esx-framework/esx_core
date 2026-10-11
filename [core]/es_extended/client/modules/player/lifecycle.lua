-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

RegisterNetEvent("esx:requestModel", function(model)
    xLib.streaming.requestModel(model)
end)

RegisterNetEvent("esx:playerLoaded", function(xPlayer, _, skin)
    ESX.PlayerData = xPlayer

    if not Config.Multichar then
        ESX.SpawnPlayer(skin, ESX.PlayerData.coords, function()
            TriggerEvent("esx:onPlayerSpawn")
            TriggerEvent("esx:restoreLoadout")
            TriggerServerEvent("esx:onPlayerSpawn")
            TriggerEvent("esx:loadingScreenOff")
            ShutdownLoadingScreen()
            ShutdownLoadingScreenNui()
        end)
    end

    while not DoesEntityExist(ESX.PlayerData.ped) do
        Wait(20)
    end

    ESX.PlayerLoaded = true

    local timer = GetGameTimer()
    while not HaveAllStreamingRequestsCompleted(ESX.PlayerData.ped) and (GetGameTimer() - timer) < 2000 do
        Wait(0)
    end

    Adjustments:Load()
    ClearPedTasksImmediately(ESX.PlayerData.ped)

    if not Config.Multichar then
        Core.FreezePlayer(false)
        if IsScreenFadedOut() then
            DoScreenFadeIn(500)
        end
    end

    Actions:Init()
    xLib.points.startLoop()
    StartServerSyncLoops()
    NetworkSetLocalPlayerSyncLookAt(true)
end)

local isFirstSpawn = true

ESX.SecureNetEvent("esx:onPlayerLogout", function()
    ESX.PlayerLoaded = false
    isFirstSpawn = true
end)

ESX.SecureNetEvent("esx:setMaxWeight", function(newMaxWeight)
    ESX.SetPlayerData("maxWeight", newMaxWeight)
end)

ESX.SecureNetEvent("esx:setInventory", function(newInventory)
    ESX.SetPlayerData("inventory", newInventory)
end)

local function onPlayerSpawn()
    ESX.SetPlayerData("ped", PlayerPedId())
    ESX.SetPlayerData("dead", false)
end

AddEventHandler("playerSpawned", onPlayerSpawn)
AddEventHandler("esx:onPlayerSpawn", function()
    onPlayerSpawn()

    if isFirstSpawn then
        isFirstSpawn = false

        if ESX.PlayerData.metadata.health and (ESX.PlayerData.metadata.health > 0 or Config.SaveDeathStatus) then
            SetEntityHealth(ESX.PlayerData.ped, ESX.PlayerData.metadata.health)
        end

        if ESX.PlayerData.metadata.armor and ESX.PlayerData.metadata.armor > 0 then
            SetPedArmour(ESX.PlayerData.ped, ESX.PlayerData.metadata.armor)
        end
    end
end)

AddEventHandler("esx:onPlayerDeath", function()
    ESX.SetPlayerData("ped", PlayerPedId())
    ESX.SetPlayerData("dead", true)
end)

AddEventHandler("skinchanger:modelLoaded", function()
    while not ESX.PlayerLoaded do
        Wait(100)
    end

    TriggerEvent("esx:restoreLoadout")
end)

ESX.SecureNetEvent("esx:setAccountMoney", function(account)
    for i = 1, #ESX.PlayerData.accounts do
        if ESX.PlayerData.accounts[i].name == account.name then
            ESX.PlayerData.accounts[i] = account
            break
        end
    end

    ESX.SetPlayerData("accounts", ESX.PlayerData.accounts)
end)

ESX.SecureNetEvent("esx:setJob", function(Job)
    ESX.SetPlayerData("job", Job)
end)

ESX.SecureNetEvent("esx:jobDataRefreshed", function(Job)
    ESX.SetPlayerData("job", Job)
end)

ESX.SecureNetEvent("esx:setGroup", function(group)
    ESX.SetPlayerData("group", group)
end)

ESX.SecureNetEvent("esx:registerSuggestions", function(registeredCommands)
    for name, command in pairs(registeredCommands) do
        if command.suggestion then
            TriggerEvent("chat:addSuggestion", ("/%s"):format(name), command.suggestion.help, command.suggestion.arguments)
        end
    end
end)

ESX.SecureNetEvent("esx:updatePlayerData", function(key, val)
    ESX.SetPlayerData(key, val)
end)
