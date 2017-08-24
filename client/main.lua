local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX                           = nil
local GUI                     = {}
GUI.Time                      = 0
local PlayerData              = {}
local FirstSpawn              = true
local IsDead                  = false
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local RespawnToHospitalMenu   = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function RespawnPed(ped, coords)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, true, false)
	SetPlayerInvincible(ped, false)
	TriggerEvent('playerSpawned', coords.x, coords.y, coords.z, coords.heading)
	ClearPedBloodDamage(ped)
	if RespawnToHospitalMenu ~= nil then
		RespawnToHospitalMenu.close()
		RespawnToHospitalMenu = nil
	end
	ESX.UI.Menu.CloseAll()
end

function StartRespawnToHospitalMenuTimer()

	ESX.SetTimeout(Config.MenuRespawnToHospitalDelay, function()

		if IsDead then

			local elements = {}

			table.insert(elements, {label = _U('yes'), value = 'yes'})

			RespawnToHospitalMenu = ESX.UI.Menu.Open(
				'default', GetCurrentResourceName(), 'menuName',
				{
					title = _U('respawn_at_hospital'),
					align = 'top-left',
					elements = elements
				},
		        function(data, menu) --Submit Cb

		        	menu.close()

		         	Citizen.CreateThread(function()

						DoScreenFadeOut(800)

						while not IsScreenFadedOut() do
							Citizen.Wait(0)
						end

						ESX.TriggerServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function()

							TriggerServerEvent('esx:updateLastPosition', Config.Zones.HospitalInteriorInside1.Pos)

							RespawnPed(GetPlayerPed(-1), Config.Zones.HospitalInteriorInside1.Pos)
							StopScreenEffect('DeathFailOut')
							DoScreenFadeIn(800)
						end)
					end)
		        end,
		        function(data, menu) --Cancel Cb
		                --menu.close()
		        end,
		        function(data, menu) --Change Cb
		                --print(data.current.value)
		        end,
		        function(data, menu) --Close Cb
		            RespawnToHospitalMenu = nil
		        end
			)
		end
	end)
end

function StartRespawnTimer()

	ESX.SetTimeout(Config.RespawnDelayAfterRPDeath, function()

		if IsDead then

			Citizen.CreateThread(function()

				DoScreenFadeOut(800)

				while not IsScreenFadedOut() do
					Citizen.Wait(0)
				end

				ESX.TriggerServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function()

					TriggerServerEvent('esx:updateLastPosition', Config.Zones.HospitalInteriorInside1.Pos)

					RespawnPed(GetPlayerPed(-1), Config.Zones.HospitalInteriorInside1.Pos)
					StopScreenEffect('DeathFailOut')
					DoScreenFadeIn(800)
				end)
			end)
		end
	end)
end

