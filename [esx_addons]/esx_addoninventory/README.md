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
There are two types of inventories: shared and not shared.

- Shared inventories don't belong to a specific user. Example: foodstore items.
- None-shared inventories are created for every user in the server. They are created in db when player is loaded, Example: property items

### `addon_inventory` database information
An addon inventory must be configured in the database before using it. Don't forget to run a server restart afterwards (you can alternative restart the script and relog all clients)

| `name`   | `label` | `shared` |
| -------- | ------- | -------- |
| name of the inventory | label of the inventory (not used) | is the inventory shared with others? (boolean either `0` or `1`) |

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

Copyright (C) 2015-2022 Jérémie N'gadi

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.