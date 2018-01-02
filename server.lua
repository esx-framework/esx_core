ESX = nil

local SeatsTaken = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- SEATS
RegisterServerEvent('esx_interact:takePlace')
AddEventHandler('esx_interact:takePlace', function(object)
	table.insert(SeatsTaken, object)
end)

RegisterServerEvent('esx_interact:leavePlace')
AddEventHandler('esx_interact:leavePlace', function(object)

	local _SeatsTaken = {}

	for i=1, #SeatsTaken, 1 do
		if object ~= SeatsTaken[i] then
			table.insert(_SeatsTaken, SeatsTaken[i])
		end
	end

	SeatsTaken = _SeatsTaken
	
end)

ESX.RegisterServerCallback('esx_interact:getPlace', function(source, cb, id)
	local found = false

	for i=1, #SeatsTaken, 1 do
		if SeatsTaken[i] == id then
			found = true
		end
	end
	cb(found)
end)