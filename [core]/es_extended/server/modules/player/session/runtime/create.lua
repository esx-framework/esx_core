-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

function Core.PlayerSession.CreateESXPlayer(identifier, playerId, data, loading)
    if not Core.PlayerSession.IsPlayerLoadActive(playerId, loading) then
        return
    end

    local accounts = {}

    for account, money in pairs(Config.StartingAccountMoney) do
        accounts[account] = money
    end

    local defaultGroup = "user"
    if Core.IsPlayerAdmin(playerId) then
        print(("[^2INFO^0] Player ^5%s^0 Has been granted admin permissions via ^5Ace Perms^7."):format(playerId))
        defaultGroup = "admin"
    end

    local parameters = Config.Multichar and {
        json.encode(accounts),
        identifier,
        Core.generateSSN(),
        defaultGroup,
        data.firstname,
        data.lastname,
        data.dateofbirth,
        data.sex,
        data.height,
    } or {
        json.encode(accounts),
        identifier,
        Core.generateSSN(),
        defaultGroup,
    }

    if Config.StartingInventoryItems then
        parameters[#parameters + 1] = json.encode(Config.StartingInventoryItems)
    end

    MySQL.prepare.await(Core.PlayerSession.newPlayerQuery, parameters)

    if Core.PlayerSession.IsPlayerLoadActive(playerId, loading) then
        loadESXPlayer(identifier, playerId, true, loading)
    end
end