local isLoadoutLoaded, isPaused, isDead, isFirstSpawn, pickups = false, false, false, true, {}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if NetworkIsPlayerActive(PlayerId()) then
			TriggerServerEvent('esx:onPlayerJoined')
			break
		end
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
	ESX.PlayerLoaded = true
	ESX.PlayerData = playerData

	-- check if player is coming from loading screen
	if GetEntityModel(PlayerPedId()) == GetHashKey('PLAYER_ZERO') then
		local defaultModel = GetHashKey('a_m_y_stbla_02')
		RequestModel(defaultModel)

		while not HasModelLoaded(defaultModel) do
			Citizen.Wait(100)
		end

		SetPlayerModel(PlayerId(), defaultModel)
		local playerPed = PlayerPedId()

		SetPedDefaultComponentVariation(playerPed)
		SetPedRandomComponentVariation(playerPed, true)
		SetModelAsNoLongerNeeded(defaultModel)
		FreezeEntityPosition(playerPed, false)
	end

	local playerPed = PlayerPedId()

	if Config.EnablePvP then
		SetCanAttackFriendly(playerPed, true, false)
		NetworkSetFriendlyFireOption(true)
	end

	if Config.EnableHud then
		for k,v in ipairs(playerData.accounts) do
			local accountTpl = '<div><img src="img/accounts/' .. v.name .. '.png"/>&nbsp;{{money}}</div>'
			ESX.UI.HUD.RegisterElement('account_' .. v.name, k, 0, accountTpl, {money = ESX.Math.GroupDigits(v.money)})
		end

		local jobTpl = '<div>{{job_label}} - {{grade_label}}</div>'

		if playerData.job.grade_label == '' or playerData.job.grade_label == playerData.job.label then
			jobTpl = '<div>{{job_label}}</div>'
		end

		ESX.UI.HUD.RegisterElement('job', #playerData.accounts, 0, jobTpl, {
			job_label = playerData.job.label,
			grade_label = playerData.job.grade_label
		})
	end

	ESX.Game.Teleport(playerPed, {
		x = playerData.coords.x,
		y = playerData.coords.y,
		z = playerData.coords.z + 0.5,
		heading = playerData.coords.heading
	}, function()
		isLoadoutLoaded, isDead = true, false
		TriggerServerEvent('esx:onPlayerSpawn')
		TriggerEvent('esx:onPlayerSpawn')
		TriggerEvent('playerSpawned') -- compatibility with old scripts, will be removed soon
		TriggerEvent('esx:restoreLoadout')

		Citizen.Wait(3000)
		ShutdownLoadingScreen()
		DoScreenFadeIn(10000)
	end)
end)

RegisterNetEvent('esx:setMaxWeight')
AddEventHandler('esx:setMaxWeight', function(newMaxWeight) ESX.PlayerData.maxWeight = newMaxWeight end)

AddEventHandler('esx:onPlayerDeath', function() isDead = true end)
AddEventHandler('skinchanger:loadDefaultModel', function() isLoadoutLoaded = false end)

AddEventHandler('skinchanger:modelLoaded', function()
	while not ESX.PlayerLoaded do
		Citizen.Wait(100)
	end

	TriggerEvent('esx:restoreLoadout')
end)

AddEventHandler('esx:restoreLoadout', function()
	local playerPed = PlayerPedId()
	local ammoTypes = {}

	RemoveAllPedWeapons(playerPed, true)

	for k,v in ipairs(ESX.PlayerData.loadout) do
		local weaponName = v.name
		local weaponHash = GetHashKey(weaponName)

		GiveWeaponToPed(playerPed, weaponHash, 0, false, false)
		SetPedWeaponTintIndex(playerPed, weaponHash, v.tintIndex)

		local ammoType = GetPedAmmoTypeFromWeapon(playerPed, weaponHash)

		for k2,v2 in ipairs(v.components) do
			local componentHash = ESX.GetWeaponComponent(weaponName, v2).hash

			GiveWeaponComponentToPed(playerPed, weaponHash, componentHash)
		end

		if not ammoTypes[ammoType] then
			AddAmmoToPed(playerPed, weaponHash, v.ammo)
			ammoTypes[ammoType] = true
		end
	end

	isLoadoutLoaded = true
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
	for k,v in ipairs(ESX.PlayerData.accounts) do
		if v.name == account.name then
			ESX.PlayerData.accounts[k] = account
			break
		end
	end

	if Config.EnableHud then
		ESX.UI.HUD.UpdateElement('account_' .. account.name, {
			money = ESX.Math.GroupDigits(account.money)
		})
	end
end)

