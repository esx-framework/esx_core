exports("getSharedObject", function()
    return ESX
end)

AddEventHandler("esx:getSharedObject", function()
    local Invoke = GetInvokingResource()
    print(("[^1ERROR^7] Resource ^5%s^7 Used the ^5getSharedObject^7 Event, this event ^1no longer exists!^7 Visit https://documentation.esx-framework.org/tutorials/tutorials-esx/sharedevent for how to fix!"):format(Invoke))
end)
