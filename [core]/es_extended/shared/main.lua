ESX = {}
Core = {}
Core.Modules = {}

local function upgradeObj()
	local Invoke = GetInvokingResource()
	print(("[^1ERROR^7] Resource ^5%s^7 Used the ^5getSharedObject^7 Event, this event ^1no longer exists!^7 Visit https://documentation.esx-framework.org/tutorials/sharedevent for how to fix!"):format(Invoke))
end

if IsDuplicityVersion() then
	-- Server
	exports('getSharedObject', function()
		return ESX
	end)

	AddEventHandler('esx:getSharedObject', function(cb)
		upgradeObj()
		cb(ESX)
	end)

	exports('getModule', function(module)
		return Core.Modules[module]
	end)
else
	-- Client
	exports('getSharedObject', function()
		return ESX
	end)

	AddEventHandler('esx:getSharedObject', function(cb)
		upgradeObj()
		cb(ESX)
	end)

	exports('getModule', function(module)
		return Core.Modules[module]
	end)
end
