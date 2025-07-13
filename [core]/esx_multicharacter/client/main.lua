local nuiReady = false

CreateThread(function()
    while not ESX.PlayerLoaded do
        Wait(100)

        if NetworkIsPlayerActive(ESX.playerId) then
            ESX.DisableSpawnManager()
            DoScreenFadeOut(0)
            Multicharacter:SetupCharacters()
            break
        end
    end
end)

-- Events

ESX.SecureNetEvent("esx_multicharacter:SetupUI", function(data, slots)
    if not nuiReady then
        print('[WARNING]', 'NUI not ready yet, awaiting...')
        ESX.Await(function()
            return nuiReady == true
        end, 'NUI Failed to load after 10000ms', 10000)
    end
    Multicharacter:SetupUI(data, slots)
end)

RegisterNetEvent('esx:playerLoaded', function(playerData, isNew, skin)
    Multicharacter:PlayerLoaded(playerData, isNew, skin)
end)

ESX.SecureNetEvent('esx:onPlayerLogout', function()
    DoScreenFadeOut(500)
    Wait(5000)

    Multicharacter.spawned = false

    Multicharacter:SetupCharacters()
    TriggerEvent("esx_skin:resetFirstSpawn")
end)

-- Relog

if Config.Relog then
    RegisterCommand("relog", function()
        if Multicharacter.canRelog then
            Multicharacter.canRelog = false
            TriggerServerEvent("esx_multicharacter:relog")

            ESX.SetTimeout(10000, function()
                Multicharacter.canRelog = true
            end)
        end
    end, false)
end

RegisterNuiCallback('nuiReady', function(_, cb)
    nuiReady = true
    cb(1)
end)