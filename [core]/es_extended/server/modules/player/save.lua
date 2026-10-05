-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local SAVE_QUERY <const> =
    'UPDATE `users` SET `accounts` = ?, `job` = ?, `job_grade` = ?, `group` = ?, `position` = ?, `inventory` = ?, `loadout` = ?, `metadata` = ? WHERE `identifier` = ?'
local SAVE_BATCH_SIZE <const> = 25
local SAVE_BATCH_INTERVAL <const> = 50
local saveQueues = {}
local savedFingerprints = setmetatable({}, { __mode = 'k' })
local savingAll = false
local allSaveCallbacks = {}
local repeatAllSave = false
local allSaveSucceeded = true

local function updateHealthAndArmorInMetadata(xPlayer)
    local ped = ESX.Players[xPlayer.source] == xPlayer and GetPlayerPed(xPlayer.source) or 0

    local metadata = xPlayer.getMeta()

    if ped ~= 0 then
        metadata.health = GetEntityHealth(ped)
        metadata.armor = GetPedArmour(ped)
    end

    metadata.lastPlaytime = xPlayer.getPlayTime()
end

---@param xPlayer table
---@return table
local function buildSaveParameters(xPlayer)
    return {
        json.encode(xPlayer.getAccounts(true)),
        xPlayer.job.name,
        xPlayer.job.grade,
        xPlayer.group,
        json.encode(xPlayer.getCoords(false, true)),
        json.encode(xPlayer.getInventory(true)),
        json.encode(xPlayer.getLoadout(true)),
        json.encode(xPlayer.getMeta()),
        xPlayer.identifier,
    }
end

---@param xPlayer table
---@param cb? function
---@return nil
local function executePlayerSave(xPlayer, cb, force)
    if not xPlayer.spawned then
        return cb(true)
    end

    updateHealthAndArmorInMetadata(xPlayer)

    local parameters = buildSaveParameters(xPlayer)
    local metadata = {}

    for key, value in pairs(xPlayer.getMeta()) do
        if key ~= 'lastPlaytime' then
            metadata[key] = value
        end
    end

    local fingerprint = json.encode({
        parameters[1],
        parameters[2],
        parameters[3],
        parameters[4],
        parameters[5],
        parameters[6],
        parameters[7],
        metadata,
    })
    local previous = savedFingerprints[xPlayer]

    if
        not force
        and previous
        and previous.value == fingerprint
        and GetGameTimer() - previous.time < 60000
    then
        return cb(true)
    end

    local function confirmed(affectedRows)
        local success = type(affectedRows) == 'number' and affectedRows >= 0 and affectedRows <= 1

        if success then
            savedFingerprints[xPlayer] = {
                value = fingerprint,
                time = GetGameTimer(),
            }
        end

        if affectedRows == 1 then
            print(('[^2INFO^7] Saved player ^5"%s^7"'):format(xPlayer.name))
            TriggerEvent('esx:playerSaved', xPlayer.playerId, xPlayer)
        end

        cb(success)
    end

    MySQL.prepare(SAVE_QUERY, parameters, function(affectedRows)
        if affectedRows == 0 then
            local ok = pcall(
                MySQL.scalar,
                'SELECT COUNT(*) FROM users WHERE identifier = ?',
                { xPlayer.identifier },
                function(count)
                    confirmed(tonumber(count) == 1 and 0 or nil)
                end
            )

            if not ok then
                confirmed(nil)
            end
        else
            confirmed(affectedRows)
        end
    end)
end

local function pumpSave(identifier, queue)
    if queue.busy or not queue.pending then
        return
    end

    local request = queue.pending
    queue.pending = nil
    queue.busy = true

    local completed = false

    local function finish(success)
        if completed then
            return
        end

        completed = true
        queue.busy = false

        for i = 1, #request.callbacks do
            local ok, err = pcall(request.callbacks[i], success)

            if not ok then
                print(('[es_extended] save callback failed: %s'):format(err))
            end
        end

        if queue.pending then
            pumpSave(identifier, queue)
        elseif not queue.busy then
            saveQueues[identifier] = nil
        end
    end

    local ok, err = pcall(executePlayerSave, request.player, finish, request.force)

    if not ok then
        print(('[es_extended] save failed for %s: %s'):format(identifier, err))
        finish(false)
    end
end

function Core.SavePlayer(xPlayer, cb, force)
    if not xPlayer then
        return cb and cb(false)
    end

    local identifier = xPlayer.identifier
    local queue = saveQueues[identifier] or {}
    saveQueues[identifier] = queue
    queue.pending = queue.pending or {
        player = xPlayer,
        callbacks = {},
    }
    queue.pending.player = xPlayer
    queue.pending.force = queue.pending.force or force

    if cb then
        queue.pending.callbacks[#queue.pending.callbacks + 1] = cb
    end

    pumpSave(identifier, queue)
end

exports('SavePlayer', function(playerId, cb)
    Core.SavePlayer(ESX.GetPlayerFromId(playerId), cb)
end)

---@param cb? function
---@return nil
function Core.SavePlayers(cb)
    if cb then
        allSaveCallbacks[#allSaveCallbacks + 1] = cb
    end

    if savingAll then
        repeatAllSave = true
        return
    end

    savingAll = true
    local allSucceeded = true

    local function complete()
        if not allSucceeded then
            allSaveSucceeded = false
        end

        savingAll = false

        if repeatAllSave then
            repeatAllSave = false
            return Core.SavePlayers()
        end

        local callbacks = allSaveCallbacks
        allSaveCallbacks = {}
        local succeeded = allSaveSucceeded
        allSaveSucceeded = true

        for i = 1, #callbacks do
            local ok, err = pcall(callbacks[i], succeeded)

            if not ok then
                print(('[es_extended] batch save callback failed: %s'):format(err))
            end
        end
    end

    local xPlayers <const> = ESX.Players or {}
    local players = {}

    for _, xPlayer in pairs(xPlayers) do
        if xPlayer.spawned then
            players[#players + 1] = xPlayer
        end
    end

    if #players == 0 then
        return complete()
    end

    local startTime <const> = GetGameTimer()
    local savedCount = 0
    local totalCount = #players
    local done = false

    local function saveBatch(index)
        if done then
            return
        end

        local last = math.min(index + SAVE_BATCH_SIZE - 1, totalCount)
        local batch = {}

        for i = index, last do
            local xPlayer = players[i]

            if ESX.Players[xPlayer.source] == xPlayer then
                batch[#batch + 1] = xPlayer
            end
        end

        local function onBatchSaved()
            savedCount = savedCount + #batch

            if last < totalCount then
                SetTimeout(SAVE_BATCH_INTERVAL, function()
                    saveBatch(last + 1)
                end)
            else
                done = true

                complete()
                print(
                    ('[^2INFO^7] Saved ^5%s^7 %s over ^5%s^7 ms'):format(
                        savedCount,
                        savedCount > 1 and 'players' or 'player',
                        GetGameTimer() - startTime
                    )
                )
            end
        end

        if #batch == 0 then
            return onBatchSaved()
        end

        local pending = #batch

        for i = 1, #batch do
            Core.SavePlayer(batch[i], function(success)
                if not success then
                    allSucceeded = false
                end

                pending = pending - 1

                if pending == 0 then
                    onBatchSaved()
                end
            end)
        end
    end

    saveBatch(1)
end
