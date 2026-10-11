-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

ESX.Players = {}
ESX.Jobs = {}
ESX.Items = {}

RegisterNetEvent("esx:onPlayerSpawn", function()
    local xPlayer = ESX.Players[source]

    if xPlayer then
        xPlayer.spawned = true
    end
end)

if Config.CustomInventory then
    SetConvarReplicated("inventory:framework", "esx")
    SetConvarReplicated("inventory:weight", tostring(Config.MaxWeight * 1000))
end

local function StartDBSync()
    CreateThread(function()
        local interval <const> = 10 * 60 * 1000
        while true do
            Wait(interval)
            Core.SavePlayers()
        end
    end)
end

MySQL.ready(function()
    ESXCatalog.awaitReady()

    Core.DatabaseConnected = true

    if not Config.CustomInventory then
        ESX.RefreshItems()
    end

    ESX.RefreshJobs()

    print(("[^2INFO^7] ESX ^5Legacy %s^0 initialized!"):format(GetResourceMetadata(GetCurrentResourceName(), "version", 0)))

    StartDBSync()
    if Config.EnablePaycheck then
        StartPayCheck()
    end
end)

GlobalState.playerCount = 0
