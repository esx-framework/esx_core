-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

if Config.CustomInventory then
    return
end

RegisterNetEvent("esx:useItem", function(itemName)
    local playerId = source

    if not Core.InventoryEvents.ConsumeRate("use", playerId) then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(playerId)

    if not xPlayer or type(itemName) ~= "string" then
        return
    end

    local item = xPlayer.getInventoryItem(itemName)

    if not item then
        return
    end

    if item.count < 1 then
        return xPlayer.showNotification(TranslateCap("act_imp"))
    end

    ESX.UseItem(playerId, itemName)
end)