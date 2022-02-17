local DataStores, DataStoresIndex, SharedDataStores = {}, {}, {}

AddEventHandler('onResourceStart', function(resourceName)
	if resourceName == GetCurrentResourceName() then
		local dataStore = MySQL.query.await('SELECT * FROM datastore_data LEFT JOIN datastore ON datastore_data.name = datastore.name UNION SELECT * FROM datastore_data RIGHT JOIN datastore ON datastore_data.name = datastore.name')

		local newData = {}
		for i = 1, #dataStore do
			local data = dataStore[i]
			if data.shared == 0 then
				if not DataStores[data.name] then
					DataStoresIndex[#DataStoresIndex + 1] = data.name
					DataStores[data.name] = {}
				end
				DataStores[data.name][#DataStores[data.name] + 1] = CreateDataStore(data.name, data.owner, json.decode(data.data))
			else
				if data.data then
					SharedDataStores[data.name] = CreateDataStore(data.name, nil, json.decode(data.data))
				else
					newData[#newData + 1] = {data.name, '\'{}\''}
				end
			end
		end

		if next(newData) then
			MySQL.prepare('INSERT INTO datastore_data (name, data) VALUES (?, ?)', newData)
			for i = 1, #newData do
				local new = newData[i]
				SharedDataStores[new[1]] = CreateDataStore(new[1], nil, {})
			end
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
			MySQL.insert('INSERT INTO datastore_data (name, owner, data) VALUES (?, ?, ?)', {name, xPlayer.identifier, '{}'})

			DataStores[name][#DataStores[name] + 1] = CreateDataStore(name, xPlayer.identifier, {})
		end
	end
end)