function RespawnTimer()

	local timer = Config.RespawnDelayAfterRPDeath
	local allowRespawn = Config.RespawnDelayAfterRPDeath/2
	local enoughMoney = false
	local money = 0

	if IsDead and Config.ShowDeathTimer then
		ESX.TriggerServerCallback('esx_ambulancejob:getBankMoney', function(money)
			if money >= Config.EarlyRespawnFineAmount then
				enoughMoney = true
			else
				enoughMoney = false
			end
		end)
		Citizen.CreateThread(function()

			while timer > 0 and IsDead do
				raw_seconds = timer/1000
				raw_minutes = raw_seconds/60
				minutes = stringsplit(raw_minutes, ".")[1]
				seconds = stringsplit(raw_seconds-(minutes*60), ".")[1]

				if Config.EarlyRespawn and Config.EarlyRespawnFine and enoughMoney then
					SetTextFont(4)
					SetTextProportional(0)
					SetTextScale(0.0, 0.5)
					SetTextColour(255, 255, 255, 255)
					SetTextDropshadow(0, 0, 0, 0, 255)
					SetTextEdge(1, 0, 0, 0, 255)
					SetTextDropShadow()
					SetTextOutline()
					SetTextEntry("STRING")
					AddTextComponentString(_U('please_wait') .. minutes .. _U('minutes') .. seconds .. _U('seconds_fine') .. Config.EarlyRespawnFineAmount .. _U('press_respawn_fine'))
					SetTextCentre(true)
					DrawText(0.5, 0.8)
					timer = timer - 15
					Citizen.Wait(0)
					if IsControlPressed(0,  Keys['E']) then
						DoScreenFadeOut(800)

						while not IsScreenFadedOut() do
							Citizen.Wait(0)
						end

						ESX.TriggerServerCallback('esx_ambulancejob:removeItemsAfterRPDeathRemoveMoney', function()

							TriggerServerEvent('esx_ambulancejob:removeAccountMoney', source)
							TriggerServerEvent('esx:updateLastPosition', Config.Zones.HospitalInteriorInside1.Pos)

							RespawnPed(GetPlayerPed(-1), Config.Zones.HospitalInteriorInside1.Pos)
							StopScreenEffect('DeathFailOut')
							DoScreenFadeIn(800)
						end)
					end
				else
					SetTextFont(4)
					SetTextProportional(0)
					SetTextScale(0.0, 0.5)
					SetTextColour(255, 255, 255, 255)
					SetTextDropshadow(0, 0, 0, 0, 255)
					SetTextEdge(1, 0, 0, 0, 255)
					SetTextDropShadow()
					SetTextOutline()
					SetTextEntry("STRING")
					AddTextComponentString(_U('please_wait') .. minutes .. _U('minutes') .. seconds .. _U('seconds'))
					SetTextCentre(true)
					DrawText(0.5, 0.8)
					timer = timer - 15
					Citizen.Wait(0)
				end
			end

			while timer <= 0 and IsDead do
				SetTextFont(4)
				SetTextProportional(0)
				SetTextScale(0.0, 0.5)
				SetTextColour(255, 255, 255, 255)
				SetTextDropshadow(0, 0, 0, 0, 255)
				SetTextEdge(1, 0, 0, 0, 255)
				SetTextDropShadow()
				SetTextOutline()
				SetTextEntry("STRING")
				AddTextComponentString(_U('press_respawn'))
				SetTextCentre(true)
				DrawText(0.5, 0.8)
				Citizen.Wait(0)
				if IsControlPressed(0,  Keys['E']) then
					DoScreenFadeOut(800)

					while not IsScreenFadedOut() do
						Citizen.Wait(0)
					end

					ESX.TriggerServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function()

						TriggerServerEvent('esx:updateLastPosition', Config.Zones.HospitalInteriorInside1.Pos)

						RespawnPed(GetPlayerPed(-1), Config.Zones.HospitalInteriorInside1.Pos)
						--StopScreenEffect('DeathFailOut')
						DoScreenFadeIn(800)
					end)
				end
			end
		end)
	end
end

function TeleportFadeEffect(entity, coords)

	Citizen.CreateThread(function()

		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Citizen.Wait(0)
		end

		ESX.Game.Teleport(entity, coords, function()
			DoScreenFadeIn(800)
		end)

	end)

end

function WarpPedInClosestVehicle(ped)

	local coords = GetEntityCoords(ped)

  local vehicle, distance = ESX.Game.GetClosestVehicle({
  	x = coords.x,
  	y = coords.y,
  	z = coords.z
  })

  if distance ~= -1 and distance <= 5.0 then

  	local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
  	local freeSeat = nil

  	for i=maxSeats - 1, 0, -1 do
  		if IsVehicleSeatFree(vehicle,  i) then
  			freeSeat = i
  			break
  		end
  	end

  	if freeSeat ~= nil then
  		TaskWarpPedIntoVehicle(ped,  vehicle,  freeSeat)
  	end

  else
  	ESX.ShowNotification(_U('no_vehicles'))
  end

end

