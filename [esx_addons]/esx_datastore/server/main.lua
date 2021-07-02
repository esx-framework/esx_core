local DataStores, DataStoresIndex, SharedDataStores = {}, {}, {}
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()
	local result = MySQL.Sync.fetchAll('SELECT * FROM datastore')

	for i=1, #result, 1 do
		local name, label, shared = result[i].name, result[i].label, result[i].shared
		local result2 = MySQL.Sync.fetchAll('SELECT * FROM datastore_data WHERE name = @name', {
			['@name'] = name
		})

		if shared == 0 then
			table.insert(DataStoresIndex, name)
			DataStores[name] = {}

			for j=1, #result2, 1 do
				local storeName  = result2[j].name
				local storeOwner = result2[j].owner
				local storeData  = (result2[j].data == nil and {} or json.decode(result2[j].data))
				local dataStore  = CreateDataStore(storeName, storeOwner, storeData)

				table.insert(DataStores[name], dataStore)
			end
		else
			local data

			if #result2 == 0 then
				MySQL.Sync.execute('INSERT INTO datastore_data (name, owner, data) VALUES (@name, NULL, \'{}\')', {
					['@name'] = name
				})

				data = {}
			else
				data = json.decode(result2[1].data)
			end

			local dataStore = CreateDataStore(name, nil, data)
			SharedDataStores[name] = dataStore
		end
	end
end)

function GetDataStore(name, owner)
	for i=1, #DataStores[name], 1 do
		if DataStores[name][i].owner == owner then
			return DataStores[name][i]
		end
	end
end

function GetDataStoreOwners(name)
	local identifiers = {}

	for i=1, #DataStores[name], 1 do
		table.insert(identifiers, DataStores[name][i].owner)
	end

	return identifiers
end

function GetSharedDataStore(name)
	return SharedDataStores[name]
end

AddEventHandler('esx_datastore:getDataStore', function(name, owner, cb)
	cb(GetDataStore(name, owner))
end)

AddEventHandler('esx_datastore:getDataStoreOwners', function(name, cb)
	cb(GetDataStoreOwners(name))
end)

AddEventHandler('esx_datastore:getSharedDataStore', function(name, cb)
	cb(GetSharedDataStore(name))
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	for i=1, #DataStoresIndex, 1 do
		local name = DataStoresIndex[i]
		local dataStore = GetDataStore(name, xPlayer.identifier)

		if not dataStore then
			MySQL.Async.execute('INSERT INTO datastore_data (name, owner, data) VALUES (@name, @owner, @data)', {
				['@name']  = name,
				['@owner'] = xPlayer.identifier,
				['@data']  = '{}'
			})

			dataStore = CreateDataStore(name, xPlayer.identifier, {})
			table.insert(DataStores[name], dataStore)
		end
	end
end)
