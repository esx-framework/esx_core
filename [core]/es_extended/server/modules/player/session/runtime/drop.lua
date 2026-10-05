-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

function Core.PlayerSession.OnPlayerDropped(playerId, reason, cb)
    Core.PlayerSession.CancelPlayerLoad(playerId)

    local p = not cb and promise:new()

    local function resolve()
        if cb then
            return cb()
        elseif p then
            return p:resolve()
        end
    end

    local xPlayer = ESX.GetPlayerFromId(playerId)

    if not xPlayer then
        return resolve()
    end

    if xPlayer.beginAccountShutdown then
        xPlayer.beginAccountShutdown()
    end

    TriggerEvent('esx:playerDropped', playerId, reason)
    Core.PlayerSession.DecrementJobCount(xPlayer.getJob().name)

    while xPlayer.getPendingAccountOperations and xPlayer.getPendingAccountOperations() > 0 do
        Wait(50)
    end

    local function finishDrop(success)
        if not success then
            print(
                ('[es_extended] Final save failed for %s; retaining session and retrying'):format(
                    xPlayer.identifier
                )
            )
            return SetTimeout(5000, function()
                Core.SavePlayer(xPlayer, finishDrop, true)
            end)
        end

        GlobalState['playerCount'] = math.max((GlobalState['playerCount'] or 1) - 1, 0)

        if ESX.Players[playerId] == xPlayer then
            ESX.Players[playerId] = nil
        end

        if Core.playersByIdentifier[xPlayer.identifier] == xPlayer then
            Core.playersByIdentifier[xPlayer.identifier] = nil
        end

        resolve()
    end

    Core.SavePlayer(xPlayer, finishDrop, true)

    if p then
        return Citizen.Await(p)
    end
end

AddEventHandler('esx:onPlayerDropped', Core.PlayerSession.OnPlayerDropped)
