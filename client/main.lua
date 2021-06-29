ESX = exports['es_extended']:getSharedObject()
if ESX.GetConfig().Multichar then

	Citizen.CreateThread(function()
		while not ESX.PlayerLoaded do
			Citizen.Wait(0)
			if NetworkIsPlayerActive(PlayerId()) then
				exports.spawnmanager:setAutoSpawn(false)
				DoScreenFadeOut(0)
				while not GetResourceState('esx_menu_default') == 'started' do 
					Citizen.Wait(0)
				end
				TriggerEvent("esx_multicharacter:SetupCharacters")
				break
			end
		end
	end)


	local canRelog, cam, Spawned = true
	local Characters =  {}

	RegisterNetEvent('esx_multicharacter:SetupCharacters')
	AddEventHandler('esx_multicharacter:SetupCharacters', function()
		ESX.PlayerLoaded = false
		ESX.PlayerData = {}
		Spawned = false
		cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.Spawn.x, Config.Spawn.y+1.6, Config.Spawn.z+1.3, 0.0, 0.0, 180.0, 100.00, false, 0)
		SetEntityCoords(PlayerPedId(), Config.Spawn.x, Config.Spawn.y, Config.Spawn.z, true, false, false, false)
		SetEntityHeading(PlayerPedId(), Config.Spawn.w)
		DoScreenFadeOut(0)
		SetCamActive(cam, true)
		RenderScriptCams(true, false, 1, true, true)
		ESX.UI.HUD.SetDisplay(0.0)
		StartLoop()
		ShutdownLoadingScreen()
		ShutdownLoadingScreenNui()
		TriggerEvent('esx:loadingScreenOff')
		Citizen.Wait(200)
		TriggerServerEvent("esx_multicharacter:SetupCharacters")
	end)

	StartLoop = function()
		hidePlayers = true
		MumbleSetVolumeOverride(PlayerId(), 0.0)
		Citizen.CreateThread(function()
			local keys = {18, 27, 172, 173, 174, 175, 176, 177, 187, 188, 191, 201, 108, 109}
			while hidePlayers do
				DisableAllControlActions(0)
				for i=1, #keys do
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
				Citizen.Wait(3)
				local vehicles = GetGamePool('CVehicle')
				for i=1, #vehicles do
					SetEntityLocallyInvisible(vehicles[i])
				end
			end
			local playerId, playerPed = PlayerId(), PlayerPedId()
			MumbleSetVolumeOverride(playerId, -1.0)
			SetEntityVisible(playerPed, 1, 0)
			SetPlayerInvincible(playerId, 0)
			FreezeEntityPosition(playerPed, false)
			Citizen.Wait(10000)
			canRelog = true
		end)
		Citizen.CreateThread(function()
			local playerPool = {}
			while hidePlayers do
				local players = GetActivePlayers()
				for i=1, #players do
					local player = players[i]
					if player ~= PlayerId() and not playerPool[player] then
						playerPool[player] = true
						NetworkConcealPlayer(players[player], true, true)
					end
				end
				Citizen.Wait(500)
			end
			for i=1, #playerPool do
				NetworkConcealPlayer(playerPool[i], false, false)
			end
		end)
	end

	SetupCharacter = function(index)
		if Spawned == false then
			exports.spawnmanager:spawnPlayer({
				x = Config.Spawn.x,
				y = Config.Spawn.y,
				z = Config.Spawn.z,
				heading = Config.Spawn.w,
				model = Characters[index].model or `mp_m_freemode_01`,
				skipFade = true
			}, function()
				canRelog = false
				if Characters[index] then
					local skin = Characters[index].skin or Config.Default
					if not Characters[index].model then
						if Characters[index].sex == _('female') then skin.sex = 1 else skin.sex = 0 end
					end
					TriggerEvent('skinchanger:loadSkin', skin)
				end
				DoScreenFadeIn(400)
				while IsScreenFadedOut() do Citizen.Wait(100) end
			end)
			
		elseif Characters[index] and Characters[index].skin then
			if Characters[Spawned] and Characters[Spawned].model then
				RequestModel(Characters[index].model)
				while not HasModelLoaded(Characters[index].model) do
					RequestModel(Characters[index].model)
					Citizen.Wait(0)
				end
				SetPlayerModel(PlayerId(), Characters[index].model)
				SetModelAsNoLongerNeeded(Characters[index].model)
			end
			TriggerEvent('skinchanger:loadSkin', Characters[index].skin)
		end
		Spawned = index
		local playerPed = PlayerPedId()
		FreezeEntityPosition(PlayerPedId(), true)
		SetPedAoBlobRendering(playerPed, true)
		SetEntityAlpha(playerPed, 255)
		SendNUIMessage({
			action = "openui",
			character = Characters[Spawned]
		})
	end
	
	RegisterNetEvent('esx_multicharacter:SetupUI')
	AddEventHandler('esx_multicharacter:SetupUI', function(data)
		DoScreenFadeOut(0)
		Characters = data
		local elements = {}
		local Character = next(Characters)

		if Character == nil then
			SendNUIMessage({
				action = "closeui"
			})
			exports.spawnmanager:spawnPlayer({
				x = Config.Spawn.x,
				y = Config.Spawn.y,
				z = Config.Spawn.z,
				heading = Config.Spawn.w,
				model = `mp_m_freemode_01`,
				skipFade = true
			}, function()
				canRelog = false
				DoScreenFadeIn(400)
				Citizen.Wait(400)
				local playerPed = PlayerPedId()
				SetPedAoBlobRendering(playerPed, false)
				SetEntityAlpha(playerPed, 0)
				TriggerServerEvent('esx_multicharacter:CharacterChosen', 1, true)
				TriggerEvent('esx_identity:showRegisterIdentity')
			end)
		else
			for k,v in pairs(Characters) do
				if not v.model and v.skin then
					if v.skin.model then v.model = v.skin.model elseif v.skin.sex == 1 then v.model =  `mp_f_freemode_01` else v.model = `mp_m_freemode_01` end
				end
				if Spawned == false then SetupCharacter(Character) end
				local label = v.firstname..' '..v.lastname
				elements[#elements+1] = {label = label, value = v.id}
			end
			if #elements < Config.Slots then
				elements[#elements+1] = {label = _('create_char'), value = (#elements+1), new = true}
			end
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'selectchar', {
				title    = _('select_char'),
				align    = 'top-left',
				elements = elements
			}, function(data, menu)
				local elements = {}
				if not data.current.new then
					elements[1] = {label = _('char_play'), action = 'play', value = data.current.value}
					elements[2] = {label = _('char_delete'), action = 'delete', value = data.current.value}
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'choosechar', {
						title = _('select_char'),
						align = 'top-left',
						elements = elements
					}, function(data, menu)
						if data.current.action == 'play' then
							ESX.UI.Menu.CloseAll()
							SendNUIMessage({
								action = "closeui"
							})
							TriggerServerEvent('esx_multicharacter:CharacterChosen', data.current.value, false)
						else
							local elements2 = {}
							elements2[1] = {label = _('cancel')}
							elements2[2] = {label = _('confirm'), value = data.current.value}
							ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'deletechar', {
								title = _('delete_label', Characters[data.current.value].firstname, Characters[data.current.value].lastname),
								align = 'center',
								elements = elements2
							}, function(data, menu)
								if data.current.value then
									TriggerServerEvent('esx_multicharacter:DeleteCharacter', data.current.value)
									Spawned = false
									ESX.UI.Menu.CloseAll()
								else
									menu.close()
								end
							end, function(data, menu)
								menu.close()
							end)
						end
					end, function(data, menu)
						menu.close()
					end)
				else
					ESX.UI.Menu.CloseAll()
					local GetSlot = function()
						for i=1, Config.Slots do
							if not Characters[i] then
								return i
							end
						end
					end
					local slot = GetSlot()
					TriggerServerEvent('esx_multicharacter:CharacterChosen', slot, true)
					TriggerEvent('esx_identity:showRegisterIdentity')
				end		
			end, function(data, menu)
				menu.refresh()
			end, function(data, menu)
				if data.current.new then
					local playerPed = PlayerPedId()
					SetPedAoBlobRendering(playerPed, false)
					SetEntityAlpha(playerPed, 0)
					SendNUIMessage({
						action = "closeui"
					})
				else
					SetupCharacter(data.current.value)
					local playerPed = PlayerPedId()
					SetPedAoBlobRendering(playerPed, true)
					ResetEntityAlpha(playerPed)
				end
			end)
		end
	end)

	RegisterNetEvent('esx:playerLoaded')
	AddEventHandler('esx:playerLoaded', function(playerData, isNew, skin)
		DoScreenFadeOut(100)
		local spawn = playerData.coords
		local playerPed = PlayerPedId()
		FreezeEntityPosition(playerPed, true)
		SetEntityCoords(playerPed, spawn.x, spawn.y, spawn.z-1.3, true, false, false, false)
		SetEntityHeading(playerPed, spawn.heading)
		Citizen.Wait(300)
		SetCamActive(cam, false)
		RenderScriptCams(0, 0)
		DestroyAllCams(true)
		DoScreenFadeIn(400)
		Citizen.Wait(400)

		if isNew or not skin or #skin == 1 then
			local sex = skin.sex or 0
			if sex == 0 then model = `mp_m_freemode_01` else model = `mp_f_freemode_01` end
			RequestModel(model)
			while not HasModelLoaded(model) do
				RequestModel(model)
				Citizen.Wait(0)
			end
			SetPlayerModel(PlayerId(), model)
			SetModelAsNoLongerNeeded(model)
			skin = Config.Default
			skin.sex = sex
			TriggerEvent('skinchanger:loadSkin', skin, function()
				playerPed = PlayerPedId()
				SetPedAoBlobRendering(playerPed, true)
				ResetEntityAlpha(playerPed)
				TriggerEvent('esx_skin:openSaveableMenu', function()
					finished = true end, function() finished = true
				end)
				SetEntityHeading(playerPed, spawn.heading)
			end)
			while not finished do Citizen.Wait(200) end
		else
			local playerPed = PlayerPedId()
			SetEntityHeading(playerPed, spawn.heading)
			TriggerEvent('skinchanger:loadSkin', skin or Characters[Spawned].skin)
			playerPed = PlayerPedId()
			SetEntityVisible(playerPed, true, 0)
		end
		TriggerServerEvent('esx:onPlayerSpawn')
		TriggerEvent('esx:onPlayerSpawn')
		TriggerEvent('playerSpawned')
		TriggerEvent('esx:restoreLoadout')
		Characters, hidePlayers = {}, false
	end)

	RegisterNetEvent('esx:onPlayerLogout')
	AddEventHandler('esx:onPlayerLogout', function()
		DoScreenFadeOut(0)
		Spawned = false
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
