Debug = false

---@param message any
---@param type string
local function TextUI(message, type)
    SendNUIMessage({
        action = 'show',
        message = message or 'ESX-TextUI',
        type = type or 'info'
    })
end

local function HideUI()
    SendNUIMessage({
        action = 'hide'
    })
end

exports('TextUI', TextUI)
exports('HideUI', HideUI)
RegisterNetEvent('ESX:TextUI', TextUI)
RegisterNetEvent('ESX:HideUI', HideUI)

if Debug then
    RegisterCommand("textui:error", function()
        TriggerEvent("ESX:TextUI", "i ~r~love~s~ donuts", "error")
    end)

    RegisterCommand("textui:success", function()
        TriggerEvent("ESX:TextUI", "i ~r~love~s~ donuts", "success")
    end)

    RegisterCommand("textui:info", function()
        TriggerEvent("ESX:TextUI", "i ~r~love~s~ donuts", "info")
    end)

    RegisterCommand("textui:hide", function()
        TriggerEvent("ESX:HideUI")
    end)
end
