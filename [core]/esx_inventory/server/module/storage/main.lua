-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@class InventoryStorageDefinition
---@field label string                                              # Display name of the storage.
---@field slots number                                              # Maximum distinct items, enforced on put.
---@field maxWeight number                                          # Maximum total weight enforced on put, 0 disables the limit.
---@field canAccess fun(xPlayer: table): boolean                    # Synchronous access check, no awaits.
---@field getItems fun(xPlayer: table): table[]                     # Synchronous read of { name, label, count, weight? } entries.
---@field putItem fun(xPlayer: table, itemName: string, count: number): boolean   # Synchronous, must atomically add to the storage state.
---@field takeItem fun(xPlayer: table, itemName: string, count: number): boolean  # Synchronous, must atomically deduct from the storage state.
---@field coords vector3?                                          # Optional anchor, transfers are refused beyond distance.
---@field distance number?                                         # Range around coords, defaults to 5.0.
---@field owner string?                                            # Resource that registered the storage, set internally.

local MAX_TRANSFER_COUNT <const> = 1000000

local storages = {} ---@type table<string, InventoryStorageDefinition>
local openedStorage = {} ---@type table<number, string>
local storageViewers = {} ---@type table<string, table<number, boolean>>
local storageSnapshots = {} ---@type table<string, table<number, table[]>>
local busy = {} ---@type table<number, boolean>
local transferLimiter = xLib.rateLimiter({
    capacity = Config.StorageBurst,
    refill = Config.StorageBurst,
    interval = Config.StorageRefillInterval,
})

---@param items table[]
---@return table<string, table>
local function buildItemMap(items)
    local map = {}

    for i = 1, #items do
        map[items[i].name] = items[i]
    end

    return map
end

---@param lastItems table[]
---@param newItems table[]
---@return table[] ops
local function buildStorageDelta(lastItems, newItems)
    local lastMap = buildItemMap(lastItems)
    local newMap = buildItemMap(newItems)
    local ops = {}

    for name, item in pairs(newMap) do
        local lastItem = lastMap[name]

        if not lastItem or lastItem.count ~= item.count then
            ops[#ops + 1] = {
                op = "set",
                name = name,
                count = item.count,
                label = item.label,
                weight = item.weight,
                image = item.image,
            }
        end

        lastMap[name] = nil
    end

    for name in pairs(lastMap) do
        ops[#ops + 1] = {
            op = "remove",
            name = name,
        }
    end

    return ops
end

---@param storageId string
---@param callback string
---@param err any
local function warnCallback(storageId, callback, err)
    print(("[^3WARNING^7] Storage ^5%s^7 callback ^5%s^7 failed: %s"):format(storageId, callback, err))
end

---@return table<string, table>
local function getItemRegistry()
    local registry = ESX.GetItems()

    return type(registry) == "table" and registry or {}
end

---@param registry table<string, table>
---@param itemName string
---@param fallback number
---@return number
local function getItemWeight(registry, itemName, fallback)
    local entry = registry[itemName]

    if type(entry) == "table" and type(entry.weight) == "number" then
        return entry.weight
    end

    return fallback
end

---@param playerId number
---@return nil
local function clearViewer(playerId)
    local storageId = openedStorage[playerId]

    if not storageId then
        return
    end

    openedStorage[playerId] = nil

    local viewers = storageViewers[storageId]

    if not viewers then
        return
    end

    viewers[playerId] = nil

    local snapshots = storageSnapshots[storageId]

    if snapshots then
        snapshots[playerId] = nil

        if not next(snapshots) then
            storageSnapshots[storageId] = nil
        end
    end

    if not next(viewers) then
        storageViewers[storageId] = nil
    end
end

---@param playerId number
---@param definition InventoryStorageDefinition
---@return boolean
local function isPlayerInRange(playerId, definition)
    if not definition.coords then
        return true
    end

    local ped = GetPlayerPed(playerId)

    if not ped or ped == 0 then
        return false
    end

    return #(GetEntityCoords(ped) - definition.coords) <= definition.distance
