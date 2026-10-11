-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core.vehicleClass = Core.vehicleClass or { plate = "" }

function Core.vehicleClass.isValid(self)
    local vehicleData = Core.vehicles[self.plate]
    if not vehicleData then
        return false
    end

    local entity = NetworkGetEntityFromNetworkId(vehicleData.netId)
    if entity <= 0 or Entity(entity).state.owner ~= vehicleData.owner or Entity(entity).state.plate ~= vehicleData.plate then
        self:delete()
        return false
    end

    vehicleData.entity = entity

    return true
end
