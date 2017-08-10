ESX                      = {}
ESX.Players              = {}
ESX.UsableItemsCallbacks = {}
ESX.Items                = {}
ESX.ServerCallbacks      = {}
ESX.LastPlayerData       = {}

AddEventHandler('esx:getSharedObject', function(cb)
	cb(ESX)
end)

function getSharedObject()
	return ESX
end

AddEventHandler('onMySQLReady', function ()

	MySQL.Async.fetchAll(
		'SELECT * FROM items',
		{},
		function(result)

			for i=1, #result, 1 do
				ESX.Items[result[i].name] = {
					label = result[i].label,
					limit = result[i].limit
				}
			end

		end
	)

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
