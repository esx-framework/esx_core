-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

if Config.CustomInventory then
    return
end

Core.InventoryEvents = Core.InventoryEvents or {}

function Core.InventoryEvents.GetPositiveCount(count)
    count = tonumber(count)

    if not count then
        return nil
    end

    count = ESX.Math.Round(count)

    if count < 1 then
        return nil
    end

    return count
end

function Core.InventoryEvents.WarnInvalidTransfer(playerId)
    print(("[^3WARNING^7] Player Detected Cheating: ^5%s^7"):format(GetPlayerName(playerId)))
end

function Core.InventoryEvents.GetTransferPlayers(playerId, target)
    target = tonumber(target)

    if not target then
        return nil, nil
    end

    local sourceXPlayer = ESX.GetPlayerFromId(playerId)
    local targetXPlayer = ESX.GetPlayerFromId(target)

    if not sourceXPlayer or not targetXPlayer then
        return nil, nil
    end

    local sourcePed = GetPlayerPed(playerId)
    local targetPed = GetPlayerPed(target)

    if sourcePed == 0 or targetPed == 0 then
        return nil, nil
    end

    if GetPlayerRoutingBucket(playerId) ~= GetPlayerRoutingBucket(target) then
        return nil, nil
    end

    local distance = #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed))
    if distance > Config.DistanceGive then
        return nil, nil
    end

    return sourceXPlayer, targetXPlayer
end

local RATE_LIMITS <const> = {
    give = { capacity = 3, refill = 3, interval = 1000 },
    remove = { capacity = 3, refill = 3, interval = 1000 },
    use = { capacity = 5, refill = 5, interval = 1000 },
    pickup = { capacity = 5, refill = 5, interval = 1000 },
}

local limiters = {}

for name, options in pairs(RATE_LIMITS) do
    limiters[name] = xLib.rateLimiter(options)
end

---@param name "give" | "remove" | "use" | "pickup"
---@param playerId number
---@return boolean
function Core.InventoryEvents.ConsumeRate(name, playerId)
    return limiters[name]:consume(playerId)
end

---@param accountName string
---@return boolean
function Core.InventoryEvents.IsAccountTransferable(accountName)
    local account = Config.Accounts[accountName]

    return account ~= nil and account.transferable ~= false
end
