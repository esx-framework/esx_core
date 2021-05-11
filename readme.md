### ESX Legacy  
This resource is using some new features added in the latest update to ESX v1.
Requires esx_identity and esx_skin to work - if you want to use something else (such as cui_character) you will need to work out the necessary changes.
* By default, identifiers will write as `char#:license`, you can change the prefix in kashacters but the identifier is set by ESX


### Nuclear Disarmament  
The old kashacters queried the database when you selected a different character than your last; selecting the 3rd slot meant replacing every instance of `license` with `Char2:license`, then updating `Char3:license` to just `license`.  
While the end result worked it wasn't exactly optimised and had the reputation of "nuking your database".
* When a character is created, append the character id to the license
* (Framework) xPlayer and ESX.PlayerData `identifier` will display `char#:license` - `license` will display the actual identifier

### Requirements
* [esx_identity 83d155e](https://github.com/thelindat/esx_identity/tree/83d155e01e3ebfd87f2577052d343b60d56fc25a) Needs to be my fork for the moment
* [esx_skin 1a0302b](https://github.com/esx-framework/esx_skin/tree/1a0302be4d6dc44d4cb80588775c8723e6f8d6c4)
* Resource must be named `esx_kashacters` to function properly
* All `owner` and `identifier` columns in your SQL tables must be set to at least **VARCHAR(50)** to correctly insert data
* Do not run `essentialsmode` and ensure you are using `spawnmanager`


# Information below is outdated and pending review

## SQL Injection fix from [KASHZIN/kashacters/pull/36](https://github.com/KASHZIN/kashacters/pull/36) is applied to this fork!

# Thanks to KASH and XxFri3ndlyxX


## Current design:
![img](https://i.gyazo.com/9ec7181c10679e4053ced5349884f4e8.jpg)


## Duplication Entry (Datastore)

* esx_datastore: (`esx_datastore/server/main.lua `)
### Comment out this code:
```lua
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
```

### Add this code 
```lua
-- Fix for kashacters duplication entry --
-- Fix was taken from this link --
-- https://forum.fivem.net/t/release-esx-kashacters-multi-character/251613/448?u=xxfri3ndlyxx --
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)

local result = MySQL.Sync.fetchAll('SELECT * FROM datastore')

    for i=1, #result, 1 do
        local name   = result[i].name
        local label  = result[i].label
        local shared = result[i].shared

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
        end
    end

    local dataStores = {}
    for i=1, #DataStoresIndex, 1 do
        local name      = DataStoresIndex[i]
        local dataStore = GetDataStore(name, xPlayer.identifier)

        if dataStore == nil then
            MySQL.Async.execute('INSERT INTO datastore_data (name, owner, data) VALUES (@name, @owner, @data)',
            {
                ['@name']  = name,
                ['@owner'] = xPlayer.identifier,
                ['@data']  = '{}'
            })

            dataStore = CreateDataStore(name, xPlayer.identifier, {})
            table.insert(DataStores[name], dataStore)
        end

        table.insert(dataStores, dataStore)
    end

    xPlayer.set('dataStores', dataStores)
end)
```
