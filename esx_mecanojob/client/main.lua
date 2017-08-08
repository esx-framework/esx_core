ESX                             = nil
local PlayerData                = {}
local GUI                       = {}
GUI.Time                        = 0
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local OnJob                     = false
local TargetCoords              = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function OpenMecanoActionsMenu()

	local elements = {
		{label = 'Sortir Véhicule', value = 'vehicle_list'},
		{label = 'Tenue de travail', value = 'cloakroom'},
		{label = 'Tenue civile', value = 'cloakroom2'}
	}
	if Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.grade_name == 'boss' then
  		table.insert(elements, {label = 'Retirer argent société', value = 'withdraw_society_money'})
  		table.insert(elements, {label = 'Déposer argent ',        value = 'deposit_money'})
  		table.insert(elements, {label = 'Blanchir argent',        value = 'wash_money'})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'mecano_actions',
		{
			title    = 'Mecano',
			elements = elements
		},
		function(data, menu)
			if data.current.value == 'vehicle_list' then
				local elements = {
					{label = 'Plateau', value = 'flatbed'},
					{label = 'Dépaneuse', value = 'towtruck2'}					
				}

				if Config.EnablePlayerManagement and PlayerData.job ~= nil and 
					(PlayerData.job.grade_name == 'boss' or PlayerData.job.grade_name == 'chef' or PlayerData.job.grade_name == 'experimente') then
					table.insert(elements, {label = 'SlamVan', value = 'slamvan3'})
				end

				ESX.UI.Menu.CloseAll()

				ESX.UI.Menu.Open(
					'default', GetCurrentResourceName(), 'spawn_vehicle',
					{
						title    = 'Véhicule de service',
						elements = elements
					},
					function(data, menu)
						for i=1, #elements, 1 do							
							if Config.MaxInService == -1 then
								local playerPed = GetPlayerPed(-1)
								local coords    = Config.Zones.VehicleSpawnPoint.Pos
								ESX.Game.SpawnVehicle(data.current.value, coords, 90.0, function(vehicle)
									TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
								end)
								break
							else
								ESX.TriggerServerCallback('esx_service:enableService', function(canTakeService, maxInService, inServiceCount)
									if canTakeService then
										local playerPed = GetPlayerPed(-1)
										local coords    = Config.Zones.VehicleSpawnPoint.Pos
										ESX.Game.SpawnVehicle(data.current.value, coords, 90.0, function(vehicle)
											TaskWarpPedIntoVehicle(playerPed,  vehicle, -1)
										end)
									else
										ESX.ShowNotification('Service complet : ' .. inServiceCount .. '/' .. maxInService)
									end
								end, 'mecano')
								break
							end
						end						
						menu.close()
					end,
					function(data, menu)
						menu.close()
						OpenMecanoActionsMenu()
					end
				)
			end

			if data.current.value == 'cloakroom' then
				menu.close()
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)

    				if skin.sex == 0 then
        				TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
    				else
        				TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
    				end
    
				end)
			end

			if data.current.value == 'cloakroom2' then
				menu.close()
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)

    				TriggerEvent('skinchanger:loadSkin', skin)
    
				end)
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
							TriggerServerEvent('esx_society:withdrawMoney', 'mecano', amount)
						end
					end,
					function(data, menu)
						menu.close()
					end
				)
			end

			if data.current.value == 'deposit_money' then
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
							TriggerServerEvent('esx_society:depositMoney', 'mecano', amount)
						end
					end,
					function(data, menu)
						menu.close()
					end
				)
			end

			if data.current.value == 'wash_money' then
				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'wash_money_amount',
					{
						title = 'Montant à blanchir'
					},
					function(data, menu)
						local amount = tonumber(data.value)
						if amount == nil then
							ESX.ShowNotification('Montant invalide')
						else
							menu.close()
							TriggerServerEvent('esx_society:washMoney', 'mecano', amount)
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
			CurrentAction     = 'mecano_actions_menu'
			CurrentActionMsg  = 'Appuyez sur ~INPUT_CONTEXT~ pour accéder au menu.'
			CurrentActionData = {}
		end
	)
end

