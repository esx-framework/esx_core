-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

if Config.CustomInventory then
    return
end

RegisterNetEvent("esx:onPickup", function(pickupId)
    pickupId = tonumber(pickupId)
    if not pickupId then
        return
    end

    if not Core.InventoryEvents.ConsumeRate("pickup", source) then
        return
    end

    local pickup = Core.Pickups[pickupId]

    if not pickup or pickup.claimed then
        return
    end

    if GetPlayerRoutingBucket(source) ~= pickup.bucket then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return
    end

    local playerPickupDistance = #(pickup.coords - xPlayer.getCoords(true))
    if playerPickupDistance > 5.0 then
        print(("[^3WARNING^7] Player Detected Cheating (Out of range pickup): ^5%s^7"):format(xPlayer.getIdentifier()))
        return
    end

    pickup.claimed = true
    local success = false

    if pickup.type == "item_standard" then
        if not xPlayer.canCarryItem(pickup.name, pickup.count) then
            pickup.claimed = nil
            return xPlayer.showNotification(TranslateCap("threw_cannot_pickup"))
        end

        xPlayer.addInventoryItem(pickup.name, pickup.count)
        success = true
    elseif pickup.type == "item_account" then
        xPlayer.addAccountMoney(pickup.name, pickup.count, "Picked up")
        success = true
    elseif pickup.type == "item_weapon" then
        if xPlayer.hasWeapon(pickup.name) then
            pickup.claimed = nil
            return xPlayer.showNotification(TranslateCap("threw_weapon_already"))
        end

        xPlayer.addWeapon(pickup.name, pickup.count)
        xPlayer.setWeaponTint(pickup.name, pickup.tintIndex)

        for _, component in ipairs(pickup.components or {}) do
            xPlayer.addWeaponComponent(pickup.name, component)
        end

        success = true
    end

    if success then
        local targets = Core.GetPickupTargets(pickup.coords, pickup.bucket)

        Core.RemovePickup(pickupId, targets)
    else
        pickup.claimed = nil
    end
end)