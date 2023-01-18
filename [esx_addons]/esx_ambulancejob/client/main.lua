local firstSpawn = true

isDead, isSearched, medic = false, false, 0

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
  ESX.PlayerLoaded = false
  firstSpawn = true
end)

AddEventHandler('esx:onPlayerSpawn', function()
  isDead = false
  ClearTimecycleModifier()
  SetPedMotionBlur(PlayerPedId(), false)
  ClearExtraTimecycleModifier()
  EndDeathCam()
  if firstSpawn then
    firstSpawn = false

    if Config.SaveDeathStatus then
      while not ESX.PlayerLoaded do
        Wait(1000)
      end

      ESX.TriggerServerCallback('esx_ambulancejob:getDeathStatus', function(shouldDie)
        if shouldDie then
          Wait(1000)
          SetEntityHealth(PlayerPedId(), 0)
        end
      end)
    end
  end
end)

-- Create blips
CreateThread(function()
  for k, v in pairs(Config.Hospitals) do
    local blip = AddBlipForCoord(v.Blip.coords)

    SetBlipSprite(blip, v.Blip.sprite)
    SetBlipScale(blip, v.Blip.scale)
    SetBlipColour(blip, v.Blip.color)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(TranslateCap('blip_hospital'))
    EndTextCommandSetBlipName(blip)
  end

  while true do
    local Sleep = 1500

    if isDead then
      Sleep = 0
      DisableAllControlActions(0)
      EnableControlAction(0, 47, true) -- G 
      EnableControlAction(0, 245, true) -- T
      EnableControlAction(0, 38, true) -- E

      ProcessCamControls()
      if isSearched then
        local playerPed = PlayerPedId()
        local ped = GetPlayerPed(GetPlayerFromServerId(medic))
        isSearched = false

        AttachEntityToEntity(playerPed, ped, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        Wait(1000)
        DetachEntity(playerPed, true, false)
        ClearPedTasksImmediately(playerPed)
      end
    end

    Wait(Sleep)
  end
end)

RegisterNetEvent('esx_ambulancejob:clsearch')
AddEventHandler('esx_ambulancejob:clsearch', function(medicId)
  local playerPed = PlayerPedId()

  if isDead then
    local coords = GetEntityCoords(playerPed)
    local playersInArea = ESX.Game.GetPlayersInArea(coords, 50.0)

    for i = 1, #playersInArea, 1 do
      local player = playersInArea[i]
      if player == GetPlayerFromServerId(medicId) then
        medic = tonumber(medicId)
        isSearched = true
        break
      end
    end
  end
end)

function OnPlayerDeath()
  isDead = true
  ESX.CloseContext()
  ClearTimecycleModifier()
  SetTimecycleModifier("REDMIST_blend")
  SetTimecycleModifierStrength(0.7)
  SetExtraTimecycleModifier("fp_vig_red")
  SetExtraTimecycleModifierStrength(1.0)
  SetPedMotionBlur(PlayerPedId(), true)
  TriggerServerEvent('esx_ambulancejob:setDeathStatus', true)
  StartDeathTimer()
  StartDeathCam()
  StartDistressSignal()
end

RegisterNetEvent('esx_ambulancejob:useItem')
AddEventHandler('esx_ambulancejob:useItem', function(itemName)
  ESX.CloseContext()

  if itemName == 'medikit' then
    local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO better animations
    local playerPed = PlayerPedId()

    ESX.Streaming.RequestAnimDict(lib, function()
      TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
      RemoveAnimDict(lib)

      Wait(500)
      while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
        Wait(0)
        DisableAllControlActions(0)
      end

      TriggerEvent('esx_ambulancejob:heal', 'big', true)
      ESX.ShowNotification(TranslateCap('used_medikit'))
    end)

  elseif itemName == 'bandage' then
    local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO better animations
    local playerPed = PlayerPedId()

    ESX.Streaming.RequestAnimDict(lib, function()
      TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
      RemoveAnimDict(lib)

      Wait(500)
      while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
        Wait(0)
        DisableAllControlActions(0)
      end

      TriggerEvent('esx_ambulancejob:heal', 'small', true)
      ESX.ShowNotification(TranslateCap('used_bandage'))
    end)
  end
end)

function StartDistressSignal()
  CreateThread(function()
    local timer = Config.BleedoutTimer

    while timer > 0 and isDead do
      Wait(0)
      timer = timer - 30

      SetTextFont(4)
      SetTextScale(0.5, 0.5)
      SetTextColour(200, 50, 50, 255)
      SetTextDropshadow(0.1, 3, 27, 27, 255)
      BeginTextCommandDisplayText('STRING')
      AddTextComponentSubstringPlayerName(TranslateCap('distress_send'))
      EndTextCommandDisplayText(0.43, 0.77)

      if IsControlJustReleased(0, 47) then
        SendDistressSignal()
        break
      end
    end
  end)
end

function SendDistressSignal()
  local playerPed = PlayerPedId()
  local coords = GetEntityCoords(playerPed)

  ESX.ShowNotification(TranslateCap('distress_sent'))
  TriggerServerEvent('esx_ambulancejob:onPlayerDistress')
end

function DrawGenericTextThisFrame()
  SetTextFont(4)
  SetTextScale(0.0, 0.5)
  SetTextColour(255, 255, 255, 255)
  SetTextDropshadow(0, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(true)
end

function secondsToClock(seconds)
  local seconds, hours, mins, secs = tonumber(seconds), 0, 0, 0

  if seconds <= 0 then
    return 0, 0
  else
    local hours = string.format('%02.f', math.floor(seconds / 3600))
    local mins = string.format('%02.f', math.floor(seconds / 60 - (hours * 60)))
    local secs = string.format('%02.f', math.floor(seconds - hours * 3600 - mins * 60))

    return mins, secs
  end
end

function StartDeathTimer()
  local canPayFine = false

  if Config.EarlyRespawnFine then
    ESX.TriggerServerCallback('esx_ambulancejob:checkBalance', function(canPay)
      canPayFine = canPay
    end)
  end

  local earlySpawnTimer = ESX.Math.Round(Config.EarlyRespawnTimer / 1000)
  local bleedoutTimer = ESX.Math.Round(Config.BleedoutTimer / 1000)

  CreateThread(function()
    -- early respawn timer
    while earlySpawnTimer > 0 and isDead do
      Wait(1000)

      if earlySpawnTimer > 0 then
        earlySpawnTimer = earlySpawnTimer - 1
      end
    end

    -- bleedout timer
    while bleedoutTimer > 0 and isDead do
      Wait(1000)

      if bleedoutTimer > 0 then
        bleedoutTimer = bleedoutTimer - 1
      end
    end
  end)

  CreateThread(function()
    local text, timeHeld

    -- early respawn timer
    while earlySpawnTimer > 0 and isDead do
      Wait(0)
      text = TranslateCap('respawn_available_in', secondsToClock(earlySpawnTimer))

      DrawGenericTextThisFrame()
      BeginTextCommandDisplayText('STRING')
      AddTextComponentSubstringPlayerName(text)
      EndTextCommandDisplayText(0.5, 0.8)
    end

    -- bleedout timer
    while bleedoutTimer > 0 and isDead do
      Wait(0)
      text = TranslateCap('respawn_bleedout_in', secondsToClock(bleedoutTimer))

      if not Config.EarlyRespawnFine then
        text = text .. TranslateCap('respawn_bleedout_prompt')

        if IsControlPressed(0, 38) and timeHeld > 120 then
          RemoveItemsAfterRPDeath()
          break
        end
      elseif Config.EarlyRespawnFine and canPayFine then
        text = text .. TranslateCap('respawn_bleedout_fine', ESX.Math.GroupDigits(Config.EarlyRespawnFineAmount))

        if IsControlPressed(0, 38) and timeHeld > 120 then
          TriggerServerEvent('esx_ambulancejob:payFine')
          RemoveItemsAfterRPDeath()
          break
        end
      end

      if IsControlPressed(0, 38) then
        timeHeld += 1
      else
        timeHeld = 0
      end

      DrawGenericTextThisFrame()

      BeginTextCommandDisplayText('STRING')
      AddTextComponentSubstringPlayerName(text)
      EndTextCommandDisplayText(0.5, 0.8)
    end

    if bleedoutTimer < 1 and isDead then
      RemoveItemsAfterRPDeath()
    end
  end)
end

function GetClosestRespawnPoint()
  local PlyCoords = GetEntityCoords(PlayerPedId())
  local ClosestDist, ClosestHospital, ClosestCoord = 10000, {}, nil

  for k, v in pairs(Config.RespawnPoints) do
    local Distance = #(PlyCoords - vector3(v.coords.x, v.coords.y, v.coords.z))
    if Distance <= ClosestDist then
      ClosestDist = Distance
      ClosestHospital = v
      ClosestCoord = vector3(v.coords.x, v.coords.y, v.coords.z)
    end
  end

  return ClosestCoord, ClosestHospital
end

function RemoveItemsAfterRPDeath()
  TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)

  CreateThread(function()
    ESX.TriggerServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function()
      local RespawnCoords, ClosestHospital = GetClosestRespawnPoint()

      ESX.SetPlayerData('loadout', {})

      DoScreenFadeOut(800)
      RespawnPed(PlayerPedId(), RespawnCoords, ClosestHospital.heading)
      while not IsScreenFadedOut() do
        Wait(0)
      end
      DoScreenFadeIn(800)
    end)
  end)
