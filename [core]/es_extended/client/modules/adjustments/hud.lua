-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

function Adjustments:RemoveHudComponents()
    for i = 1, #Config.RemoveHudComponents do
        if Config.RemoveHudComponents[i] then
            SetHudComponentSize(i, 0.0, 0.0)
            SetHudComponentPosition(i, 900.0, 900.0)
        end
    end
end

function Adjustments:AmmoAndVehicleRewards()
    if not Config.DisableDisplayAmmo and not Config.DisableVehicleRewards then
        return
    end

    CreateThread(function()
        while ESX.PlayerLoaded do
            if Config.DisableDisplayAmmo then
                DisplayAmmoThisFrame(false)
            end

            if Config.DisableVehicleRewards then
                DisablePlayerVehicleRewards(ESX.playerId)
            end

            Wait(0)
        end
    end)
end