local function Progressbar(message,length, FreezePlayer,animation, onFinish)
    if animation then 
        if animation.type == "anim" then
            ESX.Streaming.RequestAnimDict(animation.dict, function()
                TaskPlayAnim(ESX.PlayerData.ped, animation.dict, animation.lib, 1.0, 1.0, length, 1, 1.0, false,false,false)
            end)
        end
    end
    if FreezePlayer then FreezeEntityPosition(PlayerPedId(),FreezePlayer) end
    SendNuiMessage(json.encode({
        type = "Progressbar",
        length = length or 3000,
        message = message or "ESX-Framework"
    }))
    Wait(length)
    if FreezePlayer then FreezeEntityPosition(PlayerPedId(),not FreezePlayer) end
    if onFinish then onFinish() end
end

exports('Progressbar', Progressbar)

-- Example
--[[RegisterCommand("progress", function()
    exports["esx_progressbar"]:Progressbar("test", 25000, false,{type = "anim",dict = "mini@prostitutes@sexlow_veh", lib ="low_car_sex_to_prop_p2_player" }, function()
        print("finish")
    end)
end)]] 