function OpenAmbulanceActionsMenu()

	local elements = {
		{label = _U('cloakroom'), value = 'cloakroom'}
	}

	if Config.EnablePlayerManagement and PlayerData.job.grade_name == 'boss' then
		table.insert(elements, {label = _U('withdraw_society'), value = 'withdraw_society_money'})
		table.insert(elements, {label = _U('deposit_society'), value = 'deposit_society_money'})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'ambulance_actions',
		{
			title    = _U('ambulance'),
			elements = elements
		},
		function(data, menu)

			if data.current.value == 'cloakroom' then
				OpenCloakroomMenu()
			end

			if data.current.value == 'withdraw_society_money' then

				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'withdraw_society_money_amount',
					{
						title = _U('money_withdraw')
					},
					function(data, menu)

						local amount = tonumber(data.value)

						if amount == nil then
							ESX.ShowNotification(_U('invalid_amount'))
						else
							menu.close()
							TriggerServerEvent('esx_society:withdrawMoney', 'ambulance', amount)
						end

					end,
					function(data, menu)
						menu.close()
					end
				)

			end

			if data.current.value == 'deposit_society_money' then

				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'deposit_money_amount',
					{
						title = _U('deposit_amount')
					},
					function(data, menu)

						local amount = tonumber(data.value)

						if amount == nil then
							ESX.ShowNotification(_U('invalid_amount'))
						else
							menu.close()
							TriggerServerEvent('esx_society:depositMoney', 'ambulance', amount)
						end

					end,
					function(data, menu)
						menu.close()
					end
				)

			end

		end,
		function(data, menu)

			menu.close()

			CurrentAction     = 'ambulance_actions_menu'
			CurrentActionMsg  = _U('open_menu')
			CurrentActionData = {}

		end
	)

end

function OpenMobileAmbulanceActionsMenu()

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'mobile_ambulance_actions',
		{
			title    = _U('ambulance'),
			elements = {
				{label = _U('ems_menu'), value = 'citizen_interaction'},
			}
		},
		function(data, menu)

			if data.current.value == 'citizen_interaction' then

				ESX.UI.Menu.Open(
					'default', GetCurrentResourceName(), 'citizen_interaction',
					{
						title    = _U('ems_menu_title'),
						elements = {
					  	{label = _U('ems_menu_revive'),             value = 'revive'},
					  	{label = _U('ems_menu_putincar'), value = 'put_in_vehicle'},
						}
					},
					function(data, menu)

						if data.current.value == 'revive' then

							menu.close()

							local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

							if closestPlayer == -1 or closestDistance > 3.0 then
								ESX.ShowNotification(_U('no_players'))
							else

								local ped    = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(ped)

								if health == 0 then

								local playerPed        = GetPlayerPed(-1)
								local closestPlayerPed = GetPlayerPed(closestPlayer)

								Citizen.CreateThread(function()

									ESX.ShowNotification(_U('revive_inprogress'))

									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									Citizen.Wait(10000)
									ClearPedTasks(playerPed)

									if GetEntityHealth(closestPlayerPed) == 0 then
										TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(closestPlayer))
										ESX.ShowNotification(_U('revive_complete') .. GetPlayerName(closestPlayer))
									else
										ESX.ShowNotification(GetPlayerName(closestPlayer) .. _U('isdead'))
									end

								end)

								else
									ESX.ShowNotification(GetPlayerName(closestPlayer) .. _U('unconscious'))
								end

							end

						end

						if data.current.value == 'put_in_vehicle' then
							menu.close()
							WarpPedInClosestVehicle(GetPlayerPed(closestPlayer))
						end

					end,
					function(data, menu)
						menu.close()
					end
				)

			end

		end,
		function(data, menu)
			menu.close()
		end
	)

end

function OpenCloakroomMenu()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'cloakroom',
		{
			title    = _U('cloakroom'),
			align    = 'top-left',
			elements = {
				{label = _U('ems_clothes_civil'), value = 'citizen_wear'},
				{label = _U('ems_clothes_ems'), value = 'ambulance_wear'},
			},
		},
		function(data, menu)

			menu.close()

			if data.current.value == 'citizen_wear' then

				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					TriggerEvent('skinchanger:loadSkin', skin)
				end)

			end

			if data.current.value == 'ambulance_wear' then

				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)

					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
					else
						TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
					end

				end)

			end

			CurrentAction     = 'ambulance_actions_menu'
			CurrentActionMsg  = _U('open_menu')
			CurrentActionData = {}

		end,
		function(data, menu)
			menu.close()
		end
	)

end

