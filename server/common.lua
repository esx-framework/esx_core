ESX = {}
ESX.Players = {}
ESX.UsableItemsCallbacks = {}
ESX.Items = {}
ESX.ServerCallbacks = {}
ESX.TimeoutCount = -1
ESX.CancelledTimeouts = {}
ESX.LastPlayerData = {}
ESX.Pickups = {}
ESX.PickupId = 0
ESX.Jobs = {}

AddEventHandler('esx:getSharedObject', function(cb)
	cb(ESX)
end)

function getSharedObject()
	return ESX
end

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM items', {}, function(result)
		for k,v in ipairs(result) do
			ESX.Items[v.name] = {
				label = v.label,
				weight = v.weight,
				rare = v.rare,
				canRemove = v.can_remove
			}
		end
	end)

	local result = MySQL.Sync.fetchAll('SELECT * FROM jobs', {})

	for i=1, #result do
		ESX.Jobs[result[i].name] = result[i]
		ESX.Jobs[result[i].name].grades = {}
	end

	local result2 = MySQL.Sync.fetchAll('SELECT * FROM job_grades', {})

	for i=1, #result2 do
		if ESX.Jobs[result2[i].job_name] then
			ESX.Jobs[result2[i].job_name].grades[tostring(result2[i].grade)] = result2[i]
		else
			print(('es_extended: invalid job "%s" from table job_grades ignored!'):format(result2[i].job_name))
		end
	end

	for k,v in pairs(ESX.Jobs) do
		if next(v.grades) == nil then
			ESX.Jobs[v.name] = nil
			print(('es_extended: ignoring job "%s" due to missing job grades!'):format(v.name))
		end
	end
end)

AddEventHandler('esx:playerLoaded', function(source)
	local xPlayer         = ESX.GetPlayerFromId(source)
	local accounts        = {}
	local items           = {}
	local xPlayerAccounts = xPlayer.getAccounts()
	local xPlayerItems    = xPlayer.getInventory()

	for i=1, #xPlayerAccounts, 1 do
		accounts[xPlayerAccounts[i].name] = xPlayerAccounts[i].money
	end

	for i=1, #xPlayerItems, 1 do
		items[xPlayerItems[i].name] = xPlayerItems[i].count
	end

	ESX.LastPlayerData[source] = {
		accounts = accounts,
		items    = items
	}
end)

RegisterServerEvent('esx:clientLog')
AddEventHandler('esx:clientLog', function(msg)
	RconPrint(msg .. "\n")
end)

RegisterServerEvent('esx:triggerServerCallback')
AddEventHandler('esx:triggerServerCallback', function(name, requestId, ...)
	local _source = source

	ESX.TriggerServerCallback(name, requestID, _source, function(...)
		TriggerClientEvent('esx:serverCallback', _source, requestId, ...)
	end, ...)
end)
