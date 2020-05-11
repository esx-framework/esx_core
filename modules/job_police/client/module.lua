ESX.Modules['job_police'] = {}
local self = ESX.Modules['job_police']

-- Properties
self.Config = ESX.EvalFile(GetCurrentResourceName(), 'modules/job_police/data/config.lua', {
  vector3 = vector3
})['Config']

self.CurrentActionData       = {}
self.HandcuffTimer           = {}
self.DragStatus              = {isDragged = false}
self.BlipsCops               = {}
self.CurrentTask             = {}
self.HasAlreadyEnteredMarker = false
self.IsDead                  = false
self.IsHandcuffed            = false
self.HasAlreadyJoined        = false
self.PlayerInService         = false
self.LastStation             = nil
self.LastPart                = nil
self.LastPartNum             = nil
self.LastEntity              = nil
self.CurrentAction           = nil
self.CurrentActionMsg        = nil
self.IsInShopMenu            = false
self.SpawnedVehicles         = {}

-- Locals
local Interact = ESX.Modules['interact']
local Input    = ESX.Modules['input']

-- Methods
self.Init = function()

  self.RegisterControls()

  local translations = ESX.EvalFile(GetCurrentResourceName(), 'modules/job_police/data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('job_police', Config.Locale, translations)

  for stationName, station in pairs(self.Config.PoliceStations) do

    -- Blip
    local blip = AddBlipForCoord(station.Blip.Coords)

    SetBlipSprite (blip, station.Blip.Sprite)
    SetBlipDisplay(blip, station.Blip.Display)
    SetBlipScale  (blip, station.Blip.Scale)
    SetBlipColour (blip, station.Blip.Colour)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(_U('job_police:map_blip'))
    EndTextCommandSetBlipName(blip)

    -- Cloakrooms
    for i=1, #station.Cloakrooms, 1 do

      local cloakroom = station.Cloakrooms[i]
      local key       = 'job_police:' .. stationName .. 'cloakroom:' .. tostring(i)

      Interact.Register({
        name     = key,
        type     = 'marker',
        distance = self.Config.DrawDistance,
        radius   = 2.0,
        pos      = cloakroom,
        size     = 1.0,
        mtype    = 20,
        color    = self.Config.MarkerColor,
        rotate   = true,
        check    = self.IsPolice,
      })

      AddEventHandler('esx:interact:enter:' .. key, function(data)

        ESX.ShowHelpNotification(_U('job_police:open_cloackroom'))

        self.CurrentAction = function()
          self.OpenCloakroomMenu(station)
        end

      end)

      AddEventHandler('esx:interact:exit:' .. key, function(data)
        self.CurrentAction = nil
      end)

    end

    -- Armories
    for i=1, #station.Armories, 1 do

      local armory = station.Armories[i]
      local key    = 'job_police:' .. stationName .. ':armory:' .. tostring(i)

      Interact.Register({
        name     = key,
        type     = 'marker',
        distance = self.Config.DrawDistance,
        radius   = 1.0,
        pos      = armory,
        size     = 0.5,
        mtype    = 21,
        color    = self.Config.MarkerColor,
        rotate   = true,
        check    = self.IsPolice,
      })

      AddEventHandler('esx:interact:enter:' .. key, function(data)

        ESX.ShowHelpNotification(_U('job_police:open_armory'))

        self.CurrentAction = function()
          self.OpenArmoryMenu(station)
        end

      end)

      AddEventHandler('esx:interact:exit:' .. key, function(data)
        self.CurrentAction = nil
      end)

    end

    -- Vehicles
    for i=1, #station.Vehicles, 1 do

      local vehicle = station.Vehicles[i]
      local key     = 'job_police:' .. stationName .. ':garage:' .. tostring(i)

      Interact.Register({
        name     = key,
        type     = 'marker',
        distance = self.Config.DrawDistance,
        radius   = 2.0,
        pos      = vehicle.Spawner,
        size     = 1.0,
        mtype    = 36,
        color    = self.Config.MarkerColor,
        rotate   = true,
        check    = self.IsPolice,
        config   = vehicle
      })

      AddEventHandler('esx:interact:enter:' .. key, function(data)

        ESX.ShowHelpNotification(_U('job_police:garage_prompt'))

        self.CurrentAction = function()
          self.OpenVehicleSpawnerMenu('car', data.config)
        end

      end)

      AddEventHandler('esx:interact:exit:' .. key, function(data)
        self.CurrentAction = nil
      end)

    end

      -- Helicopters
    for i=1, #station.Helicopters, 1 do

      local heli = station.Helicopters[i]
      local key  = 'job_police:' .. stationName .. ':garage_heli:' .. tostring(i)

      Interact.Register({
        name     = key,
        type     = 'marker',
        distance = self.Config.DrawDistance,
        radius   = 2.0,
        pos      = heli.Spawner,
        size     = 1.0,
        mtype    = 36,
        color    = self.Config.MarkerColor,
        rotate   = true,
        check    = self.IsPolice,
        config   = heli
      })

      AddEventHandler('esx:interact:enter:' .. key, function(data)

        ESX.ShowHelpNotification(_U('job_police:helicopter_prompt'))

        self.CurrentAction = function()
          self.OpenVehicleSpawnerMenu('helicopter', data.config)
        end

      end)

      AddEventHandler('esx:interact:exit:' .. key, function(data)
        self.CurrentAction = nil
      end)

    end

    -- Boss actions
    for i=1, #station.BossActions, 1 do

      local actions = station.BossActions[i]
      local key     = 'job_police:' .. stationName .. ':bossactions:' .. tostring(i)

      Interact.Register({
        name     = key,
        type     = 'marker',
        distance = self.Config.DrawDistance,
        radius   = 2.0,
        pos      = actions,
        size     = 1.0,
        mtype    = 22,
        color    = self.Config.MarkerColor,
        rotate   = true,
        check    = self.IsPoliceBoss,
      })

      AddEventHandler('esx:interact:enter:' .. key, function(data)

        ESX.ShowHelpNotification(_U('job_police:open_bossmenu'))

        local bossAction

        bossAction = function()

          TriggerEvent('esx_society:openBossMenu', 'police', function(data, menu)
            menu.close()
            self.CurrentAction = bossAction
          end, {
            wash = false
          })

        end

        self.CurrentAction = bossAction

      end)

      AddEventHandler('esx:interact:exit:' .. key, function(data)
        self.CurrentAction = nil
      end)

    end

  end

end

self.RegisterControls = function()

  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.PICKUP)
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.SELECT_CHARACTER_FRANKLIN)
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.PICKUP)

