local Debug = ESX.GetConfig().EnableDebug

---@param notificatonType string the notification type
---@param length number the length of the notification
---@param message any the message :D
---@param title string optional title for the notification
local function Notify(notificatonType, length, message, title)
    if Debug then
        print("1 ".. tostring(notificatonType))
        print("2 "..tostring(length))
        print("3 "..message)
        print("4 "..tostring(title))
    end

    if type(notificatonType) ~= "string" then
        notificatonType = "info"
    end

    if type(length) ~= "number" then
        length = 3000
    end

    if Debug then
        print("5 ".. tostring(notificatonType))
        print("6 "..tostring(length))
        print("7 "..message)
        print("8 "..tostring(title))
    end

    if type(message) == "string" then
        message = message:gsub("~br~", "<br>")
    end

    SendNuiMessage(json.encode({
        type = notificatonType or "info",
        length = length or 5000,
        message = message or "ESX-Notify",
        title = title or "New Notification"
    }))
end

exports('Notify', Notify)
RegisterNetEvent("ESX:Notify", Notify)

if Debug then
    RegisterCommand("oldnotify", function()
        ESX.ShowNotification('No Waypoint Set.', true, false, 140)
    end)

    RegisterCommand("notify", function()
        ESX.ShowNotification("You Received <br>1x ball!", "success", 3000)
    end)

    RegisterCommand("notify1", function()
        ESX.ShowNotification("Well ~g~Done~s~!", "success", 3000, "Achievement")
    end)

    RegisterCommand("notify2", function()
        ESX.ShowNotification("Information Received", "info", 3000, "System Info")
    end)

    RegisterCommand("notify3", function()
        ESX.ShowNotification("You Did something ~r~WRONG~s~!", "error", 3000, "Error")
    end)

    RegisterCommand("notify4", function()
        ESX.ShowNotification("You Did something ~r~WRONG~s~!", "warning", 3000, "~y~Warning~s~")
    end)
end
