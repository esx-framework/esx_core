# esx_datastore

## Download & Installation

### Using [fvm](https://github.com/qlaffont/fvm-installer)
```
fvm install --save --folder=esx esx-org/esx_datastore
```

### Using Git
```
cd resources
git clone https://github.com/ESX-Org/esx_datastore [esx]/esx_datastore
```

### Manually
- Download https://github.com/ESX-Org/esx_datastore/archive/master.zip
- Put it in the `[esx]` directory

## Installation
- Import `esx_datastore.sql` in your database
- Add this in your `server.cfg`:

```
start esx_datastore
```

## Usage
There are two types of datastores: shared and not shared.

- Shared datastores does not belong to a specific user, Example: police armory
- None-shared datastores are created for every user in the server. They are created in db when player is loaded, Example: property (weapons, dressing).

### `datastore` database information
An datastore must be configured in the database before using it. Don't forget to run a server restart afterwards (you can alternative restart the script and relog all clients)

| `name`   | `label` | `shared` |
| -------- | ------- | -------- |
| name of the datastore | label of the datastore (not used) | is the datastore shared with others? (boolean either `0` or `1`) |

```lua
TriggerEvent('esx_datastore:getSharedDataStore', 'police', function(store)
	local weapons = store.get('weapons') or {}

	table.insert(weapons, {name = 'WEAPON_PUMPSHOTGUN', ammo = 50})
	store.set('weapons', weapons)
end)

TriggerEvent('esx_datastore:getDataStore', 'property', 'steam:0123456789', function(store)
	local dressing = store.get('dressing') or {}
end)
```

# Legal
### License
esx_datastore - datastore inventory for ESX

Copyright (C) 2015-2019 Jérémie N'gadi

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