end

self.IsPolice = function(playerPed, coords)
  return ESX.PlayerData.job and (ESX.PlayerData.job.name == 'police')
end

self.IsPoliceBoss = function(playerPed, coords)
  return self.IsPolice() and (ESX.PlayerData.job.grade_name == 'boss')
end

self.CleanPlayer = function(playerPed)
	SetPedArmour(playerPed, 0)
	ClearPedBloodDamage(playerPed)
	ResetPedVisibleDamage(playerPed)
	ClearPedLastWeaponDamage(playerPed)
	ResetPedMovementClipset(playerPed, 0)
end

self.SetUniform = function(uniform, playerPed)

  TriggerEvent('skinchanger:getSkin', function(skin)

		local uniformObject

		if skin.sex == 0 then
			uniformObject = self.Config.Uniforms[uniform].male
		else
			uniformObject = self.Config.Uniforms[uniform].female
		end

		if uniformObject then
			TriggerEvent('skinchanger:loadClothes', skin, uniformObject)

			if uniform == 'bullet_wear' then
				SetPedArmour(playerPed, 100)
			end
		else
			ESX.ShowNotification(_U('job_police:no_outfit'))
    end
  end)

end

self.OpenCloakroomMenu = function()

  local playerPed = PlayerPedId()
	local grade = ESX.PlayerData.job.grade_name

	local elements = {
		{label = _U('job_police:citizen_wear'), value = 'citizen_wear'},
		{label = _U('job_police:bullet_wear'), uniform = 'bullet_wear'},
		{label = _U('job_police:gilet_wear'), uniform = 'gilet_wear'},
		{label = _U('job_police:police_wear'), uniform = grade}
	}

	if self.Config.EnableCustomPeds then
		for k,v in ipairs(Config.CustomPeds.shared) do
			table.insert(elements, {label = v.label, value = 'freemode_ped', maleModel = v.maleModel, femaleModel = v.femaleModel})
		end

		for k,v in ipairs(Config.CustomPeds[grade]) do
			table.insert(elements, {label = v.label, value = 'freemode_ped', maleModel = v.maleModel, femaleModel = v.femaleModel})
		end
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom', {
		title    = _U('job_police:cloakroom'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)

    menu.close()

    self.CleanPlayer(playerPed)

		if data.current.value == 'citizen_wear' then
			if self.Config.EnableNonFreemodePeds then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					local isMale = skin.sex == 0

					TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
						ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
							TriggerEvent('skinchanger:loadSkin', skin)
							TriggerEvent('esx:restoreLoadout')
						end)
					end)

				end)
			else
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					TriggerEvent('skinchanger:loadSkin', skin)
				end)
			end

			if self.Config.EnableESXService then
				ESX.TriggerServerCallback('esx_service:isInService', function(isInService)
					if isInService then
						PlayerInService = false

						local notification = {
							title    = _U('job_police:service_anonunce'),
							subject  = '',
							msg      = _U('job_police:service_out_announce', GetPlayerName(PlayerId())),
							iconType = 1
						}

						TriggerServerEvent('esx_service:notifyAllInService', notification, 'police')

						TriggerServerEvent('esx_service:disableService', 'police')
						TriggerEvent('esx_policejob:updateBlip')
						ESX.ShowNotification(_U('job_police:service_out'))
					end
				end, 'police')
			end
		end

		if self.Config.EnableESXService and data.current.value ~= 'citizen_wear' then
			local awaitService

			ESX.TriggerServerCallback('esx_service:isInService', function(isInService)
				if not isInService then

					ESX.TriggerServerCallback('esx_service:enableService', function(canTakeService, maxInService, inServiceCount)
						if not canTakeService then
							ESX.ShowNotification(_U('job_police:service_max', inServiceCount, maxInService))
						else
							awaitService = true
							PlayerInService = true

							local notification = {
								title    = _U('job_police:service_anonunce'),
								subject  = '',
								msg      = _U('job_police:service_in_announce', GetPlayerName(PlayerId())),
								iconType = 1
							}

							TriggerServerEvent('esx_service:notifyAllInService', notification, 'police')
							TriggerEvent('esx_policejob:updateBlip')
							ESX.ShowNotification(_U('job_police:service_in'))
						end
					end, 'police')

				else
					awaitService = true
				end
			end, 'police')

			while awaitService == nil do
				Citizen.Wait(5)
			end

			-- if we couldn't enter service don't let the player get changed
			if not awaitService then
				return
			end
		end

		if data.current.uniform then
			self.SetUniform(data.current.uniform, playerPed)
		elseif data.current.value == 'freemode_ped' then
			local modelHash

			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				if skin.sex == 0 then
					modelHash = GetHashKey(data.current.maleModel)
				else
					modelHash = GetHashKey(data.current.femaleModel)
				end

				ESX.Streaming.RequestModel(modelHash, function()
					SetPlayerModel(PlayerId(), modelHash)
					SetModelAsNoLongerNeeded(modelHash)
					SetPedDefaultComponentVariation(PlayerPedId())

					TriggerEvent('esx:restoreLoadout')
				end)
			end)
		end
  end, function(data, menu)

    menu.close()

  end, nil, function()

    ESX.ShowHelpNotification(_U('job_police:open_cloackroom'))

    self.CurrentAction = function()
      self.OpenCloakroomMenu(station)
    end

  end)

