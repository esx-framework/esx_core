-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core.vehicleClass = Core.vehicleClass or { plate = "" }

function Core.vehicleClass.delete(self, garageName, isImpound)
    if type(garageName) ~= "string" then
        garageName = nil
    end
    if type(isImpound) ~= "boolean" then
        isImpound = false
    end

    local vehicleData = Core.vehicles[self.plate]
    if not vehicleData then
        return
    end

    local entity = NetworkGetEntityFromNetworkId(vehicleData.netId)
    if
        entity ~= 0
        and DoesEntityExist(entity)
        and GetEntityType(entity) == 2
        and Entity(entity).state.owner == vehicleData.owner
    then
        DeleteEntity(entity)
    end

    local query = "UPDATE `owned_vehicles` SET `stored` = true WHERE `plate` = ? AND `owner` = ?"
    local queryParams = { vehicleData.plate, vehicleData.owner }
    if garageName then
        if isImpound then
            query = "UPDATE `owned_vehicles` SET `stored` = true, `parking` = NULL, `pound` = ? WHERE `plate` = ? AND `owner` = ?"
        else
            query = "UPDATE `owned_vehicles` SET `stored` = true, `pound` = NULL, `parking` = ? WHERE `plate` = ? AND `owner` = ?"
        end

        queryParams = { garageName, vehicleData.plate, vehicleData.owner }
    end

    MySQL.update.await(query, queryParams)
    TriggerEvent("esx:deletedExtendedVehicle", self)

    Core.vehicles[self.plate] = nil
end
