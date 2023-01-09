local pickups = {}

CreateThread(function()
	while not Config.Multichar do
		Wait(0)
		if NetworkIsPlayerActive(PlayerId()) then
			exports.spawnmanager:setAutoSpawn(false)
			DoScreenFadeOut(0)
			Wait(500)
			TriggerServerEvent('esx:onPlayerJoined')
			break
		end
	end
end)

RegisterNetEvent("esx:requestModel", function(model)
    ESX.Streaming.RequestModel(model)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
	ESX.PlayerData = xPlayer

	if Config.Multichar then
		Wait(3000)
	else
		exports.spawnmanager:spawnPlayer({
			x = ESX.PlayerData.coords.x,
			y = ESX.PlayerData.coords.y,
			z = ESX.PlayerData.coords.z + 0.25,
			heading = ESX.PlayerData.coords.heading,
			model = `mp_m_freemode_01`,
			skipFade = false
		}, function()
			TriggerServerEvent('esx:onPlayerSpawn')
			TriggerEvent('esx:onPlayerSpawn')
			TriggerEvent('esx:restoreLoadout')

			if isNew then
				TriggerEvent('skinchanger:loadDefaultModel', skin.sex == 0)
			elseif skin then
				TriggerEvent('skinchanger:loadSkin', skin)
			end

			TriggerEvent('esx:loadingScreenOff')
			ShutdownLoadingScreen()
			ShutdownLoadingScreenNui()
		end)
	end

	ESX.PlayerLoaded = true

	while ESX.PlayerData.ped == nil do Wait(20) end

	if Config.EnablePVP then
		SetCanAttackFriendly(ESX.PlayerData.ped, true, false)
		NetworkSetFriendlyFireOption(true)
	end

	CreateThread(function()
		local SetPlayerHealthRechargeMultiplier = SetPlayerHealthRechargeMultiplier
		local BlockWeaponWheelThisFrame = BlockWeaponWheelThisFrame
		local DisableControlAction = DisableControlAction
		local IsPedArmed = IsPedArmed
		local SetPlayerLockonRangeOverride = SetPlayerLockonRangeOverride
		local DisablePlayerVehicleRewards = DisablePlayerVehicleRewards
		local RemoveAllPickupsOfType = RemoveAllPickupsOfType
		local HideHudComponentThisFrame = HideHudComponentThisFrame
		local PlayerId = PlayerId()
		local DisabledComps = {}
		for i=1, #(Config.RemoveHudCommonents) do
			if Config.RemoveHudCommonents[i] then
				DisabledComps[#DisabledComps + 1] = i
			end
		end

		while true do 
			local Sleep = true

			if Config.DisableHealthRegeneration then
				Sleep = false
				SetPlayerHealthRechargeMultiplier(PlayerId, 0.0)
			end

			if Config.DisableWeaponWheel then
				Sleep = false
				BlockWeaponWheelThisFrame()
				DisableControlAction(0, 37,true)
			end

			if Config.DisableAimAssist then
				Sleep = false
				if IsPedArmed(ESX.PlayerData.ped, 4) then
					SetPlayerLockonRangeOverride(PlayerId, 2.0)
				end
			end

			if Config.DisableVehicleRewards then
				Sleep = false
				DisablePlayerVehicleRewards(PlayerId)
			end
			
			if Config.DisableNPCDrops then
				Sleep = false
				RemoveAllPickupsOfType(0xDF711959)
				RemoveAllPickupsOfType(0xF9AFB48F)
				RemoveAllPickupsOfType(0xA9355DCD)
			end

			if #DisabledComps > 0 then
				Sleep = false
				for i=1, #(DisabledComps) do
					HideHudComponentThisFrame(DisabledComps[i])
				end
			end
				
			Wait(Sleep and 1500 or 0)
		end
	end)

	if Config.EnableHud then
		for i=1, #(ESX.PlayerData.accounts) do
			local accountTpl = '<div><img src="img/accounts/' .. ESX.PlayerData.accounts[i].name .. '.png"/>&nbsp;{{money}}</div>'
			ESX.UI.HUD.RegisterElement('account_' .. ESX.PlayerData.accounts[i].name, i, 0, accountTpl, {money = ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money)})
		end

		local jobTpl = '<div>{{job_label}}{{grade_label}}</div>'

		local gradeLabel = ESX.PlayerData.job.grade_label ~= ESX.PlayerData.job.label and ESX.PlayerData.job.grade_label or ''
		if gradeLabel ~= '' then gradeLabel = ' - '..gradeLabel end

		ESX.UI.HUD.RegisterElement('job', #ESX.PlayerData.accounts, 0, jobTpl, {
			job_label = ESX.PlayerData.job.label,
			grade_label = gradeLabel
		})
	end

	SetDefaultVehicleNumberPlateTextPattern(-1, Config.CustomAIPlates)
	StartServerSyncLoops()
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	if Config.EnableHud then ESX.UI.HUD.Reset() end
end)

