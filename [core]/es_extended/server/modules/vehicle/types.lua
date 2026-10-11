-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local KVP_KEY <const> = "esx_vehicleTypes"
local KVP_VERSION <const> = 2
local CONFIRMATIONS_REQUIRED <const> = 2
local PRELOAD_PAGE_SIZE <const> = 256
local PRELOAD_MAX_MODELS <const> = 10000
local PRELOAD_MAX_MODEL_LENGTH <const> = 64
local PRELOAD_TIMEOUT <const> = 10000

local validTypes <const> = {
    automobile = true,
    bike = true,
    boat = true,
    heli = true,
    plane = true,
    submarine = true,
    trailer = true,
    train = true,
}

local storedTypes = {}
local reports = {}
local askedPlayers = {}
local persistQueued = false
local preloadReporters = {}
local preloadReporterCount = 0
local preloadAttempts = setmetatable({}, { __mode = "k" })
local preloadSession
local preloadSequence = 0
local preloadGeneration = 0

local function persistVehicleTypes()
    if persistQueued then
        return
    end

    persistQueued = true

    SetTimeout(1000, function()
        persistQueued = false

        if not next(storedTypes) then
            return DeleteResourceKvp(KVP_KEY)
        end

        SetResourceKvp(KVP_KEY, json.encode({ version = KVP_VERSION, types = storedTypes }))
    end)
end

local function getReporterKey(playerId)
    return GetPlayerIdentifierByType(tostring(playerId), "license") or ("source:%s"):format(playerId)
end

local function countVotes(modelReports, vehicleType)
    local votes = 0

    for _, reportedType in pairs(modelReports) do
        if reportedType == vehicleType then
            votes = votes + 1
        end
    end

    return votes
end

local function askPlayer(model, playerId, cb)
    local player = ESX.Players[playerId]
    local reporter = getReporterKey(playerId)
    local asked = askedPlayers[model] or {}
    askedPlayers[model] = asked
    asked[reporter] = true

    xLib.callback("esx:GetVehicleType", playerId, function(vehicleType)
        if ESX.Players[playerId] ~= player or getReporterKey(playerId) ~= reporter then
            if cb then
                cb(false)
            end

            return
        end

        if askedPlayers[model] == asked then
            Core.CacheVehicleType(model, vehicleType, playerId)
        end

        if cb then
            cb(validTypes[vehicleType] and vehicleType or false)
        end
    end, model)
end

local function requestConfirmation(model)
    local asked = askedPlayers[model] or {}

    for playerId in pairs(ESX.Players) do
        if not asked[getReporterKey(playerId)] then
            return askPlayer(model, playerId)
        end
    end
end

---@param model string|number
---@param vehicleType string|false|nil
---@param playerId? number
---@return nil
function Core.CacheVehicleType(model, vehicleType, playerId, skipConfirmation)
    model = type(model) == "string" and joaat(model) or model

    if type(model) ~= "number" then
        return
    end

    if not validTypes[vehicleType] then
        if playerId and not skipConfirmation and reports[model] then
            requestConfirmation(model)
        end

        return
    end

    local key = tostring(model)

    if storedTypes[key] then
        return
    end

    local modelReports = reports[model] or {}
    reports[model] = modelReports

    if playerId then
        modelReports[getReporterKey(playerId)] = vehicleType
    end

    local votes = countVotes(modelReports, vehicleType)

    if votes >= CONFIRMATIONS_REQUIRED then
        storedTypes[key] = vehicleType
        reports[model] = nil
        askedPlayers[model] = nil
        Core.vehicleTypesByModel[model] = vehicleType

        return persistVehicleTypes()
    end

    local current = Core.vehicleTypesByModel[model]

    if not current or votes > countVotes(modelReports, current) then
        Core.vehicleTypesByModel[model] = vehicleType
    end

    if playerId and not skipConfirmation then
        requestConfirmation(model)
    end
end

local function restoreVehicleTypes()
    local stored = GetResourceKvpString(KVP_KEY)

    if not stored then
        return
    end

    local ok, decoded = pcall(json.decode, stored)

    if not ok or type(decoded) ~= "table" or decoded.version ~= KVP_VERSION or type(decoded.types) ~= "table" then
        return DeleteResourceKvp(KVP_KEY)
    end

    for model, vehicleType in pairs(decoded.types) do
        model = tonumber(model)

        if model and validTypes[vehicleType] then
            Core.vehicleTypesByModel[model] = vehicleType
            storedTypes[tostring(model)] = vehicleType
        end
    end
end

local startNextPreload

local function isCurrentPreload(session)
    return preloadSession == session
        and ESX.Players[session.playerId] == session.player
        and getReporterKey(session.playerId) == session.reporter
end

local function finishPreload(session, success)
    if preloadSession ~= session then
        return
    end

    preloadSession = nil

    if success and session.count > 0 and not preloadReporters[session.reporter] then
        preloadReporters[session.reporter] = true
        preloadReporterCount = preloadReporterCount + 1
    end

    local generation = preloadGeneration

    SetTimeout(0, function()
        if generation == preloadGeneration then
            startNextPreload()
        end
    end)
