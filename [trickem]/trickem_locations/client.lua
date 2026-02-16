local ESX = exports["es_extended"]:getSharedObject()
local blips = {}

-- Create all map blips
Citizen.CreateThread(function()
    for _, blipData in ipairs(Config.Blips) do
        local blip = AddBlipForCoord(blipData.coords.x, blipData.coords.y, blipData.coords.z)
        SetBlipSprite(blip, blipData.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, blipData.scale)
        SetBlipColour(blip, blipData.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipData.name)
        EndTextCommandSetBlipName(blip)

        table.insert(blips, blip)
    end
end)

-- Spawn ambient NPCs
Citizen.CreateThread(function()
    for _, npcData in ipairs(Config.NPCLocations) do
        local modelHash = GetHashKey(npcData.model)
        RequestModel(modelHash)

        local timeout = 0
        while not HasModelLoaded(modelHash) and timeout < 50 do
            Citizen.Wait(100)
            timeout = timeout + 1
        end

        if HasModelLoaded(modelHash) then
            local ped = CreatePed(4, modelHash, npcData.coords.x, npcData.coords.y, npcData.coords.z, npcData.coords.w, false, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            FreezeEntityPosition(ped, true)

            if npcData.scenario then
                TaskStartScenarioInPlace(ped, npcData.scenario, 0, true)
            end

            SetModelAsNoLongerNeeded(modelHash)
        end
    end
end)

-- Welcome message when player spawns
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    Citizen.Wait(5000)
    ESX.ShowNotification("~o~Welcome to TrickEm City~s~ - The year is 1975. Stay groovy!")
    Citizen.Wait(3000)
    ESX.ShowNotification("~y~Press F7~s~ to toggle the HUD")
end)

-- Cleanup blips on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, blip in ipairs(blips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
    end
end)
