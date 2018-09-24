# esx_addoninventory

## Download & Installation

### Using [fvm](https://github.com/qlaffont/fvm-installer)
```
fvm install --save --folder=esx esx-org/esx_addoninventory
```

### Using Git
```
cd resources
git clone https://github.com/ESX-Org/esx_addoninventory [esx]/esx_addoninventory
```

### Manually
- Download https://github.com/ESX-Org/esx_addoninventory/archive/master.zip
- Put it in the `[esx]` directory

## Installation
- Import `esx_addoninventory.sql` in your database
- Add this in your `server.cfg`:

```
start esx_addoninventory
```

## Usage
There is two types of inventories : shared and not shared.

- Shared inventories dont belong to a specific user. Example: foodstore items.
- Not shared inventories are created for every user in the server. They are created in db when player is loaded, Example: property items

You must create the inventory in the database (addon_inventory) before using it :

name = name of the inventory, label = label of the inventory, shared (0 or 1) = Is inventory shared

```lua
TriggerEvent('esx_addoninventory:getSharedInventory', 'society_police', function(inventory)
	inventory.addItem('bread', 1)
end)

TriggerEvent('esx_addoninventory:getInventory', 'property', 'steam:0123456789', function(inventory)
	inventory.removeItem('water', 1)
end)

```
# Legal
### License
esx_addoninventory - inventories!

Copyright (C) 2015-2018 Jérémie N'gadi

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.