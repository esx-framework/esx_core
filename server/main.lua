ESX                = nil
local InService    = {}
local MaxInService = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function GetInServiceCount(name)

	local count = 0

	for k,v in pairs(InService[name]) do
		if v == true then
			count = count + 1
		end
	end

	return count

end

AddEventHandler('esx_service:activateService', function(name, max)
	InService[name]    = {}
	MaxInService[name] = max
end)

AddEventHandler('esx_service:disableService', function(name)
	InService[name][source] = nil
end)

ESX.RegisterServerCallback('esx_service:enableService', function(source, cb, name)

	local inServiceCount = GetInServiceCount(name)

	if inServiceCount >= MaxInService[name] then
		cb(false, MaxInService[name], inServiceCount)
	else
		InService[name][source] = enable
		cb(true, MaxInService[name], inServiceCount)
	end

end)


