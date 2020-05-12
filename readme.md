# Thanks to KASH and XxFri3ndlyxX
### If you are updating ESX, be sure to update the remaining scripts!

Instrukcja w języku Polskim znajduje się [tutaj](https://github.com/fivem-ex/esx_kashacter/blob/master/readme-pl.md).
![img](https://i.gyazo.com/9ec7181c10679e4053ced5349884f4e8.jpg)

## Required changes:

* es_extended: (`es_extended/client/main.lua`)
### Replace this code:
```lua
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if NetworkIsPlayerActive(PlayerId()) then
			TriggerServerEvent('esx:onPlayerJoined')
			break
		end
	end
end)
```

### with:
```lua
RegisterNetEvent('esx:kashloaded')
AddEventHandler('esx:kashloaded', function()
	TriggerServerEvent('esx:onPlayerJoined')
end)
```

* es_extended: (`es_extended/client/main.lua` at RegisterNetEvent('esx:playerLoaded'))
### Comment out this code:
```lua
-- check if player is coming from loading screen
	if GetEntityModel(PlayerPedId()) == GetHashKey('PLAYER_ZERO') then
		local defaultModel = GetHashKey('a_m_y_stbla_02')
		RequestModel(defaultModel)

		while not HasModelLoaded(defaultModel) do
			Citizen.Wait(100)
		end

		SetPlayerModel(PlayerId(), defaultModel)
		local playerPed = PlayerPedId()

		SetPedDefaultComponentVariation(playerPed)
		SetPedRandomComponentVariation(playerPed, true)
		SetModelAsNoLongerNeeded(defaultModel)
		FreezeEntityPosition(playerPed, false)
	end
```
### and  
```lua
		Citizen.Wait(3000)
		ShutdownLoadingScreen()
		FreezeEntityPosition(PlayerPedId(), false)
		DoScreenFadeIn(10000)
		StartServerSyncLoops()	
```
### keep
```lua
		FreezeEntityPosition(PlayerPedId(), false)
		StartServerSyncLoops()	
```

* es_extended: (`es_extended/server/main.lua`)

### Change this code in `onPlayerJoined(playerId)` function:
```lua
	for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
		if string.match(v, 'license:') then
			identifier = string.sub(v, 9)
			break
		end
	end
```

### to:
```lua
	for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
		if string.match(v, 'license:') then
			identifier = v
			break
		end
	end
```


# **IMPORTANT**
## Tables (Owned & Identifier)
- Now we edit the table and add all our identifier to make sure our character loads.
- *Edit the code in esx_kashacters\server\main.lua*
```
local IdentifierTables = {
    {table = "addon_account_data", column = "owner"},
    {table = "addon_inventory_items", column = "owner"},
    {table = "billing", column = "identifier"},
    {table = "datastore_data", column = "owner"},
    {table = "owned_vehicles", column = "owner"},
    {table = "owned_properties", column = "owner"},
    {table = "rented_vehicles", column = "owner"},
    {table = "users", column = "identifier"},
    {table = "user_licenses", column = "owner"}
}
```

To get your identifier.
Do this query in your database

`SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'owner'`

and

`SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'identifier'`

## Duplication Entry (Datastore)
To fix The datastore duplicated entry download this https://github.com/XxFri3ndlyxX/esx_datastore   

Or  

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

## Add this code 
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

# Read carefully...
> You **MUST** increase the character limit in all tables where column name `owner` or `identifier` occurs to at least  **48**.

> Do **not** use essentialsmode, mapmanager and spawnmanager!

> *ATTENTION: You have to call the resource **esx_kashacters** in order for the javascript to work!**

## How it works
> What this script does it manipulates ESX for loading characters
So when you are choosing your character it changes your **Rockstar license** which is normally **license:** to **Char:** this prevents ESX from loading another character because it is looking for you exact license. So when you choose your character it will change it from Char: to your normal Rockstar license (license:). When creating a new character it will spawn you without an exact license which creates a new database entry for your license.

## Multiple languages support
Just change locales/en.js in html/ui.html (line 10)
