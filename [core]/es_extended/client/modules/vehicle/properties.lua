-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@diagnostic disable-next-line: param-type-mismatch
AddStateBagChangeHandler("VehicleProperties", nil, function(bagName, _, value)
    if type(value) ~= "table" or not bagName:find("^entity:") then
        return
    end

    bagName = bagName:gsub("entity:", "")
    local netId = tonumber(bagName)
    if not netId then
        error("Tried to set vehicle properties with invalid netId")
        return
    end

    local tries = 0

    while not NetworkDoesEntityExistWithNetworkId(netId) do
        Wait(200)
        tries += 1
        if tries > 20 then
            return error(("Invalid entity - ^5%s^7!"):format(netId))
        end
    end

    local vehicle = NetToVeh(netId)

    if NetworkGetEntityOwner(vehicle) ~= ESX.playerId then
        return
    end

    xLib.game.setVehicleProperties(vehicle, value)
end)

xLib.callback.registerCompat("esx:GetVehicleType", function(cb, model)
    cb(ESX.GetVehicleTypeClient(model))
end)

local PRELOAD_PAGE_SIZE <const> = 256
local PRELOAD_MAX_MODELS <const> = 10000
local PRELOAD_MAX_MODEL_LENGTH <const> = 64
local modelSnapshot

xLib.callback.registerCompat("esx:GetVehicleTypes", function(cb, offset, snapshotId)
    if
        type(offset) ~= "number"
        or offset ~= math.floor(offset)
        or offset < 0
        or offset > PRELOAD_MAX_MODELS
        or type(snapshotId) ~= "number"
        or snapshotId ~= math.floor(snapshotId)
        or snapshotId < 1
        or snapshotId == math.huge
    then
        return cb(false)
    end

    if offset == 0 then
        if type(GetAllVehicleModels) ~= "function" then
            return cb(false)
        end

        local models = GetAllVehicleModels()

        if type(models) ~= "table" then
            return cb(false)
        end

        modelSnapshot = {
            id = snapshotId,
            models = models,
        }
    end

    if not modelSnapshot or modelSnapshot.id ~= snapshotId then
        return cb(false)
    end

    local snapshot = modelSnapshot
    local models = snapshot.models
    local total = math.min(#models, PRELOAD_MAX_MODELS)

    if offset > total then
        return cb(false)
    end

    local last = math.min(offset + PRELOAD_PAGE_SIZE, total)
    local types = {}

    for i = offset + 1, last do
        local modelName = models[i]

        if
            type(modelName) == "string"
            and #modelName > 0
            and #modelName <= PRELOAD_MAX_MODEL_LENGTH
        then
            local vehicleType = ESX.GetVehicleTypeClient(modelName)

            if type(vehicleType) == "string" then
                types[modelName] = vehicleType
            end
        end

        if i % 64 == 0 then
            Wait(0)
        end
    end

    if last == total and modelSnapshot == snapshot then
        modelSnapshot = nil
    end

    cb({
        types = types,
        total = total,
        nextOffset = last < total and last or nil,
    })
end)
