### Requirements
* [ESX Legacy](https://github.com/thelindat/es_extended/tree/multichar) [Currently requires my fork]
* [esx_identity](https://github.com/thelindat/esx_identity) [Currently requires my fork]
* [esx_skin](https://github.com/thelindat/esx_skin) [Currently requires my fork]
* [spawnmanager](https://github.com/citizenfx/cfx-server-data/blob/master/resources/[managers]/spawnmanager)
* Do not run `essentialsmode` or `basic-gamemode`


### Installation
* Modify your ESX config and set `Config.Multichar = true`
* All `owner` and `identifier` columns in your SQL must have their size increased to at least **VARCHAR(50)**
* You can add the following command to `server.lua` to easily update all your columns
```lua
	RegisterCommand('varchar', function(source)
		if source == 0 then
			for _, itable in pairs(IdentifierTables) do
				print('Setting `'..itable.table..'` column `'..itable.column..'` to VARCHAR(50)')
				MySQL.Sync.execute("ALTER TABLE "..itable.table.." MODIFY COLUMN "..itable.column.." VARCHAR(50)", {})
			end
		end
	end, true)
```


### ESX Legacy  
* This resource is not compatible with previous versions of ESX or EXM
* Requires ESX_Identity and ESX_Skin to function properly - edits will be required to use other resources that modify character spawning
* The method for storing characters is different from kashacters - if you want to use previous characters you will need to find a way to update stored identifiers
* The player identifier used is set by ESX and by default only allows for a Rockstar License


### What's new?
Although kashacters provided an easy-to-use and free method of multiple characters, the method for doing so was inefficient and potentially database breaking.
* All users are created with a modified identifier entry, instead using `char#:identifier`
* There is no SQL table or modifications required for this to function
* Selecting a different character does not require modifying every instance of the characters identifier
* All tables containing an `owner` or `identifier` column are checked on startup, so character deletion will properly wipe all data

#### The menu interface is esx_menu_default - you can use any version if you want a different appearance
![image](https://user-images.githubusercontent.com/65407488/119010385-592a8c80-b9d7-11eb-9aa1-eb7051004843.png)



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


# Thanks to KASH and XxFri3ndlyxX
