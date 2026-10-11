-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

if Config.CustomInventory then
    return
end

RegisterNetEvent("esx:removeInventoryItem", function(itemType, itemName, itemCount)
    local playerId = source

    if type(itemName) ~= "string" or itemName == "" or #itemName > 100 then
        return
    end

    if not Core.InventoryEvents.ConsumeRate("remove", playerId) then
        return
    end

    if itemType ~= "item_standard" and itemType ~= "item_account" and itemType ~= "item_weapon" then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(playerId)

    if not xPlayer then
        return
    end

    if itemType == "item_standard" then
        local count = Core.InventoryEvents.GetPositiveCount(itemCount)

        if not count then
            return xPlayer.showNotification(TranslateCap("imp_invalid_quantity"))
        end

        local xItem = xPlayer.getInventoryItem(itemName)
        if not xItem or xItem.canRemove == false then
            return
        end

        if count > xItem.count or xItem.count < 1 then
            return xPlayer.showNotification(TranslateCap("imp_invalid_quantity"))
        end

        xPlayer.removeInventoryItem(itemName, count)
        local pickupLabel = ("%s [%s]"):format(xItem.label, count)
        local ok = ESX.CreatePickup("item_standard", itemName, count, pickupLabel, playerId)

        if not ok then
            xPlayer.addInventoryItem(itemName, count)
            return xPlayer.showNotification(TranslateCap("threw_cannot_pickup"))
        end

        xPlayer.showNotification(TranslateCap("threw_standard", count, xItem.label))
    elseif itemType == "item_account" then
        local count = Core.InventoryEvents.GetPositiveCount(itemCount)

        if not count then
            return xPlayer.showNotification(TranslateCap("imp_invalid_amount"))
        end

        local account = xPlayer.getAccount(itemName)
        if not account or not Core.InventoryEvents.IsAccountTransferable(itemName) then
            return
        end

        if count > account.money or account.money < 1 then
            return xPlayer.showNotification(TranslateCap("imp_invalid_amount"))
        end

        xPlayer.removeAccountMoney(itemName, count, "Threw away")
        local pickupLabel = ("%s [%s]"):format(account.label, TranslateCap("locale_currency", ESX.Math.GroupDigits(count)))
        local ok = ESX.CreatePickup("item_account", itemName, count, pickupLabel, playerId)

        if not ok then
            xPlayer.addAccountMoney(itemName, count, "Threw away")
            return xPlayer.showNotification(TranslateCap("threw_cannot_pickup"))
        end

        xPlayer.showNotification(TranslateCap("threw_account", ESX.Math.GroupDigits(count), string.lower(account.label)))
    elseif itemType == "item_weapon" then
        if type(itemName) ~= "string" then
            return
        end

        itemName = string.upper(itemName)

        if not xPlayer.hasWeapon(itemName) then
            return
        end

        local _, weapon = xPlayer.getWeapon(itemName)
        if not weapon then
            return
        end

        local _, weaponObject = ESX.GetWeapon(itemName)
        local weaponPickupLabel = ""
        local weaponCount = weapon.ammo
        local weaponComponents = xLib.table.clone(weapon.components)
        local weaponTint = weapon.tintIndex

        xPlayer.removeWeapon(itemName)

        if weaponObject.ammo and weaponCount > 0 then
            local ammoLabel = weaponObject.ammo.label
            weaponPickupLabel = ("%s [%s %s]"):format(weapon.label, weaponCount, ammoLabel)
            xPlayer.showNotification(TranslateCap("threw_weapon_ammo", weapon.label, weaponCount, ammoLabel))
        else
            weaponPickupLabel = ("%s"):format(weapon.label)
            xPlayer.showNotification(TranslateCap("threw_weapon", weapon.label))
        end

        local ok = ESX.CreatePickup("item_weapon", itemName, weaponCount, weaponPickupLabel, playerId, weaponComponents, weaponTint)

        if not ok then
            xPlayer.addWeapon(itemName, weaponCount)
            xPlayer.setWeaponTint(itemName, weaponTint)

            for _, component in ipairs(weaponComponents) do
                xPlayer.addWeaponComponent(itemName, component)
            end

            return xPlayer.showNotification(TranslateCap("threw_cannot_pickup"))
        end
    end
end)
