ESX = nil
local debugProps, sitting, lastPos, currentSitCoords, currentScenario = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

if Config.Debug then
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)

			for i=1, #debugProps, 1 do
				local coords = GetEntityCoords(debugProps[i])
				local hash = GetEntityModel(debugProps[i])
				local id = coords.x .. coords.y .. coords.z
				local model = 'unknown'

				for i=1, #Config.Interactables, 1 do
					local seat = Config.Interactables[i]

					if hash == GetHashKey(seat) then
						model = seat
						break
					end
				end

				local text = ('ID: %s~n~Hash: %s~n~Model: %s'):format(id, hash, model)

				ESX.Game.Utils.DrawText3D({
					x = coords.x,
					y = coords.y,
					z = coords.z + 2.0
				}, text, 0.5)
			end

			if #debugProps == 0 then
				Citizen.Wait(500)
			end
		end
	end)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()

		if sitting and not IsPedUsingScenario(playerPed, currentScenario) then
			wakeup()
		end

		if IsControlJustPressed(0, 38) and IsControlPressed(0, 21) and IsInputDisabled(0) and IsPedOnFoot(playerPed) then
			if sitting then
				wakeup()
			else
				local object, distance = ESX.Game.GetClosestObject(Config.Interactables)

				if Config.Debug then
					table.insert(debugProps, object)
				end

				if distance < 1.5 then
					local hash = GetEntityModel(object)

					for k,v in pairs(Config.Sitable) do
						if GetHashKey(k) == hash then
							sit(object, k, v)
							break
						end
					end
				end
			end
		end
	end
end)

function wakeup()
	local playerPed = PlayerPedId()
	ClearPedTasks(playerPed)

	sitting = false

	SetEntityCoords(playerPed, lastPos)
	FreezeEntityPosition(playerPed, false)

	TriggerServerEvent('esx_sit:leavePlace', currentSitCoords)
	currentSitCoords, currentScenario = nil, nil
end

function sit(object, modelName, data)
	local pos = GetEntityCoords(object)
	local objectCoords = pos.x .. pos.y .. pos.z

	ESX.TriggerServerCallback('esx_sit:getPlace', function(occupied)
		if occupied then
			ESX.ShowNotification('Cette place est prise...')
		else
			local playerPed = PlayerPedId()
			lastPos, currentSitCoords = GetEntityCoords(playerPed), objectCoords

			TriggerServerEvent('esx_sit:takePlace', objectCoords)
			FreezeEntityPosition(object, true)

			currentScenario = data.scenario
			TaskStartScenarioAtPosition(playerPed, currentScenario, pos.x, pos.y, pos.z - data.verticalOffset, GetEntityHeading(object) + 180.0, 0, true, true)
			Citizen.Wait(1000)
			sitting = true
		end
	end)
end
