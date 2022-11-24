Debug = ESX.GetConfig().EnableDebug

---@param message string
---@param typ string
local function TextUI(message, typ)
    SendNUIMessage({
        action = 'show',
        message = message and message or 'ESX-TextUI',
        type = type(typ) == "string" and typ or 'info'
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
        ESX.TextUI("i ~r~love~s~ donuts", "error")
    end)

    RegisterCommand("textui:success", function()
        ESX.TextUI("i ~g~love~s~ donuts", "success")
    end)

    RegisterCommand("textui:info", function()
        ESX.TextUI("i ~b~love~s~ donuts", "info")
    end)

    RegisterCommand("textui:hide", function()
        ESX.HideUI()
    end)
end
