# Thanks to KASH and XxFri3ndlyxX

## Required changes:

* es_extended: (`es_extended/client/main.lua`)

Replace `AddEventHandler('playerSpawned', function()` (35) with:

```lua
RegisterNetEvent('esx:kashloaded')
AddEventHandler('esx:kashloaded', function()
```

> *Pay ATTENTION: You have to call the resource 'esx_kashacters' in order for the javascript to work!!!**

## How it works
> What this script does it manipulates ESX for loading characters
So when you are choosing your character it changes your **Rockstar license** which is normally **license:** to **Char:** this prevents ESX from loading another character because it is looking for you exact license. So when you choose your character it will change it from Char: to your normal Rockstar license (license:). When creating a new character it will spawn you without an exact license which creates a new database entry for your license.

## Credits

> ESX Framework and **KASH** AND **Onno204** for creating the resource. You can do whatever the f with it what you want but it is nice to give the main man credits ;)
