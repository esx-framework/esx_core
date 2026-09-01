Camera = {}
Camera._index = Camera

function Camera:AngleLoop()
    CreateThread(function()
        while self.cam do
            if IsDisabledControlPressed(0, 44) then
                Skin.heading = Skin.heading - 1
            elseif IsDisabledControlPressed(0, 38) then
                Skin.heading = Skin.heading + 1
            end

            if Skin.heading > 360 then
                Skin.heading = Skin.heading - 360
            elseif Skin.heading < 0 then
                Skin.heading = Skin.heading + 360
            end

            Wait(0)
        end
    end)
end

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
    ESX.TextUI(Translate('use_rotate_view', "Q", "E"))
    self:AngleLoop()
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