end

self.OpenArmoryMenu = function(station)
	local elements = {
		{label = _U('job_police:buy_weapons'), value = 'buy_weapons'}
	}

	if self.Config.EnableArmoryManagement then
		table.insert(elements, {label = _U('job_police:get_weapon'),     value = 'get_weapon'})
		table.insert(elements, {label = _U('job_police:put_weapon'),     value = 'put_weapon'})
		table.insert(elements, {label = _U('job_police:remove_object'),  value = 'get_stock'})
		table.insert(elements, {label = _U('job_police:deposit_object'), value = 'put_stock'})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory', {
		title    = _U('job_police:armory'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)

		if data.current.value == 'get_weapon' then
			self.OpenGetWeaponMenu()
		elseif data.current.value == 'put_weapon' then
			self.OpenPutWeaponMenu()
		elseif data.current.value == 'buy_weapons' then
			self.OpenBuyWeaponsMenu()
		elseif data.current.value == 'put_stock' then
			self.OpenPutStocksMenu()
		elseif data.current.value == 'get_stock' then
			self.OpenGetStocksMenu()
		end

  end, function(data, menu)
    menu.close()
  end, nil, function()


    ESX.ShowHelpNotification(_U('job_police:open_armory'))

    self.CurrentAction = function()
      self.OpenArmoryMenu(station)
    end

    return true

  end)

end

self.OpenPoliceActionsMenu = function()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'police_actions', {
		title    = 'Police',
		align    = 'top-left',
		elements = {
			{label = _U('job_police:citizen_interaction'), value = 'citizen_interaction'},
			{label = _U('job_police:vehicle_interaction'), value = 'vehicle_interaction'},
			{label = _U('job_police:object_spawner'), value = 'object_spawner'}
	}}, function(data, menu)
		if data.current.value == 'citizen_interaction' then
			local elements = {
				{label = _U('job_police:id_card'), value = 'identity_card'},
				{label = _U('job_police:search'), value = 'search'},
				{label = _U('job_police:handcuff'), value = 'handcuff'},
				{label = _U('job_police:drag'), value = 'drag'},
				{label = _U('job_police:put_in_vehicle'), value = 'put_in_vehicle'},
				{label = _U('job_police:out_the_vehicle'), value = 'out_the_vehicle'},
				{label = _U('job_police:fine'), value = 'fine'},
				{label = _U('job_police:unpaid_bills'), value = 'unpaid_bills'}
			}

			if self.Config.EnableLicenses then
				table.insert(elements, {label = _U('job_police:license_check'), value = 'license'})
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
				title    = _U('job_police:citizen_interaction'),
				align    = 'top-left',
				elements = elements
			}, function(data2, menu2)
				local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
				if closestPlayer ~= -1 and closestDistance <= 3.0 then
					local action = data2.current.value

					if action == 'identity_card' then
						OpenIdentityCardMenu(closestPlayer)
					elseif action == 'search' then
						OpenBodySearchMenu(closestPlayer)
					elseif action == 'handcuff' then
						TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(closestPlayer))
					elseif action == 'drag' then
						TriggerServerEvent('esx_policejob:drag', GetPlayerServerId(closestPlayer))
					elseif action == 'put_in_vehicle' then
						TriggerServerEvent('esx_policejob:putInVehicle', GetPlayerServerId(closestPlayer))
					elseif action == 'out_the_vehicle' then
						TriggerServerEvent('esx_policejob:OutVehicle', GetPlayerServerId(closestPlayer))
					elseif action == 'fine' then
						OpenFineMenu(closestPlayer)
					elseif action == 'license' then
						ShowPlayerLicense(closestPlayer)
					elseif action == 'unpaid_bills' then
						OpenUnpaidBillsMenu(closestPlayer)
					end
				else
					ESX.ShowNotification(_U('job_police:no_players_nearby'))
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'vehicle_interaction' then
			local elements  = {}
			local playerPed = PlayerPedId()
			local vehicle = ESX.Game.GetVehicleInDirection()

			if DoesEntityExist(vehicle) then
				table.insert(elements, {label = _U('job_police:vehicle_info'), value = 'vehicle_infos'})
				table.insert(elements, {label = _U('job_police:pick_lock'), value = 'hijack_vehicle'})
				table.insert(elements, {label = _U('job_police:impound'), value = 'impound'})
			end

			table.insert(elements, {label = _U('job_police:search_database'), value = 'search_database'})

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_interaction', {
				title    = _U('job_police:vehicle_interaction'),
				align    = 'top-left',
				elements = elements
			}, function(data2, menu2)
				local coords  = GetEntityCoords(playerPed)
				vehicle = ESX.Game.GetVehicleInDirection()
				action  = data2.current.value

				if action == 'search_database' then
					LookupVehicle()
				elseif DoesEntityExist(vehicle) then
					if action == 'vehicle_infos' then
						local vehicleData = ESX.Game.GetVehicleProperties(vehicle)
						OpenVehicleInfosMenu(vehicleData)
					elseif action == 'hijack_vehicle' then
						if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
							TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
							Citizen.Wait(20000)
							ClearPedTasksImmediately(playerPed)

							SetVehicleDoorsLocked(vehicle, 1)
							SetVehicleDoorsLockedForAllPlayers(vehicle, false)
							ESX.ShowNotification(_U('job_police:vehicle_unlocked'))
						end
					elseif action == 'impound' then
						-- is the script busy?
						if CurrentTask.busy then
							return
						end

						ESX.ShowHelpNotification(_U('job_police:impound_prompt'))
						TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)

						CurrentTask.busy = true
						CurrentTask.task = ESX.SetTimeout(10000, function()
							ClearPedTasks(playerPed)
							ImpoundVehicle(vehicle)
							Citizen.Wait(100) -- sleep the entire script to let stuff sink back to reality
						end)

						-- keep track of that vehicle!
						Citizen.CreateThread(function()
							while CurrentTask.busy do
								Citizen.Wait(1000)

								vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71)
								if not DoesEntityExist(vehicle) and CurrentTask.busy then
									ESX.ShowNotification(_U('job_police:impound_canceled_moved'))
									ESX.ClearTimeout(CurrentTask.task)
									ClearPedTasks(playerPed)
									CurrentTask.busy = false
									break
								end
							end
						end)
					end
				else
					ESX.ShowNotification(_U('job_police:no_vehicles_nearby'))
				end

      end)

		elseif data.current.value == 'object_spawner' then
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
				title    = _U('job_police:traffic_interaction'),
				align    = 'top-left',
				elements = {
					{label = _U('job_police:cone'), model = 'prop_roadcone02a'},
					{label = _U('job_police:barrier'), model = 'prop_barrier_work05'},
					{label = _U('job_police:spikestrips'), model = 'p_ld_stinger_s'},
					{label = _U('job_police:box'), model = 'prop_boxpile_07d'},
					{label = _U('job_police:cash'), model = 'hei_prop_cash_crate_half_full'}
			}}, function(data2, menu2)
				local playerPed = PlayerPedId()
				local coords, forward = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
				local objectCoords = (coords + forward * 1.0)

				ESX.Game.SpawnObject(data2.current.model, objectCoords, function(obj)
					SetEntityHeading(obj, GetEntityHeading(playerPed))
					PlaceObjectOnGroundProperly(obj)
				end)
			end, function(data2, menu2)
				menu2.close()
			end)
		end
  end)

