<h1 align='center'>ESX Legacy</a></h1><h5 align='center'>There is no official support for this resource. Create a thread on the <a href='https://forum.cfx.re/c/server-development/essentialmode/46'>ESX Server Development board</a> or find a support Discord.</h5>


ESX is the most popular framework for creating an economy-based roleplay server on FiveM, with many more official and unofficial resources designed to utilise the tools provided by this resource. Here's a taste of what's available:

###### `esx_identity` enable character registration using a name, sex, and date of birth
###### `esx_society` add employee management, society funds and more
###### `esx_billing` add support for registered societies to fine or bill players
###### `esx_vehicleshop` allow players to purchase vehicles directly or from players
###### `esx_ambulancejob` adds a death and respawn system while allowing players to become EMS to heal or revive others
###### `esx_policejob` allow players to become cops, granting the ability to detain and fine others


Many more resources are available on the [ESX Framework Github](https://github.com/esx-framework) and [ESX Community Github](https://github.com/esx-community/) pages.


## Information

- [ESX Forum](https://forum.esx-framework.org/)
- [ESX Documentation](https://wiki.esx-framework.org/)
- [ESX Development Discord](https://discord.me/esx)
- [FiveM Native Reference](https://runtime.fivem.net/doc/reference.html)

ESX was initially developed by Gizz back in 2017 for his friend as the were creating an FiveM server and there wasn't any economy roleplaying frameworks available. The original code was written within a week or two and later open sourced, it has ever since been improved and parts been rewritten to further improve on it.


## Legacy

ESX Legacy is mostly intended as a bug-fix and optimisation update to provide a more stable experience for the people using ESX 1.2 or Final, however there are also some new features added in to allow better server performance with other resources and official support for esx_multicharacter.
#### Bug fixes
* ESX.Jobs is no longer set until the full table has been creating, allowing other resources to retrieve it more easily
* Now using spawnmanager to spawn players and prevent weird desync issues
	- This may cause problems with some third-party resources that modify player spawns
* /clearloadout now properly removes all weapons instead of needing to be performed multiple times
 
#### Optimisation
* Support for compile-time hashing instead of calling the native
* Utilise the `MySQL.Store` function to reduce overhead when executing queries
* Allow loops to sleep while not performing any tasks
* The current player ped and death status are now stored in ESX.PlayerData, reducing the need to constantly call the native
* Weapon ammo is no longer synced on every frame, instead triggering a server event once shooting has ceased
* Reduced the number of queries being performed by a single player connecting to the server

#### Features
* Support for the latest weapons and components
* Additional admin commands from esx_adminplus
* Save all players before the txAdmin scheduled restarts
* When loading a new player, send the isNew argument along with `esx:playerLoaded`
* Added an imports file to load in other resource manifests with `shared_script '@es_extended/imports.lua'`
	- Removes the need to define ESX in your resources, as it will perform the task for you
	- Ensures ESX.PlayerData will always return current information (exception: loadout and inventory)
* Support for relogging, clearing all player data and cancelling sync loops
* Added the `ESX.GetExtendedPlayers` function to be used with xPlayer loops without causing massive server hitches

To get an idea for how you can utilise imports and the new functions, you can refer to [this updated boilerplate](https://github.com/thelindat/esx_legacy_boilerplate).  
##### Any resources made using the imports will only work for ESX Legacy.


## Conflicts
* The following resources should not be used with ESX Legacy and can result in errors
	- **essentialsmode**
	- basic-gamemode
	- fivem-map-skater
	- fivem-map-hipster
	- default_spawnpoint


## 1.2 + Features

- Weight based inventory system
- Weapons support, including support for attachments and tints
- Supports different money accounts (defaulted with cash, bank and black money)
- Many official resources available in our GitHub
- Job system, with grades and clothes support
- Supports multiple languages, most strings are localized
- Easy to use API for developers to easily integrate ESX to their projects
- Register your own commands easily, with argument validation, chat suggestion and using FXServer ACL


## Requirements

- [mysql-async](https://github.com/brouznouf/fivem-mysql-async)
- [async](https://github.com/esx-framework/async)


## Download & Installation


### Using Git

```
cd resources
git clone https://github.com/esx-framework/es_extended.git --branch legacy
git clone https://github.com/esx-framework/esx_menu_default [esx]/[ui]/esx_menu_default
git clone https://github.com/esx-framework/esx_menu_dialog [esx]/[ui]/esx_menu_dialog
git clone https://github.com/esx-framework/esx_menu_list [esx]/[ui]/esx_menu_list
```

### Plume ESX:

PlumeESX is a full featured (13 jobs) and highly configurable yet lightweight ESX v1.2 base that can be easily extendable.
Forum Thread: https://forum.cfx.re/t/recipe-plumeesx-full-base-2021/1964029
YouTube Tutorial: https://www.youtube.com/watch?v=iGfwUCO0RZQ

### Manually

- Download https://github.com/esx-framework/es_extended/archive/refs/heads/legacy.zip
- Put it in the `resource/[esx]` directory
- Download https://github.com/esx-framework/esx_menu_default/archive/refs/heads/master.zip
- Put it in the `resource/[esx]/[ui]` directory
- Download https://github.com/esx-framework/esx_menu_dialog/archive/refs/heads/master.zip
- Put it in the `resource/[esx]/[ui]` directory
- Download https://github.com/esx-framework/esx_menu_list/archive/refs/heads/master.zip
- Put it in the `resource/[esx]/[ui]` directory


### Installation

- Import `es_extended.sql` in your database
- Configure your `server.cfg` to look like this

```
add_principal group.admin group.user
add_ace resource.es_extended command.add_ace allow
add_ace resource.es_extended command.add_principal allow
add_ace resource.es_extended command.remove_principal allow
add_ace resource.es_extended command.stop allow

start mysql-async
start es_extended

start esx_menu_default
start esx_menu_list
start esx_menu_dialog
```

## Reborn

ESX Reborn is the name for the framework being actively developed by the team, with many existing features being rewritten and improved upon. It is currently possible to create a server using ESX Reborn, however the project is still missing many features and should not be used unless you are a developer looking to contribute in some way.


## Legal

### License

es_extended - ESX framework for FiveM

Copyright (C) 2015-2021 Jérémie N'gadi

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