end

local function normalizePreloadPage(session, page)
    if type(page) ~= "table" or type(page.types) ~= "table" then
        return
    end

    local total = page.total

    if
        type(total) ~= "number"
        or total ~= math.floor(total)
        or total < session.offset
        or total > PRELOAD_MAX_MODELS
        or (session.total and session.total ~= total)
    then
        return
    end

    local last = math.min(session.offset + PRELOAD_PAGE_SIZE, total)
    local nextOffset = last < total and last or nil

    if page.nextOffset ~= nextOffset then
        return
    end

    local types = {}
    local count = 0

    for modelName, vehicleType in pairs(page.types) do
        count = count + 1

        if
            count > last - session.offset
            or type(modelName) ~= "string"
            or #modelName == 0
            or #modelName > PRELOAD_MAX_MODEL_LENGTH
            or not validTypes[vehicleType]
        then
            return
        end

        local model = joaat(modelName:lower())

        if types[model] or session.models[model] then
            return
        end

        types[model] = vehicleType
    end

    return types, count, total, nextOffset
end

local function requestPreloadPage(session)
    if not isCurrentPreload(session) then
        return finishPreload(session, false)
    end

    local request = {}
    session.request = request

    SetTimeout(PRELOAD_TIMEOUT, function()
        if preloadSession == session and session.request == request then
            finishPreload(session, false)
        end
    end)

    local ok = pcall(
        xLib.callback,
        "esx:GetVehicleTypes",
        session.playerId,
        function(page)
            if preloadSession ~= session or session.request ~= request then
                return
            end

            if not isCurrentPreload(session) then
                return finishPreload(session, false)
            end

            local types, count, total, nextOffset = normalizePreloadPage(session, page)

            if not types then
                return finishPreload(session, false)
            end

            session.request = nil
            session.total = total
            session.count = session.count + count

            for model, vehicleType in pairs(types) do
                session.models[model] = true

                if not storedTypes[tostring(model)] then
                    local asked = askedPlayers[model] or {}
                    askedPlayers[model] = asked
                    asked[session.reporter] = true

                    Core.CacheVehicleType(model, vehicleType, session.playerId, true)
                end
            end

            if not nextOffset then
                return finishPreload(session, true)
            end

            session.offset = nextOffset

            SetTimeout(50, function()
                requestPreloadPage(session)
            end)
        end,
        session.offset,
        session.id
    )

    if not ok then
        finishPreload(session, false)
    end
end

startNextPreload = function()
    if preloadSession or preloadReporterCount >= CONFIRMATIONS_REQUIRED then
        return
    end

    for playerId, player in pairs(ESX.Players) do
        local reporter = GetPlayerIdentifierByType(tostring(playerId), "license")

        if reporter and not preloadReporters[reporter] and not preloadAttempts[player] then
            preloadAttempts[player] = true
            preloadSequence = preloadSequence + 1
            preloadSession = {
                id = preloadSequence,
                playerId = playerId,
                player = player,
                reporter = reporter,
                offset = 0,
                count = 0,
                models = {},
            }

            requestPreloadPage(preloadSession)
            return
        end
    end
end

AddEventHandler("esx:playerLoaded", function()
    startNextPreload()
end)

AddEventHandler("esx:playerDropped", function(playerId)
    if preloadSession and preloadSession.playerId == playerId then
        finishPreload(preloadSession, false)
    end
end)

---@param model string|number
---@param player? number
---@param cb function?
---@return string?
---@diagnostic disable-next-line: duplicate-set-field
function ESX.GetVehicleType(model, player, cb)
    if ESX.IsFunctionReference(player) and cb == nil then
        cb = player
        player = nil
    elseif cb == false then
        cb = nil
    elseif cb and not ESX.IsFunctionReference(cb) then
        cb = nil
    end

    local promise = not cb and promise.new()
    local function resolve(result)
        if promise then
            promise:resolve(result)
        elseif cb then
            cb(result)
        end

        return result
    end

    model = type(model) == "string" and joaat(model) or model

    if Core.vehicleTypesByModel[model] then
        if player and reports[model] then
            local asked = askedPlayers[model]

            if not (asked and asked[getReporterKey(player)]) then
                askPlayer(model, player)
            end
        end

        return resolve(Core.vehicleTypesByModel[model])
    end

    if not player then
        return resolve(nil)
    end

    askPlayer(model, player, resolve)

    if promise then
        return Citizen.Await(promise)
    end
end

RegisterCommand("clearvehicletypes", function(src)
    if src ~= 0 then
        print("^1[ERROR]^7 This command can only be run from the server console.")
        return
    end

    storedTypes = {}
    reports = {}
    askedPlayers = {}
    preloadReporters = {}
    preloadReporterCount = 0
    preloadAttempts = setmetatable({}, { __mode = "k" })
    preloadSession = nil
    preloadGeneration = preloadGeneration + 1
    Core.vehicleTypesByModel = {}
    DeleteResourceKvp(KVP_KEY)

    print("^2[SUCCESS]^7 Cleared the vehicle type cache.")
end, true)

restoreVehicleTypes()
