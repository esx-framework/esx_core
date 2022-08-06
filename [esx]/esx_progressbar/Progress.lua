local InProgress = false
local function Progressbar(message,length,Options)
    if not InProgress then
        if Options.animation then 
            if Options.animation.type == "anim" then
                ESX.Streaming.RequestAnimDict(Options.animation.dict, function()
                    TaskPlayAnim(ESX.PlayerData.ped, Options.animation.dict, Options.animation.lib, 1.0, 1.0, length, 1, 1.0, false,false,false)
                    RemoveAnimDict(Options.animation.dict)
                end)
            elseif Options.animation.type == "Scenario" then
                TaskStartScenarioInPlace(ESX.PlayerData.ped, Options.animation.Scenario, 0, true)
            end
        end
        if Options.FreezePlayer then FreezeEntityPosition(PlayerPedId(),Options.FreezePlayer) end
        SendNuiMessage(json.encode({
            type = "Progressbar",
            length = length or 3000,
            message = message or "ESX-Framework"
        }))
        if Options.onCancel then
            local le = length or 3000
            while le > 0 do
                Wait(0)
                le -= 1
                if IsControlJustPressed(0, 178) then
                    SendNuiMessage(json.encode({
                        type = "Close"
                    }))
                    Options.onCancel()
                    break
                end
            end
            ClearPedTasks(ESX.PlayerData.ped)
            if Options.FreezePlayer then FreezeEntityPosition(PlayerPedId(), false) end
            if Options.onFinish then Options.onFinish() end
            InProgress = false
        else 
            SetTimeout(length, function()
                ClearPedTasks(ESX.PlayerData.ped)
                if Options.FreezePlayer then FreezeEntityPosition(PlayerPedId(), false) end
                if Options.onFinish then Options.onFinish() end
                InProgress = false
            end)
        end
    end
end

exports('Progressbar', Progressbar)

