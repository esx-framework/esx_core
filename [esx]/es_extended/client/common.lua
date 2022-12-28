exports('getSharedObject', function()
	return ESX
end)

if GetResourceState('ox_inventory') ~= 'missing' then
	Config.OxInventory = true
end

if Config.Multichar then
	if GetResourceState('esx_multicharacter') == 'missing' then
		Config.Multichar = false
	end
end