RegisterNetEvent('esx:setMaxWeight')
AddEventHandler('esx:setMaxWeight', function(newMaxWeight) ESX.SetPlayerData("maxWeight", newMaxWeight) end)

local function onPlayerSpawn()
		ESX.SetPlayerData('ped', PlayerPedId())
		ESX.SetPlayerData('dead', false)
end

AddEventHandler('playerSpawned', onPlayerSpawn)
AddEventHandler('esx:onPlayerSpawn', onPlayerSpawn)

AddEventHandler('esx:onPlayerDeath', function()
	ESX.SetPlayerData('ped', PlayerPedId())
	ESX.SetPlayerData('dead', true)
end)

AddEventHandler('skinchanger:modelLoaded', function()
	while not ESX.PlayerLoaded do
		Wait(100)
	end
	TriggerEvent('esx:restoreLoadout')
end)

AddEventHandler('esx:restoreLoadout', function()
	ESX.SetPlayerData('ped', PlayerPedId())

	if not Config.OxInventory then
		local ammoTypes = {}
		RemoveAllPedWeapons(ESX.PlayerData.ped, true)

		for k,v in ipairs(ESX.PlayerData.loadout) do
			local weaponName = v.name
			local weaponHash = joaat(weaponName)

			GiveWeaponToPed(ESX.PlayerData.ped, weaponHash, 0, false, false)
			SetPedWeaponTintIndex(ESX.PlayerData.ped, weaponHash, v.tintIndex)

			local ammoType = GetPedAmmoTypeFromWeapon(ESX.PlayerData.ped, weaponHash)

			for k2,v2 in ipairs(v.components) do
				local componentHash = ESX.GetWeaponComponent(weaponName, v2).hash
				GiveWeaponComponentToPed(ESX.PlayerData.ped, weaponHash, componentHash)
			end

			if not ammoTypes[ammoType] then
				AddAmmoToPed(ESX.PlayerData.ped, weaponHash, v.ammo)
				ammoTypes[ammoType] = true
			end
		end
	end
end)

AddStateBagChangeHandler('VehicleProperties', nil, function(bagName, key, value)
	if value then
			Wait(0)
			local NetId = value.NetId
			local Vehicle = NetworkGetEntityFromNetworkId(NetId)
			local Tries = 0
			while Vehicle == 0 do
				Vehicle = NetworkGetEntityFromNetworkId(NetId)
				Wait(100)
				Tries = Tries + 1
				if Tries > 300 then
					break
				end
			end
			if NetworkGetEntityOwner(Vehicle) == PlayerId() then
					ESX.Game.SetVehicleProperties(Vehicle, value)
			end
	end
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
	for i=1, #(ESX.PlayerData.accounts) do
		if ESX.PlayerData.accounts[i].name == account.name then
			ESX.PlayerData.accounts[i] = account
			break
		end
	end

	ESX.SetPlayerData('accounts', ESX.PlayerData.accounts)

	if Config.EnableHud then
		ESX.UI.HUD.UpdateElement('account_' .. account.name, {
			money = ESX.Math.GroupDigits(account.money)
		})
	end
end)

