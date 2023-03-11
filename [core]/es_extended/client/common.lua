exports('getSharedObject', function()
	return ESX
end)

if GetResourceState('ox_inventory') ~= 'missing' then
	Config.OxInventory = true
end

AddEventHandler("esx:getSharedObject", function(cb)
	if Config.EnableGetSharedObjectEvent then
		cb(ESX)
	else
		local Invoke = GetInvokingResource()
		print(("[^1ERROR^7] Resource ^5%s^7 Used the ^5getSharedObject^7 Event, This Is NOT Recommended and is very bad for performance! Visit https://documentation.esx-framework.org/tutorials/tutorials-esx/sharedevent For More details"):format(Invoke))
	end
end)
