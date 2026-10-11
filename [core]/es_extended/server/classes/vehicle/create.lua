-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core.vehicleClass = Core.vehicleClass or { plate = "" }

function Core.vehicleClass.new(owner, plate, coords)
    assert(type(owner) == "string", "Expected 'owner' to be a string")
    assert(type(plate) == "string", "Expected 'plate' to be a string")
    assert(type(coords) == "vector4", "Expected 'coords' to be a vector4")

    local xVehicle = Core.vehicleClass.getFromPlate(plate)
    if xVehicle then
        return xVehicle
    end

    local vehicleProps = MySQL.scalar.await("SELECT `vehicle` FROM `owned_vehicles` WHERE `stored` = true AND `owner` = ? AND `plate` = ? LIMIT 1", { owner, plate })
    if not vehicleProps then
        return
    end
    vehicleProps = json.decode(vehicleProps)

    if type(vehicleProps.model) ~= "number" then
        vehicleProps.model = joaat(vehicleProps.model)
    end

    local netId = ESX.OneSync.SpawnVehicle(vehicleProps.model, coords.xyz, coords.w, vehicleProps)
    if not netId then
        return
    end

    local entity = NetworkGetEntityFromNetworkId(netId)
    if entity <= 0 then
        return
    end
    Entity(entity).state:set("owner", owner, false)
    Entity(entity).state:set("plate", plate, false)

    ---@type CVehicleData
    local vehicleData = {
        plate = plate,
        entity = entity,
        netId = netId,
        modelHash = vehicleProps.model,
        owner = owner,
    }
    Core.vehicles[plate] = vehicleData

    MySQL.update.await("UPDATE `owned_vehicles` SET `stored` = false WHERE `owner` = ? AND `plate` = ?", { owner, plate })

    local obj = table.clone(Core.vehicleClass)
    obj.plate = plate
    TriggerEvent("esx:createdExtendedVehicle", obj)

    return obj
end

function Core.vehicleClass.getFromPlate(plate)
    assert(type(plate) == "string", "Expected 'plate' to be a string")

    if Core.vehicles[plate] then
        local obj = table.clone(Core.vehicleClass)
        obj.plate = plate

        if obj:isValid() then
            return obj
        end
    end
end
