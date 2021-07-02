<h3 align='center'>Although this resource is included, a more updated version <a href='https://github.com/thelindat/esx_multicharacter'>may be available</a>.</h3>


### Requirements (ensure you are using the latest)
- [ESX Legacy](https://github.com/esx-framework/es_extended/tree/legacy)
- [MySQL Async 3.3.2](https://github.com/brouznouf/fivem-mysql-async/releases/tag/3.3.2)
- [ESX Identity](https://github.com/esx-framework/esx_identity)
- [ESX Skin](https://github.com/esx-framework/esx_skin)
- [Spawnmanager](https://github.com/citizenfx/cfx-server-data/tree/master/resources/%5Bmanagers%5D/spawnmanager)

### Installation
- Modify your ESX config with `Config.Multichar = true`
- Set your database name for `Config.Database` in server/main.lua
- All owner and identifier columns should be set to `VARCHAR(60)` to ensure correct data entry
- Use the `varchar` command from the console to update your SQL tables
- Once you have used the command you should just remove it for sanity's sake

### Conflicts
* The following resources should not be used with ESX Legacy and can result in errors
	- **essentialsmode**
	- basic-gamemode
	- fivem-map-skater
	- fivem-map-hipster
	- default_spawnpoint
	- cui_character (or other resources that modify spawn behaviour)

### Common issues
#### Black screen / loading scripts
	- Download and run all requirements
	- Ensure none of the conflicting resources are enabled
#### mysql-async duplicate entry
	- You have not increased the VARCHAR size of the table holding identifiers - usually `owner` or `identifier`

#### The menu interface is esx_menu_default - you can use any version if you want a different appearance
![image](https://user-images.githubusercontent.com/65407488/119010385-592a8c80-b9d7-11eb-9aa1-eb7051004843.png)

### Relogging
- Do not enable this setting if you do not intend to properly set up relog support
- Requires the latest update for ESX Status (prevents multiple status ticks from running)
- Add the following events to resources that require support for relogging, or
- Add them to [@esx/imports.lua](https://github.com/esx-framework/es_extended/blob/legacy/imports.lua) (and use the imports in your resources)
```lua
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
 	ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)
```
- Any threads using ESX.PlayerData in a loop should check if ESX.PlayerLoaded is true
	- This ensures the resource does not error after relogging, or while on character selection
	- Setup correctly you can break your loops and trigger them again after loading
	- Refer to my [boilerplate](https://github.com/thelindat/esx_legacy_boilerplate) for more information and usage examples

### Notes
- This resource is not compatible with ExtendedMode or previous versions of ESX
- Legacy, skin, and identity must be updated to at least the minimum commits specified above
- Characters are stored in the users table as `char#:license` - if you need to use a different identifier then you need to modify ESX itself
- Character deletion does not require manual entries for the tables to remove
- As characters are stored with unique identifiers, there is no excessive queries being executed
	
### Kashacters
- This project is forked from the [kashacters multicharacter resource](https://github.com/FiveEYZ/esx_kashacter)
- Most of the code has been entirely rewritten
- KASH has given permission for this resource to use his code and the addition of a license
- The license obviously does not apply to previous versions and KASH has stated his resource is free to be used however



## Notice
Copyright© 2021 Linden and KASH

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see https://www.gnu.org/licenses.


### Thanks to KASH, XxFri3ndlyxX, and all those who have contributed
