local CruisedSpeed, CruisedSpeedKm, VehicleVectorY = 0, 0, 0

RegisterCommand("cruise", function(src)
	if IsDriver() then 
		TriggerCruiseControl()
	end
end)

RegisterKeyMapping("cruise", "Enable Cruise Control", "keyboard",Config.ToggleKey)

function TriggerCruiseControl()
	if CruisedSpeed == 0 and IsDriving() then
		if GetVehicleSpeed() > 0 and GetVehicleCurrentGear(GetVehicle()) > 0	then
			CruisedSpeed = GetVehicleSpeed()
			CruisedSpeedKm = TransformToKm(CruisedSpeed)

			ESX.ShowNotification(TranslateCap('activated') .. ':  ' .. CruisedSpeedKm .. ' km/h')

			CreateThread(function ()
				while CruisedSpeed > 0 and IsInVehicle() == PlayerPedId() do
					Wait(0)

					if not IsTurningOrHandBraking() and GetVehicleSpeed() < (CruisedSpeed - 1.5) then
						CruisedSpeed = 0
						ESX.ShowNotification(TranslateCap('deactivated'))
						Wait(2000)
						break
					end

					if not IsTurningOrHandBraking() and IsVehicleOnAllWheels(GetVehicle()) and GetVehicleSpeed() < CruisedSpeed then
						SetVehicleForwardSpeed(GetVehicle(), CruisedSpeed)
					end

					if IsControlJustPressed(1, 246) then
						CruisedSpeed = GetVehicleSpeed()
						CruisedSpeedKm = TransformToKm(CruisedSpeed)
					end

					if IsControlJustPressed(2, 72) then
						CruisedSpeed = 0
						ESX.ShowNotification(TranslateCap('deactivated'))
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
	return IsPedInAnyVehicle(PlayerPedId(), false)
end

function GetVehicle ()
	return GetVehiclePedIsIn(PlayerPedId(), false)
end

function IsInVehicle ()
	return GetPedInVehicleSeat(GetVehicle(), -1)
end

function IsDriver ()
	return GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), -1)
end

function GetVehicleSpeed ()
	return GetEntitySpeed(GetVehicle())
end

function TransformToKm (speed)
	return math.floor(speed * 3.6 + 0.5)
end
