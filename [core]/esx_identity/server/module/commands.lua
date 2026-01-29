local Commands = {}

function Commands.Register()
    if not Config.EnableCommands then
        return
    end

    ESX.RegisterCommand("char", "user", function(xPlayer)
        if xPlayer and xPlayer.getName() then
            xPlayer.showNotification(TranslateCap("active_character", xPlayer.getName()))
        else
            xPlayer.showNotification(TranslateCap("error_active_character"))
        end
    end, false, { help = TranslateCap("show_active_character") })

    ESX.RegisterCommand("chardel", "user", function(xPlayer)
        if xPlayer and xPlayer.getName() then
            local identifier = xPlayer.getIdentifier()
            if Config.UseDeferrals then
                xPlayer.kick(TranslateCap("deleted_identity"))
                Wait(1500)
                Modules.Database.DeleteIdentity(xPlayer)
                Modules.Identity.SetPlayerData(xPlayer, { firstName = nil, lastName = nil, dateOfBirth = nil, sex = nil, height = nil })
                xPlayer.showNotification(TranslateCap("deleted_character"))
                Modules.Identity.ClearPlayerIdentity(identifier)
                Modules.Identity.MarkAsNotRegistered(identifier)
            else
                Modules.Database.DeleteIdentity(xPlayer)
                Modules.Identity.SetPlayerData(xPlayer, { firstName = nil, lastName = nil, dateOfBirth = nil, sex = nil, height = nil })
                xPlayer.showNotification(TranslateCap("deleted_character"))
                Modules.Identity.ClearPlayerIdentity(identifier)
                Modules.Identity.MarkAsNotRegistered(identifier)
                TriggerClientEvent("esx_identity:showRegisterIdentity", xPlayer.source)
            end
        else
            xPlayer.showNotification(TranslateCap("error_delete_character"))
        end
    end, false, { help = TranslateCap("delete_character") })
end

Modules.Commands = Commands
return Commands

