-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Camera = {}
Camera._index = Camera

function Camera:Reset()
    Skin.heading = 90.0
end

function Camera:DisableContols()
    local controls = {30, 31, 32, 33, 34, 35, 25, 24}
    for i=1 , #controls do
        DisableControlAction(2, controls[i], true)
    end
end

function Camera:PositionLoop()
    CreateThread(function()
        while self.cam do
            self:DisableContols()

            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)

            local pos, posToLook = Skin:CalcuatePosition(coords)

            SetCamCoord(self.cam, pos.x, pos.y, coords.z + Skin.camOffset)
            PointCamAtCoord(self.cam, posToLook.x, posToLook.y, coords.z + Skin.camOffset)
            Wait(0)
        end
    end)
end

function Camera:StartLoops()
    ESX.TextUI(Translate("drag_rotate_view"))
    self:PositionLoop()
end

function Camera:Create()
    if self.cam then
        return
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    self.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(self.cam, playerCoords.x, playerCoords.y, playerCoords.z + 1.0)
    SetCamRot(self.cam, 0.0, 0.0, 270.0, 2)
    SetEntityHeading(playerPed, 0.0)

    SetCamActive(self.cam, true)
    RenderScriptCams(true, true, 500, true, true)
    self:StartLoops()
end

function Camera:Destroy()
    if not self.cam then
        return
    end

    ESX.HideUI()
    RenderScriptCams(false, true, 500, true, true)
    DestroyCam(self.cam, true)
    self.cam = nil
end
