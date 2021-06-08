### Requirements
#### [ESX Legacy](https://github.com/esx-framework/es_extended/tree/legacy)
- Minimum commit: 89f8d87
- Legacy is an update from v1 Final with bug fixes, optimisations and some new features
#### [MySQL Async](https://github.com/brouznouf/fivem-mysql-async/releases/tag/3.3.2)
- Minimum commit:  ec81359
#### [ESX Identity](https://github.com/esx-framework/esx_identity)
- Minimum commit: 5d28b23
- Required for character registration
#### [ESX Skin](https://github.com/esx-framework/esx_skin)
- Minimum commit: 3a81208
- If you wish to use other resources, you will need to adjust events in multicharacter
#### [Spawnmanager](https://github.com/citizenfx/cfx-server-data/tree/master/resources/%5Bmanagers%5D/spawnmanager)
- Required for spawning as well as ESX Legacy

### Installation
- Modify your ESX config with `Config.Multichar = true`
- Set your database name for `Config.Database` in server/main.lua
- All owner and identifier columns should be set to `VARCHAR(60)` to ensure correct data entry
- Use the `varchar` command from the console to update your SQL tables
- Once you have used the command you should just remove it for sanity's sake
### Relogging
- Modify the config with `Config.Relog = true`
- Use the latest version of [ESX Status](https://github.com/esx-framework/esx_status)
- If you have any threads running with `while true do` I recommend using `while ESX.PlayerLoaded do` instead
	- For threads that are triggered by a spawn/load event this will ensure they do not start a second time
	- You can clear loops that may break after ESX.PlayerData is cleared
	- For an example, refer to my [boilerplate](https://github.com/thelindat/esx_legacy_boilerplate/blob/main/client.lua)
- Add the following event to any resources that will benefit from clearing ESX.PlayerData
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

#### The menu interface is esx_menu_default - you can use any version if you want a different appearance
![image](https://user-images.githubusercontent.com/65407488/119010385-592a8c80-b9d7-11eb-9aa1-eb7051004843.png)

### Conflicts
	- essentialsmode
	- basic-gamemode
	- fivem-maps
	- cui_character

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