if not Config.OxInventory then
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

		ESX.ShowInventory()
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

		ESX.ShowInventory()
	end)

	RegisterNetEvent('esx:addWeapon')
	AddEventHandler('esx:addWeapon', function(weapon, ammo)
		print("[^1ERROR^7] event ^5'esx:addWeapon'^7 Has Been Removed. Please use ^5xPlayer.addWeapon^7 Instead!")
	end)

	RegisterNetEvent('esx:addWeaponComponent')
	AddEventHandler('esx:addWeaponComponent', function(weapon, weaponComponent)
		print("[^1ERROR^7] event ^5'esx:addWeaponComponent'^7 Has Been Removed. Please use ^5xPlayer.addWeaponComponent^7 Instead!")
	end)

	RegisterNetEvent('esx:setWeaponAmmo')
	AddEventHandler('esx:setWeaponAmmo', function(weapon, weaponAmmo)
		print("[^1ERROR^7] event ^5'esx:setWeaponAmmo'^7 Has Been Removed. Please use ^5xPlayer.addWeaponAmmo^7 Instead!")
	end)

	RegisterNetEvent('esx:setWeaponTint')
	AddEventHandler('esx:setWeaponTint', function(weapon, weaponTintIndex)
		SetPedWeaponTintIndex(ESX.PlayerData.ped, joaat(weapon), weaponTintIndex)
		
	end)

	RegisterNetEvent('esx:removeWeapon')
	AddEventHandler('esx:removeWeapon', function(weapon)
		local playerPed = ESX.PlayerData.ped
		RemoveWeaponFromPed(ESX.PlayerData.ped, joaat(weapon))
		SetPedAmmo(ESX.PlayerData.ped, joaat(weapon), 0)
	end)

	RegisterNetEvent('esx:removeWeaponComponent')
	AddEventHandler('esx:removeWeaponComponent', function(weapon, weaponComponent)
		local componentHash = ESX.GetWeaponComponent(weapon, weaponComponent).hash
		RemoveWeaponComponentFromPed(ESX.PlayerData.ped, joaat(weapon), componentHash)
	end)
end

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(Job)
	if Config.EnableHud then
		local gradeLabel = Job.grade_label ~= Job.label and Job.grade_label or ''
		if gradeLabel ~= '' then gradeLabel = ' - '..gradeLabel end
		ESX.UI.HUD.UpdateElement('job', {
			job_label = Job.label,
			grade_label = gradeLabel
		})
	end
	ESX.SetPlayerData('job', Job)
end)

if not Config.OxInventory then
	RegisterNetEvent('esx:createPickup')
	AddEventHandler('esx:createPickup', function(pickupId, label, coords, type, name, components, tintIndex)
		local function setObjectProperties(object)
			SetEntityAsMissionEntity(object, true, false)
			PlaceObjectOnGroundProperly(object)
			FreezeEntityPosition(object, true)
			SetEntityCollision(object, false, true)

			pickups[pickupId] = {
				obj = object,
				label = label,
				inRange = false,
				coords = vector3(coords.x, coords.y, coords.z)
			}
		end

		if type == 'item_weapon' then
			local weaponHash = joaat(name)
			ESX.Streaming.RequestWeaponAsset(weaponHash)
			local pickupObject = CreateWeaponObject(weaponHash, 50, coords.x, coords.y, coords.z, true, 1.0, 0)
			SetWeaponObjectTintIndex(pickupObject, tintIndex)

			for k,v in ipairs(components) do
				local component = ESX.GetWeaponComponent(name, v)
				GiveWeaponComponentToWeaponObject(pickupObject, component.hash)
			end

			setObjectProperties(pickupObject)
		else
			ESX.Game.SpawnLocalObject('prop_money_bag_01', coords, setObjectProperties)
		end
	end)

	RegisterNetEvent('esx:createMissingPickups')
	AddEventHandler('esx:createMissingPickups', function(missingPickups)
		for pickupId, pickup in pairs(missingPickups) do
			TriggerEvent('esx:createPickup', pickupId, pickup.label, pickup.coords - vector3(0,0, 1.0), pickup.type, pickup.name, pickup.components, pickup.tintIndex)
		end
	end)