RegisterNetEvent('esx:addInventoryItem')
AddEventHandler('esx:addInventoryItem', function(item, count, showNotification)
	for k,v in ipairs(ESX.PlayerData.inventory) do
		if v.name == item then
			ESX.UI.ShowInventoryItemNotification(true, v.label, count - v.count)
			ESX.PlayerData.inventory[k].count = count
			break
		end
	end

	if showNotification then
		ESX.UI.ShowInventoryItemNotification(true, item, count)
	end

	if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
		ESX.ShowInventory()
	end
end)

RegisterNetEvent('esx:removeInventoryItem')
AddEventHandler('esx:removeInventoryItem', function(item, count, showNotification)
	for k,v in ipairs(ESX.PlayerData.inventory) do
		if v.name == item then
			ESX.UI.ShowInventoryItemNotification(false, v.label, v.count - count)
			ESX.PlayerData.inventory[k].count = count
			break
		end
	end

	if showNotification then
		ESX.UI.ShowInventoryItemNotification(false, item, count)
	end

	if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
		ESX.ShowInventory()
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:addWeapon')
AddEventHandler('esx:addWeapon', function(weaponName, ammo)
	local playerPed = PlayerPedId()
	local weaponHash = GetHashKey(weaponName)

	GiveWeaponToPed(playerPed, weaponHash, ammo, false, false)
end)

RegisterNetEvent('esx:addWeaponComponent')
AddEventHandler('esx:addWeaponComponent', function(weaponName, weaponComponent)
	local playerPed = PlayerPedId()
	local weaponHash = GetHashKey(weaponName)
	local componentHash = ESX.GetWeaponComponent(weaponName, weaponComponent).hash

	GiveWeaponComponentToPed(playerPed, weaponHash, componentHash)
end)

RegisterNetEvent('esx:setWeaponAmmo')
AddEventHandler('esx:setWeaponAmmo', function(weaponName, weaponAmmo)
	local playerPed = PlayerPedId()
	local weaponHash = GetHashKey(weaponName)

	SetPedAmmo(playerPed, weaponHash, weaponAmmo)
end)

RegisterNetEvent('esx:setWeaponTint')
AddEventHandler('esx:setWeaponTint', function(weaponName, weaponTintIndex)
	local playerPed = PlayerPedId()
	local weaponHash = GetHashKey(weaponName)

	SetPedWeaponTintIndex(playerPed, weaponHash, weaponTintIndex)
end)

RegisterNetEvent('esx:removeWeapon')
AddEventHandler('esx:removeWeapon', function(weaponName)
	local playerPed = PlayerPedId()
	local weaponHash = GetHashKey(weaponName)

	RemoveWeaponFromPed(playerPed, weaponHash)
	SetPedAmmo(playerPed, weaponHash, 0) -- remove leftover ammo
end)

RegisterNetEvent('esx:removeWeaponComponent')
AddEventHandler('esx:removeWeaponComponent', function(weaponName, weaponComponent)
	local playerPed = PlayerPedId()
	local weaponHash = GetHashKey(weaponName)
	local componentHash = ESX.GetWeaponComponent(weaponName, weaponComponent).hash

	RemoveWeaponComponentFromPed(playerPed, weaponHash, componentHash)
end)

RegisterNetEvent('esx:teleport')
AddEventHandler('esx:teleport', function(coords)
	local playerPed = PlayerPedId()

	-- ensure decmial number
	coords.x = coords.x + 0.0
	coords.y = coords.y + 0.0
	coords.z = coords.z + 0.0

	ESX.Game.Teleport(playerPed, coords)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	if Config.EnableHud then
		ESX.UI.HUD.UpdateElement('job', {
			job_label   = job.label,
			grade_label = job.grade_label
		})
	end
end)

RegisterNetEvent('esx:spawnVehicle')
AddEventHandler('esx:spawnVehicle', function(vehicle)
	local model = (type(vehicle) == 'number' and vehicle or GetHashKey(vehicle))

	if IsModelInCdimage(model) then
		local playerPed = PlayerPedId()
		local playerCoords, playerHeading = GetEntityCoords(playerPed), GetEntityHeading(playerPed)

		ESX.Game.SpawnVehicle(model, playerCoords, playerHeading, function(vehicle)
			TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		end)
	else
		TriggerEvent('chat:addMessage', { args = { '^1SYSTEM', 'Invalid vehicle model.' } })
	end
end)

RegisterNetEvent('esx:createPickup')
AddEventHandler('esx:createPickup', function(pickupId, label, playerId, type, name, components, tintIndex)
	local playerPed = GetPlayerPed(GetPlayerFromServerId(playerId))
	local entityCoords, forward, pickupObject = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
	local objectCoords = (entityCoords + forward * 1.0)

	if type == 'item_weapon' then
		ESX.Streaming.RequestWeaponAsset(GetHashKey(name))
		pickupObject = CreateWeaponObject(GetHashKey(name), 50, objectCoords, true, 1.0, 0)
		SetWeaponObjectTintIndex(pickupObject, tintIndex)

		for k,v in ipairs(components) do
			local component = ESX.GetWeaponComponent(name, v)
			GiveWeaponComponentToWeaponObject(pickupObject, component.hash)
		end
	else
		ESX.Game.SpawnLocalObject('prop_money_bag_01', objectCoords, function(obj)
			pickupObject = obj
		end)

		while not pickupObject do
			Citizen.Wait(10)
		end
	end

	SetEntityAsMissionEntity(pickupObject, true, false)
	PlaceObjectOnGroundProperly(pickupObject)
	FreezeEntityPosition(pickupObject, true)
	SetEntityCollision(pickupObject, false, true)

	pickups[pickupId] = {
		id = pickupId,
		obj = pickupObject,
		label = label,
		inRange = false,
		coords = objectCoords
	}
end)

RegisterNetEvent('esx:createMissingPickups')
AddEventHandler('esx:createMissingPickups', function(missingPickups)
	for pickupId,pickup in pairs(missingPickups) do
		local pickupObject = nil

		if pickup.type == 'item_weapon' then
			ESX.Streaming.RequestWeaponAsset(GetHashKey(pickup.name))
			pickupObject = CreateWeaponObject(GetHashKey(pickup.name), 50, pickup.coords.x, pickup.coords.y, pickup.coords.z, true, 1.0, 0)
			SetWeaponObjectTintIndex(pickupObject, pickup.tintIndex)

			for k,componentName in ipairs(pickup.components) do
				local component = ESX.GetWeaponComponent(pickup.name, componentName)
				GiveWeaponComponentToWeaponObject(pickupObject, component.hash)
			end
		else
			ESX.Game.SpawnLocalObject('prop_money_bag_01', pickup.coords, function(obj)
				pickupObject = obj
			end)

			while not pickupObject do
				Citizen.Wait(10)
			end
		end

		SetEntityAsMissionEntity(pickupObject, true, false)
		PlaceObjectOnGroundProperly(pickupObject)
		FreezeEntityPosition(pickupObject, true)
		SetEntityCollision(pickupObject, false, true)

		pickups[pickupId] = {
			id = pickupId,
			obj = pickupObject,
			label = pickup.label,
			inRange = false,
			coords = vector3(pickup.coords.x, pickup.coords.y, pickup.coords.z)
		}
	end
end)

RegisterNetEvent('esx:registerSuggestions')
AddEventHandler('esx:registerSuggestions', function(registeredCommands)
	for name,command in pairs(registeredCommands) do
		if command.suggestion then
			TriggerEvent('chat:addSuggestion', ('/%s'):format(name), command.suggestion.help, command.suggestion.arguments)
		end
	end
end)

RegisterNetEvent('esx:removePickup')
AddEventHandler('esx:removePickup', function(id)
	if pickups[id] and pickups[id].obj then
		ESX.Game.DeleteObject(pickups[id].obj)
		pickups[id] = nil
	end
end)

RegisterNetEvent('esx:deleteVehicle')
AddEventHandler('esx:deleteVehicle', function(radius)
	local playerPed = PlayerPedId()

	if radius and tonumber(radius) then
		radius = tonumber(radius) + 0.01
		local vehicles = ESX.Game.GetVehiclesInArea(GetEntityCoords(playerPed), radius)

		for k,entity in ipairs(vehicles) do
			local attempt = 0

			while not NetworkHasControlOfEntity(entity) and attempt < 100 and DoesEntityExist(entity) do
				Citizen.Wait(100)
				NetworkRequestControlOfEntity(entity)
				attempt = attempt + 1
			end

			if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
				ESX.Game.DeleteVehicle(entity)
			end
		end
	else
		local vehicle, attempt = ESX.Game.GetVehicleInDirection(), 0

		if IsPedInAnyVehicle(playerPed, true) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		end

		while not NetworkHasControlOfEntity(vehicle) and attempt < 100 and DoesEntityExist(vehicle) do
			Citizen.Wait(100)
			NetworkRequestControlOfEntity(vehicle)
			attempt = attempt + 1
		end

		if DoesEntityExist(vehicle) and NetworkHasControlOfEntity(vehicle) then
			ESX.Game.DeleteVehicle(vehicle)
		end
	end
end)

-- Pause menu disables HUD display
if Config.EnableHud then
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(300)

			if IsPauseMenuActive() and not isPaused then
				isPaused = true
				ESX.UI.HUD.SetDisplay(0.0)
			elseif not IsPauseMenuActive() and isPaused then
				isPaused = false
				ESX.UI.HUD.SetDisplay(1.0)
			end
		end
	end)