function OpenVehicleSpawnerMenu()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'cloakroom',
		{
			title    = _U('veh_menu'),
			align    = 'top-left',
			elements = {
				{label = _U('ambulance'),   value = 'ambulance'},
				{label = _U('helicopter'), value = 'polmav'},
			},
		},
		function(data, menu)

			menu.close()

			local model = data.current.value

			ESX.Game.SpawnVehicle(model, Config.Zones.VehicleSpawnPoint.Pos, 270.0, function(vehicle)

				local playerPed = GetPlayerPed(-1)

				if model == 'polmav' then
					SetVehicleModKit(vehicle, 0)
					SetVehicleLivery(vehicle, 1)
				end

				TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)

			end)

		end,
		function(data, menu)

			menu.close()

			CurrentAction     = 'vehicle_spawner_menu'
			CurrentActionMsg  = _U('veh_spawn')
			CurrentActionData = {}

		end
	)

end

AddEventHandler('playerSpawned', function()

	IsDead = false

	if FirstSpawn then
		exports.spawnmanager:setAutoSpawn(false)
		FirstSpawn = false
	end

end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)

	PlayerData = xPlayer

	if PlayerData.job.name == 'ambulance' then

		Config.Zones.AmbulanceActions.Type = 1
		Config.Zones.VehicleSpawner.Type   = 1
		Config.Zones.VehicleDeleter.Type   = 1

	else

		Config.Zones.AmbulanceActions.Type = -1
		Config.Zones.VehicleSpawner.Type   = -1
		Config.Zones.VehicleDeleter.Type   = -1

	end

end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)

	PlayerData.job = job

	if PlayerData.job.name == 'ambulance' then

		Config.Zones.AmbulanceActions.Type = 1
		Config.Zones.VehicleSpawner.Type   = 1
		Config.Zones.VehicleDeleter.Type   = 1

	else

		Config.Zones.AmbulanceActions.Type = -1
		Config.Zones.VehicleSpawner.Type   = -1
		Config.Zones.VehicleDeleter.Type   = -1

	end

