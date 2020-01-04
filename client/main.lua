local Player          = nil
local CruisedSpeed, CruisedSpeedKm, VehicleVectorY = 0, 0, 0

ESX = nil

Citizen.CreateThread(function ()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Wait(0)
  end
end)

Citizen.CreateThread(function ()
  while true do
    Wait(0)
    if IsControlJustPressed(1, 246) and IsDriver() then
      Player = GetPlayerPed(-1)
      TriggerCruiseControl()
    end
  end
end)

function TriggerCruiseControl ()
  if CruisedSpeed == 0 and IsDriving() then
    if GetVehiculeSpeed() > 0 and GetVehicleCurrentGear(GetVehicle()) > 0  then
      CruisedSpeed = GetVehiculeSpeed()
      CruisedSpeedKm = TransformToKm(CruisedSpeed)

      ESX.ShowNotification(_U('activated') .. ': ~b~ ' .. CruisedSpeedKm .. ' km/h')

      Citizen.CreateThread(function ()
        while CruisedSpeed > 0 and IsInVehicle() == Player do
          Wait(0)

          if not IsTurningOrHandBraking() and GetVehiculeSpeed() < (CruisedSpeed - 1.5) then
            CruisedSpeed = 0
            ESX.ShowNotification(_U('deactivated'))
            Wait(2000)
            break
          end

          if not IsTurningOrHandBraking() and IsVehicleOnAllWheels(GetVehicle()) and GetVehiculeSpeed() < CruisedSpeed then
            SetVehicleForwardSpeed(GetVehicle(), CruisedSpeed)
          end

          if IsControlJustPressed(1, 246) then
            CruisedSpeed = GetVehiculeSpeed()
            CruisedSpeedKm = TransformToKm(CruisedSpeed)
          end

          if IsControlJustPressed(2, 72) then
            CruisedSpeed = 0
            ESX.ShowNotification(_U('deactivated'))
            Wait(2000)
            break
          end
        end
      end)
    end
  end
end

function IsTurningOrHandBraking ()
  return IsControlPressed(2, 76) or IsControlPressed(2, 63) or IsControlPressed(2, 64)
end

function IsDriving ()
  return IsPedInAnyVehicle(Player, false)
end

function GetVehicle ()
  return GetVehiclePedIsIn(Player, false)
end

function IsInVehicle ()
  return GetPedInVehicleSeat(GetVehicle(), -1)
end

function IsDriver ()
  return GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1) == GetPlayerPed(-1)
end

function GetVehiculeSpeed ()
  return GetEntitySpeed(GetVehicle())
end

function TransformToKm (speed)
  return math.floor(speed * 3.6 + 0.5)
end
