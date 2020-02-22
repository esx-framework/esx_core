# Thanks to KASH and XxFri3ndlyxX

## Required changes:

* es_extended:
  * `es_extended/client/main.lua`

Change `AddEventHandler('playerSpawned', function()` (35) to:

```lua
RegisterNetEvent('esx:kashloaded')
AddEventHandler('esx:kashloaded', function()
```