ESX.RegisterCommand(
    "setslots",
    "admin",
    function(xPlayer, args)
        MySQL.insert("INSERT INTO `multicharacter_slots` (`identifier`, `slots`) VALUES (?, ?) ON DUPLICATE KEY UPDATE `slots` = VALUES(`slots`)", {
            args.identifier,
            args.slots,
        })
        xPlayer.triggerEvent("esx:showNotification", TranslateCap("slotsadd", args.slots, args.identifier))
    end,
    true,
    {
        help = TranslateCap("command_setslots"),
        validate = true,
        arguments = {
            { name = "identifier", help = TranslateCap("command_identifier"), type = "string" },
            { name = "slots", help = TranslateCap("command_slots"), type = "number" },
        },
    }
)

ESX.RegisterCommand(
    "remslots",
    "admin",
    function(xPlayer, args)
        local slots = MySQL.scalar.await("SELECT `slots` FROM `multicharacter_slots` WHERE identifier = ?", {
            args.identifier,
        })

        if slots then
            MySQL.update("DELETE FROM `multicharacter_slots` WHERE `identifier` = ?", {
                args.identifier,
            })
            xPlayer.triggerEvent("esx:showNotification", TranslateCap("slotsrem", args.identifier))
        end
    end,
    true,
    {
        help = TranslateCap("command_remslots"),
        validate = true,
        arguments = {
            { name = "identifier", help = TranslateCap("command_identifier"), type = "string" },
        },
    }
)

ESX.RegisterCommand(
    "enablechar",
    "admin",
    function(xPlayer, args)
        local selectedCharacter = "char" .. args.charslot .. ":" .. args.identifier

        MySQL.update("UPDATE `users` SET `disabled` = 0 WHERE identifier = ?", {
            selectedCharacter,
        }, function(result)
            if result > 0 then
                xPlayer.triggerEvent("esx:showNotification", TranslateCap("charenabled", args.charslot, args.identifier))
            else
                xPlayer.triggerEvent("esx:showNotification", TranslateCap("charnotfound", args.charslot, args.identifier))
            end
        end)
    end,
    true,
    {
        help = TranslateCap("command_enablechar"),
        validate = true,
        arguments = {
            { name = "identifier", help = TranslateCap("command_identifier"), type = "string" },
            { name = "charslot", help = TranslateCap("command_charslot"), type = "number" },
        },
    }
)

ESX.RegisterCommand(
    "disablechar",
    "admin",
    function(xPlayer, args)
        local selectedCharacter = "char" .. args.charslot .. ":" .. args.identifier

        MySQL.update("UPDATE `users` SET `disabled` = 1 WHERE identifier = ?", {
            selectedCharacter,
        }, function(result)
            if result > 0 then
                xPlayer.triggerEvent("esx:showNotification", TranslateCap("chardisabled", args.charslot, args.identifier))
            else
                xPlayer.triggerEvent("esx:showNotification", TranslateCap("charnotfound", args.charslot, args.identifier))
            end
        end)
    end,
    true,
    {
        help = TranslateCap("command_disablechar"),
        validate = true,
        arguments = {
            { name = "identifier", help = TranslateCap("command_identifier"), type = "string" },
            { name = "charslot", help = TranslateCap("command_charslot"), type = "number" },
        },
    }
)

RegisterCommand("forcelog", function(source)
    TriggerEvent("esx:playerLogout", source)
end, true)