function OpenMecanoHarvestMenu()

	if Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.grade_name ~= 'recrue' then
		local elements = {
			{label = 'Bouteille de gaz', value = 'gaz_bottle'},
			{label = 'Outils réparation', value = 'fix_tool'},
			{label = 'Outils Carosserie', value = 'caro_tool'}
		}

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'mecano_harvest',
			{
				title    = 'Récolte',
				elements = elements
			},
			function(data, menu)
				if data.current.value == 'gaz_bottle' then
					menu.close()
					TriggerServerEvent('esx_mecanojob:startHarvest')
				end

				if data.current.value == 'fix_tool' then
					menu.close()
					TriggerServerEvent('esx_mecanojob:startHarvest2')
				end

				if data.current.value == 'caro_tool' then
					menu.close()
					TriggerServerEvent('esx_mecanojob:startHarvest3')
				end

			end,
			function(data, menu)
				menu.close()
				CurrentAction     = 'mecano_harvest_menu'
				CurrentActionMsg  = 'Appuyez sur ~INPUT_CONTEXT~ pour accéder au menu de récolte.'
				CurrentActionData = {}
			end
		)
	else
		ESX.ShowNotification("Vous n'êtes ~r~pas assez expérimenté~s~ pour effectuer cette action.")
	end
end

function OpenMecanoCraftMenu()
	if Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.grade_name ~= 'recrue' then

		local elements = {
			{label = 'Chalumeaux', value = 'blow_pipe'},
			{label = 'Kit réparation', value = 'fix_kit'},
			{label = 'Outils Carosserie', value = 'caro_kit'}
		}

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'mecano_craft',
			{
				title    = 'Etabli',
				elements = elements
			},
			function(data, menu)
				if data.current.value == 'blow_pipe' then
					menu.close()
					TriggerServerEvent('esx_mecanojob:startCraft')
				end

				if data.current.value == 'fix_kit' then
					menu.close()
					TriggerServerEvent('esx_mecanojob:startCraft2')
				end

				if data.current.value == 'caro_kit' then
					menu.close()
					TriggerServerEvent('esx_mecanojob:startCraft3')
				end

			end,
			function(data, menu)
				menu.close()
				CurrentAction     = 'mecano_craft_menu'
				CurrentActionMsg  = 'Appuyez sur ~INPUT_CONTEXT~ pour accéder au menu établi.'
				CurrentActionData = {}
			end
		)
	else
		ESX.ShowNotification("Vous n'êtes ~r~pas assez expérimenté~s~ pour effectuer cette action.")
	end
end

