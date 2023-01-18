local CurrentActionData, handcuffTimer, dragStatus, blipsCops, currentTask = {}, {}, {}, {}, {}
local HasAlreadyEnteredMarker, isDead, isHandcuffed, hasAlreadyJoined, playerInService = false, false, false, false, false
local LastStation, LastPart, LastPartNum, LastEntity, CurrentAction, CurrentActionMsg
dragStatus.isDragged, isInShopMenu = false, false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

function cleanPlayer(playerPed)
	SetPedArmour(playerPed, 0)
	ClearPedBloodDamage(playerPed)
	ResetPedVisibleDamage(playerPed)
	ClearPedLastWeaponDamage(playerPed)
	ResetPedMovementClipset(playerPed, 0)
end

function setUniform(uniform, playerPed)
	TriggerEvent('skinchanger:getSkin', function(skin)
		local uniformObject

		if skin.sex == 0 then
			uniformObject = Config.Uniforms[uniform].male
		else
			uniformObject = Config.Uniforms[uniform].female
		end

		if uniformObject then
			TriggerEvent('skinchanger:loadClothes', skin, uniformObject)

			if uniform == 'bullet_wear' then
				SetPedArmour(playerPed, 100)
			end
		else
			ESX.ShowNotification(TranslateCap('no_outfit'))
		end
	end)
end

function OpenCloakroomMenu()
	local playerPed = PlayerPedId()
	local grade = ESX.PlayerData.job.grade_name

	local elements = {
		{unselectable = true, icon = "fas fa-shirt", title = TranslateCap("cloakroom")},
		{icon = "fas fa-shirt", title = TranslateCap('citizen_wear'), value = 'citizen_wear'},
		{icon = "fas fa-shirt", title = TranslateCap('bullet_wear'), uniform = 'bullet_wear'},
		{icon = "fas fa-shirt", title = TranslateCap('gilet_wear'), uniform = 'gilet_wear'},
		{icon = "fas fa-shirt", title = TranslateCap('police_wear'), uniform = grade}
	}

	if Config.EnableCustomPeds then
		for k,v in ipairs(Config.CustomPeds.shared) do
			elements[#elements+1] = {
				icon = "fas fa-shirt",
				title = v.label, 
				value = 'freemode_ped', 
				maleModel = v.maleModel, 
				femaleModel = v.femaleModel
			}
		end

		for k,v in ipairs(Config.CustomPeds[grade]) do
			elements[#elements+1] = {
				icon = "fas fa-shirt",
				title = v.label, 
				value = 'freemode_ped', 
				maleModel = v.maleModel, 
				femaleModel = v.femaleModel
			}
		end
	end

	ESX.OpenContext("right", elements, function(menu,element)
		cleanPlayer(playerPed)
		local data = {current = element}

		if data.current.value == 'citizen_wear' then
			if Config.EnableCustomPeds then
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

			if Config.EnableESXService then
				ESX.TriggerServerCallback('esx_service:isInService', function(isInService)
					if isInService then
						playerInService = false

						local notification = {
							title    = TranslateCap('service_anonunce'),
							subject  = '',
							msg      = TranslateCap('service_out_announce', GetPlayerName(PlayerId())),
							iconType = 1
						}

						TriggerServerEvent('esx_service:notifyAllInService', notification, 'police')

						TriggerServerEvent('esx_service:disableService', 'police')
						TriggerEvent('esx_policejob:updateBlip')
						ESX.ShowNotification(TranslateCap('service_out'))
					end
				end, 'police')
			end
		end

		if Config.EnableESXService and data.current.value ~= 'citizen_wear' then
			local awaitService

			ESX.TriggerServerCallback('esx_service:isInService', function(isInService)
				if not isInService then

					if Config.MaxInService ~= -1 then
						ESX.TriggerServerCallback('esx_service:enableService', function(canTakeService, maxInService, inServiceCount)
							if not canTakeService then
								ESX.ShowNotification(TranslateCap('service_max', inServiceCount, maxInService))
							else
								awaitService = true
								playerInService = true

								local notification = {
									title    = TranslateCap('service_anonunce'),
									subject  = '',
									msg      = TranslateCap('service_in_announce', GetPlayerName(PlayerId())),
									iconType = 1
								}

								TriggerServerEvent('esx_service:notifyAllInService', notification, 'police')
								TriggerEvent('esx_policejob:updateBlip')
								ESX.ShowNotification(TranslateCap('service_in'))
							end
						end, 'police')
					else
						awaitService = true
						playerInService = true

						local notification = {
							title    = TranslateCap('service_anonunce'),
							subject  = '',
							msg      = TranslateCap('service_in_announce', GetPlayerName(PlayerId())),
							iconType = 1
						}

						TriggerServerEvent('esx_service:notifyAllInService', notification, 'police')
						TriggerEvent('esx_policejob:updateBlip')
						ESX.ShowNotification(TranslateCap('service_in'))
					end

				else
					awaitService = true
				end
			end, 'police')

			while awaitService == nil do
				Wait(0)
			end

			-- if we couldn't enter service don't let the player get changed
			if not awaitService then
				return
			end
		end

		if data.current.uniform then
			setUniform(data.current.uniform, playerPed)
		elseif data.current.value == 'freemode_ped' then
			local modelHash

			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				if skin.sex == 0 then
					modelHash = joaat(data.current.maleModel)
				else
					modelHash = joaat(data.current.femaleModel)
				end

				ESX.Streaming.RequestModel(modelHash, function()
					SetPlayerModel(PlayerId(), modelHash)
					SetModelAsNoLongerNeeded(modelHash)
					SetPedDefaultComponentVariation(PlayerPedId())

					TriggerEvent('esx:restoreLoadout')
				end)
			end)
		end
	end, function(menu)
		CurrentAction     = 'menu_cloakroom'
		CurrentActionMsg  = TranslateCap('open_cloackroom')
		CurrentActionData = {}
	end)