end

RegisterNetEvent('esx:registerSuggestions')
AddEventHandler('esx:registerSuggestions', function(registeredCommands)
	for name,command in pairs(registeredCommands) do
		if command.suggestion then
			TriggerEvent('chat:addSuggestion', ('/%s'):format(name), command.suggestion.help, command.suggestion.arguments)
		end
	end
end)

if not Config.OxInventory then
	RegisterNetEvent('esx:removePickup')
	AddEventHandler('esx:removePickup', function(pickupId)
		if pickups[pickupId] and pickups[pickupId].obj then
			ESX.Game.DeleteObject(pickups[pickupId].obj)
			pickups[pickupId] = nil
		end
	end)
end

-- Pause menu disables HUD display
if Config.EnableHud then
	CreateThread(function()
		local isPaused = false
		
		while true do
			local time = 500
			Wait(time)

			if IsPauseMenuActive() and not isPaused then
				time = 100
				isPaused = true
				ESX.UI.HUD.SetDisplay(0.0)
			elseif not IsPauseMenuActive() and isPaused then
				time = 100
				isPaused = false
				ESX.UI.HUD.SetDisplay(1.0)
			end
		end
	end)

	AddEventHandler('esx:loadingScreenOff', function()
		ESX.UI.HUD.SetDisplay(1.0)
	end)
end

function StartServerSyncLoops()
	if not Config.OxInventory then
			-- keep track of ammo

			CreateThread(function()
					local currentWeapon = {Ammo = 0}
					while ESX.PlayerLoaded do
						local sleep = 1500
						if GetSelectedPedWeapon(ESX.PlayerData.ped) ~= -1569615261 then
							sleep = 1000
							local _,weaponHash = GetCurrentPedWeapon(ESX.PlayerData.ped, true)
							local weapon = ESX.GetWeaponFromHash(weaponHash) 
							if weapon then
								local ammoCount = GetAmmoInPedWeapon(ESX.PlayerData.ped, weaponHash)
								if weapon.name ~= currentWeapon.name then 
									currentWeapon.Ammo = ammoCount
									currentWeapon.name = weapon.name
								else
									if ammoCount ~= currentWeapon.Ammo then
										currentWeapon.Ammo = ammoCount
										TriggerServerEvent('esx:updateWeaponAmmo', weapon.name, ammoCount)
									end 
								end   
							end
						end    
					Wait(sleep)
					end
			end)
	end
end

if not Config.OxInventory and Config.EnableDefaultInventory then
	RegisterCommand('showinv', function()
		if not ESX.PlayerData.dead then
			ESX.ShowInventory()
		end
	end)

	RegisterKeyMapping('showinv', TranslateCap('keymap_showinventory'), 'keyboard', 'F2')
end

-- disable wanted level
if not Config.EnableWantedLevel then
	ClearPlayerWantedLevel(PlayerId())
	SetMaxWantedLevel(0)
end

