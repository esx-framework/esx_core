ESX = {}
Core = {}
Core.Modules = {}

if GetResourceState('ox_inventory') ~= 'missing' then
	Config.OxInventory = true
end

local function upgradeObj()
	local Invoke = GetInvokingResource()
	print(("[^1ERROR^7] Resource ^5%s^7 Used the ^5getSharedObject^7 Event, this event ^1not recommend to use!^7 Visit https://documentation.esx-framework.org/tutorials/sharedevent for how to fix!"):format(Invoke))
end

local function moduleValidation(module)
	if type(module) == 'table' then
		local tempModule = {}
		for i = 1, #module do
			module[i] = string.lower(module[i])
			if Core.Modules[module[i]] then
				tempModule[module[i]] = Core.Modules[module[i]]
			end
		end

		return tempModule
	end

	if not Core.Modules[module] then
		print('[^1ERROR^7] Module whit that key are not exists!', module)
		return nil
	end

	return Core.Modules[module]
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
		return moduleValidation(module)
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
		return moduleValidation(module)
	end)
end
