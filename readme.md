### Requirements (ensure you are using the latest)
- [ESX Legacy](https://github.com/esx-framework/esx-legacy)
- [OxMySQL](https://github.com/overextended/oxmysql/releases)

### Conflicts
* The following resources should not be used with ESX Legacy and can result in errors
	- essentialmode
	- basic-gamemode
	- fivem-map-skater
	- fivem-map-hipster
	- default_spawnpoint

### Installation
- Modify your ESX config with `Config.Multichar = true`
- Set your database name for `Config.Database` in server/main.lua
- Run `esx_multicharacter.sql` into your database
- All owner and identifier columns should be set to `VARCHAR(60)` to ensure correct data entry
	- The resource will attempt to set columns automatically


#### The menu is esx_menu_default - you can use any version if you want a different appearance
![image](https://user-images.githubusercontent.com/65407488/126976325-17cc3241-bb9e-451f-a6ed-610a8ef52fa5.png)

### Relogging
- Do not enable this setting if you do not intend to properly set up relog support
- Requires the latest update for ESX Status (prevents multiple status ticks from running)
- Add the following events to resources that require support for relogging, or
- Add them to [@esx/imports.lua](https://github.com/esx-framework/es_extended/blob/legacy/imports.lua) (and use the imports in your resources)
```lua
RegisterNetEvent('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
 	ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)
```

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
Copyright © 2021 Linden <https://github.com/thelindat/> and KASH

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
