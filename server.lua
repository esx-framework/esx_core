ESX = nil
local occupied = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('sit:occupyObj')
AddEventHandler('sit:occupyObj', function(object)
	table.insert(occupied, object)
end)

RegisterServerEvent('sit:unoccupyObj')
AddEventHandler('sit:unoccupyObj', function(object)
	for k,v in pairs(occupied) do
		if v == object then
			table.remove(occupied, k)
		end
	end
	end)


ESX.RegisterServerCallback('sit:getOccupied', function(source, cb)
	cb(occupied)
end)