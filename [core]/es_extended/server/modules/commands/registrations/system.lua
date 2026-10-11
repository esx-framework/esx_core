-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local CommandPermissions = Core.CommandPermissions
local FilterGroups = Core.FilterCommandGroups
ESX.RegisterCommand({ "clear", "cls" }, FilterGroups(CommandPermissions.clear, "clear"), function(xPlayer)
    xPlayer.triggerEvent("chat:clear")
end, false, { help = TranslateCap("command_clear") })

ESX.RegisterCommand({ "clearall", "clsall" }, FilterGroups(CommandPermissions.clearall, "clearall"), function(xPlayer)
    TriggerClientEvent("chat:clear", -1)
    if Config.AdminLogging then
        ESX.DiscordLogFields("UserActions", "Clear Chat /clearall Triggered!", "pink", {
            { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
            { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
        })
    end
end, true, { help = TranslateCap("command_clearall") })

ESX.RegisterCommand("refreshjobs", FilterGroups(CommandPermissions.refreshjobs, "refreshjobs"), function()
    ESX.RefreshJobs()
end, true, { help = TranslateCap("command_clearall") })

ESX.RegisterCommand(
    "save",
    FilterGroups(CommandPermissions.save, "save"),
    function(_, args)
        Core.SavePlayer(args.playerId)
        print(("[^2Info^0] Saved Player - ^5%s^0"):format(args.playerId.source))
    end,
    true,
    {
        help = TranslateCap("command_save"),
        validate = true,
        arguments = {
            { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
        },
    }
)

ESX.RegisterCommand("saveall", FilterGroups(CommandPermissions.saveall, "saveall"), function()
    Core.SavePlayers()
end, true, { help = TranslateCap("command_saveall") })

ESX.RegisterCommand("group", FilterGroups(CommandPermissions.group, "group"), function(xPlayer, _, _)
    print(("%s, you are currently: ^5%s^0"):format(xPlayer.getName(), xPlayer.getGroup()))
end, false)

ESX.RegisterCommand("job", FilterGroups(CommandPermissions.job, "job"), function(xPlayer, _, _)
    local job = xPlayer.getJob()

    print(("%s, your job is: ^5%s^0 - ^5%s^0 - ^5%s^0"):format(xPlayer.getName(), job.name, job.grade_label, job.onDuty and "On Duty" or "Off Duty"))
end, false)

ESX.RegisterCommand("info", FilterGroups(CommandPermissions.info, "info"), function(xPlayer)
    local job = xPlayer.getJob().name
    print(("^2ID: ^5%s^0 | ^2Name: ^5%s^0 | ^2Group: ^5%s^0 | ^2Job: ^5%s^0"):format(xPlayer.source, xPlayer.getName(), xPlayer.getGroup(), job))
end, false)

ESX.RegisterCommand("playtime", FilterGroups(CommandPermissions.playtime, "playtime"), function(xPlayer)
    local playtime = xPlayer.getPlayTime()
    local days = math.floor(playtime / 86400)
    local hours = math.floor((playtime % 86400) / 3600)
    local minutes = math.floor((playtime % 3600) / 60)
    print(("Playtime: ^5%s^0 Days | ^5%s^0 Hours | ^5%s^0 Minutes"):format(days, hours, minutes))
end, false)

ESX.RegisterCommand("coords", FilterGroups(CommandPermissions.coords, "coords"), function(xPlayer)
    local ped = GetPlayerPed(xPlayer.source)
    local coords = GetEntityCoords(ped, false)
    local heading = GetEntityHeading(ped)
    print(("Coords - Vector3: ^5%s^0"):format(vector3(coords.x, coords.y, coords.z)))
    print(("Coords - Vector4: ^5%s^0"):format(vector4(coords.x, coords.y, coords.z, heading)))
end, false)

ESX.RegisterCommand("players", FilterGroups(CommandPermissions.players, "players"), function()
    local xPlayers = ESX.GetExtendedPlayers() -- Returns all xPlayers
    print(("^5%s^2 online player(s)^0"):format(#xPlayers))
    for i = 1, #xPlayers do
        local xPlayer = xPlayers[i]
        print(("^1[^2ID: ^5%s^0 | ^2Name : ^5%s^0 | ^2Group : ^5%s^0 | ^2Identifier : ^5%s^1]^0\n"):format(xPlayer.source, xPlayer.getName(), xPlayer.getGroup(), xPlayer.identifier))
    end
end, true)
