--[[
      ESX Property - Properties Made Right!
    Copyright (C) 2023 ESX-Framework

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]
function CCTV(PropertyID)
  DoScreenFadeOut(500)
  Wait(500)
  local Property = Properties[PropertyID]
  local CamTakePic = true
  if Property.cctv.enabled then
    ESX.TriggerServerCallback("esx_property:CCTV", function(CanCCTV)
      if CanCCTV then
        InCCTV = true
        local NightVision = false
        local function InstructionButtonMessage(text)
          BeginTextCommandScaleformString("STRING")
          AddTextComponentScaleform(text)
          EndTextCommandScaleformString()
        end

        local function CreateInstuctionScaleform(scaleform)
          local scaleform = RequestScaleformMovie(scaleform)
          while not HasScaleformMovieLoaded(scaleform) do
            Wait(0)
          end
          PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
          PopScaleformMovieFunctionVoid()

          PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
          PushScaleformMovieFunctionParameterInt(200)
          PopScaleformMovieFunctionVoid()

          if Config.CCTV.PictureWebook ~= "" then
            PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
            PushScaleformMovieFunctionParameterInt(1)
            ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.Screenshot, true))
            InstructionButtonMessage(TranslateCap("take_picture"))
            PopScaleformMovieFunctionVoid()
          end

          PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
          PushScaleformMovieFunctionParameterInt(2)
          ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.Right, true))
          ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.Left, true))
          InstructionButtonMessage(TranslateCap("rot_left_right"))
          PopScaleformMovieFunctionVoid()

          PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
          PushScaleformMovieFunctionParameterInt(3)
          ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.Down, true))
          ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.Up, true))
          InstructionButtonMessage(TranslateCap("rot_up_down"))
          PopScaleformMovieFunctionVoid()

          PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
          PushScaleformMovieFunctionParameterInt(4)
          ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.ZoomOut, true))
          ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.ZoomIn, true))
          InstructionButtonMessage(TranslateCap("zoom"))
          PopScaleformMovieFunctionVoid()

          PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
          PushScaleformMovieFunctionParameterInt(5)
          ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.NightVision, true))
          InstructionButtonMessage(TranslateCap("night_vision"))
          PopScaleformMovieFunctionVoid()

          PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
          PushScaleformMovieFunctionParameterInt(0)
          ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, Config.CCTV.Controls.Exit, true))
          InstructionButtonMessage(TranslateCap("exit"))
          PopScaleformMovieFunctionVoid()

          PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
          PopScaleformMovieFunctionVoid()

          PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
          PushScaleformMovieFunctionParameterInt(0)
          PushScaleformMovieFunctionParameterInt(0)
          PushScaleformMovieFunctionParameterInt(0)
          PushScaleformMovieFunctionParameterInt(80)
          PopScaleformMovieFunctionVoid()

          return scaleform
        end
        ESX.CloseContext()
        local cctvcam = nil
        ClearFocus()
        local playerPed = PlayerPedId()
        cctvcam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA",
          vector3(Property.Entrance.x, Property.Entrance.y, Property.Entrance.z + Config.CCTV.HeightAboveDoor), 0, 0, 0, Config.CCTV.FOV)
        SetCamRot(cctvcam, Property.cctv.rot.x, Property.cctv.rot.y, Property.cctv.rot.z, 2)
        SetCamActive(cctvcam, true)
        SetTimecycleModifier("scanline_cam_cheap")
        TriggerServerEvent("p_instance:s:leave")
        DisableAllControlActions(0)
        FreezeEntityPosition(playerPed, true)
        SetEntityCollision(playerPed, false, true)
        local ShowButtons = true
        SetEntityVisible(playerPed, false)
        SetTimecycleModifierStrength(2.0)
        SetFocusArea(Property.Entrance.x, Property.Entrance.y, Property.Entrance.z, 0.0, 0.0, 0.0)
        PointCamAtCoord(cctvcam, vector3(Property.Entrance.x, Property.Entrance.y, Property.Entrance.z + Config.CCTV.HeightAboveDoor))
        RenderScriptCams(true, false, 1, true, false)
        Wait(1000)
        DoScreenFadeIn(500)
        RequestAmbientAudioBank("Phone_Soundset_Franklin", 0, 0)
        RequestAmbientAudioBank("HintCamSounds", 0, 0)
        while IsCamActive(cctvcam) do
          Wait(5)
          DisableAllControlActions(0)
          EnableControlAction(0, 245, true)
          EnableControlAction(0, 246, true)
          EnableControlAction(0, 249, true)
          HideHudComponentThisFrame(7)
          HideHudComponentThisFrame(8)
          HideHudComponentThisFrame(9)
          HideHudComponentThisFrame(6)
          HideHudComponentThisFrame(19)
          HideHudAndRadarThisFrame()

          if ShowButtons then
            local instructions = CreateInstuctionScaleform("instructional_buttons")
            DrawScaleformMovieFullscreen(instructions, 255, 255, 255, 255, 0)
          end
          -- ROTATE LEFT
          local getCameraRot = GetCamRot(cctvcam, 2)

          if IsDisabledControlPressed(0, Config.CCTV.Controls.Left) and getCameraRot.z < Property.cctv.maxleft then
            PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
            SetCamRot(cctvcam, getCameraRot.x, 0.0, getCameraRot.z + Config.CCTV.RotateSpeed, 2)
          end
          -- ROTATE RIGHT
          if IsDisabledControlPressed(0, Config.CCTV.Controls.Right) and getCameraRot.z > Property.cctv.maxright then
            PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
            SetCamRot(cctvcam, getCameraRot.x, 0.0, getCameraRot.z - Config.CCTV.RotateSpeed, 2)
          end

          -- ROTATE UP
          if IsDisabledControlPressed(0, Config.CCTV.Controls.Up) and getCameraRot.x < Config.CCTV.MaxUpRotation then
            PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
            SetCamRot(cctvcam, getCameraRot.x + Config.CCTV.RotateSpeed, 0.0, getCameraRot.z, 2)
          end

          if IsDisabledControlPressed(0, Config.CCTV.Controls.Down) and getCameraRot.x > Config.CCTV.MaxDownRotation then
            PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
            SetCamRot(cctvcam, getCameraRot.x - Config.CCTV.RotateSpeed, 0.0, getCameraRot.z, 2)
          end

          if IsDisabledControlPressed(0, Config.CCTV.Controls.ZoomIn) and GetCamFov(cctvcam) > Config.CCTV.MaxZoom then
            SetCamFov(cctvcam, GetCamFov(cctvcam) - 1.0)
          end

          if IsDisabledControlPressed(0, Config.CCTV.Controls.ZoomOut) and GetCamFov(cctvcam) < Config.CCTV.MinZoom then
            SetCamFov(cctvcam, GetCamFov(cctvcam) + 1.0)
          end

          if IsDisabledControlPressed(0, Config.CCTV.Controls.Down) and getCameraRot.x > Config.CCTV.MaxDownRotation then
            PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
            SetCamRot(cctvcam, getCameraRot.x - Config.CCTV.RotateSpeed, 0.0, getCameraRot.z, 2)
          end

          SetTextFont(4)
          SetTextScale(0.8, 0.8)
          SetTextColour(255, 255, 255, 255)
          SetTextDropshadow(0.1, 3, 27, 27, 255)
          BeginTextCommandDisplayText('STRING')
          AddTextComponentSubstringPlayerName(Property.setName ~= "" and Property.setName or Property.Name)
          EndTextCommandDisplayText(0.01, 0.01)

          SetTextFont(4)
          SetTextScale(0.7, 0.7)
          SetTextColour(255, 255, 255, 255)
          SetTextDropshadow(0.1, 3, 27, 27, 255)
          BeginTextCommandDisplayText('STRING')
          local year --[[ integer ]] , month --[[ integer ]] , day --[[ integer ]] , hour --[[ integer ]] , minute --[[ integer ]] , second --[[ integer ]] =
            GetPosixTime()
          AddTextComponentSubstringPlayerName("" .. day .. "/" .. month .. "/" .. year .. " " .. hour .. ":" .. minute .. ":" .. second)
          EndTextCommandDisplayText(0.01, 0.055)

          SetTextFont(4)
          SetTextScale(0.6, 0.6)
          SetTextColour(255, 255, 255, 255)
          SetTextDropshadow(0.1, 3, 27, 27, 255)
          BeginTextCommandDisplayText('STRING')
          local Zoom = ((Config.CCTV.FOV - GetCamFov(cctvcam)) / GetCamFov(cctvcam)) * 100
          AddTextComponentSubstringPlayerName(TranslateCap("zoom_level", math.floor(Zoom)))
          EndTextCommandDisplayText(0.01, 0.09)

          SetTextFont(4)
          SetTextScale(0.6, 0.6)
          SetTextColour(255, 255, 255, 255)
          SetTextDropshadow(0.1, 3, 27, 27, 255)
          BeginTextCommandDisplayText('STRING')
          AddTextComponentSubstringPlayerName(NightVision and "Night Vision: Active" or "CCTV System: Active")
          EndTextCommandDisplayText(0.01, 0.12)

          if IsDisabledControlPressed(0, Config.CCTV.Controls.Down) and getCameraRot.x > Config.CCTV.MaxDownRotation then
            PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
            SetCamRot(cctvcam, getCameraRot.x - Config.CCTV.RotateSpeed, 0.0, getCameraRot.z, 2)
          end

          if IsDisabledControlJustPressed(0, 38) then
            NightVision = not NightVision
            SetNightvision(NightVision)
            SetTimecycleModifier("scanline_cam")
          end

          if Config.CCTV.PictureWebook ~= "" and IsDisabledControlJustPressed(0, 201) then
            if CamTakePic then
              ShowButtons = false
              Wait(1)
              PlaySoundFrontend(-1, "Camera_Shoot", "Phone_Soundset_Franklin", 1)
              ESX.TriggerServerCallback("esx_property:GetWebhook", function(hook)
                if hook then
                  exports['screenshot-basic']:requestScreenshotUpload(hook, "files[]", function(data)
                    local image = json.decode(data)
                    ESX.ShowNotification(TranslateCap("picture_taken"), "success")
                    SendNUIMessage({link = image.attachments[1].proxy_url})
                    ESX.ShowNotification(TranslateCap("clipboard"), "success")
                    ShowButtons = true
                    CamTakePic = false
                    SetTimeout(5000, function()
                      CamTakePic = true
                    end)
                  end)
                end
              end)
            else
              ESX.ShowNotification(TranslateCap("please_wait"), "error")
            end
          end

          if IsDisabledControlPressed(1, Config.CCTV.Controls.Exit) then
            DoScreenFadeOut(1000)
            ESX.TriggerServerCallback("esx_property:ExitCCTV", function(CanExit)
              if CanExit then
                InCCTV = false
                Wait(1000)
                ClearFocus()
                ClearTimecycleModifier()
                ClearExtraTimecycleModifier()
                RenderScriptCams(false, false, 0, true, false)
                DestroyCam(cctvcam, false)
                SetFocusEntity(playerPed)
                SetNightvision(false)
                SetSeethrough(false)
                SetEntityCollision(playerPed, true, true)
                FreezeEntityPosition(playerPed, false)
                SetEntityVisible(playerPed, true)
                Wait(1500)
                DoScreenFadeIn(1000)
              end
            end, PropertyID)
            break
          end
        end
      end
    end, PropertyID)
  end
end
