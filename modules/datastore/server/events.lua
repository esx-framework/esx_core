local self = ESX.Modules['datastore']

AddEventHandler('esx_datastore:getDataStore', function(name, owner, cb)

  Citizen.CreateThread(function()

    while not self.Ready do
      Citizen.Wait(0)
    end

    cb(self.GetDataStore(name, owner))

  end)

end)

AddEventHandler('esx_datastore:getDataStoreOwners', function(name, cb)

  Citizen.CreateThread(function()

    while not self.Ready do
      Citizen.Wait(0)
    end

    cb(self.GetDataStoreOwners(name))

  end)

end)

AddEventHandler('esx_datastore:getSharedDataStore', function(name, cb)

  Citizen.CreateThread(function()

    while not self.Ready do
      Citizen.Wait(0)
    end

    cb(self.GetSharedDataStore(name))

  end)

end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)

  Citizen.CreateThread(function()

    while not self.Ready do
      Citizen.Wait(0)
    end

    for i=1, #self.DataStoresIndex, 1 do
      local name = self.DataStoresIndex[i]
      local dataStore = self.GetDataStore(name, xPlayer.identifier)

      if not dataStore then
        MySQL.Async.execute('INSERT INTO datastore_data (name, owner, data) VALUES (@name, @owner, @data)', {
          ['@name']  = name,
          ['@owner'] = xPlayer.identifier,
          ['@data']  = '{}'
        })

        dataStore = CreateDataStore(name, xPlayer.identifier, {})
        table.insert(self.DataStores[name], dataStore)
      end
    end

  end)

end)

MySQL.ready(function()
	local result = MySQL.Sync.fetchAll('SELECT * FROM datastore')

	for i=1, #result, 1 do
		local name, label, shared = result[i].name, result[i].label, result[i].shared
		local result2 = MySQL.Sync.fetchAll('SELECT * FROM datastore_data WHERE name = @name', {
			['@name'] = name
		})

		if shared == 0 then
			table.insert(self.DataStoresIndex, name)
			self.DataStores[name] = {}

			for j=1, #result2, 1 do
				local storeName  = result2[j].name
				local storeOwner = result2[j].owner
				local storeData  = (result2[j].data == nil and {} or json.decode(result2[j].data))
				local dataStore  = self.CreateDataStore(storeName, storeOwner, storeData)

				table.insert(self.DataStores[name], dataStore)
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

			local dataStore = self.CreateDataStore(name, nil, data)
			self.SharedDataStores[name] = dataStore
		end
  end

  self.Ready = true

end)
