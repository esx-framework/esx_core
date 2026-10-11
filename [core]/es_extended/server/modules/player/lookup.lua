-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

ESX.GetPlayers = GetPlayers

local function checkTable(key, val, xPlayer, xPlayers, minimal)
    for valIndex = 1, #val do
        local value = val[valIndex]
        xPlayers[value] = xPlayers[value] or {}

        if (key == "job" and xPlayer.job.name == value) or xPlayer[key] == value then
            xPlayers[value][#xPlayers[value] + 1] = (minimal and xPlayer.source or xPlayer)
        end
    end
end

---@param key? string
---@param val? string|table
---@param minimal? boolean
---@return xPlayer[]|number[]|table<any, xPlayer[]>|table<any, number[]>
function ESX.GetExtendedPlayers(key, val, minimal)
    local players = ESX.Players or {}

    if not key then
        if not minimal then
            return xLib.table.toArray(players)
        end

        local xPlayers = {}
        local index = 1
        for src in pairs(players) do
            xPlayers[index] = src
            index += 1
        end

        return xPlayers
    end

    local xPlayers = {}
    if type(val) == "table" then
        for _, xPlayer in pairs(players) do
            checkTable(key, val, xPlayer, xPlayers, minimal)
        end

        return xPlayers
    end

    for _, xPlayer in pairs(players) do
        if (key == "job" and xPlayer.job.name == val) or xPlayer[key] == val then
            xPlayers[#xPlayers + 1] = (minimal and xPlayer.source or xPlayer)
        end
    end

    return xPlayers
end

---@param key? string
---@param val? string|table
---@return number | table
function ESX.GetNumPlayers(key, val)
    if not key then
        return #GetPlayers()
    end

    if type(val) == "table" then
        local numPlayers = {}
        if key == "job" then
            for _, v in ipairs(val) do
                numPlayers[v] = (Core.JobsPlayerCount[v] or 0)
            end
            return numPlayers
        end

        local filteredPlayers = ESX.GetExtendedPlayers(key, val)
        for i, v in pairs(filteredPlayers) do
            numPlayers[i] = (#v or 0)
        end
        return numPlayers
    end

    if key == "job" then
        return (Core.JobsPlayerCount[val] or 0)
    end

    return #ESX.GetExtendedPlayers(key, val)
end

---@param source number
---@return xPlayer?
function ESX.GetPlayerFromId(source)
    return ESX.Players and ESX.Players[tonumber(source)] or nil
end

---@param identifier string
---@return xPlayer?
function ESX.GetPlayerFromIdentifier(identifier)
    return Core.playersByIdentifier[identifier]
end

---@param identifier string
---@return number playerId
function ESX.GetPlayerIdFromIdentifier(identifier)
    return Core.playersByIdentifier[identifier]?.source
end

---@param source number
---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
function ESX.IsPlayerLoaded(source)
    return ESX.Players and ESX.Players[source] ~= nil
end
