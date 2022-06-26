local function Notify(type, length, message)
    local msg = string.gsub(message, '~%a~', '')
    SendNuiMessage(json.encode({
        type = type or "info",
        length = length or 3000,
        message = msg or "ESX-Notify"
    }))
end




exports('Notify', Notify)
RegisterNetEvent("ESX:Notify", Notify)
