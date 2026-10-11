-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core.vehicleClass = Core.vehicleClass or { plate = "" }

function Core.vehicleClass.setPlate(self, newPlate)
    if not self:isValid() then
        return false
    end
    assert(type(newPlate) == "string", "Expected 'plate' to be a string")

    local vehicleData = Core.vehicles[self.plate]
    local affectedRows = MySQL.update.await("UPDATE `owned_vehicles` SET `plate` = ? WHERE `plate` = ? AND `owner` = ?", { newPlate, vehicleData.plate, vehicleData.owner })
    if affectedRows <= 0 then
        self:delete()
        return false
    end

    Entity(vehicleData.entity).state:set("plate", newPlate, false)
    SetVehicleNumberPlateText(vehicleData.entity, newPlate)

    local oldPlate = vehicleData.plate
    vehicleData.plate = newPlate
    Core.vehicles[newPlate] = table.clone(vehicleData)
    Core.vehicles[oldPlate] = nil
    self.plate = newPlate

    TriggerEvent("esx:changedExtendedVehiclePlate", vehicleData.plate, oldPlate)
    Wait(0)

    return true
end

function Core.vehicleClass.setProps(self, newProps)
    if not self:isValid() then
        return false
    end
    assert(type(newProps) == "table", "Expected 'props' to be a table")

    local vehicleData = Core.vehicles[self.plate]
    local affectedRows = MySQL.update.await("UPDATE `owned_vehicles` SET `vehicle` = ? WHERE `plate` = ? AND `owner` = ?", { json.encode(newProps), vehicleData.plate, vehicleData.owner })
    if affectedRows <= 0 then
        self:delete()
        return false
    end

    Entity(vehicleData.entity).state:set("VehicleProperties", newProps, true)

    return true
end

function Core.vehicleClass.setOwner(self, newOwner)
    if not self:isValid() then
        return false
    end
    assert(type(newOwner) == "string", "Expected 'owner' to be a string")

    local vehicleData = Core.vehicles[self.plate]
    if vehicleData.owner == newOwner then
        return true
    end

    local affectedRows = MySQL.update.await("UPDATE `owned_vehicles` SET `owner` = ? WHERE owner = ? AND `plate` = ?", { newOwner, vehicleData.owner, vehicleData.plate })
    if affectedRows <= 0 then
        self:delete()
        return false
    end

    Entity(vehicleData.entity).state:set("owner", newOwner, false)
    vehicleData.owner = newOwner

    return true
end
