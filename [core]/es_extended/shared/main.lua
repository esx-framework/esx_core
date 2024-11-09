ESX = {}

exports("getSharedObject", function()
    return ESX
end)

AddEventHandler("esx:getSharedObject", function()
    local Invoke = GetInvokingResource()
    error(("Resource ^5%s^1 Used the ^5getSharedObject^1 Event, this event ^1no longer exists!^1 Visit https://documentation.esx-framework.org/tutorials/tutorials-esx/sharedevent for how to fix!"):format(Invoke))
end)

-- backwards compatibility (DO NOT TOUCH !) 
Config.OxInventory = Config.CustomInventory == "ox"