DoScreenFadeIn(0)

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

function TeleportFadeEffect(entity, coords)

	Citizen.CreateThread(function()
		
		DoScreenFadeOut(800)
		
		while not IsScreenFadedOut() do
			Citizen.Wait(0)
		end

		ESX.Game.TeleportEntity(entity, coords, function()
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
  	ESX.ShowNotification('Aucun véhicule à proximité')
  end

end

function OpenAmbulanceActionsMenu()

	local elements = {
		{label = 'Vestiaire', value = 'cloakroom'}
	}

	if Config.EnablePlayerManagement and PlayerData.job.grade_name == 'boss' then
		table.insert(elements, {label = 'Retirer argent société', value = 'withdraw_society_money'})
		table.insert(elements, {label = 'Déposer argent',         value = 'deposit_society_money'})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'ambulance_actions',
		{
			title    = 'Ambulance',
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
						title = 'Montant du retrait'
					},
					function(data, menu)

						local amount = tonumber(data.value)

						if amount == nil then
							ESX.ShowNotification('Montant invalide')
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
						title = 'Montant du dépôt'
					},
					function(data, menu)

						local amount = tonumber(data.value)

						if amount == nil then
							ESX.ShowNotification('Montant invalide')
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
			CurrentActionMsg  = 'Appuyez sur ~INPUT_CONTEXT~ pour ouvrir le menu'
			CurrentActionData = {}

		end
	)

end

function OpenMobileAmbulanceActionsMenu()

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'mobile_ambulance_actions',
		{
			title    = 'Ambulance',
			elements = {
				{label = 'Interaction citoyen', value = 'citizen_interaction'},
			}
		},
		function(data, menu)

			if data.current.value == 'citizen_interaction' then

				ESX.UI.Menu.Open(
					'default', GetCurrentResourceName(), 'citizen_interaction',
					{
						title    = 'Ambulance - Interactions Citoyen',
						elements = {
					  	{label = 'Réanimer',             value = 'revive'},
					  	{label = 'Mettre dans véhicule', value = 'put_in_vehicle'},
						}
					},
					function(data, menu)

						if data.current.value == 'revive' then

							menu.close()

							local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

							if closestPlayer == -1 or closestDistance > 3.0 then
								ESX.ShowNotification('Aucun joueur à proximité')
							else

								local ped    = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(ped)

								if health == 0 then

								local playerPed        = GetPlayerPed(-1)
								local closestPlayerPed = GetPlayerPed(closestPlayer)

								Citizen.CreateThread(function()
									
									ESX.ShowNotification('Réanimation en cours')

									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									Citizen.Wait(10000)
									ClearPedTasks(playerPed)

									if GetEntityHealth(closestPlayerPed) == 0 then
										TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(closestPlayer))
										ESX.ShowNotification('Vous avez réanimé ' .. GetPlayerName(closestPlayer))
									else
										ESX.ShowNotification(GetPlayerName(closestPlayer) .. ' a succombé')
									end

								end)

								else
									ESX.ShowNotification(GetPlayerName(closestPlayer) .. ' n\'est pas inconscient')
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
			title    = 'Vestiaire',
			align    = 'top-left',
			elements = {
				{label = 'Tenue Civil',       value = 'citizen_wear'},
				{label = 'Tenue Ambulancier', value = 'ambulance_wear'},
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
			CurrentActionMsg  = 'Appuyez sur ~INPUT_CONTEXT~ pour ouvrir le menu'
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
			title    = 'Véhicule',
			align    = 'top-left',
			elements = {
				{label = 'Ambulance',   value = 'ambulance'},
				{label = 'Hélicoptère', value = 'polmav'},
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
			CurrentActionMsg  = 'Appuyez sur ~INPUT_CONTEXT~ pour sortir un véhicule'
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

AddEventHandler('baseevents:onPlayerDied', function(killerType, coords)
	TriggerEvent('esx_ambulancejob:onPlayerDeath')
end)

AddEventHandler('baseevents:onPlayerKilled', function(killerId, data)
	TriggerEvent('esx_ambulancejob:onPlayerDeath')
end)

AddEventHandler('esx_ambulancejob:onPlayerDeath', function()

	IsDead = true

	StartRespawnTimer()

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
		CurrentActionMsg  = 'Appuyez sur ~INPUT_CONTEXT~ pour ouvrir le menu'
		CurrentActionData = {}
	end

	if zone == 'VehicleSpawner' and PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' then
		CurrentAction     = 'vehicle_spawner_menu'
		CurrentActionMsg  = 'Appuyez sur ~INPUT_CONTEXT~ pour sortir un véhicule'
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
				CurrentActionMsg  = 'Appuyez sur ~INPUT_CONTEXT~ pour ranger le véhicule'
				CurrentActionData = {vehicle = vehicle}

			end

		end

		end

end)

AddEventHandler('esx_ambulancejob:hasExitedMarker', function(zone)
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
  AddTextComponentString("Hôpital")
  EndTextCommandSetBlipName(blip)

end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		
		Wait(0)
		
		local coords = GetEntityCoords(GetPlayerPed(-1))
		
		for k,v in pairs(Config.Zones) do

			if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
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
			if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.MarkerSize.x) then
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