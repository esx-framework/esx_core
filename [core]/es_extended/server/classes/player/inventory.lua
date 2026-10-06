-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core.PlayerClass = Core.PlayerClass or {}

---@type table<table, table<string, ESXInventoryItem>>
local inventoryIndexes = setmetatable({}, { __mode = "k" })

local function buildItemEntry(itemName, count)
    local itemData = ESX.Items[itemName]

    if not itemData then
        return nil
    end

    return {
        name = itemName,
        count = count,
        label = itemData.label,
        weight = itemData.weight,
        usable = Core.UsableItemsCallbacks[itemName] ~= nil,
        rare = itemData.rare,
        canRemove = itemData.canRemove,
    }
end

local function sortByLabel(a, b)
    return a.label < b.label
end

---@param index table<string, ESXInventoryItem>
---@return ESXInventoryItem[]
local function buildInventoryList(index)
    local items = {}

    for _, item in pairs(index) do
        items[#items + 1] = item
    end

    table.sort(items, sortByLabel)

    return items
end

---@param inventory table?
---@return table<string, ESXInventoryItem>
local function buildInventoryIndex(inventory)
    local index = {}

    if type(inventory) ~= "table" then
        return index
    end

    for key, item in pairs(inventory) do
        if type(item) == "table" then
            local itemName = item.name or key

            if type(itemName) == "string" and type(item.count) == "number" and item.count > 0 then
                item.name = itemName
                index[itemName] = item
            end
        end
    end

    return index
end

---@param counts table<string, number>
---@return ESXInventoryItem[] items
---@return number weight
function Core.PlayerClass.BuildInventory(counts)
    local index = {}
    local weight = 0

    if type(counts) == "table" then
        for itemName, count in pairs(counts) do
            if type(count) == "number" and count > 0 then
                local item = buildItemEntry(itemName, count)

                if item then
                    index[itemName] = item
                    weight = weight + (item.weight * count)
                end
            end
        end
    end

    return buildInventoryList(index), weight
end

---@param xPlayer xPlayer
---@param counts table<string, number>
---@return nil
function Core.PlayerClass.ReplaceInventory(xPlayer, counts)
    local items, weight = Core.PlayerClass.BuildInventory(counts)

    inventoryIndexes[xPlayer] = buildInventoryIndex(items)
    xPlayer.inventory = items
    xPlayer.weight = weight
end

function Core.PlayerClass.AttachInventory(self)
    if not Config.CustomInventory then
        inventoryIndexes[self] = buildInventoryIndex(self.inventory)
        self.inventory = buildInventoryList(inventoryIndexes[self])
    end

    function self.getInventory(minimal)
        if minimal then
            local minimalInventory = {}

            for itemName, item in pairs(inventoryIndexes[self]) do
                minimalInventory[itemName] = item.count
            end

            return minimalInventory
        end

        return self.inventory
    end

    function self.getInventoryItem(itemName)
        local item = inventoryIndexes[self][itemName]

        if item then
            return item
        end

        return buildItemEntry(itemName, 0)
    end

    function self.addInventoryItem(itemName, count)
        count = ESX.Math.Round(count)

        if count <= 0 then
            return false
        end

        local item = inventoryIndexes[self][itemName]

        if item then
            item.count = item.count + count
        else
            local newItem = buildItemEntry(itemName, count)

            if not newItem then
                print(("[^3WARNING^7] Item ^5\"%s\"^7 was used but does not exist!"):format(itemName))
                return false
            end

            item = newItem
            inventoryIndexes[self][itemName] = item
            self.inventory = buildInventoryList(inventoryIndexes[self])
        end

        self.weight = self.weight + (item.weight * count)

        TriggerEvent("esx:onAddInventoryItem", self.source, itemName, item.count)
        self.triggerEvent("esx:addInventoryItem", itemName, item.count, false, item)
        self.triggerEvent("esx:setInventory", self.getInventory())
        return true
    end

    function self.removeInventoryItem(itemName, count)
        local item = inventoryIndexes[self][itemName]

        if item then
            count = ESX.Math.Round(count)

            if count > 0 then
                local newCount = item.count - count

                if newCount >= 0 then
                    item.count = newCount
                    self.weight = self.weight - (item.weight * count)

                    if newCount == 0 then
                        inventoryIndexes[self][itemName] = nil
                        self.inventory = buildInventoryList(inventoryIndexes[self])
                    end

                    TriggerEvent("esx:onRemoveInventoryItem", self.source, itemName, item.count)
                    self.triggerEvent("esx:removeInventoryItem", itemName, item.count)
                    self.triggerEvent("esx:setInventory", self.getInventory())
                    return true
                end

                return false
            else
                error(("Player ID:^5%s Tried remove a Invalid count -> %s of %s"):format(self.playerId, count, itemName))
            end
        end

        return false
    end

    function self.setInventoryItem(itemName, count)
        local item = inventoryIndexes[self][itemName]

        if (item or ESX.Items[itemName]) and count >= 0 then
            count = ESX.Math.Round(count)

            if item and count == item.count then
                return
            end

            if count > (item and item.count or 0) then
                return self.addInventoryItem(itemName, count - (item and item.count or 0))
            else
                return self.removeInventoryItem(itemName, (item and item.count or 0) - count)
            end
        end

        return false
    end

    function self.getWeight()
        return self.weight
    end


    function self.getMaxWeight()
        return self.maxWeight
    end

    function self.canCarryItem(itemName, count)
        if ESX.Items[itemName] then
            local currentWeight, itemWeight = self.weight, ESX.Items[itemName].weight
            local newWeight = currentWeight + (itemWeight * count)

            return newWeight <= self.maxWeight
        else
            print(("[^3WARNING^7] Item ^5\"%s\"^7 was used but does not exist!"):format(itemName))
            return false
        end
    end

    function self.canSwapItem(firstItem, firstItemCount, testItem, testItemCount)
        local firstItemObject = self.getInventoryItem(firstItem)
        if not firstItemObject then
            return false
        end
        local testItemObject = self.getInventoryItem(testItem)
        if not testItemObject then
            return false
        end

        if firstItemObject.count >= firstItemCount then
            local weightWithoutFirstItem = ESX.Math.Round(self.weight - (firstItemObject.weight * firstItemCount))
            local weightWithTestItem = ESX.Math.Round(weightWithoutFirstItem + (testItemObject.weight * testItemCount))

            return weightWithTestItem <= self.maxWeight
        end

        return false
    end

    function self.setMaxWeight(newWeight)
        if
            type(newWeight) ~= "number"
            or newWeight ~= newWeight
            or newWeight < 0
            or newWeight == math.huge
        then
            return false
        end

        self.maxWeight = newWeight
        self.triggerEvent("esx:setMaxWeight", self.maxWeight)
    end

    function self.hasItem(item)
        local entry = inventoryIndexes[self][item]

        if entry and entry.count >= 1 then
            return entry, entry.count
        end

        return false
    end

end
