-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local CommandPermissions = Core.CommandPermissions
local FilterGroups = Core.FilterCommandGroups
if not Config.CustomInventory then
    ESX.RegisterCommand(
        "giveitem",
        FilterGroups(CommandPermissions.giveitem, "giveitem"),
        function(xPlayer, args)
            args.playerId.addInventoryItem(args.item, args.count)
            if Config.AdminLogging then
                ESX.DiscordLogFields("UserActions", "Give Item /giveitem Triggered!", "pink", {
                    { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                    { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                    { name = "Target", value = args.playerId.name, inline = true },
                    { name = "Item", value = args.item, inline = true },
                    { name = "Quantity", value = args.count, inline = true },
                })
            end
        end,
        true,
        {
            help = TranslateCap("command_giveitem"),
            validate = true,
            arguments = {
                { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
                { name = "item", help = TranslateCap("command_giveitem_item"), type = "item" },
                { name = "count", help = TranslateCap("command_giveitem_count"), type = "number", Validator = {
                    validate = function(x) return x > 0 end,
                    err = TranslateCap("commanderror_argumentmismatch_positive_number", "count")
                }},
            },
        }
    )

    ESX.RegisterCommand(
        "giveweapon",
        FilterGroups(CommandPermissions.giveweapon, "giveweapon"),
        function(xPlayer, args, showError)
            if args.playerId.hasWeapon(args.weapon) then
                return showError(TranslateCap("command_giveweapon_hasalready"))
            end
            args.playerId.addWeapon(args.weapon, args.ammo)
            if Config.AdminLogging then
                ESX.DiscordLogFields("UserActions", "Give Weapon /giveweapon Triggered!", "pink", {
                    { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                    { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                    { name = "Target", value = args.playerId.name, inline = true },
                    { name = "Weapon", value = args.weapon, inline = true },
                    { name = "Ammo", value = args.ammo, inline = true },
                })
            end
        end,
        true,
        {
            help = TranslateCap("command_giveweapon"),
            validate = true,
            arguments = {
                { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
                { name = "weapon", help = TranslateCap("command_giveweapon_weapon"), type = "weapon" },
                { name = "ammo", help = TranslateCap("command_giveweapon_ammo"), type = "number" },
            },
        }
    )

    ESX.RegisterCommand(
        "giveammo",
        FilterGroups(CommandPermissions.giveammo, "giveammo"),
        function(xPlayer, args, showError)
            if not args.playerId.hasWeapon(args.weapon) then
                return showError(TranslateCap("command_giveammo_noweapon_found"))
            end
            args.playerId.addWeaponAmmo(args.weapon, args.ammo)
            if Config.AdminLogging then
                ESX.DiscordLogFields("UserActions", "Give Ammunition /giveammo Triggered!", "pink", {
                    { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                    { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                    { name = "Target", value = args.playerId.name, inline = true },
                    { name = "Weapon", value = args.weapon, inline = true },
                    { name = "Ammo", value = args.ammo, inline = true },
                })
            end
        end,
        true,
        {
            help = TranslateCap("command_giveammo"),
            validate = true,
            arguments = {
                { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
                { name = "weapon", help = TranslateCap("command_giveammo_weapon"), type = "weapon" },
                {
                    name = "ammo",
                    help = TranslateCap("command_giveammo_ammo"),
                    type = "number",
                    Validator = {
                        validate = function(x) return x > 0 end,
                        err = TranslateCap("commanderror_argumentmismatch_positive_number", "ammo")
                    }
                },
            },
        }
    )

    ESX.RegisterCommand(
        "giveweaponcomponent",
        FilterGroups(CommandPermissions.giveweaponcomponent, "giveweaponcomponent"),
        function(xPlayer, args, showError)
            if args.playerId.hasWeapon(args.weaponName) then
                local component = ESX.GetWeaponComponent(args.weaponName, args.componentName)

                if component then
                    if args.playerId.hasWeaponComponent(args.weaponName, args.componentName) then
                        showError(TranslateCap("command_giveweaponcomponent_hasalready"))
                    else
                        args.playerId.addWeaponComponent(args.weaponName, args.componentName)
                        if Config.AdminLogging then
                            ESX.DiscordLogFields("UserActions", "Give Weapon Component /giveweaponcomponent Triggered!", "pink", {
                                { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                                { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                                { name = "Target", value = args.playerId.name, inline = true },
                                { name = "Weapon", value = args.weaponName, inline = true },
                                { name = "Component", value = args.componentName, inline = true },
                            })
                        end
                    end
                else
                    showError(TranslateCap("command_giveweaponcomponent_invalid"))
                end
            else
                showError(TranslateCap("command_giveweaponcomponent_missingweapon"))
            end
        end,
        true,
        {
            help = TranslateCap("command_giveweaponcomponent"),
            validate = true,
            arguments = {
                { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
                { name = "weaponName", help = TranslateCap("command_giveweapon_weapon"), type = "weapon" },
                { name = "componentName", help = TranslateCap("command_giveweaponcomponent_component"), type = "string" },
            },
        }
    )
end

if not Config.CustomInventory then
    ESX.RegisterCommand("refreshitems", FilterGroups(CommandPermissions.refreshitems, "refreshitems"), function(xPlayer)
        local itemCount = ESX.RefreshItems()

        if xPlayer then
            xPlayer.showNotification(Translate("command_refreshitems_success", itemCount))
        else
            print(("[^2INFO^7] %s^7"):format(Translate("command_refreshitems_success", itemCount)))
        end
    end, true, { help = TranslateCap("command_refreshitems") })

    ESX.RegisterCommand(
        "clearinventory",
        FilterGroups(CommandPermissions.clearinventory, "clearinventory"),
        function(xPlayer, args)
            for itemName in pairs(args.playerId.getInventory(true)) do
                args.playerId.setInventoryItem(itemName, 0)
            end
            TriggerEvent("esx:playerInventoryCleared", args.playerId)
            if Config.AdminLogging then
                ESX.DiscordLogFields("UserActions", "Clear Inventory /clearinventory Triggered!", "pink", {
                    { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                    { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                    { name = "Target", value = args.playerId.name, inline = true },
                })
            end
        end,
        true,
        {
            help = TranslateCap("command_clearinventory"),
            validate = true,
            arguments = {
                { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
            },
        }
    )

    ESX.RegisterCommand(
        "clearloadout",
        FilterGroups(CommandPermissions.clearloadout, "clearloadout"),
        function(xPlayer, args)
            for i = #args.playerId.loadout, 1, -1 do
                args.playerId.removeWeapon(args.playerId.loadout[i].name)
            end
            TriggerEvent("esx:playerLoadoutCleared", args.playerId)
            if Config.AdminLogging then
                ESX.DiscordLogFields("UserActions", "/clearloadout Triggered!", "pink", {
                    { name = "Player", value = xPlayer and xPlayer.name or "Server Console", inline = true },
                    { name = "ID", value = xPlayer and xPlayer.source or "Unknown ID", inline = true },
                    { name = "Target", value = args.playerId.name, inline = true },
                })
            end
        end,
        true,
        {
            help = TranslateCap("command_clearloadout"),
            validate = true,
            arguments = {
                { name = "playerId", help = TranslateCap("commandgeneric_playerid"), type = "player" },
            },
        }
    )
end