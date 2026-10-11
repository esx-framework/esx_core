-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Inventory = ESXInventory

local itemsBySlot = nil
local ownedItems = nil
local cachedInventory = nil
local cachedLoadout = nil
local cachedAccounts = nil

function Inventory.invalidateItems()
    itemsBySlot = nil
    ownedItems = nil
end

local function ensureItems()
    local data = ESX.PlayerData

    if
        not itemsBySlot
        or data.inventory ~= cachedInventory
        or data.loadout ~= cachedLoadout
        or data.accounts ~= cachedAccounts
    then
        Inventory.buildItems()
    end
end

function Inventory.getItemInSlot(slot)
    ensureItems()

    return itemsBySlot[slot]
end

function Inventory.getOwnedItem(itemType, name)
    ensureItems()

    local items = ownedItems[itemType]

    return items and items[name]
end

---@return NuiInventoryItem[]
function Inventory.buildItems()
    local items = {}
    local owned = {
        item_standard = {},
        item_weapon = {},
    }

    for i = 1, #(ESX.PlayerData.accounts or {}) do
        local account = ESX.PlayerData.accounts[i]

        if account.money > 0 and account.name ~= 'bank' then
            items[#items + 1] = {
                type = 'item_account',
                name = account.name,
                label = account.label,
                count = account.money,
                weight = 0,
                usable = false,
                canRemove = true,
                image = Config.ItemImageUrl:format(account.name),
            }
        end
    end

    for i = 1, #(ESX.PlayerData.inventory or {}) do
        local item = ESX.PlayerData.inventory[i]

        owned.item_standard[item.name] = item

        if item.count > 0 then
            items[#items + 1] = {
                type = 'item_standard',
                name = item.name,
                label = item.label,
                count = item.count,
                weight = item.weight,
                usable = item.usable == true,
                canRemove = item.canRemove == true,
                image = Config.ItemImageUrl:format(item.name),
            }
        end
    end

    for i = 1, #(ESX.PlayerData.loadout or {}) do
        local weapon = ESX.PlayerData.loadout[i]

        owned.item_weapon[weapon.name] = weapon

        local label = weapon.ammo
                and ('%s [%s %s]'):format(weapon.label, weapon.ammo, TranslateCap('ammo_rounds'))
            or weapon.label

        items[#items + 1] = {
            type = 'item_weapon',
            name = weapon.name,
            label = label,
            count = 1,
            weight = 0,
            usable = true,
            canRemove = true,
            image = Config.ItemImageUrl:format(weapon.name),
            ammo = type(weapon.ammo) == 'number' and weapon.ammo or 0,
        }
    end

    Inventory.assignSlots(items)
    Inventory.saveSlotMap()

    itemsBySlot = {}

    for i = 1, #items do
        local item = items[i]

        itemsBySlot[item.slot] = item
    end

    cachedInventory = ESX.PlayerData.inventory
    cachedLoadout = ESX.PlayerData.loadout
    cachedAccounts = ESX.PlayerData.accounts
    ownedItems = owned

    return items
end

---@param items NuiInventoryItem[]
---@return number
function Inventory.computeSlotCount(items)
    local maxSlot = Config.PlayerSlots - 1

    for i = 1, #items do
        if items[i].slot > maxSlot then
            maxSlot = items[i].slot
        end
    end

    return maxSlot + 1
end

---@return table<string, string>
function Inventory.buildLocale()
    return {
        inventory = TranslateCap('player_inventory'),
        storage = TranslateCap('storage'),
        weight = TranslateCap('weight'),
        use = TranslateCap('use'),
        give = TranslateCap('give'),
        giveAmmo = TranslateCap('giveammo'),
        remove = TranslateCap('remove'),
        take = TranslateCap('take'),
        amount = TranslateCap('amount'),
        nearbyPlayers = TranslateCap('nearby_players'),
        noNearbyPlayers = TranslateCap('players_nearby'),
        addedToInventory = TranslateCap('added_to_inventory'),
        removedFromInventory = TranslateCap('removed_from_inventory'),
    }
end

---@return table<string, string>
function Inventory.buildTheme()
    return xLib.colors.getESXTheme()
end
