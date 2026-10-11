-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core.vehicleClass = Core.vehicleClass or { plate = "" }

function Core.vehicleClass.getNetId(self)
    if not self:isValid() then
        return
    end

    return Core.vehicles[self.plate].netId
end

function Core.vehicleClass.getEntity(self)
    if not self:isValid() then
        return
    end

    return Core.vehicles[self.plate].entity
end

function Core.vehicleClass.getPlate(self)
    if not self:isValid() then
        return
    end

    return Core.vehicles[self.plate].plate
end

function Core.vehicleClass.getModelHash(self)
    if not self:isValid() then
        return
    end

    return Core.vehicles[self.plate].modelHash
end

function Core.vehicleClass.getOwner(self)
    if not self:isValid() then
        return
    end

    return Core.vehicles[self.plate].owner
end
