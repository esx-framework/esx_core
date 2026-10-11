-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local CommandPermissions = Core.CommandPermissions
local FilterGroups = Core.FilterCommandGroups
local upgrades = Config.SpawnVehMaxUpgrades and {
    plate = "ADMINCAR",
    modEngine = 3,
    modBrakes = 2,
    modTransmission = 2,
    modSuspension = 3,
    modArmor = true,
    windowTint = 1,
} or {}

ESX.RegisterCommand(
    "car",
    FilterGroups(CommandPermissions.car, "car"),
    function(xPlayer, args, showError)
        if not xPlayer then
            return showError("[^1ERROR^7] The xPlayer value is nil")
        end

        local playerPed = GetPlayerPed(xPlayer.source)
        local playerCoords = GetEntityCoords(playerPed)
        local playerHeading = GetEntityHeading(playerPed)
        local playerVehicle = GetVehiclePedIsIn(playerPed, false)

        if not args.car or type(args.car) ~= "string" then
            args.car = "adder"
        end

        if playerVehicle then
            DeleteEntity(playerVehicle)
        end

        if Config.AdminLogging then
            ESX.DiscordLogFields("UserActions", "Spawn Car /car Triggered!", "pink", {
                { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                { name = "Vehicle", value = args.car, inline = true },
            })
        end

        local xRoutingBucket = GetPlayerRoutingBucket(xPlayer.source)

        ESX.OneSync.SpawnVehicle(args.car, playerCoords, playerHeading, upgrades, function(networkId)
            if networkId then
                local vehicle = NetworkGetEntityFromNetworkId(networkId)

                if xRoutingBucket ~= 0 then
                    SetEntityRoutingBucket(vehicle, xRoutingBucket)
                end

                for _ = 1, 100 do
                    Wait(0)
                    SetPedIntoVehicle(playerPed, vehicle, -1)

                    if GetVehiclePedIsIn(playerPed, false) == vehicle then
                        break
                    end
                end

                if GetVehiclePedIsIn(playerPed, false) ~= vehicle then
                    showError("[^1ERROR^7] The player could not be seated in the vehicle")
                end
            end
        end)
    end,
    false,
    {
        help = TranslateCap("command_car"),
        validate = false,
        arguments = {
            { name = "car", validate = false, help = TranslateCap("command_car_car"), type = "string" },
        },
    }
)

ESX.RegisterCommand(
    { "cardel", "dv" },
    FilterGroups(CommandPermissions.cardel, "cardel"),
    function(xPlayer, args)
        local ped = GetPlayerPed(xPlayer.source)
        local pedVehicle = GetVehiclePedIsIn(ped, false)

        if DoesEntityExist(pedVehicle) then
            DeleteEntity(pedVehicle)
        end

        local coords = GetEntityCoords(ped)
        local Vehicles = xLib.onesync.getVehiclesInArea(coords, tonumber(args.radius) or 5.0)
        for i = 1, #Vehicles do
            local Vehicle = NetworkGetEntityFromNetworkId(Vehicles[i])
            if DoesEntityExist(Vehicle) then
                DeleteEntity(Vehicle)
            end
        end
        if Config.AdminLogging then
            ESX.DiscordLogFields("UserActions", "Delete Vehicle /dv Triggered!", "pink", {
                { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
            })
        end
    end,
    false,
    {
        help = TranslateCap("command_cardel"),
        validate = false,
        arguments = {
            { name = "radius", validate = false, help = TranslateCap("command_cardel_radius"), type = "number" },
        },
    }
)

ESX.RegisterCommand(
    { "fix", "repair" },
    FilterGroups(CommandPermissions.fix, "fix"),
    function(xPlayer, args, showError)
        local xTarget = args.playerId
        local ped = GetPlayerPed(xTarget.source)
        local pedVehicle = GetVehiclePedIsIn(ped, false)
        if not pedVehicle or GetPedInVehicleSeat(pedVehicle, -1) ~= ped then
            showError(TranslateCap("not_in_vehicle"))
            return
        end
        xTarget.triggerEvent("esx:repairPedVehicle")
        if xPlayer then
            xPlayer.showNotification(TranslateCap("command_repair_success"))
        end
        if not xPlayer or xPlayer.source ~= xTarget.source then
            xTarget.showNotification(TranslateCap("command_repair_success_target"))
        end
        if Config.AdminLogging then
            ESX.DiscordLogFields("UserActions", "Fix Vehicle /fix Triggered!", "pink", {
                { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                { name = "Target", value = xTarget.name, inline = true },
            })
        end
    end,
    true,
    {
        help = TranslateCap("command_repair"),
        validate = false,
        arguments = {
            { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
        },
    }
)