function OpenMobileMecanoActionsMenu()

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'mobile_mecano_actions',
		{
			title    = 'Mécano',
			elements = {
				{label = 'Facuration', value = 'billing'},
				{label = 'Crocheter', value = 'hijack_vehicle'},
				{label = 'Réparer', value = 'fix_vehicle'},
				{label = 'Netoyer', value = 'clean_vehicle'},
				{label = 'Fourrière', value = 'del_vehicle'},
				{label = 'Plateau', value = 'dep_vehicle'},
				{label = 'Placer objets', value = 'object_spawner'}
			}
		},
		function(data, menu)
			if data.current.value == 'billing' then
				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'billing',
					{
						title = 'Montant de la facture'
					},
					function(data, menu)
						local amount = tonumber(data.value)
						if amount == nil then
							ESX.ShowNotification('Montant invalide')
						else							
							menu.close()							
							local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
							if closestPlayer == -1 or closestDistance > 3.0 then
								ESX.ShowNotification('Aucun joueur à proximité')
							else
								TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_mecano', 'Mecano', amount)
							end
						end
					end,
				function(data, menu)
					menu.close()
				end
				)
			end

			if data.current.value == 'hijack_vehicle' then

				local playerPed = GetPlayerPed(-1)
				local coords    = GetEntityCoords(playerPed)

				if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then

					local vehicle = nil

					if IsPedInAnyVehicle(playerPed, false) then
						vehicle = GetVehiclePedIsIn(playerPed, false)
					else
						vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
					end

					if DoesEntityExist(vehicle) then
						TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", 0, true)
						Citizen.CreateThread(function()
							Citizen.Wait(10000)
							SetVehicleDoorsLocked(vehicle, 1)
							SetVehicleDoorsLockedForAllPlayers(vehicle, false)
							ClearPedTasksImmediately(playerPed)
							TriggerEvent('esx:showNotification', 'Véhicule ~g~déverouillé')
						end)
					end

				end

			end

			if data.current.value == 'fix_vehicle' then
			
				local playerPed = GetPlayerPed(-1)
				local coords    = GetEntityCoords(playerPed)
				
				if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
					
					local vehicle = nil

					if IsPedInAnyVehicle(playerPed, false) then
						vehicle = GetVehiclePedIsIn(playerPed, false)
					else
						vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
					end
					
					if DoesEntityExist(vehicle) then
						TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
						Citizen.CreateThread(function()
							Citizen.Wait(20000)
							SetVehicleFixed(vehicle)
							SetVehicleDeformationFixed(vehicle)
							SetVehicleUndriveable(vehicle, false)
							ClearPedTasksImmediately(playerPed)
							TriggerEvent('esx:showNotification', 'Véhicule ~g~réparé')
						end)
					end
				end
			end

			if data.current.value == 'clean_vehicle' then
			
				local playerPed = GetPlayerPed(-1)
				local coords    = GetEntityCoords(playerPed)
				
				if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
					
					local vehicle = nil

					if IsPedInAnyVehicle(playerPed, false) then
						vehicle = GetVehiclePedIsIn(playerPed, false)
					else
						vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
					end
					
					if DoesEntityExist(vehicle) then
						TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_MAID_CLEAN", 0, true)
						Citizen.CreateThread(function()
							Citizen.Wait(10000)
							SetVehicleDirtLevel(vehicle, 0)
							ClearPedTasksImmediately(playerPed)
							TriggerEvent('esx:showNotification', 'Véhicule ~g~néttoyé')
						end)
					end
				end
			end
			
			if data.current.value == 'del_vehicle' then
			
				local ped = GetPlayerPed( -1 )

				if ( DoesEntityExist( ped ) and not IsEntityDead( ped ) ) then 
					local pos = GetEntityCoords( ped )

					if ( IsPedSittingInAnyVehicle( ped ) ) then 
						local vehicle = GetVehiclePedIsIn( ped, false )

						if ( GetPedInVehicleSeat( vehicle, -1 ) == ped ) then 
							TriggerEvent('esx:showNotification', 'Vehicule ~r~mis en fourrière')
							SetEntityAsMissionEntity( vehicle, true, true )
							deleteCar( vehicle )
						else 
							TriggerEvent('esx:showNotification', 'Vous devez être assis du ~r~côté conducteur!')
						end 
					else
						local playerPos = GetEntityCoords( ped, 1 )
						local inFrontOfPlayer = GetOffsetFromEntityInWorldCoords( ped, 0.0, distanceToCheck, 0.0 )
						local vehicle = GetVehicleInDirection( playerPos, inFrontOfPlayer )

						if ( DoesEntityExist( vehicle ) ) then
							TriggerEvent('esx:showNotification', 'Vehicule ~r~mis en fourrière')
							SetEntityAsMissionEntity( vehicle, true, true )
							deleteCar( vehicle )
						else 
							TriggerEvent('esx:showNotification', 'Vous devez être ~r~près d\'un véhicule~s~ pour le mettre en fourrière')
						end 
					end 
				end
			end
			
			if data.current.value == 'dep_vehicle' then
			
				local playerped = GetPlayerPed(-1)
				local vehicle = GetVehiclePedIsIn(playerped, true)
	
				local towmodel = GetHashKey('flatbed')
				local isVehicleTow = IsVehicleModel(vehicle, towmodel)

				if isVehicleTow then

					local coordA = GetEntityCoords(playerped, 1)
					local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 5.0, 0.0)
					local targetVehicle = getVehicleInDirection(coordA, coordB)
		
					if currentlyTowedVehicle == nil then
						if targetVehicle ~= 0 then
							if not IsPedInAnyVehicle(playerped, true) then
								if vehicle ~= targetVehicle then
									AttachEntityToEntity(targetVehicle, vehicle, 20, -0.5, -5.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
									currentlyTowedVehicle = targetVehicle
									TriggerEvent('esx:showNotification', 'Vehicule ~b~attaché~s~ avec succès!')
								else
									TriggerEvent('esx:showNotification', '~r~Impossible~s~ d\'attacher votre propre dépanneuse')
								end
							end
						else
							TriggerEvent('esx:showNotification', 'Il n\'y a ~r~pas de véhicule~s~ à attacher')
						end
					else
						AttachEntityToEntity(currentlyTowedVehicle, vehicle, 20, -0.5, -12.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
						DetachEntity(currentlyTowedVehicle, true, true)
						currentlyTowedVehicle = nil
						TriggerEvent('esx:showNotification', 'Vehicule ~b~détattaché~s~ avec succès!')
					end
				else
					TriggerEvent('esx:showNotification', '~r~Impossible! ~s~Vous devez avoir un ~b~Flatbed ~s~pour ça')
				end
			end

			if data.current.value == 'object_spawner' then

				ESX.UI.Menu.Open(
					'default', GetCurrentResourceName(), 'mobile_mecano_actions_spawn',
					{
						title    = 'Objets',
						align    = 'top-left',
						elements = {
					    {label = 'Plot',     value = 'prop_roadcone02a'},
					    {label = 'Boîte à outils', value = 'prop_toolchest_01'},
						},
					},
					function(data2, menu2)


						local model     = data2.current.value
						local playerPed = GetPlayerPed(-1)
						local coords    = GetEntityCoords(playerPed)
						local forward   = GetEntityForwardVector(playerPed)
						local x, y, z   = table.unpack(coords + forward * 1.0)

						if model == 'prop_roadcone02a' then
							z = z - 2.0
						elseif model == 'prop_toolchest_01' then
							z = z - 3.0
						end

						ESX.Game.SpawnObject(model, {
							x = x,
							y = y,
							z = z
						}, 3.0, function(obj)
							SetEntityHeading(obj, GetEntityHeading(playerPed))
							PlaceObjectOnGroundProperly(obj)
						end)

					end,
					function(data2, menu2)
						menu2.close()
					end
				)

			end

		end,
	function(data, menu)
		menu.close()
	end
	)
end

RegisterNetEvent('esx_mecanojob:onHijack')
AddEventHandler('esx_mecanojob:onHijack', function()
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed)

	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then

		local vehicle = nil

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
		end

		local crochete = math.random(100)
		local alarm    = math.random(100)

		if DoesEntityExist(vehicle) then
			if alarm <= 33 then
				SetVehicleAlarm(vehicle, true)
				StartVehicleAlarm(vehicle)
			end
			TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", 0, true)
			Citizen.CreateThread(function()
				Citizen.Wait(10000)
				if crochete <= 66 then
					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					ClearPedTasksImmediately(playerPed)
					TriggerEvent('esx:showNotification', '~g~Véhicule déverouillé')
				else
					TriggerEvent('esx:showNotification', '~r~Crochetage raté')
					ClearPedTasksImmediately(playerPed)
				end
			end)
		end

	end
end)

