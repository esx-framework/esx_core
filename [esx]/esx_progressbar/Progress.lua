local function Progressbar(message,length,Options)
    if Options.animation then 
        if Options.animation.type == "anim" then
            ESX.Streaming.RequestAnimDict(Options.animation.dict, function()
                TaskPlayAnim(ESX.PlayerData.ped, Options.animation.dict, Options.animation.lib, 1.0, 1.0, length, 1, 1.0, false,false,false)
            end)
        end
    end
    if Options.FreezePlayer then FreezeEntityPosition(PlayerPedId(),Options.FreezePlayer) end
    SendNuiMessage(json.encode({
        type = "Progressbar",
        length = length or 3000,
        message = message or "ESX-Framework"
    }))
    Wait(length)
    if Options.FreezePlayer then FreezeEntityPosition(PlayerPedId(),not Options.FreezePlayer) end
    if Options.onFinish then Options.onFinish() end
end

exports('Progressbar', Progressbar)

-- Example
--[[RegisterCommand("progress", function()
    exports["esx_progressbar"]:Progressbar("test", 25000, false,{animation ={type = "anim",dict = "mini@prostitutes@sexlow_veh", lib ="low_car_sex_to_prop_p2_player" }, onFinish = function()
        print("finish")
    end})
end)]] 
