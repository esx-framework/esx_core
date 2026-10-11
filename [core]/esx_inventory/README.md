<h1 align='center'>[ESX] Inventory</h1><p align='center'><b><a href='https://discord.esx-framework.org/'>Discord</a> - <a href='https://documentation.esx-framework.org/legacy/installation'>Documentation</a></b></h5>

NUI inventory for ESX Legacy. es_extended stays the authority on items, weight and validation; this resource is the presentation layer plus a generic storage bridge.

## Features
- Slot grid with drag and drop, the layout is per player and persisted locally (KVP)
- Use, give to nearby players and throw, backed by the existing validated es_extended events
- Give the ammo of a selected weapon to a nearby player
- Cash, black money and weapons shown next to items
- Hotbar styling on the first slots, with bindable keys (unbound by default) to use the item in that slot
- Item gained/lost toasts even while the inventory is closed
- Optional second panel for any storage another resource registers
- Theme convars support through `xLib.colors.getESXTheme()`: `esx:ui:primaryColor`, `esx:ui:secondaryColor`, `esx:ui:backgroundColor`, `esx:ui:accentColor`, `esx:ui:logoUrl` (logo shown above the panels when set)

## Keybinds
- `F2` opens and closes the inventory (rebindable in GTA settings)
- `Hotbar 1-5` unbound by default, usable items only

## Item images
`Config.ItemImageUrl` defaults to `nui://esx_inventory/web/images/%s.png`: drop your `itemname.png` files into `web/images/`. Any http(s) url template works too. Missing images fall back to an icon.

## Storage API (server)
Register a storage from any resource; the callbacks run synchronously in your resource and must not await:

```lua
local function registerStorages()
    exports.esx_inventory:RegisterStorage("society_mechanic", {
        label = "Mechanic Stock",
        slots = 30,
        maxWeight = 200,
        canAccess = function(xPlayer)
            return xPlayer.getJob().name == "mechanic"
        end,
        getItems = function(xPlayer)
            return stockItems -- { { name = "fixkit", label = "Repair Kit", count = 3 }, ... }
        end,
        putItem = function(xPlayer, itemName, count)
            return addToStock(itemName, count)
        end,
        takeItem = function(xPlayer, itemName, count)
            return removeFromStock(itemName, count)
        end,
        coords = vector3(-342.29, -133.37, 39.0), -- optional, transfers refused beyond distance
        distance = 5.0,
    })
end

AddEventHandler("esx_inventory:ready", registerStorages)

if GetResourceState("esx_inventory") == "started" then
    registerStorages()
end

exports.esx_inventory:OpenStorage(playerId, "society_mechanic")
exports.esx_inventory:RefreshStorage("society_mechanic")
```

- `putItem`/`takeItem` return `true` only after the storage state changed. Any other return value, or an error, is a failure: the player side (remove before put, carry check before and after take, refund on failure) is handled here, and transactions run one at a time per player.
- `slots` and `maxWeight` are enforced on put: a new item is refused once the storage holds `slots` distinct items, and `maxWeight` (0 disables it) is checked against the weights of the es_extended item registry.
- A storage belongs to the resource that registered it. It is unregistered when that resource stops, and the same resource may call `RegisterStorage` again to replace its definition.
- `esx_inventory:ready` is a local server event fired when esx_inventory starts: listen to it with `AddEventHandler` to register your storages again after an esx_inventory restart.
- `RefreshStorage(storageId)` pushes the current `getItems` result to everyone viewing the storage, call it after changing the storage state outside of `putItem`/`takeItem`.

## Structure
- `client/module/{slot,payload,ui,refresh,storage,keybind}/main.lua` and `server/module/storage/main.lua`, wired by the `client/main.lua` and `server/main.lua` entries
- `web/src` is the React source (`lib/types`, `hooks/use-drag`, one component per concern), `web/dist` the built output

## Building the UI
The NUI source lives in `web/src`, the shipped build in `web/dist`:

```
cd web
pnpm install
pnpm build
```

## Requirements
- es_extended with `EnableDefaultInventory` and without a custom inventory
