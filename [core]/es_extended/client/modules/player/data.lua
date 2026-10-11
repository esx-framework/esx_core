-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
function ESX.IsPlayerLoaded()
    return ESX.PlayerLoaded
end

---@return table
function ESX.GetPlayerData()
    return ESX.PlayerData
end

---@param items string | table The item(s) to search for
---@param count? boolean Whether to return the count of the item as well
---@return table | number
function ESX.SearchInventory(items, count)
    local item
    if type(items) == "string" then
        item, items = items, { items }
    end

    local data = {}
    for i = 1, #ESX.PlayerData.inventory do
        local inventoryItem = ESX.PlayerData.inventory[i]

        for ii = 1, #items do
            if inventoryItem.name == items[ii] then
                data[table.remove(items, ii)] = count and inventoryItem.count or inventoryItem
                break
            end
        end

        if #items == 0 then
            break
        end
    end

    if count then
        for i = 1, #items do
            data[items[i]] = 0
        end
    end

    return not item and data or data[item]
end

---@param key string Table key to set
---@param val any Value to set
---@return nil
function ESX.SetPlayerData(key, val)
    local current = ESX.PlayerData[key]
    ESX.PlayerData[key] = val

    if key ~= "loadout" and (type(val) == "table" or val ~= current) then
        TriggerEvent("esx:setPlayerData", key, val, current)
    end
end

---@param account string Account name (money/bank/black_money)
---@return table|nil
function ESX.GetAccount(account)
    for i = 1, #ESX.PlayerData.accounts, 1 do
        if ESX.PlayerData.accounts[i].name == account then
            return ESX.PlayerData.accounts[i]
        end
    end

    return nil
end

function ESX.ShowInventory()
    if not Config.EnableDefaultInventory then
        return
    end

    exports.esx_inventory:ShowInventory()
end