end

self.OpenIdentityCardMenu = function(player)
	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)
		local elements = {
			{label = _U('job_police:name', data.name)},
			{label = _U('job_police:job', ('%s - %s'):format(data.job, data.grade))}
		}

		if self.Config.EnableESXIdentity then
			table.insert(elements, {label = _U('job_police:sex', _U(data.sex))})
			table.insert(elements, {label = _U('job_police:dob', data.dob)})
			table.insert(elements, {label = _U('job_police:height', data.height)})
		end

		if data.drunk then
			table.insert(elements, {label = _U('job_police:bac', data.drunk)})
		end

		if data.licenses then
			table.insert(elements, {label = _U('job_police:license_label')})

			for i=1, #data.licenses, 1 do
				table.insert(elements, {label = data.licenses[i].label})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
			title    = _U('job_police:citizen_interaction'),
			align    = 'top-left',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

self.OpenBodySearchMenu = function(player)
	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)
		local elements = {}

		for i=1, #data.accounts, 1 do
			if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
				table.insert(elements, {
					label    = _U('job_police:confiscate_dirty', ESX.Math.Round(data.accounts[i].money)),
					value    = 'black_money',
					itemType = 'item_account',
					amount   = data.accounts[i].money
				})

				break
			end
		end

		table.insert(elements, {label = _U('job_police:guns_label')})

		for i=1, #data.weapons, 1 do
			table.insert(elements, {
				label    = _U('job_police:confiscate_weapon', ESX.GetWeaponLabel(data.weapons[i].name), data.weapons[i].ammo),
				value    = data.weapons[i].name,
				itemType = 'item_weapon',
				amount   = data.weapons[i].ammo
			})
		end

		table.insert(elements, {label = _U('job_police:inventory_label')})

		for i=1, #data.inventory, 1 do
			if data.inventory[i].count > 0 then
				table.insert(elements, {
					label    = _U('job_police:confiscate_inv', data.inventory[i].count, data.inventory[i].label),
					value    = data.inventory[i].name,
					itemType = 'item_standard',
					amount   = data.inventory[i].count
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'body_search', {
			title    = _U('job_police:search'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			if data.current.value then
				TriggerServerEvent('esx_policejob:confiscatePlayerItem', GetPlayerServerId(player), data.current.itemType, data.current.value, data.current.amount)
				OpenBodySearchMenu(player)
			end
		end, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

self.OpenFineMenu = function(player)
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine', {
		title    = _U('job_police:fine'),
		align    = 'top-left',
		elements = {
			{label = _U('job_police:traffic_offense'), value = 0},
			{label = _U('job_police:minor_offense'),   value = 1},
			{label = _U('job_police:average_offense'), value = 2},
			{label = _U('job_police:major_offense'),   value = 3}
	}}, function(data, menu)
		OpenFineCategoryMenu(player, data.current.value)
	end, function(data, menu)
		menu.close()
	end)
end

self.OpenFineCategoryMenu = function(player, category)
	ESX.TriggerServerCallback('esx_policejob:getFineList', function(fines)
		local elements = {}

		for k,fine in ipairs(fines) do
			table.insert(elements, {
				label     = ('%s <span style="color:green;">%s</span>'):format(fine.label, _U('job_police:armory_item', ESX.Math.GroupDigits(fine.amount))),
				value     = fine.id,
				amount    = fine.amount,
				fineLabel = fine.label
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine_category', {
			title    = _U('job_police:fine'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			menu.close()

			if self.Config.EnablePlayerManagement then
				TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_police', _U('job_police:fine_total', data.current.fineLabel), data.current.amount)
			else
				TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), '', _U('job_police:fine_total', data.current.fineLabel), data.current.amount)
			end

			ESX.SetTimeout(300, function()
				OpenFineCategoryMenu(player, category)
			end)
		end, function(data, menu)
			menu.close()
		end)
	end, category)
end

self.LookupVehicle = function()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'lookup_vehicle', {
		title = _U('job_police:search_database_title'),
	}, function(data, menu)
		local length = string.len(data.value)
		if not data.value or length < 2 or length > 8 then
			ESX.ShowNotification(_U('job_police:search_database_error_invalid'))
		else
			ESX.TriggerServerCallback('esx_policejob:getVehicleInfos', function(retrivedInfo)
				local elements = {{label = _U('job_police:plate', retrivedInfo.plate)}}
				menu.close()

				if not retrivedInfo.owner then
					table.insert(elements, {label = _U('job_police:owner_unknown')})
				else
					table.insert(elements, {label = _U('job_police:owner', retrivedInfo.owner)})
				end

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_infos', {
					title    = _U('job_police:vehicle_info'),
					align    = 'top-left',
					elements = elements
				}, nil, function(data2, menu2)
					menu2.close()
				end)
			end, data.value)

		end
	end, function(data, menu)
		menu.close()
	end)
