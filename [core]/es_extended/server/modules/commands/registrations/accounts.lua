-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local CommandPermissions = Core.CommandPermissions
local FilterGroups = Core.FilterCommandGroups
ESX.RegisterCommand(
    "setaccountmoney",
    FilterGroups(CommandPermissions.setaccountmoney, "setaccountmoney"),
    function(xPlayer, args, showError)
        if not args.playerId.getAccount(args.account) then
            return showError(TranslateCap("command_giveaccountmoney_invalid"))
        end
        args.playerId.setAccountMoney(args.account, args.amount, "Government Grant")
        if Config.AdminLogging then
            ESX.DiscordLogFields("UserActions", "Set Account Money /setaccountmoney Triggered!", "pink", {
                { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                { name = "Target", value = args.playerId.name, inline = true },
                { name = "Account", value = args.account, inline = true },
                { name = "Amount", value = args.amount, inline = true },
            })
        end
    end,
    true,
    {
        help = TranslateCap("command_setaccountmoney"),
        validate = true,
        arguments = {
            { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
            { name = "account", help = TranslateCap("command_giveaccountmoney_account"), type = "string" },
            { name = "amount", help = TranslateCap("command_setaccountmoney_amount"), type = "number" },
        },
    }
)

ESX.RegisterCommand(
    "giveaccountmoney",
    FilterGroups(CommandPermissions.giveaccountmoney, "giveaccountmoney"),
    function(xPlayer, args, showError)
        if not args.playerId.getAccount(args.account) then
            return showError(TranslateCap("command_giveaccountmoney_invalid"))
        end
        args.playerId.addAccountMoney(args.account, args.amount, "Government Grant")
        if Config.AdminLogging then
            ESX.DiscordLogFields("UserActions", "Give Account Money /giveaccountmoney Triggered!", "pink", {
                { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                { name = "Target", value = args.playerId.name, inline = true },
                { name = "Account", value = args.account, inline = true },
                { name = "Amount", value = args.amount, inline = true },
            })
        end
    end,
    true,
    {
        help = TranslateCap("command_giveaccountmoney"),
        validate = true,
        arguments = {
            { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
            { name = "account", help = TranslateCap("command_giveaccountmoney_account"), type = "string" },
            { name = "amount", help = TranslateCap("command_giveaccountmoney_amount"), type = "number" },
        },
    }
)

ESX.RegisterCommand(
    "removeaccountmoney",
    FilterGroups(CommandPermissions.removeaccountmoney, "removeaccountmoney"),
    function(xPlayer, args, showError)
        if not args.playerId.getAccount(args.account) then
            return showError(TranslateCap("command_removeaccountmoney_invalid"))
        end
        args.playerId.removeAccountMoney(args.account, args.amount, "Government Tax")
        if Config.AdminLogging then
            ESX.DiscordLogFields("UserActions", "Remove Account Money /removeaccountmoney Triggered!", "pink", {
                { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                { name = "Target", value = args.playerId.name, inline = true },
                { name = "Account", value = args.account, inline = true },
                { name = "Amount", value = args.amount, inline = true },
            })
        end
    end,
    true,
    {
        help = TranslateCap("command_removeaccountmoney"),
        validate = true,
        arguments = {
            { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
            { name = "account", help = TranslateCap("command_removeaccountmoney_account"), type = "string" },
            { name = "amount", help = TranslateCap("command_removeaccountmoney_amount"), type = "number" },
        },
    }
)