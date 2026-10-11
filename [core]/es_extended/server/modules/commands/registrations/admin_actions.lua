-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local CommandPermissions = Core.CommandPermissions
local FilterGroups = Core.FilterCommandGroups
ESX.RegisterCommand("tpm", FilterGroups(CommandPermissions.tpm, "tpm"), function(xPlayer)
    xPlayer.triggerEvent("esx:tpm")
    if Config.AdminLogging then
        ESX.DiscordLogFields("UserActions", "Admin Teleport /tpm Triggered!", "pink", {
            { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
            { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
        })
    end
end, false)

ESX.RegisterCommand(
    "goto",
    FilterGroups(CommandPermissions["goto"], "goto"),
    function(xPlayer, args)
        local targetCoords = args.playerId.getCoords()
        local srcDim = GetPlayerRoutingBucket(xPlayer.source)
        local targetDim = GetPlayerRoutingBucket(args.playerId.source)

        if srcDim ~= targetDim then
            SetPlayerRoutingBucket(xPlayer.source, targetDim)
        end
        xPlayer.setCoords(targetCoords)
        if Config.AdminLogging then
            ESX.DiscordLogFields("UserActions", "Admin Teleport /goto Triggered!", "pink", {
                { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                { name = "Target", value = args.playerId.name, inline = true },
                { name = "Target Coords", value = targetCoords, inline = true },
            })
        end
    end,
    false,
    {
        help = TranslateCap("command_goto"),
        validate = true,
        arguments = {
            { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
        },
    }
)

ESX.RegisterCommand(
    "bring",
    FilterGroups(CommandPermissions.bring, "bring"),
    function(xPlayer, args)
        local targetCoords = args.playerId.getCoords()
        local playerCoords = xPlayer.getCoords()
        local targetDim = GetPlayerRoutingBucket(args.playerId.source)
        local srcDim = GetPlayerRoutingBucket(xPlayer.source)

        if targetDim ~= srcDim then
            SetPlayerRoutingBucket(args.playerId.source, srcDim)
        end
        args.playerId.setCoords(playerCoords)
        if Config.AdminLogging then
            ESX.DiscordLogFields("UserActions", "Admin Teleport /bring Triggered!", "pink", {
                { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                { name = "Target", value = args.playerId.name, inline = true },
                { name = "Target Coords", value = targetCoords, inline = true },
            })
        end
    end,
    false,
    {
        help = TranslateCap("command_bring"),
        validate = true,
        arguments = {
            { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
        },
    }
)

ESX.RegisterCommand(
    "kill",
    FilterGroups(CommandPermissions.kill, "kill"),
    function(xPlayer, args)
        args.playerId.triggerEvent("esx:killPlayer")
        if Config.AdminLogging then
            ESX.DiscordLogFields("UserActions", "Kill Command /kill Triggered!", "pink", {
                { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                { name = "Target", value = args.playerId.name, inline = true },
            })
        end
    end,
    true,
    {
        help = TranslateCap("command_kill"),
        validate = true,
        arguments = {
            { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
        },
    }
)

ESX.RegisterCommand(
    "freeze",
    FilterGroups(CommandPermissions.freeze, "freeze"),
    function(xPlayer, args)
        args.playerId.triggerEvent("esx:freezePlayer", "freeze")
        if Config.AdminLogging then
            ESX.DiscordLogFields("UserActions", "Admin Freeze /freeze Triggered!", "pink", {
                { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                { name = "Target", value = args.playerId.name, inline = true },
            })
        end
    end,
    true,
    {
        help = TranslateCap("command_freeze"),
        validate = true,
        arguments = {
            { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
        },
    }
)

ESX.RegisterCommand(
    "unfreeze",
    FilterGroups(CommandPermissions.unfreeze, "unfreeze"),
    function(xPlayer, args)
        args.playerId.triggerEvent("esx:freezePlayer", "unfreeze")
        if Config.AdminLogging then
            ESX.DiscordLogFields("UserActions", "Admin UnFreeze /unfreeze Triggered!", "pink", {
                { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                { name = "Target", value = args.playerId.name, inline = true },
            })
        end
    end,
    true,
    {
        help = TranslateCap("command_unfreeze"),
        validate = true,
        arguments = {
            { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
        },
    }
)

ESX.RegisterCommand("noclip", FilterGroups(CommandPermissions.noclip, "noclip"), function(xPlayer)
    xPlayer.triggerEvent("esx:noclip")
    if Config.AdminLogging then
        ESX.DiscordLogFields("UserActions", "Admin NoClip /noclip Triggered!", "pink", {
            { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
            { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
        })
    end
end, false)

ESX.RegisterCommand(
    {"setdim", "setbucket"},
    FilterGroups(CommandPermissions.setdim, "setdim"),
    function(xPlayer, args)
        SetPlayerRoutingBucket(args.playerId.source, args.dimension)
        if Config.AdminLogging then
            ESX.DiscordLogFields("UserActions", "Admin Set Dim /setdim Triggered!", "pink", {
                { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                { name = "Target", value = args.playerId.name, inline = true },
                { name = "Dimension", value = args.dimension, inline = true },
            })
        end
    end,
    true,
    {
        help = TranslateCap("command_setdim"),
        validate = true,
        arguments = {
            { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
            { name = "dimension", help = TranslateCap("commandgeneric_dimension"), type = "number" },
        },
    }
)