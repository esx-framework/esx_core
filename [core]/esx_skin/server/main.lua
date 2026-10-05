-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

ESXCatalog.awaitReady()

local cache = {}
local writes = {}
local reads = {}
local saveLimiter = xLib.rateLimiter({
    capacity = 2,
    refill = 1,
    interval = Config.SkinSaveCooldown,
})
local readLimiter = xLib.rateLimiter({ capacity = 2, refill = 1, interval = 1000 })

local function decodeSkin(value)
    if type(value) == 'table' then
        return value
    end

    if type(value) ~= 'string' or value == '' then
        return nil
    end

    local ok, decoded = pcall(json.decode, value)
    return ok and type(decoded) == 'table' and decoded or nil
end

local function validateSkin(skin)
    if type(skin) ~= 'table' or (skin.sex ~= 0 and skin.sex ~= 1) then
        return nil
    end

    local count = 0

    for name, value in pairs(skin) do
        count = count + 1
        local bounds = Config.SkinFields[name]

        if
            count > 128
            or not bounds
            or type(value) ~= 'number'
            or value ~= value
            or value % 1 ~= 0
            or value < bounds[1]
            or value > bounds[2]
        then
            return nil
        end
    end

    local ok, encoded = pcall(json.encode, skin)

    if not ok or #encoded > Config.SkinMaxBytes then
        return nil
    end

    return encoded
end

local function applyBackpackWeight(playerId, identifier, skin)
    local config = ESX.GetConfig()

    if config.CustomInventory then
        return
    end

    local player = ESX.GetPlayerFromId(playerId)

    if not player or player.identifier ~= identifier then
        return
    end

    local bag = player.getMeta().authorizedBackpack

    if Config.AllowClothingBackpackCapacity then
        bag = skin and skin.bags_1
    end

    player.setMaxWeight(config.MaxWeight + (Config.BackpackWeight[bag] or 0))
end

exports('SetBackpackCapacity', function(playerId, bag)
    local player = ESX.GetPlayerFromId(playerId)

    if not player or (bag ~= nil and (type(bag) ~= 'number' or not Config.BackpackWeight[bag])) then
        return false
    end

    if bag == nil then
        player.clearMeta('authorizedBackpack')
    else
        player.setMeta('authorizedBackpack', bag)
    end

    applyBackpackWeight(
        playerId,
        player.identifier,
        cache[player.identifier] and cache[player.identifier].skin
    )
    return true
end)

AddEventHandler('esx:playerLoaded', function(playerId)
    if type(source) == 'number' or type(playerId) ~= 'number' then
        return
    end

    local player = ESX.GetPlayerFromId(playerId)

    if player then
        local skin

        if Config.AllowClothingBackpackCapacity then
            local ok, stored = pcall(
                MySQL.scalar.await,
                'SELECT skin FROM users WHERE identifier = ?',
                { player.identifier }
            )

            if ok then
                skin = decodeSkin(stored)
            end
        end

        applyBackpackWeight(playerId, player.identifier, skin)
    end
end)

local function reply(callback, success)
    if not callback then
        return
    end

    local ok, err = pcall(callback, success)

    if not ok then
        print(('[esx_skin] Save callback failed: %s'):format(tostring(err)))
    end
end

local function sameSkin(left, right)
    if type(left) ~= 'table' or type(right) ~= 'table' then
        return false
    end

    for name, value in pairs(left) do
        if right[name] ~= value then
            return false
        end
    end

    for name in pairs(right) do
        if left[name] == nil then
            return false
        end
    end

    return true
end

local dispatchSave

dispatchSave = function(identifier, queue)
    local request = queue.requests[1]
    local finished = false

    local function finish(rows)
        if finished then
            return
        end

        finished = true

        local success = type(rows) == 'number' and rows > 0

        if rows == 0 then
            local ok, stored = pcall(
                MySQL.scalar.await,
                'SELECT skin FROM users WHERE identifier = ?',
                { identifier }
            )

            success = ok and sameSkin(decodeSkin(stored), request.skin)
        end

        local current = ESX.GetPlayerFromId(request.playerId)

        if success and current == request.player then
            cache[identifier] = {
                skin = request.skin,
                encoded = request.encoded,
                expires = GetGameTimer() + Config.SkinCacheTTL,
            }
            local ok, err = pcall(applyBackpackWeight, request.playerId, identifier, request.skin)

            if not ok then
                print(('[esx_skin] Backpack refresh failed: %s'):format(tostring(err)))
            end
        elseif not ESX.GetPlayerFromIdentifier(identifier) then
            cache[identifier] = nil
        end

        table.remove(queue.requests, 1)

        if #queue.requests == 0 then
            writes[identifier] = nil
            queue.done:resolve(true)
        end

        reply(request.callback, success)

        if writes[identifier] == queue and #queue.requests > 0 then
            dispatchSave(identifier, queue)
        end
    end

    local ok = pcall(
        MySQL.update,
        'UPDATE users SET skin = ? WHERE identifier = ?',
        { request.encoded, identifier },
        finish
    )

    if not ok then
        finish(nil)
    end
