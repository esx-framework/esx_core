AddEventHandler('esx:getSharedObject', function(cb)
  local Invoke = GetInvokingResource()
  print(('[^3WARNING^7] ^5%s^7 used ^5esx:getSharedObject^7, this method is deprecated and should not be used! Refer to ^5https://docs.esx-framework.org/tutorials/sharedevent^7 for more info!'):format(Invoke))
  cb(ESX)
end)

exports('getSharedObject', function()
	return ESX
end)

if GetResourceState('ox_inventory') ~= 'missing' then
	Config.OxInventory = true
end
