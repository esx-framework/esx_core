-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local function getPlayerData(xPlayer)
    return {
        identifier = xPlayer.identifier,
        accounts = xPlayer.getAccounts(),
        inventory = xPlayer.getInventory(),
        job = xPlayer.getJob(),
        loadout = xPlayer.getLoadout(),
        money = xPlayer.getMoney(),
        position = xPlayer.getCoords(true),
        metadata = xPlayer.getMeta(),
    }
end

xLib.callback.registerCompat('esx:getPlayerData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return cb(nil)
    end

    cb(getPlayerData(xPlayer))
end)

xLib.callback.registerCompat('esx:isUserAdmin', function(source, cb)
    cb(Core.IsPlayerAdmin(source))
end)

xLib.callback.registerCompat('esx:getGameBuild', function(_, cb)
    cb(tonumber(GetConvar('sv_enforceGameBuild', '1604')))
end)

xLib.callback.registerCompat('esx:getOtherPlayerData', function(source, cb, target)
    if not Core.IsPlayerAdmin(source) then
        return cb(nil)
    end

    local xPlayer = ESX.GetPlayerFromId(target)

    if not xPlayer then
        return cb(nil)
    end

    cb(getPlayerData(xPlayer))
end)

xLib.callback.registerCompat('esx:getPlayerNames', function(source, cb, players)
    if type(players) ~= 'table' then
        return cb({})
    end

    players[source] = nil

    for playerId in pairs(players) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        players[playerId] = xPlayer and xPlayer.getName() or nil
    end

    cb(players)
end)

xLib.callback.registerCompat('esx:spawnVehicle', function(source, cb, vehData)
    print(
        '[^3WARNING^7] esx:spawnVehicle callback is deprecated and will be removed in a future update.'
    )

    if not Core.IsPlayerAdmin(source) then
        return cb(false)
    end

    vehData = type(vehData) == 'table' and vehData or {}

    local ped = GetPlayerPed(source)
    local coords = vehData.coords or GetEntityCoords(ped)
    local heading = vehData.heading or coords.w or coords.heading or GetEntityHeading(ped) or 0.0

    ESX.OneSync.SpawnVehicle(
        vehData.model or `ADDER`,
        coords,
        heading,
        vehData.props or {},
        function(id)
            if vehData.warp and id then
                local vehicle = NetworkGetEntityFromNetworkId(id)
                local timeout = 0

                while GetVehiclePedIsIn(ped, false) ~= vehicle and timeout <= 15 do
                    Wait(0)
                    TaskWarpPedIntoVehicle(ped, vehicle, -1)
                    timeout += 1
                end
            end

            cb(id)
        end
    )
end)
