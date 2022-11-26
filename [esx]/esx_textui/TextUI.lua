Debug = ESX.GetConfig().EnableDebug
local IsShowing = false
---@param message string
---@param Type string
local function TextUI(message, type)
    IsShowing = true
    SendNUIMessage({
        action = 'show',
        message = message and message or 'ESX-TextUI',
        type = type == 0 and "info" or type
    })
end

local function HideUI()
   if not IsShowing then 
        return 
   end
   IsShowing = false
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
