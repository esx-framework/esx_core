-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local noclip = false
local noclipPos = vector3(0, 0, 70)
local heading = 0

local function noclipThread()
    while noclip do
        SetEntityCoordsNoOffset(ESX.PlayerData.ped, noclipPos.x, noclipPos.y, noclipPos.z, false, false, true)

        if IsControlPressed(1, 34) then
            heading = heading + 1.5
            if heading > 360 then
                heading = 0
            end

            SetEntityHeading(ESX.PlayerData.ped, heading)
        end

        if IsControlPressed(1, 9) then
            heading = heading - 1.5
            if heading < 0 then
                heading = 360
            end

            SetEntityHeading(ESX.PlayerData.ped, heading)
        end

        if IsControlPressed(1, 8) then
            noclipPos = GetOffsetFromEntityInWorldCoords(ESX.PlayerData.ped, 0.0, 1.0, 0.0)
        end

        if IsControlPressed(1, 32) then
            noclipPos = GetOffsetFromEntityInWorldCoords(ESX.PlayerData.ped, 0.0, -1.0, 0.0)
        end

        if IsControlPressed(1, 27) then
            noclipPos = GetOffsetFromEntityInWorldCoords(ESX.PlayerData.ped, 0.0, 0.0, 1.0)
        end

        if IsControlPressed(1, 173) then
            noclipPos = GetOffsetFromEntityInWorldCoords(ESX.PlayerData.ped, 0.0, 0.0, -1.0)
        end
        Wait(0)
    end
end

RegisterNetEvent("esx:noclip", function()
    xLib.callback("esx:isUserAdmin", false, function(admin)
        if not admin then
            return
        end

        if not noclip then
            noclipPos = GetEntityCoords(ESX.PlayerData.ped, false)
            heading = GetEntityHeading(ESX.PlayerData.ped)
        end

        noclip = not noclip
        if noclip then
            CreateThread(noclipThread)
        end

        if noclip then
            ESX.ShowNotification(TranslateCap("noclip_message", Translate("enabled")), "success")
        else
            ESX.ShowNotification(TranslateCap("noclip_message", Translate("disabled")), "error")
        end
    end)
end)