end

function RespawnPed(ped, coords, heading)
  SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
  NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
  SetPlayerInvincible(ped, false)
  ClearPedBloodDamage(ped)

  TriggerServerEvent('esx:onPlayerSpawn')
  TriggerEvent('esx:onPlayerSpawn')
  TriggerEvent('playerSpawned') -- compatibility with old scripts, will be removed soon
end

AddEventHandler('esx:onPlayerDeath', function(data)
  OnPlayerDeath()
end)

RegisterNetEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function()
  local playerPed = PlayerPedId()
  local coords = GetEntityCoords(playerPed)
  TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)

  DoScreenFadeOut(800)

  while not IsScreenFadedOut() do
    Wait(50)
  end

  local formattedCoords = {x = ESX.Math.Round(coords.x, 1), y = ESX.Math.Round(coords.y, 1), z = ESX.Math.Round(coords.z, 1)}

  RespawnPed(playerPed, formattedCoords, 0.0)
  isDead = false
  ClearTimecycleModifier()
  SetPedMotionBlur(playerPed, false)
  ClearExtraTimecycleModifier()
  EndDeathCam()
  DoScreenFadeIn(800)
end)

-- Load unloaded IPLs
if Config.LoadIpl then
  RequestIpl('Coroner_Int_on') -- Morgue
