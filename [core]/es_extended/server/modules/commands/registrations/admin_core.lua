-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local CommandPermissions = Core.CommandPermissions
local FilterGroups = Core.FilterCommandGroups
ESX.RegisterCommand(
    { "setcoords", "tp" },
    FilterGroups(CommandPermissions.setcoords, "setcoords"),
    function(xPlayer, args)
        xPlayer.setCoords({ x = args.x, y = args.y, z = args.z })
        if Config.AdminLogging then
            ESX.DiscordLogFields("UserActions", "Set Coordinates /setcoords Triggered!", "pink", {
                { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                { name = "X Coord", value = args.x, inline = true },
                { name = "Y Coord", value = args.y, inline = true },
                { name = "Z Coord", value = args.z, inline = true },
            })
        end
    end,
    false,
    {
        help = TranslateCap("command_setcoords"),
        validate = true,
        arguments = {
            { name = "x", help = TranslateCap("command_setcoords_x"), type = "coordinate" },
            { name = "y", help = TranslateCap("command_setcoords_y"), type = "coordinate" },
            { name = "z", help = TranslateCap("command_setcoords_z"), type = "coordinate" },
        },
    }
)

ESX.RegisterCommand(
    "setjob",
    FilterGroups(CommandPermissions.setjob, "setjob"),
    function(xPlayer, args, showError)
        if not ESX.DoesJobExist(args.job, args.grade) then
            return showError(TranslateCap("command_setjob_invalid"))
        end

        args.playerId.setJob(args.job, args.grade)
        if Config.AdminLogging then
            ESX.DiscordLogFields("UserActions", "Set Job /setjob Triggered!", "pink", {
                { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                { name = "Target", value = args.playerId.name, inline = true },
                { name = "Job", value = args.job, inline = true },
                { name = "Grade", value = args.grade, inline = true },
            })
        end
    end,
    true,
    {
        help = TranslateCap("command_setjob"),
        validate = true,
        arguments = {
            { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
            { name = "job", help = TranslateCap("command_setjob_job"), type = "string" },
            { name = "grade", help = TranslateCap("command_setjob_grade"), type = "number" },
        },
    }
)

ESX.RegisterCommand(
    "setgroup",
    FilterGroups(CommandPermissions.setgroup, "setgroup"),
    function(xPlayer, args)
        if not args.playerId then
            args.playerId = xPlayer.source
        end
        if args.group == "superadmin" then
            args.group = "admin"
            print("[^3WARNING^7] ^5Superadmin^7 detected, setting group to ^5admin^7")
        end
        args.playerId.setGroup(args.group)
        if Config.AdminLogging then
            ESX.DiscordLogFields("UserActions", "/setgroup Triggered!", "pink", {
                { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                { name = "Target", value = args.playerId.name, inline = true },
                { name = "Group", value = args.group, inline = true },
            })
        end
    end,
    true,
    {
        help = TranslateCap("command_setgroup"),
        validate = true,
        arguments = {
            { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
            { name = "group", help = TranslateCap("command_setgroup_group"), type = "string" },
        },
    }
)