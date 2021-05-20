ESX = exports['es_extended']:getSharedObject()
if ESX.GetConfig().Multichar then

	Citizen.CreateThread(function()
		while NetworkIsPlayerActive(PlayerId()) and not ESX.IsPlayerLoaded() do
			Citizen.Wait(5)
			DoScreenFadeOut(0)
			TriggerServerEvent("esx_multicharacter:SetupCharacters")
			TriggerEvent("esx_multicharacter:SetupCharacters")
			break
		end
	end)

	AddEventHandler("onClientMapStart", function()
		exports.spawnmanager:setAutoSpawn(false)
	end)

	local cam, cam2 = nil, nil
	local Characters =  {}
	local Spawned

	RegisterNetEvent('esx_multicharacter:SetupCharacters')
	AddEventHandler('esx_multicharacter:SetupCharacters', function()
		ESX.PlayerLoaded = false
		ESX.PlayerData = {}
		Spawned = false
		ESX.UI.HUD.SetDisplay(0.0)
		DisplayHud(false)
		DisplayRadar(false)
		StartLoop()
		ShutdownLoadingScreen()
		ShutdownLoadingScreenNui()
		TriggerEvent('esx:loadingScreenOff')
		cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.Spawn.x, Config.Spawn.y+1.6, Config.Spawn.z+0.5, 0.0, 0.0, 180.0, 100.00, false, 0)
		SetCamActive(cam, true)
		RenderScriptCams(true, false, 1, true, true)
		SetPlayerControl(PlayerId(), false, false)
	end)

	StartLoop = function()
		Citizen.CreateThread(function()
			while true do
				if hidePlayers == false then break end
				local players = GetActivePlayers()
				for i=1, #players do
					if players[i] ~= PlayerId() then NetworkConcealPlayer(players[i], true, true) end
				end
				Citizen.Wait(500)
			end
			local players = GetActivePlayers()
			for i=1, #players do
				if players[i] ~= PlayerId() then NetworkConcealPlayer(players[i], false, false) end
			end
		end)
	end

	SetupCharacter = function(index)
		if Spawned == false then
			exports.spawnmanager:forceRespawn()
			exports.spawnmanager:spawnPlayer({
				x = Config.Spawn.x,
				y = Config.Spawn.y,
				z = Config.Spawn.z,
				heading = Config.Spawn.w,
				model = Characters[index].model or `mp_m_freemode_01`,
				skipFade = true
			}, function()
				if Characters[index] then TriggerEvent('skinchanger:loadSkin', Characters[index].skin) end
			end)
		elseif Characters[index] and Characters[index].skin then
			if Characters[Spawned] and Characters[Spawned].model ~= Characters[index].model then
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
		FreezeEntityPosition(PlayerPedId(), true)
		Spawned = index
		SendNUIMessage({
			action = "openui",
			character = Characters[index]
		})
	end

	LoadPed = function(isNew, skin)
		if isNew then
			if skin.sex == 0 then isMale = true else isMale = false end
			TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
				TriggerEvent('skinchanger:loadSkin', {sex = skin.sex})
				Citizen.Wait(500)
				TriggerEvent('esx_skin:openSaveableMenu')
			end)
		else TriggerEvent('skinchanger:loadSkin', skin) Citizen.Wait(500) end
	end
	
	RegisterNetEvent('esx_multicharacter:SetupUI')
	AddEventHandler('esx_multicharacter:SetupUI', function(data)
		if data then Characters = data end
		local elements = {}

		if #Characters == 0 then
			exports.spawnmanager:spawnPlayer({
				x = Config.Spawn.x,
				y = Config.Spawn.y,
				z = Config.Spawn.z,
				heading = Config.Spawn.w,
				model = `mp_m_freemode_01`,
				skipFade = true
			}, function()
				local playerPed = PlayerPedId()
				SetPedAoBlobRendering(playerPed, false)
				SetEntityAlpha(playerPed, 0)
				TriggerServerEvent('esx_multicharacter:CharacterChosen', 1, true)
				TriggerEvent('esx_identity:showRegisterIdentity')
			end)
		else
			for i=1, #Characters+1 do
				if Characters[i] then
					if Spawned == false then SetupCharacter(i) end
					local label = Characters[i].firstname..' '..Characters[i].lastname
					if Characters[i].sex == 'Female' then Characters[i].model = `mp_f_freemode_01` else Characters[i].model = `mp_m_freemode_01` end
					elements[#elements+1] = {label = label, value = Characters[i].id, new = false}
				else elements[#elements+1] = {label = _('create_char'), new = true} end
			end
		
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'selectchar', {
				title    = _('select_char'),
				align    = 'top-left',
				elements = elements
			}, function(data, menu)
				local elements = { }
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
							DoScreenFadeOut(300)
							SendNUIMessage({
								action = "closeui"
							})
							TriggerServerEvent('esx_multicharacter:CharacterChosen', data.current.value, false)
							Citizen.Wait(300)
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
									table.remove(Characters, data.current.value)
									ESX.UI.Menu.CloseAll()
									TriggerServerEvent('esx_multicharacter:SetupCharacters')
									Citizen.Wait(100)
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
						for i=1, #Characters+1 do
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
					SetEntityAlpha(playerPed, 255)
				end
			end)
		end
	end)

	RegisterNetEvent('esx_multicharacter:SpawnCharacter')
	AddEventHandler('esx_multicharacter:SpawnCharacter', function(spawn, isNew, skin)
		DoScreenFadeOut(0)
		Citizen.Wait(300)
		local playerPed = PlayerPedId()
		cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", spawn.x,spawn.y,spawn.z+200, 0.0, 0.0, 0.0, 100.00, false, 0)
		PointCamAtCoord(cam2, spawn.x,spawn.y,spawn.z+10)
		SetCamActiveWithInterp(cam2, cam, 400, true, true)

		Citizen.Wait(700)
		DoScreenFadeIn(500)
		FreezeEntityPosition(playerPed, true)
		SetEntityVisible(playerPed, true, 0)
		SetEntityCoords(playerPed, spawn.x, spawn.y, spawn.z, true, false, false, false)

		cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", spawn.x,spawn.y,spawn.z+10, GetEntityRotation(playerPed), 100.00, false, 0)
		PointCamAtCoord(cam, spawn.x,spawn.y,spawn.z+2)
		SetCamActiveWithInterp(cam, cam2, 2700, true, true)

		PlaySoundFrontend(-1, "Zoom_Out", "DLC_HEIST_PLANNING_BOARD_SOUNDS", 1)
		Citizen.Wait(1000)
		LoadPed(isNew, skin)
		playerPed = PlayerPedId()
		TriggerServerEvent('esx:onPlayerSpawn')
		TriggerEvent('esx:onPlayerSpawn')
		TriggerEvent('playerSpawned')
		RenderScriptCams(false, true, 500, true, true)
		PlaySoundFrontend(-1, "CAR_BIKE_WHOOSH", "MP_LOBBY_SOUNDS", 1)
		SetCamActive(cam, false)
		DestroyCam(cam, true)
		DisplayHud(true)
		DisplayRadar(true)
		FreezeEntityPosition(playerPed, false)
		SetPlayerControl(PlayerId(), true, false)
		SetEntityHeading(playerPed, spawn.heading)
		hidePlayers = false
	end)

	RegisterNetEvent('esx:onPlayerLogout')
	AddEventHandler('esx:onPlayerLogout', function()
		DoScreenFadeOut(0)
		Spawned = false
		TriggerServerEvent("esx_multicharacter:SetupCharacters")
		TriggerEvent("esx_multicharacter:SetupCharacters")
		TriggerEvent('esx_skin:resetFirstSpawn')
	end)

end
