local IsChoosing = true

-- This Code Was changed to fix error With player spawner as default --
-- Link to the post with the error fix --
-- https://forum.fivem.net/t/release-esx-kashacters-multi-character/251613/316?u=xxfri3ndlyxx --
CreateThread(function()
	while true do
		Wait(0)
		if NetworkIsPlayerActive(PlayerId()) and not ESX.IsPlayerLoaded() then
			TriggerServerEvent("kashactersS:SetupCharacters")
			TriggerEvent("kashactersC:SetupCharacters")
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

RegisterNetEvent('kashactersC:SetupCharacters')
AddEventHandler('kashactersC:SetupCharacters', function()
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

RegisterNetEvent('kashactersC:SetupUI')
AddEventHandler('kashactersC:SetupUI', function(Characters)
    DoScreenFadeIn(500)
    Citizen.Wait(500)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openui",
        characters = Characters,
    })
end)

RegisterNetEvent('kashactersC:SpawnCharacter')
AddEventHandler('kashactersC:SpawnCharacter', function(spawn, skin)
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
		TriggerServerEvent('esx:onPlayerSpawn')
		TriggerEvent('esx:onPlayerSpawn')
		TriggerEvent('playerSpawned') -- compatibility with old scripts, will be removed soon.

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
		FreezeEntityPosition(PlayerPedId(), false)

		Citizen.Wait(500)

		SetCamActive(cam, false)
		DestroyCam(cam, true)
		IsChoosing = false
		if skin then
			TriggerEvent('skinchanger:loadSkin', skin)
		else
			-- New character
		end
		DisplayHud(true)
		DisplayRadar(true)
		ESX.UI.HUD.SetDisplay(1.0)
	end)
end)

RegisterNetEvent('kashactersC:ReloadCharacters')
AddEventHandler('kashactersC:ReloadCharacters', function()
    TriggerServerEvent("kashactersS:SetupCharacters")
    TriggerEvent("kashactersC:SetupCharacters")
end)

RegisterNUICallback("CharacterChosen", function(data, cb)
    SetNuiFocus(false,false)
    DoScreenFadeOut(500)
    TriggerServerEvent('kashactersS:CharacterChosen', data.charid, data.ischar)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
    cb("ok")
end)

RegisterNUICallback("DeleteCharacter", function(data, cb)
    SetNuiFocus(false,false)
    DoScreenFadeOut(500)
    TriggerServerEvent('kashactersS:DeleteCharacter', data.charid)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
    cb("ok")
end)
