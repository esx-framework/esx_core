Core = {}
Core.Input = {}
Core.Events = {}

ESX.playerId = PlayerId()
ESX.serverId = GetPlayerServerId(ESX.playerId)

if not Config.Multichar then
    CreateThread(function()
        while true do
            Wait(100)

            if NetworkIsPlayerActive(ESX.playerId) then
                ESX.DisableSpawnManager()
                DoScreenFadeOut(0)
                Wait(500)
                TriggerServerEvent("esx:onPlayerJoined")
                break
            end
        end
    end)
end
