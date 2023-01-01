local mp_m_freemode_01 = `mp_m_freemode_01`
local mp_f_freemode_01 = `mp_f_freemode_01`
if ESX.GetConfig().Multichar then

	CreateThread(function()
		while not ESX.PlayerLoaded do
			Wait(0)
			if NetworkIsPlayerActive(PlayerId()) then
				exports.spawnmanager:setAutoSpawn(false)
				DoScreenFadeOut(0)
				while not GetResourceState('esx_context') == 'started' do
					Wait(0)
				end
				TriggerEvent("esx_multicharacter:SetupCharacters")
				break
			end
		end
	end)

	local canRelog, cam, spawned = true, nil, nil
	local Characters =  {}

	RegisterNetEvent('esx_multicharacter:SetupCharacters')
	AddEventHandler('esx_multicharacter:SetupCharacters', function()
		ESX.PlayerLoaded = false
		ESX.PlayerData = {}
		spawned = false
		cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
		local playerPed = PlayerPedId()
		SetEntityCoords(playerPed, Config.Spawn.x, Config.Spawn.y, Config.Spawn.z, true, false, false, false)
		SetEntityHeading(playerPed, Config.Spawn.w)
		local offset = GetOffsetFromEntityInWorldCoords(playerPed, 0, 1.7, 0.4)
		DoScreenFadeOut(0)
		SetCamActive(cam, true)
		RenderScriptCams(true, false, 1, true, true)
		SetCamCoord(cam, offset.x, offset.y, offset.z)
		PointCamAtCoord(cam, Config.Spawn.x, Config.Spawn.y, Config.Spawn.z + 1.3)
		ESX.UI.HUD.SetDisplay(0.0)
		StartLoop()
		ShutdownLoadingScreen()
		ShutdownLoadingScreenNui()
		TriggerEvent('esx:loadingScreenOff')
		Wait(200)
		TriggerServerEvent("esx_multicharacter:SetupCharacters")
	end)

	StartLoop = function()
		hidePlayers = true
		MumbleSetVolumeOverride(PlayerId(), 0.0)
		CreateThread(function()
			local keys = {18, 27, 172, 173, 174, 175, 176, 177, 187, 188, 191, 201, 108, 109}
			while hidePlayers do
				DisableAllControlActions(0)
				for i = 1, #keys do
					EnableControlAction(0, keys[i], true)
				end
				SetEntityVisible(PlayerPedId(), 0, 0)
				SetLocalPlayerVisibleLocally(1)
				SetPlayerInvincible(PlayerId(), 1)
				ThefeedHideThisFrame()
				HideHudComponentThisFrame(11)
				HideHudComponentThisFrame(12)
				HideHudComponentThisFrame(21)
				HideHudAndRadarThisFrame()
				Wait(0)
				local vehicles = GetGamePool('CVehicle')
				for i = 1, #vehicles do
					SetEntityLocallyInvisible(vehicles[i])
				end
			end
			local playerId, playerPed = PlayerId(), PlayerPedId()
			MumbleSetVolumeOverride(playerId, -1.0)
			SetEntityVisible(playerPed, 1, 0)
			SetPlayerInvincible(playerId, 0)
			FreezeEntityPosition(playerPed, false)
			Wait(10000)
			canRelog = true
		end)
		CreateThread(function()
			local playerPool = {}
			while hidePlayers do
				local players = GetActivePlayers()
				for i = 1, #players do
					local player = players[i]
					if player ~= PlayerId() and not playerPool[player] then
						playerPool[player] = true
						NetworkConcealPlayer(player, true, true)
					end
				end
				Wait(500)
			end
			for k in pairs(playerPool) do
				NetworkConcealPlayer(k, false, false)
			end
		end)
	end

	SetupCharacter = function(index)
		if spawned == false then
			exports.spawnmanager:spawnPlayer({
				x = Config.Spawn.x,
				y = Config.Spawn.y,
				z = Config.Spawn.z,
				heading = Config.Spawn.w,
				model = Characters[index].model or mp_m_freemode_01,
				skipFade = true
			}, function()
				canRelog = false
				if Characters[index] then
					local skin = Characters[index].skin or Config.Default
					if not Characters[index].model then
						if Characters[index].sex == TranslateCap('female') then skin.sex = 1 else skin.sex = 0 end
					end
					TriggerEvent('skinchanger:loadSkin', skin)
				end
				DoScreenFadeIn(600)
			end)
		repeat Wait(200) until not IsScreenFadedOut()

		elseif Characters[index] and Characters[index].skin then
			if Characters[spawned] and Characters[spawned].model then
				RequestModel(Characters[index].model)
				while not HasModelLoaded(Characters[index].model) do
					RequestModel(Characters[index].model)
					Wait(0)
				end
				SetPlayerModel(PlayerId(), Characters[index].model)
				SetModelAsNoLongerNeeded(Characters[index].model)
			end
			TriggerEvent('skinchanger:loadSkin', Characters[index].skin)
		end
		spawned = index
		local playerPed = PlayerPedId()
		FreezeEntityPosition(PlayerPedId(), true)
		SetPedAoBlobRendering(playerPed, true)
		SetEntityAlpha(playerPed, 255)
		SendNUIMessage({
			action = "openui",
			character = Characters[spawned]
		})
	end

	function CharacterOptions(Characters, slots, SelectedCharacter)
		local elements = {{title = TranslateCap('character', Characters[SelectedCharacter.value].firstname .. " ".. Characters[SelectedCharacter.value].lastname),icon = "fa-regular fa-user", unselectable = true}, 
		{title = TranslateCap('return'), unselectable = false,icon = "fa-solid fa-arrow-left",description = TranslateCap('return_description'), action = "return"}}
		if not Characters[SelectedCharacter.value].disabled then 
			elements[3] = {title = TranslateCap('char_play'), description = TranslateCap('char_play_description'), icon ="fa-solid fa-play",action = 'play', value = SelectedCharacter.value}
		else
			elements[3] = {title = TranslateCap('char_disabled'), value = SelectedCharacter.value, icon ="fa-solid fa-xmark", description = TranslateCap('char_disabled_description'),}
		end
		if Config.CanDelete then elements[4] = {title = TranslateCap('char_delete'),icon ="fa-solid fa-xmark",description = TranslateCap('char_delete_description'), action = 'delete', value = SelectedCharacter.value} end
		ESX.OpenContext("left", elements, function(element, Action)
			if Action.action == "play" then
				SendNUIMessage({
					action = "closeui"
				})
				ESX.CloseContext()
				TriggerServerEvent('esx_multicharacter:CharacterChosen', Action.value, false)
			elseif Action.action == "delete" then
					ESX.CloseContext()
					TriggerServerEvent('esx_multicharacter:DeleteCharacter', Action.value)
					spawned = false
			elseif Action.action == "return" then
				SelectCharacterMenu(Characters, slots)
			end
		end, nil, false)
	end

	function SelectCharacterMenu(Characters, slots)
		local Character = next(Characters)
		local elements = {{title = TranslateCap('select_char') , icon = "fa-solid fa-users", description =  TranslateCap('select_char_description') , unselectable = true}}
		for k,v in pairs(Characters) do
			if not v.model and v.skin then
				if v.skin.model then v.model = v.skin.model elseif v.skin.sex == 1 then v.model = mp_f_freemode_01 else v.model = mp_m_freemode_01 end
			end
			if spawned == false then SetupCharacter(Character) end
			local label = v.firstname..' '..v.lastname
			if Characters[k].disabled then
				elements[#elements+1] = {title = label,icon = "fa-regular fa-user", value = v.id}
			else
				elements[#elements+1] = {title = label,icon = "fa-regular fa-user", value = v.id}
			end
		end
		if #elements - 1 < slots then
			elements[#elements+1] = {title = TranslateCap('create_char'), icon = "fa-solid fa-plus", value = (#elements+1), new = true}
		end

		ESX.OpenContext("left", elements, function(menu, SelectedCharacter)
			if SelectedCharacter.new then
				ESX.CloseContext()
				local GetSlot = function()
					for i = 1, slots do
						if not Characters[i] then
							return i
						end
					end
				end
				local slot = GetSlot()
				TriggerServerEvent('esx_multicharacter:CharacterChosen', slot, true)
				TriggerEvent('esx_identity:showRegisterIdentity')
				local playerPed = PlayerPedId()
					SetPedAoBlobRendering(playerPed, false)
					SetEntityAlpha(playerPed, 0)
					SendNUIMessage({
						action = "closeui"
					})
			else
				CharacterOptions(Characters,slots, SelectedCharacter)
				SetupCharacter(SelectedCharacter.value)
				local playerPed = PlayerPedId()
				SetPedAoBlobRendering(playerPed, true)
				ResetEntityAlpha(playerPed)
			end
		end, nil, false)
	end
	RegisterNetEvent('esx_multicharacter:SetupUI')
	AddEventHandler('esx_multicharacter:SetupUI', function(data, slots)
		DoScreenFadeOut(0)
		Characters = data
		slots = slots
		local Character = next(Characters)
		exports.spawnmanager:forceRespawn()

		if not Character then
			SendNUIMessage({
				action = "closeui"
			})
			exports.spawnmanager:spawnPlayer({
				x = Config.Spawn.x,
				y = Config.Spawn.y,
				z = Config.Spawn.z,
				heading = Config.Spawn.w,
				model = mp_m_freemode_01,
				skipFade = true
			}, function()
				canRelog = false
				DoScreenFadeIn(400)
				Wait(400)
				local playerPed = PlayerPedId()
				SetPedAoBlobRendering(playerPed, false)
				SetEntityAlpha(playerPed, 0)
				TriggerServerEvent('esx_multicharacter:CharacterChosen', 1, true)
				TriggerEvent('esx_identity:showRegisterIdentity')
			end)
		else
			SelectCharacterMenu(Characters, slots)
		end
	end)

	RegisterNetEvent('esx:playerLoaded')
	AddEventHandler('esx:playerLoaded', function(playerData, isNew, skin)
		local spawn = playerData.coords or Config.Spawn
		if isNew or not skin or #skin == 1 then
			local finished = false
			skin = Config.Default[playerData.sex]
			skin.sex = playerData.sex == "m" and 0 or 1
			local model = skin.sex == 0 and mp_m_freemode_01 or mp_f_freemode_01
			RequestModel(model)
			while not HasModelLoaded(model) do
				RequestModel(model)
				Wait(0)
			end
			SetPlayerModel(PlayerId(), model)
			SetModelAsNoLongerNeeded(model)
			TriggerEvent('skinchanger:loadSkin', skin, function()
				local playerPed = PlayerPedId()
				SetPedAoBlobRendering(playerPed, true)
				ResetEntityAlpha(playerPed)
				TriggerEvent('esx_skin:openSaveableMenu', function()
					finished = true end, function() finished = true
				end)
			end)
			repeat Wait(200) until finished
		end
		DoScreenFadeOut(100)

		SetCamActive(cam, false)
		RenderScriptCams(false, false, 0, true, true)
		cam = nil
		local playerPed = PlayerPedId()
		FreezeEntityPosition(playerPed, true)
		SetEntityCoordsNoOffset(playerPed, spawn.x, spawn.y, spawn.z, false, false, false, true)
		SetEntityHeading(playerPed, spawn.heading)
		if not isNew then TriggerEvent('skinchanger:loadSkin', skin or Characters[spawned].skin) end
		Wait(400)
		DoScreenFadeIn(400)
		repeat Wait(200) until not IsScreenFadedOut()
		TriggerServerEvent('esx:onPlayerSpawn')
		TriggerEvent('esx:onPlayerSpawn')
		TriggerEvent('playerSpawned')
		TriggerEvent('esx:restoreLoadout')
		Characters, hidePlayers = {}, false
	end)

	RegisterNetEvent('esx:onPlayerLogout')
	AddEventHandler('esx:onPlayerLogout', function()
		DoScreenFadeOut(500)
		Wait(1000)
		spawned = false
		TriggerEvent("esx_multicharacter:SetupCharacters")
		TriggerEvent('esx_skin:resetFirstSpawn')
	end)

	if Config.Relog then
		RegisterCommand('relog', function(source, args, rawCommand)
			if canRelog == true then
				canRelog = false
				TriggerServerEvent('esx_multicharacter:relog')
				ESX.SetTimeout(10000, function()
					canRelog = true
				end)
			end
		end)
	end

end
