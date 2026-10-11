-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

if Config.CustomInventory then
    return
end

ESX.SecureNetEvent("esx:addInventoryItem", function(item, count, showNotification, itemData)
    if type(item) ~= "string" then
        return
    end

    local found
    for k, v in ipairs(ESX.PlayerData.inventory) do
        if v.name == item then
            ESX.UI.ShowInventoryItemNotification(true, v.label, count - v.count)
            ESX.PlayerData.inventory[k].count = count
            found = true
            break
        end
    end

    if not found then
        if type(count) ~= "number" then
            if showNotification then
                ESX.UI.ShowInventoryItemNotification(true, item, count)
            end

            return
        end

        local entry

        if type(itemData) == "table" then
            entry = {
                name = item,
                count = count,
                label = itemData.label or item,
                weight = itemData.weight or 0,
                usable = itemData.usable,
                rare = itemData.rare,
                canRemove = itemData.canRemove,
            }
        else
            entry = {
                name = item,
                count = count,
                label = item,
                weight = 0,
                usable = false,
                rare = false,
                canRemove = true,
            }
        end

        ESX.PlayerData.inventory[#ESX.PlayerData.inventory + 1] = entry
        ESX.UI.ShowInventoryItemNotification(true, entry.label, count)
    end

    if showNotification then
        ESX.UI.ShowInventoryItemNotification(true, item, count)
    end
end)

ESX.SecureNetEvent("esx:removeInventoryItem", function(item, count, showNotification)
    if type(item) ~= "string" then
        return
    end

    for i = 1, #ESX.PlayerData.inventory do
        if ESX.PlayerData.inventory[i].name == item then
            ESX.UI.ShowInventoryItemNotification(false, ESX.PlayerData.inventory[i].label, ESX.PlayerData.inventory[i].count - count)

            if count > 0 then
                ESX.PlayerData.inventory[i].count = count
            else
                table.remove(ESX.PlayerData.inventory, i)
            end

            break
        end
    end

    if showNotification then
        ESX.UI.ShowInventoryItemNotification(false, item, count)
    end
end)

ESX.SecureNetEvent("esx:addLoadoutItem", function(weaponName, weaponLabel, ammo)
    ESX.PlayerData.loadout[#ESX.PlayerData.loadout + 1] = {
        name = weaponName,
        ammo = ammo,
        label = weaponLabel,
        components = {},
        tintIndex = 0,
    }
end)

ESX.SecureNetEvent("esx:removeLoadoutItem", function(weaponName)
    for i = 1, #ESX.PlayerData.loadout do
        if ESX.PlayerData.loadout[i].name == weaponName then
            table.remove(ESX.PlayerData.loadout, i)
            break
        end
    end
end)

ESX.SecureNetEvent("esx:updateWeaponAmmo", function(weaponName, ammo)
    for i = 1, #ESX.PlayerData.loadout do
        if ESX.PlayerData.loadout[i].name == weaponName then
            ESX.PlayerData.loadout[i].ammo = ammo
            break
        end
    end
end)

RegisterNetEvent("esx:addWeapon", function()
    error("event ^5'esx:addWeapon'^1 Has Been Removed. Please use ^5xPlayer.addWeapon^1 Instead!")
end)

RegisterNetEvent("esx:addWeaponComponent", function()
    error("event ^5'esx:addWeaponComponent'^1 Has Been Removed. Please use ^5xPlayer.addWeaponComponent^1 Instead!")
end)

RegisterNetEvent("esx:setWeaponAmmo", function()
    error("event ^5'esx:setWeaponAmmo'^1 Has Been Removed. Please use ^5xPlayer.addWeaponAmmo^1 Instead!")
end)

ESX.SecureNetEvent("esx:setWeaponTint", function(weapon, weaponTintIndex)
    SetPedWeaponTintIndex(ESX.PlayerData.ped, joaat(weapon), weaponTintIndex)
end)

RegisterNetEvent("esx:removeWeapon", function()
    error("event ^5'esx:removeWeapon'^1 Has Been Removed. Please use ^5xPlayer.removeWeapon^1 Instead!")
end)

ESX.SecureNetEvent("esx:removeWeaponComponent", function(weapon, weaponComponent)
    local componentHash = ESX.GetWeaponComponent(weapon, weaponComponent).hash
    RemoveWeaponComponentFromPed(ESX.PlayerData.ped, joaat(weapon), componentHash)
end)

AddEventHandler("esx:restoreLoadout", function()
    ESX.SetPlayerData("ped", PlayerPedId())

    local ammoTypes = {}
    RemoveAllPedWeapons(ESX.PlayerData.ped, true)

    for _, v in ipairs(ESX.PlayerData.loadout) do
        local weaponName = v.name
        local weaponHash = joaat(weaponName)

        GiveWeaponToPed(ESX.PlayerData.ped, weaponHash, 0, false, false)
        SetPedWeaponTintIndex(ESX.PlayerData.ped, weaponHash, v.tintIndex)

        local ammoType = GetPedAmmoTypeFromWeapon(ESX.PlayerData.ped, weaponHash)

        for _, componentName in ipairs(v.components) do
            local componentHash = ESX.GetWeaponComponent(weaponName, componentName).hash
            GiveWeaponComponentToPed(ESX.PlayerData.ped, weaponHash, componentHash)
        end

        if not ammoTypes[ammoType] then
            AddAmmoToPed(ESX.PlayerData.ped, weaponHash, v.ammo)
            ammoTypes[ammoType] = true
        end
    end
end)