RegisterNetEvent('esx_mecanojob:onCarokit')
AddEventHandler('esx_mecanojob:onCarokit', function()
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed)
				
	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
					
		local vehicle = nil

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
		end
					
		if DoesEntityExist(vehicle) then
			TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_HAMMERING", 0, true)
			Citizen.CreateThread(function()
				Citizen.Wait(10000)
				SetVehicleFixed(vehicle)
				SetVehicleDeformationFixed(vehicle)
				ClearPedTasksImmediately(playerPed)
				TriggerEvent('esx:showNotification', '~g~Carosserie réparée')
			end)
		end
	end
end)

RegisterNetEvent('esx_mecanojob:onFixkit')
AddEventHandler('esx_mecanojob:onFixkit', function()
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed)
				
	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
					
		local vehicle = nil

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
		end
					
		if DoesEntityExist(vehicle) then
			TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
			Citizen.CreateThread(function()
				Citizen.Wait(20000)
				SetVehicleFixed(vehicle)
				SetVehicleDeformationFixed(vehicle)
				SetVehicleUndriveable(vehicle, false)
				ClearPedTasksImmediately(playerPed)
				TriggerEvent('esx:showNotification', '~g~Véhicule réparé')
			end)
		end
	end
end)

function setEntityHeadingFromEntity ( vehicle, playerPed )
    local heading = GetEntityHeading(vehicle)
    SetEntityHeading( playerPed, heading )
end

function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed(-1), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

function deleteCar( entity )
    Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( entity ) )
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