end

-- Keep track of ammo usage
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if isDead then
			Citizen.Wait(500)
		else
			local playerPed = PlayerPedId()

			if IsPedShooting(playerPed) then
				local _,weaponHash = GetCurrentPedWeapon(playerPed, true)
				local weapon = ESX.GetWeaponFromHash(weaponHash)

				if weapon then
					local ammoCount = GetAmmoInPedWeapon(playerPed, weaponHash)
					TriggerServerEvent('esx:updateWeaponAmmo', weapon.name, ammoCount)
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if IsControlJustReleased(0, 289) then
			if IsInputDisabled(0) and not isDead and not ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
				ESX.ShowInventory()
			end
		end
	end
end)

-- Disable wanted level
if Config.DisableWantedLevel then
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			local playerId = PlayerId()

			if GetPlayerWantedLevel(playerId) ~= 0 then
				SetPlayerWantedLevel(playerId, 0, false)
				SetPlayerWantedLevelNow(playerId, false)
			end
		end
	end)
end

-- Pickups
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local playerCoords, letSleep = GetEntityCoords(playerPed), true
		local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

		for k,v in pairs(pickups) do
			local distance = #(playerCoords - v.coords)

			if distance < 5 then
				local label = v.label
				letSleep = false

				if distance < 1 then
					if IsControlJustReleased(0, 38) then
						if IsPedOnFoot(playerPed) and (closestDistance == -1 or closestDistance > 3) and not v.inRange then
							v.inRange = true

							local dict, anim = 'weapons@first_person@aim_rng@generic@projectile@sticky_bomb@', 'plant_floor'
							ESX.Streaming.RequestAnimDict(dict)
							TaskPlayAnim(playerPed, dict, anim, 8.0, 1.0, 1000, 16, 0.0, false, false, false)
							Citizen.Wait(1000)

							TriggerServerEvent('esx:onPickup', v.id)
							PlaySoundFrontend(-1, 'PICK_UP', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
						end
					end

					label = ('%s~n~%s'):format(label, _U('threw_pickup_prompt'))
				end

				ESX.Game.Utils.DrawText3D({
					x = v.coords.x,
					y = v.coords.y,
					z = v.coords.z + 0.25
				}, label, 1.2, 1)
			elseif v.inRange then
				v.inRange = false
			end
		end

		if letSleep then
			Citizen.Wait(500)
		end
	end
end)

-- Update current player coords
Citizen.CreateThread(function()
	-- wait for player to restore coords
	while not isLoadoutLoaded do
		Citizen.Wait(1000)
	end

	local previousCoords = vector3(ESX.PlayerData.coords.x, ESX.PlayerData.coords.y, ESX.PlayerData.coords.z)

	while true do
		Citizen.Wait(1000)
		local playerPed = PlayerPedId()

		if DoesEntityExist(playerPed) then
			local playerCoords = GetEntityCoords(playerPed)
			local distance = #(playerCoords - previousCoords)

			if distance > 1 then
				previousCoords = playerCoords
				local playerHeading = ESX.Math.Round(GetEntityHeading(playerPed), 1)
				local formattedCoords = {x = ESX.Math.Round(playerCoords.x, 1), y = ESX.Math.Round(playerCoords.y, 1), z = ESX.Math.Round(playerCoords.z, 1), heading = playerHeading}
				TriggerServerEvent('esx:updateCoords', formattedCoords)
			end
		end
	end
end)
