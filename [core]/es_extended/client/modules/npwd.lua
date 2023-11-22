local GetResourceState = GetResourceState
local npwd = GetResourceState('npwd'):find('start') and exports?.npwd

local function checkPhone()
	if not npwd then
		return
	end

	local phoneItem <const> = ESX.SearchInventory('phone')
	npwd:setPhoneDisabled((phoneItem and phoneItem.count or 0) <= 0)
end

RegisterNetEvent('esx:playerLoaded', checkPhone)

AddEventHandler('onClientResourceStart', function(resource)
	if resource ~= 'npwd' then
		return
	end

	npwd = GetResourceState('npwd'):find('start') and exports?.npwd

	if ESX.PlayerLoaded then
		checkPhone()
	end
end)

AddEventHandler('onClientResourceStop', function(resource)
	if resource == 'npwd' then
		npwd = nil
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == 'npwd' then
		npwd = nil
	end
end)

RegisterNetEvent('esx:onPlayerLogout', function()
	if not npwd then
		return
	end

	npwd:setPhoneVisible(false)
	npwd:setPhoneDisabled(true)
end)

RegisterNetEvent('esx:removeInventoryItem', function(item, count)
	if not npwd then
		return
	end

	if item == 'phone' and count == 0 then
		npwd:setPhoneDisabled(true)
	end
end)

RegisterNetEvent('esx:addInventoryItem', function(item)
	if not npwd or item ~= 'phone' then
		return
	end

	npwd:setPhoneDisabled(false)
end)
