local CurrentProgress = nil
local function Progressbar(message,length,Options)
    local Canceled = false
    if not CurrentProgress then
        CurrentProgress = Options
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
        CurrentProgress.length = length or 3000
        while CurrentProgress ~= nil do
            if CurrentProgress.length > 0 then 
                CurrentProgress.length -= 1000
            else
                ClearPedTasks(ESX.PlayerData.ped)
                if Options.FreezePlayer then FreezeEntityPosition(PlayerPedId(), false) end
                if Options.onFinish then Options.onFinish() end
                CurrentProgress = nil
            end
            Wait(1000)
        end
    end
end

ESX.RegisterInput("cancelprog", "[ProgressBar] Cancel Progressbar", "keyboard", "BACK", function()
    if not CurrentProgress then return end
    if not CurrentProgress.onCancel then return end
    SendNuiMessage(json.encode({
        type = "Close"
    }))
        ClearPedTasks(ESX.PlayerData.ped)
        if CurrentProgress.FreezePlayer then FreezeEntityPosition(PlayerPedId(), false) end
        CurrentProgress.canceled = true
        CurrentProgress.length = 0
        CurrentProgress.onCancel()
        CurrentProgress = nil
end)
exports('Progressbar', Progressbar)