end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)

	local specialContact = {
		name       = 'Ambulance',
		number     = 'ambulance',
		base64Icon = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEwAACxMBAJqcGAAABp5JREFUWIW1l21sFNcVhp/58npn195de23Ha4Mh2EASSvk0CPVHmmCEI0RCTQMBKVVooxYoalBVCVokICWFVFVEFeKoUdNECkZQIlAoFGMhIkrBQGxHwhAcChjbeLcsYHvNfsx+zNz+MBDWNrYhzSvdP+e+c973XM2cc0dihFi9Yo6vSzN/63dqcwPZcnEwS9PDmYoE4IxZIj+ciBb2mteLwlZdfji+dXtNU2AkeaXhCGteLZ/X/IS64/RoR5mh9tFVAaMiAldKQUGiRzFp1wXJPj/YkxblbfFLT/tjq9/f1XD0sQyse2li7pdP5tYeLXXMMGUojAiWKeOodE1gqpmNfN2PFeoF00T2uLGKfZzTwhzqbaEmeYWAQ0K1oKIlfPb7t+7M37aruXvEBlYvnV7xz2ec/2jNs9kKooKNjlksiXhJfLqf1PXOIU9M8fmw/XgRu523eTNyhhu6xLjbSeOFC6EX3t3V9PmwBla9Vv7K7u85d3bpqlwVcvHn7B8iVX+IFQoNKdwfstuFtWoFvwp9zj5XL7nRlPXyudjS9z+u35tmuH/lu6dl7+vSVXmDUcpbX+skP65BxOOPJA4gjDicOM2PciejeTwcsYek1hyl6me5nhNnmwPXBhjYuGC699OpzoaAO0PbYJSy5vgt4idOPrJwf6QuX2FO0oOtqIgj9pDU5dCWrMlyvXf86xsGgHyPeLos83Brns1WFXLxxgVBorHpW4vfQ6KhkbUtCot6srns1TLPjNVr7+1J0PepVc92H/Eagkb7IsTWd4ZMaN+yCXv5zLRY9GQ9xuYtQz4nfreWGdH9dNlkfnGq5/kdO88ekwGan1B3mDJsdMxCqv5w2Iq0khLs48vSllrsG/Y5pfojNugzScnQXKBVA8hrX51ddHq0o6wwIlgS8Y7obZdUZVjOYLC6e3glWkBBVHC2RJ+w/qezCuT/2sV6Q5VYpowjvnf/iBJJqvpYBgBS+w6wVB5DLEOiTZHWy36nNheg0jUBs3PoJnMfyuOdAECqrZ3K7KcACGQp89RAtlysCphqZhPtRzYlcPx+ExklJUiq0le5omCfOGFAYn3qFKS/fZAWS7a3Y2wa+GJOEy4US+B3aaPUYJamj4oI5LA/jWQBt5HIK5+JfXzZsJVpXi/ac8+mxWIXWzAG4Wb4g/jscNMp63I4U5FcKaVvsNyFALokSA47Kx8PVk83OabCHZsiqwAKEpjmfUJIkoh/R+L9oTpjluhRkGSPG4A7EkS+Y3HZk0OXYpIVNy01P5yItnptDsvtIwr0SunqoVP1GG1taTHn1CloXm9aLBEIEDl/IS2W6rg+qIFEYR7+OJTesqJqYa95/VKBNOHLjDBZ8sDS2998a0Bs/F//gvu5Z9NivadOc/U3676pEsizBIN1jCYlhClL+ELJDrkobNUBfBZqQfMN305HAgnIeYi4OnYMh7q/AsAXSdXK+eH41sykxd+TV/AsXvR/MeARAttD9pSqF9nDNfSEoDQsb5O31zQFprcaV244JPY7bqG6Xd9K3C3ALgbfk3NzqNE6CdplZrVFL27eWR+UASb6479ULfhD5AzOlSuGFTE6OohebElbcb8fhxA4xEPUgdTK19hiNKCZgknB+Ep44E44d82cxqPPOKctCGXzTmsBXbV1j1S5XQhyHq6NvnABPylu46A7QmVLpP7w9pNz4IEb0YyOrnmjb8bjB129fDBRkDVj2ojFbYBnCHHb7HL+OC7KQXeEsmAiNrnTqLy3d3+s/bvlVmxpgffM1fyM5cfsPZLuK+YHnvHELl8eUlwV4BXim0r6QV+4gD9Nlnjbfg1vJGktbI5UbN/TcGmAAYDG84Gry/MLLl/zKouO2Xukq/YkCyuWYV5owTIGjhVFCPL6J7kLOTcH89ereF1r4qOsm3gjSevl85El1Z98cfhB3qBN9+dLp1fUTco+0OrVMnNjFuv0chYbBYT2HcBoa+8TALyWQOt/ImPHoFS9SI3WyRajgdt2mbJgIlbREplfveuLf/XXemjXX7v46ZxzPlfd8YlZ01My5MUEVdIY5rueYopw4fQHkbv7/rZkTw6JwjyalBCHur9iD9cI2mU0UzD3P9H6yZ1G5dt7Gwe96w07dl5fXj7vYqH2XsNovdTI6KMrlsAXhRyz7/C7FBO/DubdVq4nBLPaohcnBeMr3/2k4fhQ+Uc8995YPq2wMzNjww2X+vwNt1p00ynrd2yKDJAVN628sBX1hZIdxXdStU9G5W2bd9YHR5L3f/CNmJeY9G8WAAAAAElFTkSuQmCC'
	}

	TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)

end)

AddEventHandler('baseevents:onPlayerDied', function(killerType, coords)
	TriggerEvent('esx_ambulancejob:onPlayerDeath')
end)

AddEventHandler('baseevents:onPlayerKilled', function(killerId, data)
	TriggerEvent('esx_ambulancejob:onPlayerDeath')
end)

AddEventHandler('esx_ambulancejob:onPlayerDeath', function()

	IsDead = true

	if Config.ShowDeathTimer == true then
		RespawnTimer()
	else
		StartRespawnTimer()
		StartRespawnToHospitalMenuTimer()
	end

	StartScreenEffect('DeathFailOut',  0,  false)

end)

RegisterNetEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function()

	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed)

	Citizen.CreateThread(function()

		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Citizen.Wait(0)
		end

		TriggerServerEvent('esx:updateLastPosition', {
			x = coords.x,
			y = coords.y,
			z = coords.z
		})

		RespawnPed(playerPed, {
			x = coords.x,
			y = coords.y,
			z = coords.z
		})

		StopScreenEffect('DeathFailOut')

		DoScreenFadeIn(800)

	end)

