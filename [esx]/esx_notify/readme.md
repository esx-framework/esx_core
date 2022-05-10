## How to change style and time
 
* ESX.ShowNotification("Text Here", "error", 3000) -- Error Notification
* ESX.ShowNotification("Text Here", "success", 3000) -- Success Notification
* ESX.ShowNotification("Text Here", "info", 3000) -- Info

* By doing ESX.ShowNotification("Text Here") it will be default/info

# Exports
* exports["esx_notify"]:Notify("info", 3000, "Text Here")

# Events
* TriggerEvent("ESX:Notify", "info", 3000, "Text Here")
