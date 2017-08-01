# fxserver-esx_datastore
FXServer ESX DataStore

[INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/FXServer-ESX/fxserver-esx_datastore esx_datastore
```
3) Import esx_datastore.sql in your database
1) Add this in your server.cfg :

```
start esx_datastore
```

[USAGE]

There is two types of datastores : shared and not shared.

- Shared datastores dont belong to a specific user. Example : property (weapons, dressing).
- Not shared datastores are created for every user in the server. They are created in db when player is loaded, Example : police armory

You must create the datastore in the database (datastore) before using it :

name = name of the datastore, label = label of the datastore, shared (0 or 1) = Is datastore shared

```
TriggerEvent('esx_datastore:getSharedDataStore', 'police', function(store)
  
  local weapons = store.get('weapons')
  
   if weapons == nil then
     weapons = {}
   end
  
  table.insert(weapons, {name = 'WEAPON_PUMPSHOTGUN', ammo = 50})
  
  store.set('weapons', weapons)
  
end)

TriggerEvent('esx_datastore:getDataStore', 'property', 'steam:0123456789', function(store)
  
  local dressing = store.get('dressing')
  
  if dressing == nil then
    dressing = {}
  end
  
end)
```
