-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

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

local forbiddenResources = {
    ["essentialmode"] = true,
    ["es_admin2"] = true,
    ["basic-gamemode"] = true,
    ["mapmanager"] = true,
    ["fivem-map-skater"] = true,
    ["fivem-map-hipster"] = true,
    ["qb-core"] = true,
    ["default_spawnpoint"] = true,
}

local artifactWarningStarted = false

local function ensureSupportedArtifact()
    -- luacheck: ignore
    if SetEntityOrphanMode or artifactWarningStarted then
        return
    end

    artifactWarningStarted = true
    CreateThread(function()
        while true do
            error("ESX Requires a minimum Artifact version of 10188, Please update your server.")
            Wait(60 * 1000)
        end
    end)
end

local function stopForbiddenResource(resourceName)
    if not forbiddenResources[string.lower(resourceName)] then
        return
    end

    while GetResourceState(resourceName) ~= "started" do
        Wait(0)
    end

    StopResource(resourceName)
    error(("WE STOPPED A RESOURCE THAT WILL BREAK ^1ESX^1, PLEASE REMOVE ^5%s^1"):format(resourceName))
end

AddEventHandler("onResourceStart", function(resourceName)
    stopForbiddenResource(resourceName)
    ensureSupportedArtifact()
end)

ensureSupportedArtifact()

for resourceName in pairs(forbiddenResources) do
    local state = GetResourceState(resourceName)

    if state == "started" or state == "starting" then
        StopResource(resourceName)
        error(("WE STOPPED A RESOURCE THAT WILL BREAK ^1ESX^1, PLEASE REMOVE ^5%s^1"):format(resourceName))
    end
end