if not Config.OxInventory then
	CreateThread(function()
		while true do
			local Sleep = 1500
			local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer(playerCoords)

			for pickupId,pickup in pairs(pickups) do
				local distance = #(playerCoords - pickup.coords)

				if distance < 5 then
					Sleep = 0
					local label = pickup.label

					if distance < 1 then
						if IsControlJustReleased(0, 38) then
							if IsPedOnFoot(ESX.PlayerData.ped) and (closestDistance == -1 or closestDistance > 3) and not pickup.inRange then
								pickup.inRange = true

								local dict, anim = 'weapons@first_person@aim_rng@generic@projectile@sticky_bomb@', 'plant_floor'
								ESX.Streaming.RequestAnimDict(dict)
								TaskPlayAnim(ESX.PlayerData.ped, dict, anim, 8.0, 1.0, 1000, 16, 0.0, false, false, false)
								RemoveAnimDict(dict)
								Wait(1000)

								TriggerServerEvent('esx:onPickup', pickupId)
								PlaySoundFrontend(-1, 'PICK_UP', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
							end
						end

						label = ('%s~n~%s'):format(label, TranslateCap('threw_pickup_prompt'))
					end

					ESX.Game.Utils.DrawText3D({
						x = pickup.coords.x,
						y = pickup.coords.y,
						z = pickup.coords.z + 0.25
					}, label, 1.2, 1)
				elseif pickup.inRange then
					pickup.inRange = false
				end
			end
			Wait(Sleep)
		end
	end)
end

----- Admin commnads from esx_adminplus

RegisterNetEvent("esx:tpm")
AddEventHandler("esx:tpm", function()
	local GetEntityCoords = GetEntityCoords
	local GetGroundZFor_3dCoord = GetGroundZFor_3dCoord
	local GetFirstBlipInfoId = GetFirstBlipInfoId
	local DoesBlipExist = DoesBlipExist
	local DoScreenFadeOut = DoScreenFadeOut
	local GetBlipInfoIdCoord = GetBlipInfoIdCoord
	local GetVehiclePedIsIn = GetVehiclePedIsIn

	ESX.TriggerServerCallback("esx:isUserAdmin", function(admin)
		if not admin then
			return
		end
		local blipMarker = GetFirstBlipInfoId(8)
		if not DoesBlipExist(blipMarker) then
			ESX.ShowNotification(TranslateCap('tpm_nowaypoint'), true, false, 140)
			return 'marker'
		end

		-- Fade screen to hide how clients get teleported.
		DoScreenFadeOut(650)
		while not IsScreenFadedOut() do
			Wait(0)
		end

		local ped, coords = ESX.PlayerData.ped, GetBlipInfoIdCoord(blipMarker)
		local vehicle = GetVehiclePedIsIn(ped, false)
		local oldCoords = GetEntityCoords(ped)

		-- Unpack coords instead of having to unpack them while iterating.
		-- 825.0 seems to be the max a player can reach while 0.0 being the lowest.
		local x, y, groundZ, Z_START = coords['x'], coords['y'], 850.0, 950.0
		local found = false
		FreezeEntityPosition(vehicle > 0 and vehicle or ped, true)

		for i = Z_START, 0, -25.0 do
			local z = i
			if (i % 2) ~= 0 then
				z = Z_START - i
			end

			NewLoadSceneStart(x, y, z, x, y, z, 50.0, 0)
			local curTime = GetGameTimer()
			while IsNetworkLoadingScene() do
				if GetGameTimer() - curTime > 1000 then
					break
				end
				Wait(0)
			end
			NewLoadSceneStop()
			SetPedCoordsKeepVehicle(ped, x, y, z)

			while not HasCollisionLoadedAroundEntity(ped) do
				RequestCollisionAtCoord(x, y, z)
				if GetGameTimer() - curTime > 1000 then
					break
				end
				Wait(0)
			end

			-- Get ground coord. As mentioned in the natives, this only works if the client is in render distance.
			found, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
			if found then
				Wait(0)
				SetPedCoordsKeepVehicle(ped, x, y, groundZ)
				break
			end
			Wait(0)
		end

		-- Remove black screen once the loop has ended.
		DoScreenFadeIn(650)
		FreezeEntityPosition(vehicle > 0 and vehicle or ped, false)

		if not found then
			-- If we can't find the coords, set the coords to the old ones.
			-- We don't unpack them before since they aren't in a loop and only called once.
			SetPedCoordsKeepVehicle(ped, oldCoords['x'], oldCoords['y'], oldCoords['z'] - 1.0)
			ESX.ShowNotification(TranslateCap('tpm_success'), true, false, 140)
		end

		-- If Z coord was found, set coords in found coords.
		SetPedCoordsKeepVehicle(ped, x, y, groundZ)
		ESX.ShowNotification(TranslateCap('tpm_success'), true, false, 140)
	end)
end)

local noclip = false
local noclip_pos = vector3(0, 0, 70)
local heading = 0

local function noclipThread()
	while noclip do
		SetEntityCoordsNoOffset(ESX.PlayerData.ped, noclip_pos.x, noclip_pos.y, noclip_pos.z, 0, 0, 0)

		if IsControlPressed(1, 34) then
			heading = heading + 1.5
			if heading > 360 then
				heading = 0
			end

			SetEntityHeading(ESX.PlayerData.ped, heading)
		end

		if IsControlPressed(1, 9) then
			heading = heading - 1.5
			if heading < 0 then
				heading = 360
			end

			SetEntityHeading(ESX.PlayerData.ped, heading)
		end

		if IsControlPressed(1, 8) then
			noclip_pos = GetOffsetFromEntityInWorldCoords(ESX.PlayerData.ped, 0.0, 1.0, 0.0)
		end

		if IsControlPressed(1, 32) then
			noclip_pos = GetOffsetFromEntityInWorldCoords(ESX.PlayerData.ped, 0.0, -1.0, 0.0)
		end

		if IsControlPressed(1, 27) then
			noclip_pos = GetOffsetFromEntityInWorldCoords(ESX.PlayerData.ped, 0.0, 0.0, 1.0)
		end

		if IsControlPressed(1, 173) then
			noclip_pos = GetOffsetFromEntityInWorldCoords(ESX.PlayerData.ped, 0.0, 0.0, -1.0)
		end
		Wait(0)
	end
end

RegisterNetEvent("esx:noclip")
AddEventHandler("esx:noclip", function(input)
	ESX.TriggerServerCallback("esx:isUserAdmin", function(admin)
		if not admin then
			return
		end

		if not noclip then
			noclip_pos = GetEntityCoords(ESX.PlayerData.ped, false)
			heading = GetEntityHeading(ESX.PlayerData.ped)
		end

		noclip = not noclip
		if noclip then
			CreateThread(noclipThread)
		end

		ESX.ShowNotification(TranslateCap('noclip_message', noclip and "enabled" or "disabled"), true, false, 140)
	end)
end)

RegisterNetEvent("esx:killPlayer")
AddEventHandler("esx:killPlayer", function()
  SetEntityHealth(ESX.PlayerData.ped, 0)
end)

RegisterNetEvent("esx:freezePlayer")
AddEventHandler("esx:freezePlayer", function(input)
    local player = PlayerId()
    if input == 'freeze' then
        SetEntityCollision(ESX.PlayerData.ped, false)
        FreezeEntityPosition(ESX.PlayerData.ped, true)
        SetPlayerInvincible(player, true)
    elseif input == 'unfreeze' then
        SetEntityCollision(ESX.PlayerData.ped, true)
		FreezeEntityPosition(ESX.PlayerData.ped, false)
        SetPlayerInvincible(player, false)
    end
end)

RegisterNetEvent("esx:GetVehicleType", function(Model, Request)
	if not IsModelInCdimage(Model) then
      return TriggerServerEvent("esx:ReturnVehicleType", false, Request)
  end

	if Model == `submersible` or Model == `submersible2` then
		  return TriggerServerEvent("esx:ReturnVehicleType", "submarine", Request)
	end

	local VehicleType = GetVehicleClassFromName(Model)
	local types = {
		[8] = "bike",
		[11] = "trailer",
		[13] = "bike",
		[14] = "boat",
		[15] = "heli",
		[16] = "plane",
		[21] = "train",
	}

	TriggerServerEvent("esx:ReturnVehicleType", types[VehicleType] or "automobile", Request)
end)

local DoNotUse = {
	'essentialmode',
	'es_admin2',
	'basic-gamemode',
	'mapmanager',
	'fivem-map-skater',
	'fivem-map-hipster',
	'qb-core',
	'default_spawnpoint',
}

for i=1, #DoNotUse do
	if GetResourceState(DoNotUse[i]) == 'started' or GetResourceState(DoNotUse[i]) == 'starting' then
		print("[^1ERROR^7] YOU ARE USING A RESOURCE THAT WILL BREAK ^1ESX^7, PLEASE REMOVE ^5"..DoNotUse[i].."^7")
	end
end