AddEventHandler('esx_mecanojob:hasEnteredMarker', function(zone)
	if zone == 'MecanoActions' then
		CurrentAction     = 'mecano_actions_menu'
		CurrentActionMsg  = 'Appuyez sur ~INPUT_CONTEXT~ pour accéder au menu.'
		CurrentActionData = {}
	end
	if zone == 'Garage' then
		CurrentAction     = 'mecano_harvest_menu'
		CurrentActionMsg  = 'Appuyez sur ~INPUT_CONTEXT~ pour accéder au menu de récolte.'
		CurrentActionData = {}
	end
	if zone == 'Craft' then
		CurrentAction     = 'mecano_craft_menu'
		CurrentActionMsg  = 'Appuyez sur ~INPUT_CONTEXT~ pour accéder au menu établi.'
		CurrentActionData = {}
	end
	if zone == 'VehicleDeleter' then
		local playerPed = GetPlayerPed(-1)
		if IsPedInAnyVehicle(playerPed,  false) then
			CurrentAction     = 'delete_vehicle'
			CurrentActionMsg  = 'Appuyez sur ~INPUT_CONTEXT~ pour ranger le véhicule.'
			CurrentActionData = {}
		end
	end
end)

AddEventHandler('esx_mecanojob:hasExitedMarker', function(zone)

	if zone == 'Craft' then
		TriggerServerEvent('esx_mecanojob:stopCraft')
		TriggerServerEvent('esx_mecanojob:stopCraft2')
		TriggerServerEvent('esx_mecanojob:stopCraft3')
	end

	if zone == 'Garage' then
		TriggerServerEvent('esx_mecanojob:stopHarvest')
		TriggerServerEvent('esx_mecanojob:stopHarvest2')
		TriggerServerEvent('esx_mecanojob:stopHarvest3')
	end

	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

AddEventHandler('esx_mecanojob:hasEnteredEntityZone', function(entity)

	local playerPed = GetPlayerPed(-1)

	if PlayerData.job ~= nil and PlayerData.job.name == 'mecano' and not IsPedInAnyVehicle(playerPed, false) then
		CurrentAction     = 'remove_entity'
		CurrentActionMsg  = 'Appuyez sur ~INPUT_CONTEXT~ pour enlever l\'objet'
		CurrentActionData = {entity = entity}
	end

end)

AddEventHandler('esx_mecanojob:hasExitedEntityZone', function(entity)

	if CurrentAction == 'remove_entity' then
		CurrentAction = nil
	end

end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
	local specialContact = {
		name       = 'Mecano',
		number     = 'mecano',
		base64Icon = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEwAACxMBAJqcGAAAA4BJREFUWIXtll9oU3cUx7/nJA02aSSlFouWMnXVB0ejU3wcRteHjv1puoc9rA978cUi2IqgRYWIZkMwrahUGfgkFMEZUdg6C+u21z1o3fbgqigVi7NzUtNcmsac40Npltz7S3rvUHzxQODec87vfD+/e0/O/QFv7Q0beV3QeXqmgV74/7H7fZJvuLwv8q/Xeux1gUrNBpN/nmtavdaqDqBK8VT2RDyV2VHmF1lvLERSBtCVynzYmcp+A9WqT9kcVKX4gHUehF0CEVY+1jYTTIwvt7YSIQnCTvsSUYz6gX5uDt7MP7KOKuQAgxmqQ+neUA+I1B1AiXi5X6ZAvKrabirmVYFwAMRT2RMg7F9SyKspvk73hfrtbkMPyIhA5FVqi0iBiEZMMQdAui/8E4GPv0oAJkpc6Q3+6goAAGpWBxNQmTLFmgL3jSJNgQdGv4pMts2EKm7ICJB/aG0xNdz74VEk13UYCx1/twPR8JjDT8wttyLZtkoAxSb8ZDCz0gdfKxWkFURf2v9qTYH7SK7rQIDn0P3nA0ehixvfwZwE0X9vBE/mW8piohhl1WH18UQBhYnre8N/L8b8xQvlx4ACbB4NnzaeRYDnKm0EALCMLXy84hwuTCXL/ExoB1E7qcK/8NCLIq5HcTT0i6u8TYbXUM1cAyyveVq8Xls7XhYrvY/4n3gC8C+dsmAzL1YUiyfWxvHzsy/w/dNd+KjhW2yvv/RfXr7x9QDcmo1he2RBiCCI1Q8jVj9szPNixVfgz+UiIGyDSrcoRu2J16d3I6e1VYvNSQjXpnucAcEPUOkGYZs/l4uUhowt/3kqu1UIv9n90fAY9jT3YBlbRvFTD4fw++wHjhiTRL/bG75t0jI2ITcHb5om4Xgmhv57xpGOg3d/NIqryOR7z+r+MC6qBJB/ZB2t9Om1D5lFm843G/3E3HI7Yh1xDRAfzLQr5EClBf/HBHK462TG2J0OABXeyWDPZ8VqxmBWYscpyghwtTd4EKpDTjCZdCNmzFM9k+4LHXIFACJN94Z6FiFEpKDQw9HndWsEuhnADVMhAUaYJBp9XrcGQKJ4qFE9k+6r2+MG3k5N8VQ22TVglbX2ZwOzX2VvNKr91zmY6S7N6zqZicVT2WNLyVSehESaBhxnOALfMeYX+K/S2yv7wmMAlvwyuR7FxQUyf0fgc/jztfkJr7XeGgC8BJJgWNV8ImT+AAAAAElFTkSuQmCC'
	}
	TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
end)

-- Create Blips
Citizen.CreateThread(function()		
	local blip = AddBlipForCoord(Config.Zones.MecanoActions.Pos.x, Config.Zones.MecanoActions.Pos.y, Config.Zones.MecanoActions.Pos.z)
	SetBlipSprite (blip, 446)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 1.0)
	SetBlipColour (blip, 5)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Mecano")
	EndTextCommandSetBlipName(blip)
end)

