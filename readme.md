## ESX_Multicharacter
### Requirements
* [ESX Legacy](https://github.com/thelindat/es_extended) [Currently requires my fork]
* [esx_identity](https://github.com/thelindat/esx_identity) [Currently requires my fork]
* [esx_skin](https://github.com/thelindat/esx_skin) [Currently requires my fork]
* All `owner` and `identifier` columns in your SQL tables must be set to at least **VARCHAR(50)** to correctly insert data
* Do not run `essentialsmode` or `basic-gamemode`, and ensure you are using `spawnmanager`


### ESX Legacy  
* This resource is not compatible with previous versions of ESX or EXM
* Requires ESX_Identity and ESX_Skin to function properly - edits will be required to use other resources that modify character spawning
* You can not upgrade to this resource from the original release of kashacters; the methods used are entirely incompatible
* The player identifier used is set by ESX and by default only allows for a Rockstar License


### What's new?
Although kashacters provided an easy-to-use and free method of multiple characters, the method for doing so was inefficient and potentially database breaking.
* All users are created with a modified identifier entry, instead using `char#:identifier`
* There is no SQL table or modifications required for this to function
* Selecting a different character does not require modifying every instance of the characters identifier
* All tables containing an `owner` or `identifier` column are checked on startup, so character deletion will properly wipe all data


![image](https://user-images.githubusercontent.com/65407488/119008926-f71d5780-b9d5-11eb-882e-1c33862e8f42.png)


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