end)

AddEventHandler('esx_ambulancejob:hasEnteredMarker', function(zone)

	if zone == 'HospitalInteriorEntering1' then
		TeleportFadeEffect(GetPlayerPed(-1), Config.Zones.HospitalInteriorInside1.Pos)
	end

	if zone == 'HospitalInteriorExit1' then
		TeleportFadeEffect(GetPlayerPed(-1), Config.Zones.HospitalInteriorOutside1.Pos)
	end

	if zone == 'HospitalInteriorEntering2' then
		TeleportFadeEffect(GetPlayerPed(-1), Config.Zones.HospitalInteriorInside2.Pos)
	end

	if zone == 'HospitalInteriorExit2' then
		TeleportFadeEffect(GetPlayerPed(-1), Config.Zones.HospitalInteriorOutside2.Pos)
	end

	if zone == 'AmbulanceActions' and PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' then
		CurrentAction     = 'ambulance_actions_menu'
		CurrentActionMsg  = _U('open_menu')
		CurrentActionData = {}
	end

	if zone == 'VehicleSpawner' and PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' then
		CurrentAction     = 'vehicle_spawner_menu'
		CurrentActionMsg  = _U('veh_spawn')
		CurrentActionData = {}
	end

	if zone == 'VehicleDeleter' and PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' then

		local playerPed = GetPlayerPed(-1)
		local coords    = GetEntityCoords(playerPed)

		if IsPedInAnyVehicle(playerPed,  false) then

			local vehicle, distance = ESX.Game.GetClosestVehicle({
				x = coords.x,
				y = coords.y,
				z = coords.z
			})

			if distance ~= -1 and distance <= 1.0 then

				CurrentAction     = 'delete_vehicle'
				CurrentActionMsg  = _U('store_veh')
				CurrentActionData = {vehicle = vehicle}

			end

		end

		end

end)

AddEventHandler('esx_ambulancejob:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)

-- Create blips
Citizen.CreateThread(function()

	local blip = AddBlipForCoord(Config.Zones.HospitalInteriorOutside1.Pos.x, Config.Zones.HospitalInteriorOutside1.Pos.y, Config.Zones.HospitalInteriorOutside1.Pos.z)

  SetBlipSprite (blip, 61)
  SetBlipDisplay(blip, 4)
  SetBlipScale  (blip, 1.2)
  SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(_U('hospital'))
  EndTextCommandSetBlipName(blip)

end)

-- Display markers
Citizen.CreateThread(function()
	while true do

		Wait(0)

		local coords = GetEntityCoords(GetPlayerPed(-1))

		for k,v in pairs(Config.Zones) do

			if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
			end
		end

	end
end)

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
	while true do

		Wait(0)

		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false
		local currentZone = nil

		for k,v in pairs(Config.Zones) do
			if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
				isInMarker  = true
				currentZone = k
			end
		end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			lastZone                = currentZone
			TriggerEvent('esx_ambulancejob:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('esx_ambulancejob:hasExitedMarker', lastZone)
		end

	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		if CurrentAction ~= nil then

			SetTextComponentFormat('STRING')
			AddTextComponentString(CurrentActionMsg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlPressed(0,  Keys['E']) and PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' and (GetGameTimer() - GUI.Time) > 150 then

				if CurrentAction == 'ambulance_actions_menu' then
					OpenAmbulanceActionsMenu()
				end

				if CurrentAction == 'vehicle_spawner_menu' then
					OpenVehicleSpawnerMenu()
				end

				if CurrentAction == 'delete_vehicle' then
					ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
				end

				CurrentAction = nil
				GUI.Time      = GetGameTimer()

			end

		end

		if IsControlPressed(0,  Keys['F6']) and PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' and (GetGameTimer() - GUI.Time) > 150 then
			OpenMobileAmbulanceActionsMenu()
			GUI.Time = GetGameTimer()
		end

	end
end)

-- Load unloaded IPLs
Citizen.CreateThread(function()
  LoadMpDlcMaps()
  EnableMpDlcMaps(true)
  RequestIpl('Coroner_Int_on') -- Morgue
end)

-- String string
function stringsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end