-- Display markers
Citizen.CreateThread(function()
	while true do		
		Wait(0)		
		if PlayerData.job ~= nil and PlayerData.job.name == 'mecano' then

			local coords = GetEntityCoords(GetPlayerPed(-1))
			
			for k,v in pairs(Config.Zones) do
				if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
				end
			end
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Wait(0)
		if PlayerData.job ~= nil and PlayerData.job.name == 'mecano' then
			local coords      = GetEntityCoords(GetPlayerPed(-1))
			local isInMarker  = false
			local currentZone = nil
			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
				end
			end
			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone                = currentZone
				TriggerEvent('esx_mecanojob:hasEnteredMarker', currentZone)
			end
			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_mecanojob:hasExitedMarker', LastZone)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		local playerPed = GetPlayerPed(-1)
		local coords    = GetEntityCoords(playerPed)

		local entity, distance = ESX.Game.GetClosestObject({
			'prop_roadcone02a',
			'prop_toolchest_01'
		})

		if distance ~= -1 and distance <= 3.0 then

 			if LastEntity ~= entity then
				TriggerEvent('esx_mecanojob:hasEnteredEntityZone', entity)
				LastEntity = entity
			end

		else

			if LastEntity ~= nil then
				TriggerEvent('esx_mecanojob:hasExitedEntityZone', LastEntity)
				LastEntity = nil
			end

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
            if IsControlJustReleased(0, 38) and PlayerData.job ~= nil and PlayerData.job.name == 'mecano' then                
                if CurrentAction == 'mecano_actions_menu' then
                    OpenMecanoActionsMenu()
                end
                if CurrentAction == 'mecano_harvest_menu' then
                    OpenMecanoHarvestMenu()
                end
                if CurrentAction == 'mecano_craft_menu' then
                    OpenMecanoCraftMenu()
                end
                if CurrentAction == 'delete_vehicle' then
                    local playerPed = GetPlayerPed(-1)
                    local vehicle   = GetVehiclePedIsIn(playerPed,  false)
                    local hash      = GetEntityModel(vehicle)
                    if hash == GetHashKey('flatbed') or hash == GetHashKey('towtruck2') or hash == GetHashKey('slamvan3') then
                        if Config.MaxInService ~= -1 then
                            TriggerServerEvent('esx_service:disableService', 'mecano')
                        end                        
                        DeleteVehicle(vehicle)
                    else
                        ESX.ShowNotification('Vous ne pouvez ranger que des ~b~véhicules de Mécano~s~.')
                    end
                end
                if CurrentAction == 'remove_entity' then
					DeleteEntity(CurrentActionData.entity)
				end
                CurrentAction = nil               
            end
        end

        if IsControlJustReleased(0, 167) and PlayerData.job ~= nil and PlayerData.job.name == 'mecano' then
            OpenMobileMecanoActionsMenu()
        end
    end
end)