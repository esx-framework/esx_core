-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Inventory = ESXInventory

local lastCounts = {} ---@type table<string, number>
local itemLabels = {} ---@type table<string, string>
local hasCountSnapshot = false
local refreshScheduled = false

local function ensureInventory()
    if type(ESX.PlayerData.inventory) ~= 'table' then
        ESX.PlayerData.inventory = {}
    end

    return ESX.PlayerData.inventory
end

local function buildEntry(name, count, itemData)
    itemData = type(itemData) == 'table' and itemData or {}

    return {
        name = name,
        count = count,
        label = itemData.label or name,
        weight = itemData.weight or 0,
        usable = itemData.usable == true,
        rare = itemData.rare == true,
        canRemove = itemData.canRemove ~= false,
    }
end

local function setInventoryItem(name, count, itemData)
    if type(name) ~= 'string' or type(count) ~= 'number' then
        return
    end

    Inventory.invalidateItems()

    local inventory = ensureInventory()

    for i = 1, #inventory do
        if inventory[i].name == name then
            if count > 0 then
                inventory[i].count = count

                if type(itemData) == 'table' then
                    inventory[i].label = itemData.label or inventory[i].label
                    inventory[i].weight = itemData.weight or inventory[i].weight
                    inventory[i].usable = itemData.usable == true
                    inventory[i].rare = itemData.rare == true
                    inventory[i].canRemove = itemData.canRemove ~= false
                end
            else
                table.remove(inventory, i)
            end

            return
        end
    end

    if count > 0 then
        inventory[#inventory + 1] = buildEntry(name, count, itemData)
    end
end

local function replaceInventory(newInventory)
    ESX.PlayerData.inventory = type(newInventory) == 'table' and newInventory or {}
    Inventory.invalidateItems()
end

---@param name any
---@param label any
local function rememberLabel(name, label)
    if type(name) == 'string' and type(label) == 'string' and label ~= '' then
        itemLabels[name] = label
    end
end

---@return table<string, number>
local function snapshotCounts()
    local counts = {}

    for i = 1, #(ESX.PlayerData.inventory or {}) do
        local item = ESX.PlayerData.inventory[i]

        if item.count > 0 then
            counts[item.name] = item.count
            rememberLabel(item.name, item.label)
        end
    end

    return counts
end

local function ensureCountSnapshot()
    if hasCountSnapshot then
        return
    end

    hasCountSnapshot = true
    lastCounts = snapshotCounts()
end

---@param name string
---@param delta number
---@param added boolean
local function notifyItemChange(name, delta, added)
    xLib.nui.send({
        action = 'notify',
        added = added,
        amount = delta,
        item = {
            name = name,
            label = itemLabels[name] or name,
            image = Config.ItemImageUrl:format(name),
        },
    })
end

---@param name string
---@param count number
local function trackCount(name, count)
    local previous = lastCounts[name] or 0

    if count > previous then
        notifyItemChange(name, count - previous, true)
    elseif count < previous then
        notifyItemChange(name, previous - count, false)
    end

    lastCounts[name] = count > 0 and count or nil
end

local function refreshAndNotify()
    local newCounts = snapshotCounts()

    if not hasCountSnapshot then
        hasCountSnapshot = true
        lastCounts = newCounts
    else
        for name, count in pairs(newCounts) do
            local previous = lastCounts[name] or 0

            if count > previous then
                notifyItemChange(name, count - previous, true)
            end
        end

        for name, previous in pairs(lastCounts) do
            local count = newCounts[name] or 0

            if count < previous then
                notifyItemChange(name, previous - count, false)
            end
        end

        lastCounts = newCounts
    end

    if Inventory.isOpen then
        Inventory.pushState()
    end
end

local function scheduleRefresh()
    Inventory.invalidateItems()

    if refreshScheduled then
        return
    end

    refreshScheduled = true

    SetTimeout(0, function()
        refreshScheduled = false
        refreshAndNotify()
    end)
end

RegisterNetEvent('esx:setInventory', function(newInventory)
    replaceInventory(newInventory)
    scheduleRefresh()
end)

RegisterNetEvent('esx:addInventoryItem', function(item, count, _, itemData)
    if type(item) ~= 'string' or type(count) ~= 'number' then
        return
    end

    ensureCountSnapshot()

    if type(itemData) == 'table' then
        rememberLabel(item, itemData.label)
    end

    setInventoryItem(item, count, itemData)
    trackCount(item, count)

    if Inventory.isOpen then
        Inventory.pushState()
    end
end)

RegisterNetEvent('esx:removeInventoryItem', function(item, count)
    if type(item) ~= 'string' or type(count) ~= 'number' then
        return
    end

    ensureCountSnapshot()
    setInventoryItem(item, count)
    trackCount(item, count)

    if Inventory.isOpen then
        Inventory.pushState()
    end
end)

RegisterNetEvent('esx:addLoadoutItem', scheduleRefresh)
RegisterNetEvent('esx:removeLoadoutItem', scheduleRefresh)

RegisterNetEvent('esx:setAccountMoney', function(account)
    if type(account) ~= 'table' or type(account.name) ~= 'string' then
        return
    end

    Inventory.invalidateItems()

    for i = 1, #(ESX.PlayerData.accounts or {}) do
        if ESX.PlayerData.accounts[i].name == account.name then
            ESX.PlayerData.accounts[i].money = account.money
            break
        end
    end

    if Inventory.isOpen then
        Inventory.pushState()
    end
end)

OnPlayerData = function(key)
    if key == 'inventory' or key == 'loadout' then
        scheduleRefresh()
    elseif key == 'accounts' then
        Inventory.invalidateItems()

        if Inventory.isOpen then
            Inventory.pushState()
        end
    end
end

RegisterNetEvent('esx:playerLoaded', function()
    Inventory.invalidateItems()
    hasCountSnapshot = true
    lastCounts = snapshotCounts()
end)

RegisterNetEvent('esx:onPlayerDeath', function()
    Inventory.close(false)
end)

CreateThread(function()
    while not ESX.PlayerLoaded do
        Wait(500)
    end

    ensureCountSnapshot()
end)
