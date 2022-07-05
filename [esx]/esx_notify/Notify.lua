---@param type string the notification type
---@param length number the length of the notification
---@param message any the message :D
local function Notify(type, length, message)
    SendNuiMessage(json.encode({
        type = type or "info",
        length = length or 3000,
        message = message or "ESX-Notify"
    }))
end

exports('Notify', Notify)
RegisterNetEvent("ESX:Notify", Notify)
