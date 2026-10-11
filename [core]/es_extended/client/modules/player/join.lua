-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

CreateThread(function()
    while not Config.Multichar do
        Wait(100)

        if NetworkIsPlayerActive(ESX.playerId) then
            ESX.DisableSpawnManager()
            DoScreenFadeOut(0)
            Wait(500)
            TriggerServerEvent("esx:onPlayerJoined")
            break
        end
    end
end)