end

---@param count any
---@return number?
local function getValidCount(count)
    count = tonumber(count)

    if not count or count ~= math.floor(count) or count < 1 or count > MAX_TRANSFER_COUNT then
        return nil
    end

    return count
end

---@param storageId string
---@param definition InventoryStorageDefinition
---@param xPlayer table
---@return boolean
local function canAccessStorage(storageId, definition, xPlayer)
    local ok, allowed = pcall(definition.canAccess, xPlayer)

    if not ok then
        warnCallback(storageId, "canAccess", allowed)
        return false
    end

    return allowed and true or false
end

---@param storageId string
---@param definition InventoryStorageDefinition
---@param xPlayer table
---@param registry table<string, table>
---@return table[]?
local function buildStorageItems(storageId, definition, xPlayer, registry)
    local ok, rawItems = pcall(definition.getItems, xPlayer)

    if not ok then
        warnCallback(storageId, "getItems", rawItems)
        return nil
    end

    local items = {}

    if type(rawItems) ~= "table" then
        return items
    end

    for i = 1, #rawItems do
        local item = rawItems[i]

        if type(item) == "table" and type(item.name) == "string" and type(item.count) == "number" and item.count > 0 then
            items[#items + 1] = {
                type = "item_standard",
                name = item.name,
                label = type(item.label) == "string" and item.label or item.name,
                count = math.floor(item.count),
                weight = getItemWeight(registry, item.name, type(item.weight) == "number" and item.weight or 0),
                usable = false,
                canRemove = true,
                image = Config.ItemImageUrl:format(item.name),
            }
        end
    end

    return items
end

---@param storageId string
---@param definition InventoryStorageDefinition
local function refreshStorageViewers(storageId, definition)
    local viewers = storageViewers[storageId]

    if not viewers then
        return
    end

    local registry = getItemRegistry()

    for playerId in pairs(viewers) do
        local viewer = ESX.GetPlayerFromId(playerId)

        if viewer and isPlayerInRange(playerId, definition) and canAccessStorage(storageId, definition, viewer) then
            local newItems = buildStorageItems(storageId, definition, viewer, registry)

            if newItems then
                local snapshots = storageSnapshots[storageId]

                if not snapshots then
                    snapshots = {}
                    storageSnapshots[storageId] = snapshots
                end

                local lastItems = snapshots[playerId] or nil

                if lastItems then
                    local ops = buildStorageDelta(lastItems, newItems)

                    if #ops > 0 then
                        TriggerClientEvent("esx_inventory:refreshStorage", playerId, {
                            id = storageId,
                            ops = ops,
                        })
                    end
                else
                    TriggerClientEvent("esx_inventory:refreshStorage", playerId, {
                        id = storageId,
                        label = definition.label,
                        slots = definition.slots,
                        maxWeight = definition.maxWeight,
                        items = newItems,
                    })
                end

                snapshots[playerId] = newItems
            end
        else
            clearViewer(playerId)
            TriggerClientEvent("esx_inventory:closeStorage", playerId)
        end
    end
end

---@param storageId string
---@param definition InventoryStorageDefinition
---@return boolean
local function registerStorage(storageId, definition)
    if type(storageId) ~= "string" or storageId == "" or type(definition) ~= "table" then
        return false
    end

    local owner = GetInvokingResource() or GetCurrentResourceName()
    local existing = storages[storageId]

    if existing and existing.owner ~= owner then
        print(("[^3WARNING^7] Storage ^5%s^7 is already registered by ^5%s^7"):format(storageId, existing.owner))
        return false
    end

    if type(definition.label) ~= "string"
        or not ESX.IsFunctionReference(definition.canAccess)
        or not ESX.IsFunctionReference(definition.getItems)
        or not ESX.IsFunctionReference(definition.putItem)
        or not ESX.IsFunctionReference(definition.takeItem) then
        print(("[^3WARNING^7] Storage ^5%s^7 has an invalid definition"):format(storageId))
        return false
    end

    local registered = {
        label = definition.label,
        slots = type(definition.slots) == "number" and math.floor(definition.slots) or 30,
        maxWeight = type(definition.maxWeight) == "number" and definition.maxWeight or 0,
        canAccess = definition.canAccess,
        getItems = definition.getItems,
        putItem = definition.putItem,
        takeItem = definition.takeItem,
        coords = type(definition.coords) == "vector3" and definition.coords or nil,
        distance = type(definition.distance) == "number" and definition.distance or 5.0,
        owner = owner,
    }

    storages[storageId] = registered

    if existing then
        storageSnapshots[storageId] = nil
        refreshStorageViewers(storageId, registered)
    end

    return true
