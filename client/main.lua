ESX = exports['es_extended']:getSharedObject()
if ESX.GetConfig().Multichar then
	local IsChoosing = true

	CreateThread(function()
		while true do
			Wait(0)
			if NetworkIsPlayerActive(PlayerId()) and not ESX.IsPlayerLoaded() then
				TriggerServerEvent("esx_multicharacter:SetupCharacters")
				TriggerEvent("esx_multicharacter:SetupCharacters")
				break
			end
		end
	end)

	AddEventHandler("onClientMapStart", function()
		exports.spawnmanager:spawnPlayer()
		Citizen.Wait(5000)
		exports.spawnmanager:setAutoSpawn(false)
	end)

	local cam, cam2 = nil, nil

	RegisterNetEvent('esx_multicharacter:SetupCharacters')
	AddEventHandler('esx_multicharacter:SetupCharacters', function()	
		ESX.PlayerLoaded = false
		ESX.PlayerData = {}
		ESX.UI.HUD.SetDisplay(0.0)
		DisplayHud(false)
		DisplayRadar(false)
		ShutdownLoadingScreen()
		Citizen.Wait(100)
		DoScreenFadeOut(10)
		while not IsScreenFadedOut() do
			Citizen.Wait(10)
		end
		SetTimecycleModifier('hud_def_blur')
		FreezeEntityPosition(PlayerPedId(), true)
		cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", -1355.93,-1487.78,520.75, 300.00,0.00,0.00, 100.00, false, 0)
		SetCamActive(cam, true)
		RenderScriptCams(true, false, 1, true, true)
	end)

	RegisterNetEvent('esx_multicharacter:SetupUI')
	AddEventHandler('esx_multicharacter:SetupUI', function(Characters)
		DoScreenFadeIn(500)
		Citizen.Wait(500)
		SetNuiFocus(true, true)
		SendNUIMessage({
			action = "openui",
			characters = Characters,
		})
	end)

	RegisterNetEvent('esx_multicharacter:SpawnCharacter')
	AddEventHandler('esx_multicharacter:SpawnCharacter', function(spawn, isNew, skin)
		local pos = spawn

		SetTimecycleModifier('default')

		exports.spawnmanager:spawnPlayer({
			x = spawn.x,
			y = spawn.y,
			z = spawn.z + 0.25,
			heading = spawn.heading,
			model = `mp_m_freemode_01`,
			skipFade = true
		}, function()
			DoScreenFadeIn(500)

			Citizen.Wait(500)

			cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", -1355.93,-1487.78,520.75, 300.00,0.00,0.00, 100.00, false, 0)
			PointCamAtCoord(cam2, pos.x,pos.y,pos.z+200)
			SetCamActiveWithInterp(cam2, cam, 900, true, true)

			Citizen.Wait(900)

			cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x,pos.y,pos.z+200, 300.00,0.00,0.00, 100.00, false, 0)
			PointCamAtCoord(cam, pos.x,pos.y,pos.z+2)
			SetCamActiveWithInterp(cam, cam2, 3700, true, true)

			Citizen.Wait(3700)

			PlaySoundFrontend(-1, "Zoom_Out", "DLC_HEIST_PLANNING_BOARD_SOUNDS", 1)
			RenderScriptCams(false, true, 500, true, true)
			PlaySoundFrontend(-1, "CAR_BIKE_WHOOSH", "MP_LOBBY_SOUNDS", 1)
			if isNew then
				if skin.sex == 0 then
					TriggerEvent('skinchanger:loadDefaultModel', true)
				else
					TriggerEvent('skinchanger:loadDefaultModel', false)
				end
			elseif skin then TriggerEvent('skinchanger:loadSkin', skin) end

			Citizen.Wait(500)

			FreezeEntityPosition(PlayerPedId(), false)
			TriggerServerEvent('esx:onPlayerSpawn')
			TriggerEvent('esx:onPlayerSpawn')
			TriggerEvent('playerSpawned') -- compatibility with old scripts, will be removed soon.

			SetCamActive(cam, false)
			DestroyCam(cam, true)
			IsChoosing = false

			DisplayHud(true)
			DisplayRadar(true)
		end)
	end)

	RegisterNetEvent('esx_multicharacter:ReloadCharacters')
	AddEventHandler('esx_multicharacter:ReloadCharacters', function()
		TriggerServerEvent("esx_multicharacter:SetupCharacters")
		TriggerEvent("esx_multicharacter:SetupCharacters")
	end)

	RegisterNUICallback("CharacterChosen", function(data, cb)
		SetNuiFocus(false,false)
		DoScreenFadeOut(500)
		TriggerServerEvent('esx_multicharacter:CharacterChosen', data.charid, data.ischar)
		if not data.ischar then TriggerEvent('esx_identity:showRegisterIdentity') end
		while not IsScreenFadedOut() do
			Citizen.Wait(10)
		end
		cb("ok")
	end)

	RegisterNUICallback("DeleteCharacter", function(data, cb)
		SetNuiFocus(false,false)
		DoScreenFadeOut(500)
		TriggerServerEvent('esx_multicharacter:DeleteCharacter', data.charid)
		while not IsScreenFadedOut() do
			Citizen.Wait(10)
		end
		cb("ok")
	end)

	RegisterNetEvent('esx:onPlayerLogout')
	AddEventHandler('esx:onPlayerLogout', function()
		TriggerServerEvent("esx_multicharacter:SetupCharacters")
		TriggerEvent("esx_multicharacter:SetupCharacters")
		TriggerEvent('esx_skin:resetFirstSpawn')
	end)

end
