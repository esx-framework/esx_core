---@class ProgressBarAnimation
---@field public type "anim" | "Scenario"
---@field public dict? string
---@field public lib? string

---@class ProgressBarOptions
---@field public animation ProgressBarAnimation
---@field public FreezePlayer? boolean
---@field public onFinish? function

local CurrentProgress = nil

local function startProcessing()
    while (CurrentProgress ~= nil) do
        if CurrentProgress.length > 0 then
            CurrentProgress.length = CurrentProgress.length - 1000
        else
            ClearPedTasks(ESX.PlayerData.ped)
            if CurrentProgress.FreezePlayer then
                FreezeEntityPosition(ESX.PlayerData.ped, false)
            end
            if CurrentProgress.onFinish then
                CurrentProgress.onFinish()
            end
            CurrentProgress = nil
        end
        Wait(1000)
    end
end

---@param message string
---@param length? number Timeout in milliseconds
---@param Options? ProgressBarOptions
---@return boolean Success
local function Progressbar(message, length, Options)
    if CurrentProgress then
        return false
    end
    CurrentProgress = Options or {}
    if CurrentProgress.animation then
        if CurrentProgress.animation.type == "anim" then
            ESX.Streaming.RequestAnimDict(CurrentProgress.animation.dict, function()
                TaskPlayAnim(ESX.PlayerData.ped, CurrentProgress.animation.dict, CurrentProgress.animation.lib, 1.0, 1.0, length, 1, 1.0, false, false, false)
                RemoveAnimDict(CurrentProgress.animation.dict)
            end)
        elseif CurrentProgress.animation.type == "Scenario" then
            TaskStartScenarioInPlace(ESX.PlayerData.ped, CurrentProgress.animation.Scenario, 0, true)
        end
    end
    if CurrentProgress.FreezePlayer then
        FreezeEntityPosition(ESX.PlayerData.ped, CurrentProgress.FreezePlayer)
    end
    SendNUIMessage({
        type = "Progressbar",
        length = length or 3000,
        message = message or "ESX-Framework",
    })
    CurrentProgress.length = length or 3000
    CreateThread(startProcessing);
    return true;
end

local function CancelProgressbar()
    if not CurrentProgress then
        return
    end
    SendNUIMessage({
        type = "Close",
    })
    ClearPedTasks(ESX.PlayerData.ped)
    if CurrentProgress.FreezePlayer then
        FreezeEntityPosition(ESX.PlayerData.ped, false)
    end
    if CurrentProgress.onCancel then
        CurrentProgress.onCancel()
    end
    CurrentProgress.canceled = true
    CurrentProgress.length = 0
    CurrentProgress = nil
end

ESX.RegisterInput("cancelprog", "[ProgressBar] Cancel Progressbar", "keyboard", "BACK", CancelProgressbar)

exports("Progressbar", Progressbar)
exports("CancelProgressbar", CancelProgressbar)