end

exports("RegisterStorage", registerStorage)

---@param storageId string
---@return boolean
local function unregisterStorage(storageId)
    if not storages[storageId] then
        return false
    end

    local isRegistered = storages[storageId] ~= nil
    storages[storageId] = nil

    local viewers = storageViewers[storageId]

    if viewers then
        for playerId in pairs(viewers) do
            openedStorage[playerId] = nil
            TriggerClientEvent("esx_inventory:closeStorage", playerId)
        end

        storageViewers[storageId] = nil
    end

    storageSnapshots[storageId] = nil

    return isRegistered
end

exports("UnregisterStorage", unregisterStorage)

---@param playerId number
---@param storageId string
---@return boolean
local function openStorage(playerId, storageId)
    local definition = storages[storageId]
    local xPlayer = ESX.GetPlayerFromId(playerId)

    if not definition or not xPlayer or not isPlayerInRange(playerId, definition) or not canAccessStorage(storageId, definition, xPlayer) then
        return false
    end

    local items = buildStorageItems(storageId, definition, xPlayer, getItemRegistry())

    if not items then
        return false
    end

    clearViewer(playerId)

    openedStorage[playerId] = storageId

    local viewers = storageViewers[storageId]

    if not viewers then
        viewers = {}
        storageViewers[storageId] = viewers
    end

    viewers[playerId] = true

    local snapshots = storageSnapshots[storageId]

    if not snapshots then
        snapshots = {}
        storageSnapshots[storageId] = snapshots
    end

    snapshots[playerId] = items

    TriggerClientEvent("esx_inventory:openStorage", playerId, {
        id = storageId,
        label = definition.label,
        slots = definition.slots,
        maxWeight = definition.maxWeight,
        items = items,
    })

    return true
end

exports("OpenStorage", openStorage)
AddEventHandler("esx_inventory:openStorage", openStorage)

---@param storageId string
---@return boolean
local function refreshStorage(storageId)
    local definition = storages[storageId]

    if not definition then
        return false
    end

    refreshStorageViewers(storageId, definition)

    return true
end

exports("RefreshStorage", refreshStorage)

---@param source number
---@param itemName any
---@param count any
---@return table?, string?, InventoryStorageDefinition?, number?
local function validateStorageAction(source, itemName, count)
    if not transferLimiter:consume(source) then
        return nil
    end

    local storageId = openedStorage[source]
    local definition = storageId and storages[storageId] or nil
    local xPlayer = ESX.GetPlayerFromId(source)
    count = getValidCount(count)

    if not definition or not xPlayer or type(itemName) ~= "string" or not count then
        return nil
    end

    if not isPlayerInRange(source, definition) then
        return nil
    end

    if not canAccessStorage(storageId, definition, xPlayer) then
        return nil
    end

    return xPlayer, storageId, definition, count
end

---@param definition InventoryStorageDefinition
---@param items table[]
---@param itemName string
---@param addedWeight number
---@return string?
local function getCapacityError(definition, items, itemName, addedWeight)
    local currentWeight = 0
    local isNewItem = true

    for i = 1, #items do
        local item = items[i]

        currentWeight += item.weight * item.count

        if item.name == itemName then
            isNewItem = false
        end
    end

    if definition.maxWeight > 0 and currentWeight + addedWeight > definition.maxWeight then
        return TranslateCap("ex_inv_lim", definition.maxWeight)
    end

    if isNewItem and #items >= definition.slots then
        return TranslateCap("storage_full")
    end

    return nil
