-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@param item string
---@return string?
---@diagnostic disable-next-line: duplicate-set-field
function ESX.GetItemLabel(item)
    if ESX.Items and ESX.Items[item] then
        return ESX.Items[item].label
    else
        print(("[^3WARNING^7] Attemting to get invalid Item -> ^5%s^7"):format(item))
    end
end

---@return table
function ESX.GetItems()
    return ESX.Items or {}
end

if not Config.CustomInventory then
    local function refreshPlayerInventories()
        local xPlayers = ESX.GetExtendedPlayers()
        for i = 1, #xPlayers do
            local xPlayer = xPlayers[i]
            local minimalInv = xPlayer.getInventory(true)

            for itemName in pairs(minimalInv) do
                if not ESX.Items[itemName] then
                    xPlayer.setInventoryItem(itemName, 0)
                    minimalInv[itemName] = nil
                end
            end

            Core.PlayerClass.ReplaceInventory(xPlayer, minimalInv)

            TriggerClientEvent("esx:setInventory", xPlayer.source, xPlayer.getInventory())
        end
    end

    ---@return number newItemCount
    function ESX.RefreshItems()
        local items = MySQL.query.await("SELECT * FROM items") or {}
        local itemCount = #items
        local registry = {}

        for i = 1, itemCount do
            local item = items[i]
            registry[item.name] = { label = item.label, weight = item.weight, rare = item.rare, canRemove = item.can_remove }
        end

        ESX.Items = registry
        refreshPlayerInventories()

        return itemCount
    end

    ---@param items { name: string, label: string, weight?: number, rare?: boolean, canRemove?: boolean }[]
    function ESX.AddItems(items)
        if type(items) ~= "table" then
            return
        end

        ESX.Items = ESX.Items or {}

        local toInsert = {}
        local toInsertIndex = 1

        for i = 1, #items do
            local item = items[i]
            local name = item.name
            local label = item.label
            local weight = item.weight or 1
            local rare = item.rare or false
            local canRemove = item.canRemove ~= false

            if type(name) ~= "string" then
                print(("^1[AddItems]^0 Invalid item name: %s"):format(name))
                goto continue
            end

            if ESX.Items[name] then
                goto continue
            end

            if type(label) ~= "string" then
                print(("^1[AddItems]^0 Invalid label for item '%s'"):format(name))
                goto continue
            end

            if type(weight) ~= "number" then
                print(("^1[AddItems]^0 Invalid weight for item '%s'"):format(name))
                goto continue
            end

            if type(rare) ~= "boolean" then
                print(("^1[AddItems]^0 Invalid rare flag for item '%s'"):format(name))
                goto continue
            end

            if type(canRemove) ~= "boolean" then
                print(("^1[AddItems]^0 Invalid canRemove flag for item '%s'"):format(name))
                goto continue
            end

            toInsert[toInsertIndex] = {
                name = name,
                label = label,
                weight = weight,
                rare = rare,
                canRemove = canRemove,
            }
            toInsertIndex += 1

            ::continue::
        end

        if #toInsert > 0 then
            local parameters = {}
            for i = 1, #toInsert do
                local row = toInsert[i]
                parameters[i] = { row.name, row.label, row.weight, row.rare, row.canRemove }
            end

            MySQL.prepare.await(
                "INSERT IGNORE INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES (?, ?, ?, ?, ?)",
                parameters
            )

            for i = 1, #toInsert do
                local row = toInsert[i]
                ESX.Items[row.name] = {
                    label = row.label,
                    weight = row.weight,
                    rare = row.rare,
                    canRemove = row.canRemove,
                }
            end

            refreshPlayerInventories()
        end
    end
end
