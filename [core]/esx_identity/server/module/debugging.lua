local Debugging = {}

function Debugging.Register()
    if not Config.EnableDebugging then
        return
    end

    ESX.RegisterCommand("xPlayerGetFirstName", "user", function(xPlayer)
        if xPlayer and xPlayer.get("firstName") then
            xPlayer.showNotification(TranslateCap("return_debug_xPlayer_get_first_name", xPlayer.get("firstName")))
        else
            xPlayer.showNotification(TranslateCap("error_debug_xPlayer_get_first_name"))
        end
    end, false, { help = TranslateCap("debug_xPlayer_get_first_name") })

    ESX.RegisterCommand("xPlayerGetLastName", "user", function(xPlayer)
        if xPlayer and xPlayer.get("lastName") then
            xPlayer.showNotification(TranslateCap("return_debug_xPlayer_get_last_name", xPlayer.get("lastName")))
        else
            xPlayer.showNotification(TranslateCap("error_debug_xPlayer_get_last_name"))
        end
    end, false, { help = TranslateCap("debug_xPlayer_get_last_name") })

    ESX.RegisterCommand("xPlayerGetFullName", "user", function(xPlayer)
        if xPlayer and xPlayer.getName() then
            xPlayer.showNotification(TranslateCap("return_debug_xPlayer_get_full_name", xPlayer.getName()))
        else
            xPlayer.showNotification(TranslateCap("error_debug_xPlayer_get_full_name"))
        end
    end, false, { help = TranslateCap("debug_xPlayer_get_full_name") })

    ESX.RegisterCommand("xPlayerGetSex", "user", function(xPlayer)
        if xPlayer and xPlayer.get("sex") then
            xPlayer.showNotification(TranslateCap("return_debug_xPlayer_get_sex", xPlayer.get("sex")))
        else
            xPlayer.showNotification(TranslateCap("error_debug_xPlayer_get_sex"))
        end
    end, false, { help = TranslateCap("debug_xPlayer_get_sex") })

    ESX.RegisterCommand("xPlayerGetDOB", "user", function(xPlayer)
        if xPlayer and xPlayer.get("dateofbirth") then
            xPlayer.showNotification(TranslateCap("return_debug_xPlayer_get_dob", xPlayer.get("dateofbirth")))
        else
            xPlayer.showNotification(TranslateCap("error_debug_xPlayer_get_dob"))
        end
    end, false, { help = TranslateCap("debug_xPlayer_get_dob") })

    ESX.RegisterCommand("xPlayerGetHeight", "user", function(xPlayer)
        if xPlayer and xPlayer.get("height") then
            xPlayer.showNotification(TranslateCap("return_debug_xPlayer_get_height", xPlayer.get("height")))
        else
            xPlayer.showNotification(TranslateCap("error_debug_xPlayer_get_height"))
        end
    end, false, { help = TranslateCap("debug_xPlayer_get_height") })
end

Modules.Debugging = Debugging
return Debugging