end

local function saveSkin(playerId, skin, callback)
    local player = ESX.GetPlayerFromId(playerId)

    if not player or not saveLimiter:consume(playerId) then
        reply(callback, false)
        return false
    end

    local identifier = player.identifier
    local encoded = validateSkin(skin)

    if not encoded then
        reply(callback, false)
        return false
    end

    local queue = writes[identifier]

    if not queue and cache[identifier] and cache[identifier].encoded == encoded then
        reply(callback, true)
        return true
    end

    if queue and #queue.requests >= 4 then
        reply(callback, false)
        return false
    end

    if not queue then
        queue = { requests = {}, done = promise.new() }
        writes[identifier] = queue
    end

    queue.requests[#queue.requests + 1] = {
        playerId = playerId,
        player = player,
        encoded = encoded,
        skin = decodeSkin(encoded),
        callback = callback,
    }

    if #queue.requests == 1 then
        dispatchSave(identifier, queue)
    end

    return true
end

RegisterNetEvent('esx_skin:save', function(skin)
    local playerId = source
    local player = ESX.GetPlayerFromId(playerId)

    saveSkin(playerId, skin, function(success)
        if not success and player and ESX.GetPlayerFromId(playerId) == player then
            TriggerClientEvent('esx_skin:saveFailed', playerId)
        end
    end)
end)

xLib.callback.registerCompat('esx_skin:save', function(source, cb, skin)
    saveSkin(source, skin, cb)
end)

exports('SaveSkin', saveSkin)

RegisterNetEvent('esx_skin:setWeight', function() end)

xLib.callback.registerCompat('esx_skin:getPlayerSkin', function(source, cb)
    local player = ESX.GetPlayerFromId(source)

    if not player then
        return cb(nil, nil)
    end

    local identifier = player.identifier

    while writes[identifier] do
        Citizen.Await(writes[identifier].done)
    end

    local entry = cache[identifier]

    if not entry or entry.expires < GetGameTimer() then
        local pending = reads[identifier]

        if not pending then
            if not readLimiter:consume(source) then
                return cb(entry and entry.skin, nil)
            end

            pending = promise.new()
            reads[identifier] = pending
            local ok, stored = pcall(
                MySQL.scalar.await,
                'SELECT skin FROM users WHERE identifier = ?',
                { identifier }
            )

            while writes[identifier] do
                Citizen.Await(writes[identifier].done)
            end

            if ok and not writes[identifier] and not cache[identifier] then
                cache[identifier] = {
                    skin = decodeSkin(stored),
                    encoded = stored,
                    expires = GetGameTimer() + Config.SkinCacheTTL,
                }
            elseif ok and not writes[identifier] and cache[identifier] == entry then
                cache[identifier] = {
                    skin = decodeSkin(stored),
                    encoded = stored,
                    expires = GetGameTimer() + Config.SkinCacheTTL,
                }
            end

            reads[identifier] = nil
            pending:resolve(ok)
        else
            Citizen.Await(pending)
        end

        entry = cache[identifier]
    end

    if ESX.GetPlayerFromId(source) ~= player then
        return cb(nil, nil)
    end

    local job = player.getJob()
    cb(entry and entry.skin, { skin_male = job.skin_male, skin_female = job.skin_female })
end)

AddEventHandler('esx:playerDropped', function(playerId)
    local player = ESX.GetPlayerFromId(playerId)

    if player then
        cache[player.identifier] = nil
    end
end)

CreateThread(function()
    while true do
        Wait(30000)

        for identifier, entry in pairs(cache) do
            if
                entry.expires < GetGameTimer()
                and not writes[identifier]
                and not reads[identifier]
            then
                cache[identifier] = nil
            end
        end
    end
end)

ESX.RegisterCommand(
    'skin',
    'admin',
    function(xPlayer, args)
        if not args.playerId then
            args.playerId = xPlayer
        end
        args.playerId.triggerEvent('esx_skin:openSaveableMenu')
    end,
    false,
    {
        help = TranslateCap('skin'),
        arguments = { { name = 'playerId', help = TranslateCap('skin'), type = 'player' } },
    }
)
