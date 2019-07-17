ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(200)
        TriggerEvent('esx:getSharedObject', function (obj) ESX = obj end)
    end
end)

-- This Code Was changed to fix error With player spawner as default --
-- Link to the post with the error fix --
-- https://forum.fivem.net/t/release-esx-kashacters-multi-character/251613/316?u=xxfri3ndlyxx --
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if NetworkIsSessionStarted() then
            Citizen.Wait(100)
            TriggerServerEvent("kashactersS:SetupCharacters")
            TriggerEvent("kashactersC:SetupCharacters")
            return -- break the loop
        end
    end
end)

local IsChoosing = true
Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(0)
        if IsChoosing then
            DisplayHud(false)
            DisplayRadar(false)
        end
    end
end)
local cam = nil
local cam2 = nil
RegisterNetEvent('kashactersC:SetupCharacters')
AddEventHandler('kashactersC:SetupCharacters', function()
    DoScreenFadeOut(10)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
    SetTimecycleModifier('hud_def_blur')
    FreezeEntityPosition(GetPlayerPed(-1), true)
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
AddEventHandler('kashactersC:SpawnCharacter', function(spawn, isnew)
    TriggerServerEvent('es:firstJoinProper')
    TriggerEvent('es:allowedToSpawn')

    SetTimecycleModifier('default')
    local pos = spawn
    SetEntityCoords(GetPlayerPed(-1), pos.x, pos.y, pos.z)
    DoScreenFadeIn(500)
    Citizen.Wait(500)
    cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", -1355.93,-1487.78,520.75, 300.00,0.00,0.00, 100.00, false, 0)
    PointCamAtCoord(cam2, pos.x,pos.y,pos.z+200)
    SetCamActiveWithInterp(cam2, cam, 900, true, true)
    Citizen.Wait(900)
    exports.spawnmanager:setAutoSpawn(false)
    TriggerEvent('esx_ambulancejob:multicharacter', source)
	
 if isnew then
	TriggerEvent('esx_identity:showRegisterIdentity')
 end

    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x,pos.y,pos.z+200, 300.00,0.00,0.00, 100.00, false, 0)
    PointCamAtCoord(cam, pos.x,pos.y,pos.z+2)
    SetCamActiveWithInterp(cam, cam2, 3700, true, true)
    Citizen.Wait(3700)
    PlaySoundFrontend(-1, "Zoom_Out", "DLC_HEIST_PLANNING_BOARD_SOUNDS", 1)
    RenderScriptCams(false, true, 500, true, true)
    PlaySoundFrontend(-1, "CAR_BIKE_WHOOSH", "MP_LOBBY_SOUNDS", 1)
    FreezeEntityPosition(GetPlayerPed(-1), false)
    Citizen.Wait(500)
    SetCamActive(cam, false)
    DestroyCam(cam, true)
    IsChoosing = false
    DisplayHud(true)
    DisplayRadar(true)
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
