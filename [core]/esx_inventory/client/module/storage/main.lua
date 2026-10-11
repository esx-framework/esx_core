-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Inventory = ESXInventory

---@param items table[]
---@return table[]
local function applyStorageSlots(items)
    for i = 1, #items do
        items[i].slot = i - 1
    end

    return items
end

---@param storage table
---@param ops table[]
---@return table[]
local function applyStorageOps(storage, ops)
    local items = storage.items or {}

    for i = 1, #ops do
        local op = ops[i]

        if type(op) ~= "table" or type(op.name) ~= "string" then
            goto continue
        end

        if op.op == "set" then
            local found

            for j = 1, #items do
                if items[j].name == op.name then
                    items[j].count = op.count

                    if type(op.label) == "string" then
                        items[j].label = op.label
                    end

                    found = true
                    break
                end
            end

            if not found then
                items[#items + 1] = {
                    type = "item_standard",
                    name = op.name,
                    label = type(op.label) == "string" and op.label or op.name,
                    count = op.count,
                    weight = type(op.weight) == "number" and op.weight or 0,
                    usable = false,
                    canRemove = true,
                    image = type(op.image) == "string" and op.image or Config.ItemImageUrl:format(op.name),
                }
            end
        elseif op.op == "remove" then
            for j = 1, #items do
                if items[j].name == op.name then
                    table.remove(items, j)
                    break
                end
            end
        end

        ::continue::
    end

    return applyStorageSlots(items)
end

RegisterNetEvent("esx_inventory:openStorage", function(storage)
    if type(storage) ~= "table" or type(storage.id) ~= "string" then
        return
    end

    applyStorageSlots(storage.items or {})
    Inventory.currentStorage = storage

    if Inventory.isOpen then
        Inventory.pushState()
    else
        Inventory.open()

        if not Inventory.isOpen then
            Inventory.currentStorage = nil
            TriggerServerEvent("esx_inventory:storageClosed")
        end
    end
end)

RegisterNetEvent("esx_inventory:refreshStorage", function(storage)
    if not Inventory.isOpen or not Inventory.currentStorage or type(storage) ~= "table" or storage.id ~= Inventory.currentStorage.id then
        return
    end

    if type(storage.ops) == "table" then
        Inventory.currentStorage.items = applyStorageOps(Inventory.currentStorage, storage.ops)
    else
        applyStorageSlots(storage.items or {})
        Inventory.currentStorage = storage
    end

    Inventory.pushState()
end)

RegisterNetEvent("esx_inventory:closeStorage", function()
    if not Inventory.currentStorage then
        return
    end

    Inventory.currentStorage = nil

    if Inventory.isOpen then
        Inventory.pushState()
    end
end)
