ESX = {}
Core = {}
Core.Modules = {}

if IsDuplicityVersion() then
	-- Server
	exports('getSharedObject', function()
		return ESX
	end)

	AddEventHandler('esx:getSharedObject', function(cb)
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
		cb(ESX)
	end)

	exports('getModule', function(module)
		return Core.Modules[module]
	end)
end
