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