# Thanks You KASH (github.com/KASHZIN)Who The Original Develop This ESX_KASHACTERS RELEASE And To XxFri3ndlyxX (github.com/XxFri3ndlyxX)

**this tutorial i made original a little bit use XxFri3ndlyxX tutorial :v**

**_How To Install and fix bug esx_kashacters**

- Step One [ essentialmode\client\main.lua ]

Delete Or Replace This !

```
--[[Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if NetworkIsSessionStarted() then
			TriggerServerEvent('es:firstJoinProper')
			TriggerEvent('es:allowedToSpawn')
			return
		end
	end
end)]]--
```

- Step Two [ es_extended [ LINE : 457 ] client/main.lua ]
This To Fix Cant Open Inventory When You Die And Get Revived

Change You Menu interactions to this !
 
 ```
 ---Menu interactions
Citizen.CreateThread(function()
	while true do
		
		Citizen.Wait(0)

		if IsControlJustReleased(0, 289) and IsInputDisabled(0) and not ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
			ESX.ShowInventory()
		end

	end
end)
```

- Step Three 
To Get Your esx_kashacters work you need do this on your query if you wan to check what is the owner and identifier tables

```SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'owner'
And This
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'identifier'
Credit @Xnubil```

- Step four [Fix Datastore]
Duplicate Your esx_datastore or add This line on your esx_datastore server\main.lua

```-- Fix was taken from this link --
-- https://forum.fivem.net/t/release-esx-kashacters-multi-character/251613/448?u=xxfri3ndlyxx --
AddEventHandler('esx:playerLoaded', function(source)

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

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
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

Download Link : https://github.com/XxFri3ndlyxX/esx_datastore
Credits : https://github.com/XxFri3ndlyxX

- Step Five [ Fix Ambulance Or Spawn ]
This To Fix Die Tele And When Your Get Revived You Cant Open any Menu only F2
Or Just Download My File the esx_ambulancejob (or download the lastest version esx_ambulancejob :v)

- Step Six [ Fix your esx_kashacters identifier ]
Download My mysql-async And start on your server.cfg

- Step Seven [ Fix Your Identifier And Spawn] 
Download My esx_kashacters Modified And start on your server.cfg
Thats All Identifier [esx_kashacters\server\main.lua] maybe thats all
you need in Roleplay Server if you wan to change just change it 

- Step Eight [ Fix F6 Can Open Menu ]
try to delete IsDie in the police and mechanic Menu
https://github.com/EbenSantuy/esx_kashacter-TUTORIAL-FIXED-ALL-ISSUE/issues/1#issuecomment-520927465

===--------------------------------------------------------------------===

# OkeyThats All Make My esx_kashacters work properly if you wanna ask
# My Discord : Blue.#5108

# Thank you Again to KASH And XxFri3ndlyxX ! :)
# ENJOY YOUR ESX_KASHACTERS



