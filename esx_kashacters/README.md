# KASHacters - ESX Multi Characters

## Installation
**_How to install instruction._ Created By XxFri3ndlyxX**
<br>
- First you need a serrver that has at least the basic scripts and their requirements. 



```
### [ESSENTIALS] ###
start mysql-async
start essentialmode
start esplugin_mysql
start es_extended
start async
start es_ui
start es_admin2
start esx_kashacters
start esx_identity
start skinchanger
start esx_skin
start instance
start esx_datastore
start esx_addonaccount
start esx_addoninventory
start cron
start esx_menu_default
start esx_menu_list
start esx_menu_dialog
start esx_license
start esx_billing
start esx_society
start esx_policejob
start esx_ambulancejob
start esx_vehicleshop
```

<br>
Then
<br>
- Download the resource
- Rename the resource to esx_kashacters
- import the sql file in your database
- Go to *essentialmode\client\main.lua* and edit/comment the code.


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
## Inventory Quick Fix
- To fix the inventory not showing after death. 
Quick fix you can do. 
In es_extended Look for 

```
-- Menu interactions
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		if IsControlJustReleased(0, Keys['F2']) and IsInputDisabled(0) and not isDead and not ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
			ESX.ShowInventory()
		end

	end
end)
```
and change it to 
```
-- Menu interactions
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		if IsControlJustReleased(0, Keys['F2']) and IsInputDisabled(0) and not ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
			ESX.ShowInventory()
		end

	end
end)
```
-I know this is not the best solution. But i don't have time to fix this the proper way. Use this quick fix or fix it properly on your own. I's something to do with isdead not being trigged properly.   Also you can do the same to other menu that don't work by removing the and not isDead

## Tables (Owned & Identifier)
- Now we edit the table and add all our identifier to make sure our character loads.
- *Edit the code in esx_kashacters\server\main.lua*


```
local IdentifierTables = {
    {table = "addon_account_data", column = "owner"},
	{table = "addon_inventory_items", column = "owner"},
    {table = "billing", column = "identifier"},
	{table = "characters", column = "identifier"},
	{table = "datastore_data", column = "owner"},
	{table = "owned_vehicles", column = "owner"},
    {table = "rented_vehicles", column = "owner"},
	{table = "society_moneywash", column = "identifier"},
	{table = "users", column = "identifier"},
    {table = "user_accounts", column = "identifier"},
	{table = "user_inventory", column = "identifier"},
	{table = "user_licenses", column = "owner"},
}
```

To get your identifier.
Do this query in your database

`SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'owner'`

and

`SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'indentifier'`


Credit @Xnubil for this query line 


The table list provided is just an example. Yours may differ depending on what you install on your server.

Once You've done all that. add start esx_kashacters to your server.cfg


## Ambulance Fix
The Fix for the ambulance on the kashacter script is already implemented.  

Now all you have to do is go to your ambulance script that is up to date and 
comment or delete



```
--[[
AddEventHandler('playerSpawned', function()
	IsDead = false

	if FirstSpawn then
		exports.spawnmanager:setAutoSpawn(false) -- disable respawn
		FirstSpawn = false

		ESX.TriggerServerCallback('esx_ambulancejob:getDeathStatus', function(isDead)
			if isDead and Config.AntiCombatLog then
				while not PlayerLoaded do
					Citizen.Wait(1000)
				end

				ESX.ShowNotification(_U('combatlog_message'))
				RemoveItemsAfterRPDeath()
			end
		end)
	end
end)
]]--
```
<br>
Then add this 
<br>

```
RegisterNetEvent('esx_ambulancejob:multicharacter')
AddEventHandler('esx_ambulancejob:multicharacter', function()
	IsDead = false

		ESX.TriggerServerCallback('esx_ambulancejob:getDeathStatus', function(isDead)
			if isDead and Config.AntiCombatLog then
				ESX.ShowNotification(_U('combatlog_message'))
				RemoveItemsAfterRPDeath()
			end
		end)
end)
```
Then change this 
```
function RespawnPed(ped, coords, heading)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetPlayerInvincible(ped, false)
	TriggerEvent('playerspawned', coords.x, coords.y, coords.z)
	ClearPedBloodDamage(ped)

	ESX.UI.Menu.CloseAll()
end
```
to
```
function RespawnPed(ped, coords, heading)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetPlayerInvincible(ped, false)
	TriggerEvent('esx_ambulancejob:multicharacter', coords.x, coords.y, coords.z)
	ClearPedBloodDamage(ped)

	ESX.UI.Menu.CloseAll()
end
```
If you do not do this last part once you repawn after death you will be frozen into place.

## Duplication Entry (Datastore)
To fix The datastore duplicated entry download this https://github.com/XxFri3ndlyxX/esx_datastore   

Or  

Add this code to your server/main.lua  
```-- Fix for kashacters duplication entry --
-- Fix was taken from this link --
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

> *Pay ATTENTION: You have to call the resource 'esx_kashacters' in order for the javascript to work!!!**

## How it works
> What this script does it manipulates ESX for loading characters
So when you are choosing your character it changes your steam id which is normally steam: to Char: this prevents ESX from loading another character because it is looking for you exact steamid. So when you choose your character it will change it from Char: to your normal steam id (steam:). When creating a new character it will spawn you without an exact steamid which creates a new database entry for your steamid

## Credits

> ESX Framework and **KASH** AND **Onno204** for creating the resource. You can do whatever the f with it what you want but it is nice to give the main man credits ;)