end

function OpenArmoryMenu(station)
	local elements
	if Config.OxInventory then
		exports.ox_inventory:openInventory('stash', {id = 'society_police', owner = station})
		return ESX.CloseContext()
	else
		elements = {
			{unselectable = true, icon = "fas fa-gun", title = TranslateCap('armory')},
			{icon = "fas fa-gun", title = TranslateCap('buy_weapons'), value = 'buy_weapons'}
			
		}

		if Config.EnableArmoryManagement then
			table.insert(elements, {icon = "fas fa-gun", title = TranslateCap('get_weapon'),     value = 'get_weapon'})
			table.insert(elements, {icon = "fas fa-gun", title = TranslateCap('put_weapon'),     value = 'put_weapon'})
			table.insert(elements, {icon = "fas fa-box", title = TranslateCap('remove_object'),  value = 'get_stock'})
			table.insert(elements, {icon = "fas fa-box", title = TranslateCap('deposit_object'), value = 'put_stock'})
		end
	end

	ESX.OpenContext("right", elements, function(menu,element)
		local data = {current = element}
		if data.current.value == 'get_weapon' then
			OpenGetWeaponMenu()
		elseif data.current.value == 'put_weapon' then
			OpenPutWeaponMenu()
		elseif data.current.value == 'buy_weapons' then
			OpenBuyWeaponsMenu()
		elseif data.current.value == 'put_stock' then
			OpenPutStocksMenu()
		elseif data.current.value == 'get_stock' then
			OpenGetStocksMenu()
		end
	end, function(menu)
		CurrentAction     = 'menu_armory'
		CurrentActionMsg  = TranslateCap('open_armory')
		CurrentActionData = {station = station}
	end)
end

