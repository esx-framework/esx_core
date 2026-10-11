-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Inventory = ESXInventory

local SLOT_KVP <const> = 'esx_inventory:slots'

local slotMap = {} ---@type table<string, number>
local slotsChanged = false

do
    local stored = GetResourceKvpString(SLOT_KVP)

    if stored then
        local decoded = json.decode(stored)

        if type(decoded) == 'table' then
            slotMap = decoded
        end
    end
end

---@param itemType string
---@param name string
---@return string
function Inventory.itemKey(itemType, name)
    return itemType .. ':' .. name
end

function Inventory.saveSlotMap()
    if not slotsChanged then
        return
    end

    SetResourceKvp(SLOT_KVP, json.encode(slotMap))
    slotsChanged = false
end

---@param key string
---@return number?
function Inventory.getSlot(key)
    return slotMap[key]
end

---@param key string
---@param slot number
function Inventory.setSlot(key, slot)
    if slotMap[key] == slot then
        return
    end

    slotMap[key] = slot
    slotsChanged = true

    if Inventory.invalidateItems then
        Inventory.invalidateItems()
    end
end

---@param items NuiInventoryItem[]
function Inventory.assignSlots(items)
    local used = {}

    for i = 1, #items do
        local item = items[i]
        local slot = slotMap[Inventory.itemKey(item.type, item.name)]

        if slot and not used[slot] then
            item.slot = slot
            used[slot] = true
        end
    end

    local nextFree = 0

    for i = 1, #items do
        local item = items[i]

        if not item.slot then
            while used[nextFree] do
                nextFree += 1
            end

            item.slot = nextFree
            used[nextFree] = true
            Inventory.setSlot(Inventory.itemKey(item.type, item.name), nextFree)
        end
    end
end
