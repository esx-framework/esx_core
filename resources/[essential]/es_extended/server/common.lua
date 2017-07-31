ESX                      = {}
ESX.Players              = {}
ESX.UsableItemsCallbacks = {}
ESX.Items                = {}
ESX.ServerCallbacks      = {}

AddEventHandler('esx:getSharedObject', function(cb)
	cb(ESX)
end)

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