end

self.ShowPlayerLicense = function(player)
	local elements = {}

	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(playerData)
		if playerData.licenses then
			for i=1, #playerData.licenses, 1 do
				if playerData.licenses[i].label and playerData.licenses[i].type then
					table.insert(elements, {
						label = playerData.licenses[i].label,
						type = playerData.licenses[i].type
					})
				end
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_license', {
			title    = _U('job_police:license_revoke'),
			align    = 'top-left',
			elements = elements,
		}, function(data, menu)
			ESX.ShowNotification(_U('job_police:licence_you_revoked', data.current.label, playerData.name))
			TriggerServerEvent('esx_policejob:message', GetPlayerServerId(player), _U('job_police:license_revoked', data.current.label))

			TriggerServerEvent('esx_license:removeLicense', GetPlayerServerId(player), data.current.type)

			ESX.SetTimeout(300, function()
				ShowPlayerLicense(player)
			end)
		end, function(data, menu)
			menu.close()
		end)

	end, GetPlayerServerId(player))
end

self.OpenUnpaidBillsMenu = function(player)
	local elements = {}

	ESX.TriggerServerCallback('esx_billing:getTargetBills', function(bills)
		for k,bill in ipairs(bills) do
			table.insert(elements, {
				label = ('%s - <span style="color:red;">%s</span>'):format(bill.label, _U('job_police:armory_item', ESX.Math.GroupDigits(bill.amount))),
				billId = bill.id
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'billing', {
			title    = _U('job_police:unpaid_bills'),
			align    = 'top-left',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

self.OpenVehicleInfosMenu = function(vehicleData)
	ESX.TriggerServerCallback('esx_policejob:getVehicleInfos', function(retrivedInfo)
		local elements = {{label = _U('job_police:plate', retrivedInfo.plate)}}

		if not retrivedInfo.owner then
			table.insert(elements, {label = _U('job_police:owner_unknown')})
		else
			table.insert(elements, {label = _U('job_police:owner', retrivedInfo.owner)})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_infos', {
			title    = _U('job_police:vehicle_info'),
			align    = 'top-left',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)
	end, vehicleData.plate)
end

self.OpenGetWeaponMenu = function()
	ESX.TriggerServerCallback('esx_policejob:getArmoryWeapons', function(weapons)
		local elements = {}

		for i=1, #weapons, 1 do
			if weapons[i].count > 0 then
				table.insert(elements, {
					label = 'x' .. weapons[i].count .. ' ' .. ESX.GetWeaponLabel(weapons[i].name),
					value = weapons[i].name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_get_weapon', {
			title    = _U('job_police:get_weapon_menu'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			menu.close()

			ESX.TriggerServerCallback('esx_policejob:removeArmoryWeapon', function()
				OpenGetWeaponMenu()
			end, data.current.value)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

self.OpenPutWeaponMenu = function()
	local elements   = {}
	local playerPed  = PlayerPedId()
	local weaponList = ESX.GetWeaponList()

	for i=1, #weaponList, 1 do
		local weaponHash = GetHashKey(weaponList[i].name)

		if HasPedGotWeapon(playerPed, weaponHash, false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
			table.insert(elements, {
				label = weaponList[i].label,
				value = weaponList[i].name
			})
		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_put_weapon', {
		title    = _U('job_police:put_weapon_menu'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		menu.close()

		ESX.TriggerServerCallback('esx_policejob:addArmoryWeapon', function()
			OpenPutWeaponMenu()
		end, data.current.value, true)
	end, function(data, menu)
		menu.close()
	end)
end

self.OpenBuyWeaponsMenu = function()
	local elements = {}
	local playerPed = PlayerPedId()

  local authorizedWeapons = {}

  for i=1, ESX.PlayerData.job.grade, 1 do

    local weapons = self.Config.AuthorizedWeapons[i]

    for j=1, #weapons, 1 do
      authorizedWeapons[#authorizedWeapons + 1] = weapons[j]
    end

  end

	for k,v in ipairs(authorizedWeapons) do
		local weaponNum, weapon = ESX.GetWeapon(v.weapon)
		local components, label = {}
		local hasWeapon = HasPedGotWeapon(playerPed, GetHashKey(v.weapon), false)

		if v.components then
			for i=1, #v.components do
				if v.components[i] then
					local component = weapon.components[i]
					local hasComponent = HasPedGotWeaponComponent(playerPed, GetHashKey(v.weapon), component.hash)

					if hasComponent then
						label = ('%s: <span style="color:green;">%s</span>'):format(component.label, _U('job_police:armory_owned'))
					else
						if v.components[i] > 0 then
							label = ('%s: <span style="color:green;">%s</span>'):format(component.label, _U('job_police:armory_item', ESX.Math.GroupDigits(v.components[i])))
						else
							label = ('%s: <span style="color:green;">%s</span>'):format(component.label, _U('job_police:armory_free'))
						end
					end

					table.insert(components, {
						label = label,
						componentLabel = component.label,
						hash = component.hash,
						name = component.name,
						price = v.components[i],
						hasComponent = hasComponent,
						componentNum = i
					})
				end
			end
		end

		if hasWeapon and v.components then
			label = ('%s: <span style="color:green;">></span>'):format(weapon.label)
		elseif hasWeapon and not v.components then
			label = ('%s: <span style="color:green;">%s</span>'):format(weapon.label, _U('job_police:armory_owned'))
		else
			if v.price > 0 then
				label = ('%s: <span style="color:green;">%s</span>'):format(weapon.label, _U('job_police:armory_item', ESX.Math.GroupDigits(v.price)))
			else
				label = ('%s: <span style="color:green;">%s</span>'):format(weapon.label, _U('job_police:armory_free'))
			end
		end

		table.insert(elements, {
			label = label,
			weaponLabel = weapon.label,
			name = weapon.name,
			components = components,
			price = v.price,
			hasWeapon = hasWeapon
		})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_buy_weapons', {
		title    = _U('job_police:armory_weapontitle'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		if data.current.hasWeapon then
			if #data.current.components > 0 then
				OpenWeaponComponentShop(data.current.components, data.current.name, menu)
			end
		else
			ESX.TriggerServerCallback('esx_policejob:buyWeapon', function(bought)
				if bought then
					if data.current.price > 0 then
						ESX.ShowNotification(_U('job_police:armory_bought', data.current.weaponLabel, ESX.Math.GroupDigits(data.current.price)))
					end

					menu.close()
					OpenBuyWeaponsMenu()
				else
					ESX.ShowNotification(_U('job_police:armory_money'))
				end
			end, data.current.name, 1)
		end
	end, function(data, menu)
		menu.close()
	end)
end

self.OpenWeaponComponentShop = function(components, weaponName, parentShop)
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_buy_weapons_components', {
		title    = _U('job_police:armory_componenttitle'),
		align    = 'top-left',
		elements = components
	}, function(data, menu)
		if data.current.hasComponent then
			ESX.ShowNotification(_U('job_police:armory_hascomponent'))
		else
			ESX.TriggerServerCallback('esx_policejob:buyWeapon', function(bought)
				if bought then
					if data.current.price > 0 then
						ESX.ShowNotification(_U('job_police:armory_bought', data.current.componentLabel, ESX.Math.GroupDigits(data.current.price)))
					end

					menu.close()
					parentShop.close()
					OpenBuyWeaponsMenu()
				else
					ESX.ShowNotification(_U('job_police:armory_money'))
				end
			end, weaponName, 2, data.current.componentNum)
		end
	end, function(data, menu)
		menu.close()
	end)
end

self.OpenGetStocksMenu = function()
	ESX.TriggerServerCallback('esx_policejob:getStockItems', function(items)
		local elements = {}

		for i=1, #items, 1 do
			table.insert(elements, {
				label = 'x' .. items[i].count .. ' ' .. items[i].label,
				value = items[i].name
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = _U('job_police:police_stock'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = _U('job_police:quantity')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification(_U('job_police:quantity_invalid'))
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_policejob:getStockItem', itemName, count)

					Citizen.Wait(300)
					OpenGetStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

self.OpenPutStocksMenu = function()
	ESX.TriggerServerCallback('esx_policejob:getPlayerInventory', function(inventory)
		local elements = {}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = _U('job_police:inventory'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
				title = _U('job_police:quantity')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification(_U('job_police:quantity_invalid'))
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_policejob:putStockItems', itemName, count)

					Citizen.Wait(300)
					OpenPutStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

-- Create blip for colleagues
self.CreateBlip = function(id)
	local ped = GetPlayerPed(id)
	local blip = GetBlipFromEntity(ped)

	if not DoesBlipExist(blip) then -- Add blip and create head display on player
		blip = AddBlipForEntity(ped)
		SetBlipSprite(blip, 1)
		ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
		SetBlipRotation(blip, math.ceil(GetEntityHeading(ped))) -- update rotation
		SetBlipNameToPlayerName(blip, id) -- update blip name
		SetBlipScale(blip, 0.85) -- set scale
		SetBlipAsShortRange(blip, true)

		table.insert(blipsCops, blip) -- add blip to array so we can remove it later
	end
end

-- handcuff timer, unrestrain the player after an certain amount of time
self.StartHandcuffTimer = function()
	if self.Config.EnableHandcuffTimer and handcuffTimer.active then
		ESX.ClearTimeout(handcuffTimer.task)
	end

	handcuffTimer.active = true

	handcuffTimer.task = ESX.SetTimeout(Config.HandcuffTimer, function()
		ESX.ShowNotification(_U('job_police:unrestrained_timer'))
		TriggerEvent('esx_policejob:unrestrain')
		handcuffTimer.active = false
	end)

end

-- TODO
--   - return to garage if owned
--   - message owner that his vehicle has been impounded
self.ImpoundVehicle = function(vehicle)
	--local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
	ESX.Game.DeleteVehicle(vehicle)
	ESX.ShowNotification(_U('job_police:impound_successful'))
	currentTask.busy = false
end

self.OpenVehicleSpawnerMenu = function(type, config)

	local playerCoords = GetEntityCoords(PlayerPedId())

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle', {
		title    = _U('job_police:garage_title'),
		align    = 'top-left',
		elements = {
			{label = _U('job_police:garage_storeditem'), action = 'garage'},
			{label = _U('job_police:garage_storeitem'), action = 'store_garage'},
			{label = _U('job_police:garage_buyitem'), action = 'buy_vehicle'}
  }}, function(data, menu)

    if data.current.action == 'buy_vehicle' then

			local shopElements       = {}
      local authorizedVehicles = {}

      for i=1, ESX.PlayerData.job.grade, 1 do

        local vehicles = self.Config.AuthorizedVehicles[type][i]

        for j=1, #vehicles, 1 do
          authorizedVehicles[#authorizedVehicles + 1] = vehicles[j]
        end

      end

			if authorizedVehicles then
				if #authorizedVehicles > 0 then
					for k,vehicle in ipairs(authorizedVehicles) do
						if IsModelInCdimage(vehicle.model) then
							local vehicleLabel = GetLabelText(GetDisplayNameFromVehicleModel(vehicle.model))

							table.insert(shopElements, {
								label = ('%s - <span style="color:green;">%s</span>'):format(vehicleLabel, _U('job_police:shop_item', ESX.Math.GroupDigits(vehicle.price))),
								name  = vehicleLabel,
								model = vehicle.model,
								price = vehicle.price,
								props = vehicle.props,
								type  = type
							})
						end
					end

					if #shopElements > 0 then
						self.OpenShopMenu(shopElements, config)
					else
						ESX.ShowNotification(_U('job_police:garage_notauthorized'))
					end
				else
					ESX.ShowNotification(_U('job_police:garage_notauthorized'))
				end
			else
				ESX.ShowNotification(_U('job_police:garage_notauthorized'))
			end
		elseif data.current.action == 'garage' then
			local garage = {}

			ESX.TriggerServerCallback('esx_vehicleshop:retrieveJobVehicles', function(jobVehicles)
				if #jobVehicles > 0 then
					local allVehicleProps = {}

					for k,v in ipairs(jobVehicles) do
						local props = json.decode(v.vehicle)

						if IsModelInCdimage(props.model) then
							local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
							local label = ('%s - <span style="color:darkgoldenrod;">%s</span>: '):format(vehicleName, props.plate)

							if v.stored then
								label = label .. ('<span style="color:green;">%s</span>'):format(_U('job_police:garage_stored'))
							else
								label = label .. ('<span style="color:darkred;">%s</span>'):format(_U('job_police:garage_notstored'))
							end

							table.insert(garage, {
								label = label,
								stored = v.stored,
								model = props.model,
								plate = props.plate
							})

							allVehicleProps[props.plate] = props
						end
					end

					if #garage > 0 then
						ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_garage', {
							title    = _U('job_police:garage_title'),
							align    = 'top-left',
							elements = garage
						}, function(data2, menu2)
              if data2.current.stored then


                local foundSpawn, spawnPoint = self.GetAvailableVehicleSpawnPoint(config.SpawnPoints)

								if foundSpawn then
									menu2.close()

									ESX.Game.SpawnVehicle(data2.current.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
										local vehicleProps = allVehicleProps[data2.current.plate]
										ESX.Game.SetVehicleProperties(vehicle, vehicleProps)

										TriggerServerEvent('esx_vehicleshop:setJobVehicleState', data2.current.plate, false)
										ESX.ShowNotification(_U('job_police:garage_released'))
									end)
                end

							else
								ESX.ShowNotification(_U('job_police:garage_notavailable'))
							end
						end, function(data2, menu2)
							menu2.close()
						end)
					else
						ESX.ShowNotification(_U('job_police:garage_empty'))
					end
				else
					ESX.ShowNotification(_U('job_police:garage_empty'))
				end
      end, type)

		elseif data.current.action == 'store_garage' then
			StoreNearbyVehicle(playerCoords)
		end
	end, function(data, menu)
		menu.close()
  end, nil, function()

    if type == 'car' then

      ESX.ShowHelpNotification(_U('job_police:garage_prompt'))

      self.CurrentAction = function()
        self.OpenVehicleSpawnerMenu('car', data.config)
      end

    elseif type == 'helicopter' then

      ESX.ShowHelpNotification(_U('job_police:helicopter_prompt'))

      self.CurrentAction = function()
        self.OpenVehicleSpawnerMenu('helicopter', data.config)
      end

    end

  end)

end

self.StoreNearbyVehicle = function(playerCoords)
	local vehicles, vehiclePlates = ESX.Game.GetVehiclesInArea(playerCoords, 30.0), {}

	if #vehicles > 0 then
		for k,v in ipairs(vehicles) do

			-- Make sure the vehicle we're saving is empty, or else it wont be deleted
			if GetVehicleNumberOfPassengers(v) == 0 and IsVehicleSeatFree(v, -1) then
				table.insert(vehiclePlates, {
					vehicle = v,
					plate = ESX.Math.Trim(GetVehicleNumberPlateText(v))
				})
			end
		end
	else
		ESX.ShowNotification(_U('job_police:garage_store_nearby'))
		return
	end

	ESX.TriggerServerCallback('esx_policejob:storeNearbyVehicle', function(storeSuccess, foundNum)
		if storeSuccess then
			local vehicleId = vehiclePlates[foundNum]
			local attempts = 0
			ESX.Game.DeleteVehicle(vehicleId.vehicle)
			IsBusy = true

			Citizen.CreateThread(function()
				BeginTextCommandBusyspinnerOn('STRING')
				AddTextComponentSubstringPlayerName(_U('job_police:garage_storing'))
				EndTextCommandBusyspinnerOn(4)

				while IsBusy do
					Citizen.Wait(100)
				end

				BusyspinnerOff()
			end)

			-- Workaround for vehicle not deleting when other players are near it.
			while DoesEntityExist(vehicleId.vehicle) do
				Citizen.Wait(500)
				attempts = attempts + 1

				-- Give up
				if attempts > 30 then
					break
				end

				vehicles = ESX.Game.GetVehiclesInArea(playerCoords, 30.0)
				if #vehicles > 0 then
					for k,v in ipairs(vehicles) do
						if ESX.Math.Trim(GetVehicleNumberPlateText(v)) == vehicleId.plate then
							ESX.Game.DeleteVehicle(v)
							break
						end
					end
				end
			end

			IsBusy = false
			ESX.ShowNotification(_U('job_police:garage_has_stored'))
		else
			ESX.ShowNotification(_U('job_police:garage_has_notstored'))
		end
	end, vehiclePlates)
end

self.GetAvailableVehicleSpawnPoint = function(spawnPoints)

	local found, foundSpawnPoint = false, nil

	for i=1, #spawnPoints, 1 do
		if ESX.Game.IsSpawnPointClear(spawnPoints[i].coords, spawnPoints[i].radius) then
			found, foundSpawnPoint = true, spawnPoints[i]
			break
		end
	end

	if found then
		return true, foundSpawnPoint
	else
		ESX.ShowNotification(_U('job_police:vehicle_blocked'))
		return false
	end
end

self.OpenShopMenu = function(elements, config)

  local playerPed = PlayerPedId()
	isInShopMenu = true

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop', {
		title    = _U('job_police:vehicleshop_title'),
		align    = 'top-left',
		elements = elements
  }, function(data, menu)

    menu.close()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop_confirm', {
			title    = _U('job_police:vehicleshop_confirm', data.current.name, data.current.price),
			align    = 'top-left',
			elements = {
				{label = _U('job_police:confirm_no'), value = 'no'},
				{label = _U('job_police:confirm_yes'), value = 'yes'}
    }}, function(data2, menu2)

      menu2.close()

			if data2.current.value == 'yes' then

				ESX.TriggerServerCallback('esx_policejob:canBuyVehicle', function (success)

          if success then

            local foundSpawn, spawnPoint = self.GetAvailableVehicleSpawnPoint(config.SpawnPoints)

            if foundSpawn then

              ESX.Game.SpawnVehicle(data.current.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)

                local props = ESX.Game.GetVehicleProperties(vehicle)
                props.plate = exports['esx_vehicleshop']:GeneratePlate() -- TODO Should be in core

                SetVehicleNumberPlateText(vehicle, props.plate)
                TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

                TriggerServerEvent('esx_policejob:buyJobVehicle', props, data.current.type)

                ESX.ShowNotification(_U('job_police:vehicleshop_bought', data.current.name, ESX.Math.GroupDigits(data.current.price)))

              end)

            end

					else
						ESX.ShowNotification(_U('job_police:vehicleshop_money'))
						menu2.close()
          end

        end, data.current.model, data.current.type)

      end

		end, function(data2, menu2)
			menu2.close()
    end)

	end)

end

self.DeleteSpawnedVehicles = function()

  for i=1, #self.SpawnedVehicles, 1 do
    ESX.Game.DeleteVehicle(self.SpawnedVehicles[i])
  end

  self.SpawnedVehicles = {}

end

self.WaitForVehicleToLoad = function(modelHash)

	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		BeginTextCommandBusyspinnerOn('STRING')
		AddTextComponentSubstringPlayerName(_U('vehicleshop_awaiting_model'))
		EndTextCommandBusyspinnerOn(4)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(0)
			DisableAllControlActions(0)
		end

		BusyspinnerOff()
	end
end
