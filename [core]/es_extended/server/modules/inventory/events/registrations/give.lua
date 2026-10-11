-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

if Config.CustomInventory then
    return
end

RegisterNetEvent("esx:giveInventoryItem", function(target, itemType, itemName, itemCount)
    if type(itemName) ~= "string" or itemName == "" or #itemName > 100 then
        return
    end
    
    local playerId = source

    if not Core.InventoryEvents.ConsumeRate("give", playerId) then
        return
    end

    if itemType ~= "item_standard" and itemType ~= "item_account" and itemType ~= "item_weapon" and itemType ~= "item_ammo" then
        return
    end

    if type(itemName) ~= "string" then
        return
    end

    local sourceXPlayer, targetXPlayer = Core.InventoryEvents.GetTransferPlayers(playerId, target)

    if not sourceXPlayer or not targetXPlayer then
        Core.InventoryEvents.WarnInvalidTransfer(playerId)
        return
    end

    if itemType == "item_standard" then
        local count = Core.InventoryEvents.GetPositiveCount(itemCount)
        local sourceItem = sourceXPlayer.getInventoryItem(itemName)

        if not sourceItem or sourceItem.canRemove == false then
            return
        end

        if not count or sourceItem.count < count then
            return sourceXPlayer.showNotification(TranslateCap("imp_invalid_quantity"))
        end

        if not targetXPlayer.canCarryItem(itemName, count) then
            return sourceXPlayer.showNotification(TranslateCap("ex_inv_lim", targetXPlayer.name))
        end

        sourceXPlayer.removeInventoryItem(itemName, count)
        targetXPlayer.addInventoryItem(itemName, count)

        sourceXPlayer.showNotification(TranslateCap("gave_item", count, sourceItem.label, targetXPlayer.name))
        targetXPlayer.showNotification(TranslateCap("received_item", count, sourceItem.label, sourceXPlayer.name))
    elseif itemType == "item_account" then
        local count = Core.InventoryEvents.GetPositiveCount(itemCount)
        local account = sourceXPlayer.getAccount(itemName)

        if not count or not account or account.money < count or not Core.InventoryEvents.IsAccountTransferable(itemName) then
            return sourceXPlayer.showNotification(TranslateCap("imp_invalid_amount"))
        end

        sourceXPlayer.removeAccountMoney(itemName, count, "Gave to " .. targetXPlayer.name)
        targetXPlayer.addAccountMoney(itemName, count, "Received from " .. sourceXPlayer.name)

        sourceXPlayer.showNotification(TranslateCap("gave_account_money", ESX.Math.GroupDigits(count), account.label, targetXPlayer.name))
        targetXPlayer.showNotification(TranslateCap("received_account_money", ESX.Math.GroupDigits(count), account.label, sourceXPlayer.name))
    elseif itemType == "item_weapon" then
        if type(itemName) ~= "string" then
            return
        end

        itemName = string.upper(itemName)

        if not sourceXPlayer.hasWeapon(itemName) then
            return
        end

        local weaponLabel = ESX.GetWeaponLabel(itemName)
        if targetXPlayer.hasWeapon(itemName) then
            sourceXPlayer.showNotification(TranslateCap("gave_weapon_hasalready", targetXPlayer.name, weaponLabel))
            targetXPlayer.showNotification(TranslateCap("received_weapon_hasalready", sourceXPlayer.name, weaponLabel))
            return
        end

        local _, weapon = sourceXPlayer.getWeapon(itemName)
        if not weapon then
            return
        end

        local _, weaponObject = ESX.GetWeapon(itemName)
        local ammoCount = weapon.ammo
        local weaponComponents = xLib.table.clone(weapon.components)
        local weaponTint = weapon.tintIndex

        sourceXPlayer.removeWeapon(itemName)
        targetXPlayer.addWeapon(itemName, ammoCount)

        if weaponTint then
            targetXPlayer.setWeaponTint(itemName, weaponTint)
        end

        if weaponComponents then
            for _, component in pairs(weaponComponents) do
                targetXPlayer.addWeaponComponent(itemName, component)
            end
        end

        if weaponObject.ammo and ammoCount > 0 then
            local ammoLabel = weaponObject.ammo.label
            sourceXPlayer.showNotification(TranslateCap("gave_weapon_withammo", weaponLabel, ammoCount, ammoLabel, targetXPlayer.name))
            targetXPlayer.showNotification(TranslateCap("received_weapon_withammo", weaponLabel, ammoCount, ammoLabel, sourceXPlayer.name))
        else
            sourceXPlayer.showNotification(TranslateCap("gave_weapon", weaponLabel, targetXPlayer.name))
            targetXPlayer.showNotification(TranslateCap("received_weapon", weaponLabel, sourceXPlayer.name))
        end
    elseif itemType == "item_ammo" then
        local count = Core.InventoryEvents.GetPositiveCount(itemCount)

        if not count then
            return sourceXPlayer.showNotification(TranslateCap("imp_invalid_quantity"))
        end

        if type(itemName) ~= "string" then
            return
        end

        itemName = string.upper(itemName)

        if not sourceXPlayer.hasWeapon(itemName) then
            return
        end

        local _, weapon = sourceXPlayer.getWeapon(itemName)
        if not weapon then
            return
        end

        if not targetXPlayer.hasWeapon(itemName) then
            sourceXPlayer.showNotification(TranslateCap("gave_weapon_noweapon", targetXPlayer.name))
            targetXPlayer.showNotification(TranslateCap("received_weapon_noweapon", sourceXPlayer.name, weapon.label))
            return
        end

        local _, weaponObject = ESX.GetWeapon(itemName)

        if not weaponObject.ammo then
            return
        end

        local ammoLabel = weaponObject.ammo.label
        if weapon.ammo >= count then
            sourceXPlayer.removeWeaponAmmo(itemName, count)
            targetXPlayer.addWeaponAmmo(itemName, count)

            sourceXPlayer.showNotification(TranslateCap("gave_weapon_ammo", count, ammoLabel, weapon.label, targetXPlayer.name))
            targetXPlayer.showNotification(TranslateCap("received_weapon_ammo", count, ammoLabel, weapon.label, sourceXPlayer.name))
        end
    end
end)