function OpenPoliceActionsMenu()
	local elements = {
		{unselectable = true, icon = "fas fa-police", title = "Police"},
		{icon = "fas fa-user", title = TranslateCap('citizen_interaction'), value = 'citizen_interaction'},
		{icon = "fas fa-car", title = TranslateCap('vehicle_interaction'), value = 'vehicle_interaction'},
		{icon = "fas fa-object", title = TranslateCap('object_spawner'), value = 'object_spawner'}
	}

	ESX.OpenContext("right", elements, function(menu,element)
		local data = {current = element}

		if data.current.value == 'citizen_interaction' then
			local elements2 = {
				{unselectable = true, icon = "fas fa-user", title = element.title},
				{icon = "fas fa-idkyet", title = TranslateCap('id_card'), value = 'identity_card'},
				{icon = "fas fa-idkyet", title = TranslateCap('search'), value = 'search'},
				{icon = "fas fa-idkyet", title = TranslateCap('handcuff'), value = 'handcuff'},
				{icon = "fas fa-idkyet", title = TranslateCap('drag'), value = 'drag'},
				{icon = "fas fa-idkyet", title = TranslateCap('put_in_vehicle'), value = 'put_in_vehicle'},
				{icon = "fas fa-idkyet", title = TranslateCap('out_the_vehicle'), value = 'out_the_vehicle'},
				{icon = "fas fa-idkyet", title = TranslateCap('fine'), value = 'fine'},
				{icon = "fas fa-idkyet", title = TranslateCap('unpaid_bills'), value = 'unpaid_bills'}
			}

			if Config.EnableLicenses then
				elements2[#elements2+1] = {
					icon = "fas fa-scroll",
					title = TranslateCap('license_check'),
					value = 'license'
				}
			end

			ESX.OpenContext("right", elements2, function(menu2,element2)
				local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
				if closestPlayer ~= -1 and closestDistance <= 3.0 then
					local data2 = {current = element2}
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
					ESX.ShowNotification(TranslateCap('no_players_nearby'))
				end
			end, function(menu)
				OpenPoliceActionsMenu()
			end)
		elseif data.current.value == 'vehicle_interaction' then
			local elements3  = {
				{unselectable = true, icon = "fas fa-car", title = element.title}
			}
			local playerPed = PlayerPedId()
			local vehicle = ESX.Game.GetVehicleInDirection()

			if DoesEntityExist(vehicle) then
				elements3[#elements3+1] = {icon = "fas fa-car", title = TranslateCap('vehicle_info'), value = 'vehicle_infos'}
				elements3[#elements3+1] = {icon = "fas fa-car", title = TranslateCap('pick_lock'), value = 'hijack_vehicle'}
				elements3[#elements3+1] = {icon = "fas fa-car", title = TranslateCap('impound'), value = 'impound'}
			end

			elements3[#elements3+1] = {
				icon = "fas fa-scroll",
				title = TranslateCap('search_database'), 
				value = 'search_database'
			}
			
			ESX.OpenContext("right", elements3, function(menu3,element3)
				local data2 = {current = element3}
				local coords  = GetEntityCoords(playerPed)
				vehicle = ESX.Game.GetVehicleInDirection()
				action  = data2.current.value

				if action == 'search_database' then
					LookupVehicle(element3)
				elseif DoesEntityExist(vehicle) then
					if action == 'vehicle_infos' then
						local vehicleData = ESX.Game.GetVehicleProperties(vehicle)
						OpenVehicleInfosMenu(vehicleData)
					elseif action == 'hijack_vehicle' then
						if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
							TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
							Wait(20000)
							ClearPedTasksImmediately(playerPed)

							SetVehicleDoorsLocked(vehicle, 1)
							SetVehicleDoorsLockedForAllPlayers(vehicle, false)
							ESX.ShowNotification(TranslateCap('vehicle_unlocked'))
						end
					elseif action == 'impound' then
						if currentTask.busy then
							return
						end

						ESX.ShowHelpNotification(TranslateCap('impound_prompt'))
						TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)

						currentTask.busy = true
						currentTask.task = ESX.SetTimeout(10000, function()
							ClearPedTasks(playerPed)
							ImpoundVehicle(vehicle)
							Wait(100)
						end)

						CreateThread(function()
							while currentTask.busy do
								Wait(1000)

								vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71)
								if not DoesEntityExist(vehicle) and currentTask.busy then
									ESX.ShowNotification(TranslateCap('impound_canceled_moved'))
									ESX.ClearTimeout(currentTask.task)
									ClearPedTasks(playerPed)
									currentTask.busy = false
									break
								end
							end
						end)
					end
				else
					ESX.ShowNotification(TranslateCap('no_vehicles_nearby'))
				end
			end, function(menu)
				OpenPoliceActionsMenu()
			end)
		elseif data.current.value == "object_spawner" then
			local elements4 = {
				{unselectable = true, icon = "fas fa-object", title = element.title},
				{icon = "fas fa-cone", title = TranslateCap('cone'), model = 'prop_roadcone02a'},
				{icon = "fas fa-cone", title = TranslateCap('barrier'), model = 'prop_barrier_work05'},
				{icon = "fas fa-cone", title = TranslateCap('spikestrips'), model = 'p_ld_stinger_s'},
				{icon = "fas fa-cone", title = TranslateCap('box'), model = 'prop_boxpile_07d'},
				{icon = "fas fa-cone", title = TranslateCap('cash'), model = 'hei_prop_cash_crate_half_full'}
			}

			ESX.OpenContext("right", elements4, function(menu4,element4)
				local data2 = {current = element4}
				local playerPed = PlayerPedId()
				local coords, forward = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
				local objectCoords = (coords + forward * 1.0)

				ESX.Game.SpawnObject(data2.current.model, objectCoords, function(obj)
					SetEntityHeading(obj, GetEntityHeading(playerPed))
					PlaceObjectOnGroundProperly(obj)
				end)
			end, function(menu)
				OpenPoliceActionsMenu()
			end)
		end
	end)
end

function OpenIdentityCardMenu(player)
	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)
		local elements = {
			{icon = "fas fa-user", title = TranslateCap('name', data.name)},
			{icon = "fas fa-user", title = TranslateCap('job', ('%s - %s'):format(data.job, data.grade))}
		}

		if Config.EnableESXIdentity then
			elements[#elements+1] = {icon = "fas fa-user", title = TranslateCap('sex', TranslateCap(data.sex))}
			elements[#elements+1] = {icon = "fas fa-user", title = TranslateCap('sex', TranslateCap(data.sex))}
			elements[#elements+1] = {icon = "fas fa-user", title = TranslateCap('height', data.height)}
		end

		if Config.EnableESXOptionalneeds and data.drunk then
			elements[#elements+1] = {title = TranslateCap('bac', data.drunk)}
		end

		if data.licenses then
			elements[#elements+1] = {title = TranslateCap('license_label')}

			for i=1, #data.licenses, 1 do
				elements[#elements+1] = {title = data.licenses[i].label}
			end
		end

		ESX.OpenContext("right", elements, nil, function(menu)
			OpenPoliceActionsMenu()	
		end)
	end, GetPlayerServerId(player))
end

function OpenBodySearchMenu(player)
	if Config.OxInventory then
		exports.ox_inventory:openInventory('player', GetPlayerServerId(player))
		return ESX.CloseContext()
	end

	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)
		local elements = {
			{unselectable = true, icon = "fas fa-user", title = TranslateCap('search')}
		}

		for i=1, #data.accounts, 1 do
			if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
				elements[#elements+1] = {
					icon = "fas fa-money",
					title    = TranslateCap('confiscate_dirty', ESX.Math.Round(data.accounts[i].money)),
					value    = 'black_money',
					itemType = 'item_account',
					amount   = data.accounts[i].money
				}
				break
			end
		end

		table.insert(elements, {label = TranslateCap('guns_label')})

		for i=1, #data.weapons, 1 do
			elements[#elements+1] = {
				icon = "fas fa-gun",
				title    = TranslateCap('confiscate_weapon', ESX.GetWeaponLabel(data.weapons[i].name), data.weapons[i].ammo),
				value    = data.weapons[i].name,
				itemType = 'item_weapon',
				amount   = data.weapons[i].ammo
			}
		end

		elements[#elements+1] = {title = TranslateCap('inventory_label')}

		for i=1, #data.inventory, 1 do
			if data.inventory[i].count > 0 then
				elements[#elements+1] = {
					icon = "fas fa-box",
					title    = TranslateCap('confiscate_inv', data.inventory[i].count, data.inventory[i].label),
					value    = data.inventory[i].name,
					itemType = 'item_standard',
					amount   = data.inventory[i].count
				}
			end
		end

		ESX.OpenContext("right", elements, function(menu,element)
			local data = {current = element}
			if data.current.value then
				TriggerServerEvent('esx_policejob:confiscatePlayerItem', GetPlayerServerId(player), data.current.itemType, data.current.value, data.current.amount)
				OpenBodySearchMenu(player)
			end
		end)
	end, GetPlayerServerId(player))
end

function OpenFineMenu(player)
	local elements = {
		{unselectable = true, icon = "fas fa-scroll", title = TranslateCap('fine')},
		{icon = "fas fa-scroll", title = TranslateCap('traffic_offense'), value = 0},
		{icon = "fas fa-scroll", title = TranslateCap('minor_offense'),   value = 1},
		{icon = "fas fa-scroll", title = TranslateCap('average_offense'), value = 2},
		{icon = "fas fa-scroll", title = TranslateCap('major_offense'),   value = 3}
	}

	ESX.OpenContext("right", elements, function(menu,element)
		local data = {current = element}
		OpenFineCategoryMenu(player, data.current.value)
	end)
end

function OpenFineCategoryMenu(player, category)
	ESX.TriggerServerCallback('esx_policejob:getFineList', function(fines)
		local elements = {
			{unselectable = true, icon = "fas fa-scroll", title = TranslateCap('fine')}
		}

		for k,fine in ipairs(fines) do
			elements[#elements+1] = {
				icon = "fas fa-scroll",
				title     = ('%s <span style="color:green;">%s</span>'):format(fine.label, TranslateCap('armory_item', ESX.Math.GroupDigits(fine.amount))),
				value     = fine.id,
				amount    = fine.amount,
				fineLabel = fine.label
			}
		end

		ESX.OpenContext("right", elements, function(menu,element)
			local data = {current = element}
			if Config.EnablePlayerManagement then
				TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_police', TranslateCap('fine_total', data.current.fineLabel), data.current.amount)
			else
				TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), '', TranslateCap('fine_total', data.current.fineLabel), data.current.amount)
			end

			ESX.SetTimeout(300, function()
				OpenFineCategoryMenu(player, category)
			end)
		end)
	end, category)
end

function LookupVehicle(elementF)
	local elements = {
		{unselectable = true, icon = "fas fa-car", title = elementF.title},
		{title = "Enter Plate", input = true, inputType = "text", inputPlaceholder = "ABC 123"},
		{icon = "fas fa-check-double", title = "Lookup Plate", value = "lookup"}
	}

	ESX.OpenContext("right", elements, function(menu,element)
		local data = {value = menu.eles[2].inputValue}
		local length = string.len(data.value)
		if not data.value or length < 2 or length > 8 then
			ESX.ShowNotification(TranslateCap('search_database_error_invalid'))
		else
			ESX.TriggerServerCallback('esx_policejob:getVehicleInfos', function(retrivedInfo)
				local elements = {
					{unselectable = true, icon = "fas fa-car", title = element.title},
					{unselectable = true, icon = "fas fa-car", title = TranslateCap('plate', retrivedInfo.plate)}			
				}

				if not retrivedInfo.owner then
					elements[#elements+1] = {unselectable = true, icon = "fas fa-user", title = TranslateCap('owner_unknown')}
				else
					elements[#elements+1] = {unselectable = true, icon = "fas fa-user", title = TranslateCap('owner', retrivedInfo.owner)}
				end

				ESX.OpenContext("right", elements, nil, function(menu)
					OpenPoliceActionsMenu()
				end)
			end, data.value)
		end
	end)
end

function ShowPlayerLicense(player)
	local elements = {
		{unselectable = true, icon = "fas fa-scroll", title = TranslateCap('license_revoke')}
	}

	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(playerData)
		if playerData.licenses then
			for i=1, #playerData.licenses, 1 do
				if playerData.licenses[i].label and playerData.licenses[i].type then
					elements[#elements+1] = {
						icon = "fas fa-scroll",
						title = playerData.licenses[i].label,
						type = playerData.licenses[i].type
					}
				end
			end
		end

		ESX.OpenContext("right", elements, function(menu,element)
			local data = {current = element}
			ESX.ShowNotification(TranslateCap('licence_you_revoked', data.current.label, playerData.name))
			TriggerServerEvent('esx_policejob:message', GetPlayerServerId(player), TranslateCap('license_revoked', data.current.label))

			TriggerServerEvent('esx_license:removeLicense', GetPlayerServerId(player), data.current.type)

			ESX.SetTimeout(300, function()
				ShowPlayerLicense(player)
			end)
		end)
	end, GetPlayerServerId(player))
end

function OpenUnpaidBillsMenu(player)
	local elements = {
		{unselectable = true, icon = "fas fa-scroll", title = TranslateCap('unpaid_bills')}
	}

	ESX.TriggerServerCallback('esx_billing:getTargetBills', function(bills)
		for k,bill in ipairs(bills) do
			elements[#elements+1] = {
				unselectable = true,
				icon = "fas fa-scroll",
				title = ('%s - <span style="color:red;">%s</span>'):format(bill.label, TranslateCap('armory_item', ESX.Math.GroupDigits(bill.amount))),
				billId = bill.id
			}
		end

		ESX.OpenContext("right", elements, nil, nil)
	end, GetPlayerServerId(player))
end

function OpenVehicleInfosMenu(vehicleData)
	ESX.TriggerServerCallback('esx_policejob:getVehicleInfos', function(retrivedInfo)
		local elements = {
			{unselectable = true, icon = "fas fa-car", title = TranslateCap('vehicle_info')},
			{icon = "fas fa-car", title = TranslateCap('plate', retrivedInfo.plate)}
			
		}

		if not retrivedInfo.owner then
			elements[#elements+1] = {unselectable = true, icon = "fas fa-user", title = TranslateCap('owner_unknown')}
		else
			elements[#elements+1] = {unselectable = true, icon = "fas fa-user", title = TranslateCap('owner', retrivedInfo.owner)}
		end

		ESX.OpenContext("right", elements, nil, nil)
	end, vehicleData.plate)
end

function OpenGetWeaponMenu()
	ESX.TriggerServerCallback('esx_policejob:getArmoryWeapons', function(weapons)
		local elements = {
			{unselectable = true, icon = "fas fa-gun", title = TranslateCap('get_weapon_menu')}
		}

		for i=1, #weapons, 1 do
			if weapons[i].count > 0 then
				elements[#elements+1] = {
					icon = "fas fa-gun",
					title = 'x' .. weapons[i].count .. ' ' .. ESX.GetWeaponLabel(weapons[i].name),
					value = weapons[i].name
				}
			end
		end

		ESX.OpenContext("right", elements, function(menu,element)
			local data = {current = element}
			ESX.TriggerServerCallback('esx_policejob:removeArmoryWeapon', function()
				ESX.CloseContext()
				OpenGetWeaponMenu()
			end, data.current.value)
		end)
	end)
end

function OpenPutWeaponMenu()
	local elements   = {
		{unselectable = true, icon = "fas fa-gun", title = TranslateCap('put_weapon_menu')}
	}
	local playerPed  = PlayerPedId()
	local weaponList = ESX.GetWeaponList()

	for i=1, #weaponList, 1 do
		local weaponHash = joaat(weaponList[i].name)

		if HasPedGotWeapon(playerPed, weaponHash, false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
			elements[#elements+1] = {
				icon = "fas fa-gun",
				title = weaponList[i].label,
				value = weaponList[i].name
			}
		end
	end

	ESX.OpenContext("right", elements, function(menu,element)
		local data = {current = element}
		ESX.TriggerServerCallback('esx_policejob:addArmoryWeapon', function()
			ESX.CloseContext()
			OpenPutWeaponMenu()
		end, data.current.value, true)
	end)
end

function OpenBuyWeaponsMenu()
	local elements = {
		{unselectable = true, icon = "fas fa-gun", title = TranslateCap('armory_weapontitle')}
	}
	local playerPed = PlayerPedId()

	for k,v in ipairs(Config.AuthorizedWeapons[ESX.PlayerData.job.grade_name]) do
		local weaponNum, weapon = ESX.GetWeapon(v.weapon)
		local components, label = {}
		local hasWeapon = HasPedGotWeapon(playerPed, joaat(v.weapon), false)

		if v.components then
			for i=1, #v.components do
				if v.components[i] then
					local component = weapon.components[i]
					local hasComponent = HasPedGotWeaponComponent(playerPed, joaat(v.weapon), component.hash)

					if hasComponent then
						label = ('%s: <span style="color:green;">%s</span>'):format(component.label, TranslateCap('armory_owned'))
					else
						if v.components[i] > 0 then
							label = ('%s: <span style="color:green;">%s</span>'):format(component.label, TranslateCap('armory_item', ESX.Math.GroupDigits(v.components[i])))
						else
							label = ('%s: <span style="color:green;">%s</span>'):format(component.label, TranslateCap('armory_free'))
						end
					end

					components[#components+1] = {
						icon = "fas fa-gun",
						title = label,
						componentLabel = component.label,
						hash = component.hash,
						name = component.name,
						price = v.components[i],
						hasComponent = hasComponent,
						componentNum = i
					}
				end
			end
		end

		if hasWeapon and v.components then
			label = ('%s: <span style="color:green;">></span>'):format(weapon.label)
		elseif hasWeapon and not v.components then
			label = ('%s: <span style="color:green;">%s</span>'):format(weapon.label, TranslateCap('armory_owned'))
		else
			if v.price > 0 then
				label = ('%s: <span style="color:green;">%s</span>'):format(weapon.label, TranslateCap('armory_item', ESX.Math.GroupDigits(v.price)))
			else
				label = ('%s: <span style="color:green;">%s</span>'):format(weapon.label, TranslateCap('armory_free'))
			end
		end

		elements[#elements+1] = {
			icon = "fas fa-gun",
			title = label,
			weaponLabel = weapon.label,
			name = weapon.name,
			components = components,
			price = v.price,
			hasWeapon = hasWeapon
		}
	end

	ESX.OpenContext("right", elements, function(menu,element)
		local data = {current = element}
		if data.current.hasWeapon then
			if #data.current.components > 0 then
				OpenWeaponComponentShop(data.current.components, data.current.name, menu)
			end
		else
			ESX.TriggerServerCallback('esx_policejob:buyWeapon', function(bought)
				if bought then
					if data.current.price > 0 then
						ESX.ShowNotification(TranslateCap('armory_bought', data.current.weaponLabel, ESX.Math.GroupDigits(data.current.price)))
					end

					menu.close()
					OpenBuyWeaponsMenu()
				else
					ESX.ShowNotification(TranslateCap('armory_money'))
				end
			end, data.current.name, 1)
		end
	end)
end

function OpenWeaponComponentShop(components, weaponName, parentShop)

	ESX.OpenContext("right", components, function(menu,element)
		local data = {current = element}
		if data.current.hasComponent then
			ESX.ShowNotification(TranslateCap('armory_hascomponent'))
		else
			ESX.TriggerServerCallback('esx_policejob:buyWeapon', function(bought)
				if bought then
					if data.current.price > 0 then
						ESX.ShowNotification(TranslateCap('armory_bought', data.current.componentLabel, ESX.Math.GroupDigits(data.current.price)))
					end

					menu.close()
					parentShop.close()
					OpenBuyWeaponsMenu()
				else
					ESX.ShowNotification(TranslateCap('armory_money'))
				end
			end, weaponName, 2, data.current.componentNum)
		end
	end)
end

function OpenGetStocksMenu()
	ESX.TriggerServerCallback('esx_policejob:getStockItems', function(items)
		local elements = {
			{unselectable = true, icon = "fas fa-box", title = TranslateCap('police_stock')}
		}

		for i=1, #items, 1 do
			elements[#elements+1] = {
				icon = "fas fa-box",
				title = 'x' .. items[i].count .. ' ' .. items[i].label,
				value = items[i].name
			}
		end

		ESX.OpenContext("right", elements, function(menu,element)
			local data = {current = element}
			local itemName = data.current.value

			local elements2 = {
				{unselectable = true, icon = "fas fa-box", title = element.title},
				{title = TranslateCap('quantity'), input = true, inputType = "number", inputMin = 1, inputMax = 150, inputPlaceholder = "Amount to withdraw.."},
				{icon = "fas fa-check-double", title = "Confirm", value = "confirm"}
			}

			ESX.OpenContext("right", elements2, function(menu2,element2)
				local data2 = {value = menu2.eles[2].inputValue}
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification(TranslateCap('quantity_invalid'))
				else
					ESX.CloseContext()
					TriggerServerEvent('esx_policejob:getStockItem', itemName, count)

					Wait(300)
					OpenGetStocksMenu()
				end
			end)
		end)
	end)
end

function OpenPutStocksMenu()
	ESX.TriggerServerCallback('esx_policejob:getPlayerInventory', function(inventory)
		local elements = {
			{unselectable = true, icon = "fas fa-box", title = TranslateCap('inventory')}
		}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				elements[#elements+1] = {
					icon = "fas fa-box",
					title = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				}
			end
		end

		ESX.OpenContext("right", elements, function(menu,element)
			local data = {current = element}
			local itemName = data.current.value

			local elements2 = {
				{unselectable = true, icon = "fas fa-box", title = element.title},
				{title = TranslateCap('quantity'), input = true, inputType = "number", inputMin = 1, inputMax = 150, inputPlaceholder = "Amount to withdraw.."},
				{icon = "fas fa-check-double", title = "Confirm", value = "confirm"}
			}

			ESX.OpenContext("right", elements2, function(menu2,element2)
				local data2 = {value = menu2.eles[2].inputValue}
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification(TranslateCap('quantity_invalid'))
				else
					ESX.CloseContext()
					TriggerServerEvent('esx_policejob:putStockItems', itemName, count)

					Wait(300)
					OpenPutStocksMenu()
				end
			end)
		end)
	end)
end

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	if job.name == 'police' then
		Wait(1000)
		TriggerServerEvent('esx_policejob:forceBlip')
	end
end)

AddEventHandler('esx_policejob:hasEnteredMarker', function(station, part, partNum)
	if part == 'Cloakroom' then
		CurrentAction     = 'menu_cloakroom'
		CurrentActionMsg  = TranslateCap('open_cloackroom')
		CurrentActionData = {}
	elseif part == 'Armory' then
		CurrentAction     = 'menu_armory'
		CurrentActionMsg  = TranslateCap('open_armory')
		CurrentActionData = {station = station}
	elseif part == 'Vehicles' then
		CurrentAction     = 'menu_vehicle_spawner'
		CurrentActionMsg  = TranslateCap('garage_prompt')
		CurrentActionData = {station = station, part = part, partNum = partNum}
	elseif part == 'Helicopters' then
		CurrentAction     = 'Helicopters'
		CurrentActionMsg  = TranslateCap('helicopter_prompt')
		CurrentActionData = {station = station, part = part, partNum = partNum}
	elseif part == 'BossActions' then
		CurrentAction     = 'menu_boss_actions'
		CurrentActionMsg  = TranslateCap('open_bossmenu')
		CurrentActionData = {}
	end
end)

AddEventHandler('esx_policejob:hasExitedMarker', function(station, part, partNum)
	if not isInShopMenu then
		ESX.CloseContext()
	end

	CurrentAction = nil
end)

AddEventHandler('esx_policejob:hasEnteredEntityZone', function(entity)
	local playerPed = PlayerPedId()

	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' and IsPedOnFoot(playerPed) then
		CurrentAction     = 'remove_entity'
		CurrentActionMsg  = TranslateCap('remove_prop')
		CurrentActionData = {entity = entity}
	end

	if GetEntityModel(entity) == `p_ld_stinger_s` then
		local playerPed = PlayerPedId()
		local coords    = GetEntityCoords(playerPed)

		if IsPedInAnyVehicle(playerPed, false) then
			local vehicle = GetVehiclePedIsIn(playerPed)

			for i=0, 7, 1 do
				SetVehicleTyreBurst(vehicle, i, true, 1000)
			end
		end
	end
end)

AddEventHandler('esx_policejob:hasExitedEntityZone', function(entity)
	if CurrentAction == 'remove_entity' then
		CurrentAction = nil
	end
end)

RegisterNetEvent('esx_policejob:handcuff')
AddEventHandler('esx_policejob:handcuff', function()
	isHandcuffed = not isHandcuffed
	local playerPed = PlayerPedId()

	if isHandcuffed then
		RequestAnimDict('mp_arresting')
		while not HasAnimDictLoaded('mp_arresting') do
			Wait(100)
		end

		TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
		RemoveAnimDict('mp_arresting')

		SetEnableHandcuffs(playerPed, true)
		DisablePlayerFiring(playerPed, true)
		SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true) -- unarm player
		SetPedCanPlayGestureAnims(playerPed, false)
		FreezeEntityPosition(playerPed, true)
		DisplayRadar(false)

		if Config.EnableHandcuffTimer then
			if handcuffTimer.active then
				ESX.ClearTimeout(handcuffTimer.task)
			end

			StartHandcuffTimer()
		end
	else
		if Config.EnableHandcuffTimer and handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end

		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(true)
	end
end)

RegisterNetEvent('esx_policejob:unrestrain')
AddEventHandler('esx_policejob:unrestrain', function()
	if isHandcuffed then
		local playerPed = PlayerPedId()
		isHandcuffed = false

		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(true)

		-- end timer
		if Config.EnableHandcuffTimer and handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end
	end
end)

RegisterNetEvent('esx_policejob:drag')
AddEventHandler('esx_policejob:drag', function(copId)
	if isHandcuffed then
		dragStatus.isDragged = not dragStatus.isDragged
		dragStatus.CopId = copId
	end
end)

CreateThread(function()
	local wasDragged

	while true do
		local Sleep = 1500

		if isHandcuffed and dragStatus.isDragged then
			Sleep = 50
			local targetPed = GetPlayerPed(GetPlayerFromServerId(dragStatus.CopId))

			if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
				if not wasDragged then
					AttachEntityToEntity(ESX.PlayerData.ped, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
					wasDragged = true
				else
					Wait(1000)
				end
			else
				wasDragged = false
				dragStatus.isDragged = false
				DetachEntity(ESX.PlayerData.ped, true, false)
			end
		elseif wasDragged then
			wasDragged = false
			DetachEntity(ESX.PlayerData.ped, true, false)
		end
	Wait(Sleep)
	end
end)

RegisterNetEvent('esx_policejob:putInVehicle')
AddEventHandler('esx_policejob:putInVehicle', function()
	if isHandcuffed then
		local playerPed = PlayerPedId()
		local vehicle, distance = ESX.Game.GetClosestVehicle()

		if vehicle and distance < 5 then
			local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

			for i=maxSeats - 1, 0, -1 do
				if IsVehicleSeatFree(vehicle, i) then
					freeSeat = i
					break
				end
			end

			if freeSeat then
				TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
				dragStatus.isDragged = false
			end
		end
	end
end)

RegisterNetEvent('esx_policejob:OutVehicle')
AddEventHandler('esx_policejob:OutVehicle', function()
	local GetVehiclePedIsIn = GetVehiclePedIsIn
	local IsPedSittingInAnyVehicle = IsPedSittingInAnyVehicle
	local TaskLeaveVehicle = TaskLeaveVehicle
	if IsPedSittingInAnyVehicle(ESX.PlayerData.ped) then
		local vehicle = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
		TaskLeaveVehicle(ESX.PlayerData.ped, vehicle, 64)
	end
end)

-- Handcuff
CreateThread(function()
	local DisableControlAction = DisableControlAction
	local IsEntityPlayingAnim = IsEntityPlayingAnim
	while true do
		local Sleep = 1000

		if isHandcuffed then
			Sleep = 0
			DisableControlAction(0, 1, true) -- Disable pan
			DisableControlAction(0, 2, true) -- Disable tilt
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			DisableControlAction(0, 32, true) -- W
			DisableControlAction(0, 34, true) -- A
			DisableControlAction(0, 31, true) -- S
			DisableControlAction(0, 30, true) -- D

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?

			DisableControlAction(0, 288,  true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job

			DisableControlAction(0, 0, true) -- Disable changing view
			DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			DisableControlAction(2, 199, true) -- Disable pause screen

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle

			if IsEntityPlayingAnim(ESX.PlayerData.ped, 'mp_arresting', 'idle', 3) ~= 1 then
				ESX.Streaming.RequestAnimDict('mp_arresting', function()
					TaskPlayAnim(ESX.PlayerData.ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
					RemoveAnimDict('mp_arresting')
				end)
			end
		end
	Wait(Sleep)
	end
end)

-- Create blips
CreateThread(function()
	for k,v in pairs(Config.PoliceStations) do
		local blip = AddBlipForCoord(v.Blip.Coords)

		SetBlipSprite (blip, v.Blip.Sprite)
		SetBlipDisplay(blip, v.Blip.Display)
		SetBlipScale  (blip, v.Blip.Scale)
		SetBlipColour (blip, v.Blip.Colour)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(TranslateCap('map_blip'))
		EndTextCommandSetBlipName(blip)
	end
end)

-- Draw markers and more
CreateThread(function()
	while true do
		local Sleep = 1500
		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
			Sleep = 500
			local playerPed = PlayerPedId()
			local playerCoords = GetEntityCoords(playerPed)
			local isInMarker, hasExited = false, false
			local currentStation, currentPart, currentPartNum

			for k,v in pairs(Config.PoliceStations) do
				for i=1, #v.Cloakrooms, 1 do
					local distance = #(playerCoords - v.Cloakrooms[i])

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.Cloakrooms, v.Cloakrooms[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						Sleep = 0

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Cloakroom', i
						end
					end
				end

				for i=1, #v.Armories, 1 do
					local distance = #(playerCoords - v.Armories[i])

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.Armories, v.Armories[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						Sleep = 0

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Armory', i
						end
					end
				end

				for i=1, #v.Vehicles, 1 do
					local distance = #(playerCoords - v.Vehicles[i].Spawner)

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.Vehicles, v.Vehicles[i].Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						Sleep = 0

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Vehicles', i
						end
					end
				end

				for i=1, #v.Helicopters, 1 do
					local distance =  #(playerCoords - v.Helicopters[i].Spawner)

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.Helicopters, v.Helicopters[i].Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						Sleep = 0

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Helicopters', i
						end
					end
				end

				if Config.EnablePlayerManagement and ESX.PlayerData.job.grade_name == 'boss' then
					for i=1, #v.BossActions, 1 do
						local distance = #(playerCoords - v.BossActions[i])

						if distance < Config.DrawDistance then
							DrawMarker(Config.MarkerType.BossActions, v.BossActions[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
							Sleep = 0

							if distance < Config.MarkerSize.x then
								isInMarker, currentStation, currentPart, currentPartNum = true, k, 'BossActions', i
							end
						end
					end
				end
			end

			if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then
				if
					(LastStation and LastPart and LastPartNum) and
					(LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
				then
					TriggerEvent('esx_policejob:hasExitedMarker', LastStation, LastPart, LastPartNum)
					hasExited = true
				end

				HasAlreadyEnteredMarker = true
				LastStation             = currentStation
				LastPart                = currentPart
				LastPartNum             = currentPartNum

				TriggerEvent('esx_policejob:hasEnteredMarker', currentStation, currentPart, currentPartNum)
			end

			if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_policejob:hasExitedMarker', LastStation, LastPart, LastPartNum)
			end
		end
	Wait(Sleep)
	end
end)

-- Enter / Exit entity zone events
CreateThread(function()
	local trackedEntities = {
		`prop_roadcone02a`,
		`prop_barrier_work05`,
		`p_ld_stinger_s`,
		`prop_boxpile_07d`,
		`hei_prop_cash_crate_half_full`
	}

	while true do
		local Sleep = 1500

			local GetEntityCoords = GetEntityCoords
			local GetClosestObjectOfType = GetClosestObjectOfType
			local DoesEntityExist = DoesEntityExist
			local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
	
			local closestDistance = -1
			local closestEntity   = nil

			for i=1, #trackedEntities, 1 do
				local object = GetClosestObjectOfType(playerCoords, 3.0, trackedEntities[i], false, false, false)

				if DoesEntityExist(object) then
					Sleep = 500
					local objCoords = GetEntityCoords(object)
					local distance = #(playerCoords - objCoords)

					if closestDistance == -1 or closestDistance > distance then
						closestDistance = distance
						closestEntity   = object
					end
				end
			end

			if closestDistance ~= -1 and closestDistance <= 3.0 then
				if LastEntity ~= closestEntity then
					TriggerEvent('esx_policejob:hasEnteredEntityZone', closestEntity)
					LastEntity = closestEntity
				end
			else
				if LastEntity then
					TriggerEvent('esx_policejob:hasExitedEntityZone', LastEntity)
					LastEntity = nil
				end
			end
		Wait(Sleep)
	end
end)

ESX.RegisterInput("police:interact", "(ESX PoliceJob) Interact", "keyboard", "E", function()
	if not CurrentAction then 
		return 
	end

	if not ESX.PlayerData.job or (ESX.PlayerData.job and not ESX.PlayerData.job.name == 'police') then
		return
	end
	if CurrentAction == 'menu_cloakroom' then
		OpenCloakroomMenu()
	elseif CurrentAction == 'menu_armory' then
		if not Config.EnableESXService then
			OpenArmoryMenu(CurrentActionData.station)
		elseif playerInService then
			OpenArmoryMenu(CurrentActionData.station)
		else
			ESX.ShowNotification(TranslateCap('service_not'))
		end
	elseif CurrentAction == 'menu_vehicle_spawner' then
		if not Config.EnableESXService then
			OpenVehicleSpawnerMenu('car', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
		elseif playerInService then
			OpenVehicleSpawnerMenu('car', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
		else
			ESX.ShowNotification(TranslateCap('service_not'))
		end
	elseif CurrentAction == 'Helicopters' then
		if not Config.EnableESXService then
			OpenVehicleSpawnerMenu('helicopter', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
		elseif playerInService then
			OpenVehicleSpawnerMenu('helicopter', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
		else
			ESX.ShowNotification(TranslateCap('service_not'))
		end
	elseif CurrentAction == 'delete_vehicle' then
		ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
	elseif CurrentAction == 'menu_boss_actions' then
		ESX.CloseContext()
		TriggerEvent('esx_society:openBossMenu', 'police', function(data, menu)
			menu.close()

			CurrentAction     = 'menu_boss_actions'
			CurrentActionMsg  = TranslateCap('open_bossmenu')
			CurrentActionData = {}
		end, { wash = false }) -- disable washing money
	elseif CurrentAction == 'remove_entity' then
		DeleteEntity(CurrentActionData.entity)
	end

	CurrentAction = nil
end)

ESX.RegisterInput("police:quickactions", "(ESX PoliceJob) Quick Actions", "keyboard", "F6", function()
	if not ESX.PlayerData.job or (ESX.PlayerData.job.name ~= 'police') or isDead then
		return
	end

	if not Config.EnableESXService then
		OpenPoliceActionsMenu()
	elseif playerInService then
		OpenPoliceActionsMenu()
	else
		ESX.ShowNotification(TranslateCap('service_not'))
	end
end)

CreateThread(function()
	while true do
		local Sleep = 1000

		if CurrentAction then
			Sleep = 0
			ESX.ShowHelpNotification(CurrentActionMsg)
		end
	Wait(Sleep)
	end
end)

-- Create blip for colleagues
function createBlip(id)
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

RegisterNetEvent('esx_policejob:updateBlip')
AddEventHandler('esx_policejob:updateBlip', function()

	-- Refresh all blips
	for k, existingBlip in pairs(blipsCops) do
		RemoveBlip(existingBlip)
	end

	-- Clean the blip table
	blipsCops = {}

	-- Enable blip?
	if Config.EnableESXService and not playerInService then
		return
	end

	if not Config.EnableJobBlip then
		return
	end

	-- Is the player a cop? In that case show all the blips for other cops
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
		ESX.TriggerServerCallback('esx_society:getOnlinePlayers', function(players)
			for i=1, #players, 1 do
				if players[i].job.name == 'police' then
					local id = GetPlayerFromServerId(players[i].source)
					if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= PlayerPedId() then
						createBlip(id)
					end
				end
			end
		end)
	end

end)

AddEventHandler('esx:onPlayerSpawn', function(spawn)
	isDead = false
	TriggerEvent('esx_policejob:unrestrain')

	if not hasAlreadyJoined then
		TriggerServerEvent('esx_policejob:spawned')
	end
	hasAlreadyJoined = true
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('esx_policejob:unrestrain')

		if Config.EnableESXService then
			TriggerServerEvent('esx_service:disableService', 'police')
		end

		if Config.EnableHandcuffTimer and handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end
	end
end)

-- handcuff timer, unrestrain the player after an certain amount of time
function StartHandcuffTimer()
	if Config.EnableHandcuffTimer and handcuffTimer.active then
		ESX.ClearTimeout(handcuffTimer.task)
	end

	handcuffTimer.active = true

	handcuffTimer.task = ESX.SetTimeout(Config.HandcuffTimer, function()
		ESX.ShowNotification(TranslateCap('unrestrained_timer'))
		TriggerEvent('esx_policejob:unrestrain')
		handcuffTimer.active = false
	end)
end

-- TODO
--   - return to garage if owned
--   - message owner that his vehicle has been impounded
function ImpoundVehicle(vehicle)
	--local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
	ESX.Game.DeleteVehicle(vehicle)
	ESX.ShowNotification(TranslateCap('impound_successful'))
	currentTask.busy = false
end

if ESX.PlayerLoaded and ESX.PlayerData.job == 'police' then
	SetTimeout(1000, function()
		TriggerServerEvent('esx_policejob:forceBlip')
	end)
end