end

local cam = nil

local isDead = false

local angleY = 0.0

local angleZ = 0.0

-------------------------------------------------------

-----------------DEATH CAMERA FUNCTIONS ---------------

--------------------------------------------------------

-- initialize camera

function StartDeathCam()
  ClearFocus()
  local playerPed = PlayerPedId()
  cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(playerPed), 0, 0, 0, GetGameplayCamFov())
  SetCamActive(cam, true)
  RenderScriptCams(true, true, 1000, true, false)
end

-- destroy camera

function EndDeathCam()
  ClearFocus()
  RenderScriptCams(false, false, 0, true, false)
  DestroyCam(cam, false)
  cam = nil
end
-- process camera controls
function ProcessCamControls()
  local playerPed = PlayerPedId()
  local playerCoords = GetEntityCoords(playerPed)
  -- disable 1st person as the 1st person camera can cause some glitches
  DisableFirstPersonCamThisFrame()
  -- calculate new position
  local newPos = ProcessNewPosition()
  SetFocusArea(newPos.x, newPos.y, newPos.z, 0.0, 0.0, 0.0)
  -- set coords of cam
  SetCamCoord(cam, newPos.x, newPos.y, newPos.z)
  -- set rotation
  PointCamAtCoord(cam, playerCoords.x, playerCoords.y, playerCoords.z + 0.5)
end

function ProcessNewPosition()
  local mouseX = 0.0
  local mouseY = 0.0
  -- keyboard
  if (IsInputDisabled(0)) then
    -- rotation
    mouseX = GetDisabledControlNormal(1, 1) * 8.0

    mouseY = GetDisabledControlNormal(1, 2) * 8.0
    -- controller
  else
    mouseX = GetDisabledControlNormal(1, 1) * 1.5

    mouseY = GetDisabledControlNormal(1, 2) * 1.5
  end

  angleZ = angleZ - mouseX -- around Z axis (left / right)

  angleY = angleY + mouseY -- up / down
  -- limit up / down angle to 90°

  if (angleY > 89.0) then
    angleY = 89.0
  elseif (angleY < -89.0) then
    angleY = -89.0
  end
  local pCoords = GetEntityCoords(PlayerPedId())
  local behindCam = {x = pCoords.x + ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * (5.5 + 0.5),

                     y = pCoords.y + ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * (5.5 + 0.5),

                     z = pCoords.z + ((Sin(angleY))) * (5.5 + 0.5)}
  local rayHandle = StartShapeTestRay(pCoords.x, pCoords.y, pCoords.z + 0.5, behindCam.x, behindCam.y, behindCam.z, -1, PlayerPedId(), 0)

  local a, hitBool, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

  local maxRadius = 1.9
  if (hitBool and Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords) < 5.5 + 0.5) then
    maxRadius = Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords)
  end

  local offset = {x = ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * maxRadius,
                  y = ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * maxRadius, z = ((Sin(angleY))) * maxRadius}

  local pos = {x = pCoords.x + offset.x, y = pCoords.y + offset.y, z = pCoords.z + offset.z}

  return pos
end
