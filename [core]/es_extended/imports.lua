ESX = exports['es_extended']:getSharedObject()

if not IsDuplicityVersion() then -- Only register this event for the client
    AddEventHandler('esx:setPlayerData', function(key, val, last)
        if GetInvokingResource() == 'es_extended' then
            ESX.PlayerData[key] = val
            if OnPlayerData then
                OnPlayerData(key, val, last)
            end
        end
    end)

    RegisterNetEvent('esx:playerLoaded', function(xPlayer)
        ESX.PlayerData = xPlayer
        ESX.PlayerLoaded = true
    end)

    RegisterNetEvent('esx:onPlayerLogout', function()
        ESX.PlayerLoaded = false
        ESX.PlayerData = {}
    end)
end
