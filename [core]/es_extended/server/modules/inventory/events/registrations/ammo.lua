-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

if Config.CustomInventory then
    return
end

local MAX_AMMO <const> = 100000

local ammoLimiter = xLib.rateLimiter({
    capacity = 10,
    refill = 10,
    interval = 1000,
})

RegisterNetEvent("esx:updateWeaponAmmo", function(weaponName, ammoCount)
    local playerId = source

    if type(weaponName) ~= "string" or not ammoLimiter:consume(playerId) then
        return
    end

    ammoCount = tonumber(ammoCount)

    if not ammoCount or ammoCount < 0 or ammoCount > MAX_AMMO or ammoCount ~= math.floor(ammoCount) then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(playerId)

    if not xPlayer then
        return
    end

    local _, weapon = xPlayer.getWeapon(weaponName)

    if not weapon then
        return
    end

    if ammoCount > weapon.ammo then
        return
    end

    xPlayer.updateWeaponAmmo(weaponName, ammoCount)
end)