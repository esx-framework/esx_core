-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core.PlayerSession = Core.PlayerSession or {}
Core.PlayerSession.loadingPlayers = {}
Core.PlayerSession.oneSyncState = GetConvar("onesync", "off")
Core.PlayerSession.isEnhanced = xLib.isEnhanced()
Core.PlayerSession.newPlayerQuery = "INSERT INTO `users` SET `accounts` = ?, `identifier` = ?, `ssn` = ?, `group` = ?"
Core.PlayerSession.loadPlayerQuery = "SELECT `accounts`, `ssn`, `job`, `job_grade`, `group`, `position`, `inventory`, `skin`, `loadout`, `metadata`"

if Config.Multichar then
    Core.PlayerSession.newPlayerQuery = Core.PlayerSession.newPlayerQuery .. ", `firstname` = ?, `lastname` = ?, `dateofbirth` = ?, `sex` = ?, `height` = ?"
end

if Config.StartingInventoryItems then
    Core.PlayerSession.newPlayerQuery = Core.PlayerSession.newPlayerQuery .. ", `inventory` = ?"
end

if Config.Multichar or Config.Identity then
    Core.PlayerSession.loadPlayerQuery = Core.PlayerSession.loadPlayerQuery .. ", `firstname`, `lastname`, `dateofbirth`, `sex`, `height`"
end

Core.PlayerSession.loadPlayerQuery = Core.PlayerSession.loadPlayerQuery .. " FROM `users` WHERE identifier = ?"

function Core.PlayerSession.WaitForJobs(playerId, loading)
    while not Core.JobsLoaded do
        if loading and not Core.PlayerSession.IsPlayerLoadActive(playerId, loading) then
            return false
        end

        Wait(50)
    end

    return true
end

function Core.PlayerSession.IsPlayerLoadActive(playerId, loading)
    if not GetPlayerName(playerId) then
        return false
    end

    if not loading then
        return true
    end

    return Core.PlayerSession.loadingPlayers[playerId] == loading
        and Core.PlayerSession.GetPlayerIdentifier(playerId) == loading.identifier
end

function Core.PlayerSession.CancelPlayerLoad(playerId)
    Core.PlayerSession.loadingPlayers[playerId] = nil
end

function Core.PlayerSession.SetJobCount(jobName, count)
    local normalizedCount = math.max(count or 0, 0)

    Core.JobsPlayerCount[jobName] = normalizedCount
    GlobalState[("%s:count"):format(jobName)] = normalizedCount
end

function Core.PlayerSession.IncrementJobCount(jobName)
    Core.PlayerSession.SetJobCount(jobName, (Core.JobsPlayerCount[jobName] or 0) + 1)
end

function Core.PlayerSession.DecrementJobCount(jobName)
    Core.PlayerSession.SetJobCount(jobName, (Core.JobsPlayerCount[jobName] or 0) - 1)
end

function Core.PlayerSession.GetPlayerIdentifier(playerId)
    local ok, identifier = pcall(ESX.GetIdentifier, playerId)

    if not ok then
        return nil
    end

    return identifier
end