local self = ESX.Modules['skin']

self.Init()

Citizen.CreateThread(function()
	while true do

    Citizen.Wait(0)

		if self.isCameraActive then
			DisableControlAction(2, 30, true)
			DisableControlAction(2, 31, true)
			DisableControlAction(2, 32, true)
			DisableControlAction(2, 33, true)
			DisableControlAction(2, 34, true)
			DisableControlAction(2, 35, true)
			DisableControlAction(0, 25, true) -- Input Aim
			DisableControlAction(0, 24, true) -- Input Attack

			local playerPed = PlayerPedId()
			local coords    = GetEntityCoords(playerPed)

			local angle = self.heading * math.pi / 180.0
			local theta = {
				x = math.cos(angle),
				y = math.sin(angle)
			}

			local pos = {
				x = coords.x + (self.zoomOffset * theta.x),
				y = coords.y + (self.zoomOffset * theta.y)
			}

      local angleToLook = self.heading - 140.0

			if angleToLook > 360 then
				angleToLook = angleToLook - 360
			elseif angleToLook < 0 then
				angleToLook = angleToLook + 360
			end

      angleToLook = angleToLook * math.pi / 180.0

			local thetaToLook = {
				x = math.cos(angleToLook),
				y = math.sin(angleToLook)
			}

			local posToLook = {
				x = coords.x + (self.zoomOffset * thetaToLook.x),
				y = coords.y + (self.zoomOffset * thetaToLook.y)
			}

			SetCamCoord(self.cam, pos.x, pos.y, coords.z + self.camOffset)
			PointCamAtCoord(self.cam, posToLook.x, posToLook.y, coords.z + self.camOffset)

      ESX.ShowHelpNotification(_U('use_rotate_view'))

		else
			Citizen.Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	local angle = 90

	while true do
		Citizen.Wait(0)

		if self.isCameraActive then
			if IsControlPressed(0, 108) then
				self.angle = angle - 1
			elseif IsControlPressed(0, 109) then
				self.angle = angle + 1
			end

			if self.angle > 360 then
				self.angle = self.angle - 360
			elseif angle < 0 then
				self.angle = self.angle + 360
			end

			self.heading = angle + 0.0
		else
			Citizen.Wait(500)
		end
	end
end)
