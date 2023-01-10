<h1 align='center'>[ESX] Data Store</a></h1><p align='center'><b><a href='https://discord.esx-framework.org/'>Discord</a> - <a href='https://esx-framework.org/'>Website</a> - <a href='https://docs.esx-framework.org/legacy/installation'>Documentation</a></b></h5>

A simple script for storing data :)

# Usage

There are two types of datastores: shared and not shared.

- Shared datastores does not belong to a specific user, Example: police armory
- None-shared datastores are created for every user in the server. They are created in db when player is loaded, Example: property (weapons, dressing).

## `datastore` database information

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

esx_datastore - Datastore for ESX-Framework

Copyright (C) 2015-2022 Jérémie N'gadi

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