end

---@param source number
---@param itemName any
---@param count any
local function storagePut(source, itemName, count)
    local xPlayer, storageId, definition
    xPlayer, storageId, definition, count = validateStorageAction(source, itemName, count)

    if not xPlayer then
        return
    end

    local item = xPlayer.getInventoryItem(itemName)

    if not item or item.count < count or item.canRemove == false then
        return
    end

    local registry = getItemRegistry()
    local storageItems = buildStorageItems(storageId, definition, xPlayer, registry)

    if not storageItems then
        return
    end

    local capacityError = getCapacityError(definition, storageItems, itemName, getItemWeight(registry, itemName, tonumber(item.weight) or 0) * count)

    if capacityError then
        xPlayer.showNotification(capacityError)
        refreshStorageViewers(storageId, definition)
        return
    end

    if xPlayer.removeInventoryItem(itemName, count) == false then
        return
    end

    local ok, stored = pcall(definition.putItem, xPlayer, itemName, count)

    if not ok or stored ~= true then
        if not ok then
            warnCallback(storageId, "putItem", stored)
        end

        xPlayer.addInventoryItem(itemName, count)
    end

    refreshStorageViewers(storageId, definition)
end

---@param source number
---@param itemName any
---@param count any
local function storageTake(source, itemName, count)
    local xPlayer, storageId, definition
    xPlayer, storageId, definition, count = validateStorageAction(source, itemName, count)

    if not xPlayer then
        return
    end

    if not xPlayer.canCarryItem(itemName, count) then
        xPlayer.showNotification(TranslateCap("ex_inv_lim", xPlayer.getMaxWeight()))
        return
    end

    local ok, taken = pcall(definition.takeItem, xPlayer, itemName, count)

    if not ok or taken ~= true then
        if not ok then
            warnCallback(storageId, "takeItem", taken)
        end

        refreshStorageViewers(storageId, definition)
        return
    end

    if not xPlayer.canCarryItem(itemName, count) then
        local restored, stored = pcall(definition.putItem, xPlayer, itemName, count)

        if restored and stored == true then
            xPlayer.showNotification(TranslateCap("ex_inv_lim", xPlayer.getMaxWeight()))
            refreshStorageViewers(storageId, definition)
            return
        end

        warnCallback(storageId, "putItem", restored and "rollback refused, items given over the weight limit" or stored)
    end

    xPlayer.addInventoryItem(itemName, count)
    refreshStorageViewers(storageId, definition)
end

---@param source number
---@param transaction fun(source: number, itemName: any, count: any)
---@param itemName any
---@param count any
local function runTransaction(source, transaction, itemName, count)
    if busy[source] then
        return
    end

    busy[source] = true

    local ok, err = pcall(transaction, source, itemName, count)

    busy[source] = nil

    if not ok then
        print(("[^1ERROR^7] Storage transaction failed for player ^5%s^7: %s"):format(source, err))
    end
end

RegisterNetEvent("esx_inventory:storagePut", function(itemName, count)
    local source = source

    runTransaction(source, storagePut, itemName, count)
end)

RegisterNetEvent("esx_inventory:storageTake", function(itemName, count)
    local source = source

    runTransaction(source, storageTake, itemName, count)
end)

RegisterNetEvent("esx_inventory:storageClosed", function()
    clearViewer(source)
end)

AddEventHandler("playerDropped", function()
    clearViewer(source)
    busy[source] = nil
end)

AddEventHandler("onResourceStop", function(resource)
    for storageId, definition in pairs(storages) do
        if definition.owner == resource then
            unregisterStorage(storageId)
        end
    end
end)

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        TriggerEvent("esx_inventory:ready")
    end
end)
