# fxserver-esx_addoninventory
ESX AddonInventory

[INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/FXServer-ESX/fxserver-esx_addoninventory esx_addoninventory
```
3) Import esx_addoninventory.sql in your database
1) Add this in your server.cfg :

```
start esx_addoninventory
```

[USAGE]

There is two types of inventories : shared and not shared.

- Shared inventories dont belong to a specific user. Example : foodstore items.
- Not shared inventories are created for every user in the server. They are created in db when player is loaded, Example : property items

You must create the inventory in the database (addon_inventory) before using it :

name = name of the inventory, label = label of the inventory, shared (0 or 1) = Is inventory shared

```
TriggerEvent('esx_addoninventory:getSharedInventory', 'main_grocery', function(inventory)
  inventory.addItem('bread', 1)
end)

TriggerEvent('esx_addoninventory:getInventory', 'property', 'steam:0123456789', function(inventory)
  inventory.removeItem('water', 1)
end)
```
