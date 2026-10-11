-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

function StartServerSyncLoops()
    if Config.CustomInventory then
        return
    end

    local currentWeapon = {
        ---@type number
        ---@diagnostic disable-next-line: assign-type-mismatch
        hash = `WEAPON_UNARMED`,
        ammo = 0,
    }

    local function updateCurrentWeaponAmmo(weaponName)
        local newAmmo = GetAmmoInPedWeapon(ESX.PlayerData.ped, currentWeapon.hash)

        if newAmmo ~= currentWeapon.ammo then
            currentWeapon.ammo = newAmmo
            TriggerServerEvent("esx:updateWeaponAmmo", weaponName, newAmmo)
        end
    end

    CreateThread(function()
        while ESX.PlayerLoaded do
            currentWeapon.hash = GetSelectedPedWeapon(ESX.PlayerData.ped)

            if currentWeapon.hash ~= `WEAPON_UNARMED` then
                local weaponConfig = ESX.GetWeaponFromHash(currentWeapon.hash)

                if weaponConfig then
                    currentWeapon.ammo = GetAmmoInPedWeapon(ESX.PlayerData.ped, currentWeapon.hash)

                    while GetSelectedPedWeapon(ESX.PlayerData.ped) == currentWeapon.hash do
                        updateCurrentWeaponAmmo(weaponConfig.name)
                        Wait(1000)
                    end

                    updateCurrentWeaponAmmo(weaponConfig.name)
                end
            end
            Wait(250)
        end
    end)

    CreateThread(function()
        local PARACHUTE_OPENING <const> = 1
        local PARACHUTE_OPEN <const> = 2

        while ESX.PlayerLoaded do
            local parachuteState = GetPedParachuteState(ESX.PlayerData.ped)

            if parachuteState == PARACHUTE_OPENING or parachuteState == PARACHUTE_OPEN then
                TriggerServerEvent("esx:updateWeaponAmmo", "GADGET_PARACHUTE", 0)

                while GetPedParachuteState(ESX.PlayerData.ped) ~= -1 do
                    Wait(1000)
                end
            end
            Wait(500)
        end
    end)
end
