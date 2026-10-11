-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@param item string
---@param cb function
---@return nil
function ESX.RegisterUsableItem(item, cb)
    Core.UsableItemsCallbacks[item] = cb

    if Config.CustomInventory or not ESX.GetExtendedPlayers then
        return
    end

    local xPlayers = ESX.GetExtendedPlayers()

    for i = 1, #xPlayers do
        local xPlayer = xPlayers[i]
        local inventory = xPlayer.inventory

        for j = 1, #inventory do
            local inventoryItem = inventory[j]

            if inventoryItem.name == item then
                inventoryItem.usable = true

                TriggerClientEvent("esx:setInventory", xPlayer.source, inventory)
                break
            end
        end
    end
end

---@param source number
---@param item string
---@param ... any
---@return nil
function ESX.UseItem(source, item, ...)
    if ESX.Items and ESX.Items[item] then
        local itemCallback = Core.UsableItemsCallbacks[item]

        if itemCallback then
            local success, result = pcall(itemCallback, source, item, ...)

            if not success then
                if result then
                    return print(result)
                end

                return print(('[^3WARNING^7] An error occured when using item ^5"%s"^7! This was not caused by ESX.'):format(item))
            end
        end
    else
        print(('[^3WARNING^7] Item ^5"%s"^7 was used but does not exist!'):format(item))
    end
end

---@return table
function ESX.GetUsableItems()
    local Usables = {}
    for k in pairs(Core.UsableItemsCallbacks) do
        Usables[k] = true
    end
    return Usables
end
