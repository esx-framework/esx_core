# Thanks to KASH and XxFri3ndlyxX

## Required changes:

* es_extended: (`es_extended/client/main.lua`)

Replace `AddEventHandler('playerSpawned', function()` (35) with:

```lua
RegisterNetEvent('esx:kashloaded')
AddEventHandler('esx:kashloaded', function()
```
