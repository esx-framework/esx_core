local Debug = ESX.GetConfig().EnableDebug

---@param type string the notification type
---@param length number the length of the notification
---@param message any the message :D
local function Notify(notificatonType, length, message)
    if Debug then
        print(('1 %s'):format(tostring(notificatonType)))
        print(('2 %s'):format(tostring(length)))
        print(('3 %s'):format(message))
    end

    if type(notificatonType) ~= "string" then
        notificatonType = "info"
    end

    if type(length) ~= "number" then
        length = 3000
    end

    if Debug then
        print(('4 %s'):format(tostring(notificatonType)))
        print(('5 %s'):format(tostring(length)))
        print(('6 %s'):format(message))
    end

    SendNuiMessage(json.encode({
        type = notificatonType or "info",
        length = length or 3000,
        message = message or "ESX-Notify"
    }))
end


exports('Notify', Notify)
RegisterNetEvent("ESX:Notify", Notify)

if Debug then
    RegisterCommand("oldnotify", function()
        ESX.ShowNotification('No Waypoint Set.', true, false, 140)
    end)

    RegisterCommand("notify", function()
        ESX.ShowNotification("You Recived ~br~ 1x ball~s~!", "success", 3000)
    end)

    RegisterCommand("notify1", function()
        ESX.ShowNotification("Well ~g~Done~s~!", "success", 3000)
    end)

    RegisterCommand("notify2", function()
        ESX.ShowNotification("Information Recived", "info", 3000)
    end)

    RegisterCommand("notify3", function()
        ESX.ShowNotification("You Did something ~r~WRONG~s~!", "error", 3000)
    end)
end
