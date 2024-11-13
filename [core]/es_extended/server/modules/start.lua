SetMapName(Config.MapName or "San Andreas")
SetGameType(Config.GameType or "ESX-Framework")

Core.BlacklistedScripts = {
    ["essentialmode"] = true,
    ["es_admin2"] = true,
    ["basic-gamemode"] = true,
    ["mapmanager"] = true,
    ["fivem-map-skater"] = true,
    ["fivem-map-hipster"] = true,
    ["qb-core"] = true,
    ["default_spawnpoint"] = true,
}

AddEventHandler("onResourceStart", function(key)
    if Core.BlacklistedScripts[string.lower(key)] then
        while GetResourceState(key) ~= "started" do
            Wait(0)
        end

        StopResource(key)
        error(("WE STOPPED A RESOURCE THAT WILL BREAK ^1ESX^1, PLEASE REMOVE ^5%s^1"):format(key))
    end

    if not SetEntityOrphanMode then
        CreateThread(function()
            while true do
                error("ESX Requires a minimum Artifact version of 10188, Please update your server.")
                Wait(60 * 1000)
            end
        end)
    end
end)

AddEventHandler("txAdmin:events:scheduledRestart", function(eventData)
    if eventData.secondsRemaining == 60 then
        CreateThread(function()
            Wait(50000)
            Core.SavePlayers()
        end)
    end
end)

AddEventHandler("txAdmin:events:serverShuttingDown", function()
    Core.SavePlayers()
end)

for key in pairs(Core.BlacklistedScripts) do
    if GetResourceState(key) == "started" or GetResourceState(key) == "starting" then
        StopResource(key)
        error(("WE STOPPED A RESOURCE THAT WILL BREAK ^1ESX^1, PLEASE REMOVE ^5%s^1"):format(key))
    end
end
