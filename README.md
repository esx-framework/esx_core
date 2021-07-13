<h1 align='center'>ESX Legacy</a></h1><p align='center'><b><a href='https://discord.gg/cNx6HF9P5J'>Development Discord</a> - <a href='https://esx-framework.org/'>Website</a> - <a href='https://discord.gg/J6VqFPwvVp'>Support Discord</a></b></h5>


##### ESX is the most popular framework for creating economy-based roleplay servers on FiveM, with many official and community resources designed to utilise the tools provided here. For a taste of what's available:
>	esx_identity: Enables character registration defining a players name, sex, height, and date of birth

>	esx_society: Allows job resources to register a society, gaining employee management, society funds, and more

>	esx_billing: Allows members of some societies to send fines or bills to other players

>	esx_vehicleshop: Allow players to purchase vehicles from a dealership, or setup society support for a player-managed dealership

>	esx_ambulancejob: Adds a death and respawn system while allowing players to work as EMS to heal and revive others

Many more resources are included in this repository, or you can browse the [ESX Community Github](https://github.com/esx-community/) or [Cfx.re Releases board](https://forum.cfx.re/tag/esx) for more.

### Information
##### Legacy provides some necessary bug-fixes and improvements to optimise the framework before reaching the end of official support by the development team.
##### Most resources designed for 1.2 will have no issues with Legacy, notable exceptions are those which modify spawning/loading behaviour.   There are several minor feature updates which do not impact compatibility with old resources.  
##### NOTE: The loadouts system in ESX has always been problematic, and fixing it would require a complete overhaul. Your best option is to use a resource that handles weapons as items.

#### Optimisation
- Utilise compile-time jenkins hashing over the GetHashKey native
- Update old MySQL queries to use MySQL.store to improve performance, especially during player saving
- Several loops will now sleep when their tasks are not necessary to perform
- Improved support when using ESX Identity to reduce events and queries during player login
- Support for the latest weapons and components

#### Features
- Integrated support for identity data
- Integrated commands from esx_adminplus
- All players will be saved immediately before a txAdmin scheduled restart
- Detect if a player is new and send the result to the playerLoaded event
- Support for players logging out when using multicharacter resources
- Cache the players ped id and death state in ESX.PlayerData
- Added an imports file (similar to locales.lua) for setting up events and functions in other resources
	- Before defining all manifest script files, add `shared_script '@es_extended/imports.lua'`
	- Automatically retrieve the ESX object, removing the need to send a callback event on both the client and server
	- Ensures current information is always returned when using `ESX.PlayerData` (except loadout and inventory)
- Spawnmanager is being utilised to correctly handle player spawns
	- Potential conflicts with some third-party resources that do not expect spawnmanager
- Added an improved function when performing xPlayer loops to prevent large server hitches
	- Using `ESX.GetExtendedPlayers()` instead of `ESX.GetPlayers()`
	- You can use arguments with the new function as well, such as
		- ESX.GetExtendedPlayers('job', 'police')
		- ESX.GetExtendedPlayers('group', 'admin')
			
#### Fixes
- ESX.Jobs table is populated after all jobs are setup, allowing other resources to retrieve it if needed
- All weapons are properly removed when using the clearloadout command
##### For creating or updating resources refer to the [updated boilerplate](/esx_example).

### 1.2 Features
- Weight based inventory system
- Weapons support, including support for attachments and tints
- Supports different money accounts (defaulted with cash, bank and black money)
- Many official resources available in our GitHub
- Job system, with grades and clothes support
- Supports multiple languages, most strings are localized
- Easy to use API for developers to easily integrate ESX to their projects
- Register your own commands easily, with argument validation, chat suggestion and using FXServer ACL

### Requirements
- All resources from the `core` folder
- [spawnmanager](https://github.com/citizenfx/cfx-server-data)
- [mysql-async](https://github.com/brouznouf/fivem-mysql-async/releases/tag/3.3.2)


### Installation
- Download files to the resources folder and, if desired, prepare directories for organisation (i.e. resources/[core]/es_extended)
- Import `es_extended.sql` in your database
- Import any other sql files for the resources you are using
- Ensure all resources config files have been adjusted for your preferences
- Use or refer to the included server.cfg for start order and settings

### Conflicts
* The following resources should not be used with ESX Legacy
	- essentialmode
	- basic-gamemode
	- fivem-map-skater
	- fivem-map-hipster
	- default_spawnpoint

### Information
ESX was initially developed by Gizz back in 2017 for his friend as the were creating an FiveM server and there wasn't any economy roleplaying frameworks available. The original code was written within a week or two and later open sourced, it has ever since been improved and parts been rewritten to further improve on it.
- [ESX Documentation](https://esx-framework.github.io/es_extended/)
- [FiveM Native Reference](https://runtime.fivem.net/doc/reference.html)


### Legal

### License

es_extended - ESX framework for FiveM

Copyright (C) 2015-2021 Jérémie N'gadi

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
