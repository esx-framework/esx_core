ESX                    = nil
Items                  = {}
local DataStoresIndex  = {}
local DataStores       = {}
local SharedDataStores = {}


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('onMySQLReady', function()

  local result = MySQL.Sync.fetchAll('SELECT * FROM datastore')

  for i=1, #result, 1 do

    local name   = result[i].name
    local label  = result[i].label
    local shared = result[i].shared

    local result2 = MySQL.Sync.fetchAll(
      'SELECT * FROM datastore_data WHERE name = @name',
      {
        ['@name'] = name
      }
    )

    if shared == 0 then

      table.insert(DataStoresIndex, name)

      DataStores[name] = {}

      for j=1, #result2, 1 do

        local storeName  = result2[j].name
        local storeOwner = result2[j].owner
        local storeData  = (result2[j].data == nil and {} or json.decode(result2[j].data))

        local dataStore = CreateDataStore(storeName, storeOwner, storeData)

        table.insert(DataStores[name], dataStore)

      end

    else

      local data = nil

      if #result2 == 0 then

        MySQL.Sync.execute(
          'INSERT INTO datastore_data (name, owner, data) VALUES (@name, NULL, \'{}\')',
          {
            ['@name'] = name,
          }
        )

        data = {}

      else
        data = json.decode(result2[1].data)
      end

      local dataStore   = CreateDataStore(name, nil, data)
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

AddEventHandler('esx:playerLoaded', function(source)

  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local dataStores = {}

  for i=1, #DataStoresIndex, 1 do

    local name      = DataStoresIndex[i]
    local dataStore = GetDataStore(name, xPlayer.identifier)

    if dataStore == nil then

      MySQL.Async.execute(
        'INSERT INTO datastore_data (name, owner, data) VALUES (@name, @owner, @data)',
        {
          ['@name']  = name,
          ['@owner'] = xPlayer.identifier,
          ['@data']  = '{}'
        }
      )

      dataStore = CreateDataStore(name, xPlayer.identifier, {})
      table.insert(DataStores[name], dataStore)
    end

    table.insert(dataStores, dataStore)

  end

  xPlayer.set('dataStores', dataStores)

end)

