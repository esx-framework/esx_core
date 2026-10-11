-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@class blipslib
xLib.blips = {}

local function toVector3(coords)
    local coordsType = type(coords)

    if coordsType == "vector3" then
        return coords
    end

    if coordsType == "vector4" then
        return vector3(coords.x, coords.y, coords.z)
    end

    if type(coords) ~= "table" then
        return
    end

    local x = coords.x or coords[1]
    local y = coords.y or coords[2]
    local z = coords.z or coords[3] or 0.0

    if not x or not y then
        return
    end

    return vector3(x + 0.0, y + 0.0, z + 0.0)
end

local function setName(blip, label)
    if not label then
        return
    end

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(label)
    EndTextCommandSetBlipName(blip)
end

---@class BlipCreateOptions
---@field coords? table|vector3
---@field entity? number
---@field radius? number
---@field sprite? number
---@field display? number
---@field scale? number
---@field color? number
---@field alpha? number
---@field highDetail? boolean
---@field shortRange? boolean
---@field friendly? boolean
---@field flashes? boolean
---@field headingIndicator? boolean
---@field rotation? number
---@field category? number
---@field label? string
---@field name? string
---@field playerName? number
---@field route? boolean
---@field routeColor? number

---@param data BlipCreateOptions|table|vector3
---@return number|nil blip
function xLib.blips.create(data)
    local dataType = type(data)

    if dataType == "vector3" or dataType == "vector4" then
        data = { coords = data }
    elseif dataType ~= "table" then
        return
    end

    local blip

    if data.entity then
        blip = AddBlipForEntity(data.entity)
    elseif data.radius then
        local coords = toVector3(data.coords)
        if not coords then return end
        blip = AddBlipForRadius(coords.x, coords.y, coords.z, data.radius + 0.0)
    else
        local coords = toVector3(data.coords or data)
        if not coords then return end
        blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    end

    if data.sprite then SetBlipSprite(blip, data.sprite) end
    if data.display then SetBlipDisplay(blip, data.display) end
    if data.scale then SetBlipScale(blip, data.scale + 0.0) end
    if data.color then SetBlipColour(blip, data.color) end
    if data.alpha then SetBlipAlpha(blip, data.alpha) end
    if data.highDetail ~= nil then SetBlipHighDetail(blip, data.highDetail) end
    if data.shortRange ~= nil then SetBlipAsShortRange(blip, data.shortRange) end
    if data.friendly ~= nil then SetBlipAsFriendly(blip, data.friendly) end
    if data.flashes ~= nil then SetBlipFlashes(blip, data.flashes) end
    if data.headingIndicator ~= nil then ShowHeadingIndicatorOnBlip(blip, data.headingIndicator) end
    if data.rotation then SetBlipRotation(blip, data.rotation) end
    if data.category then SetBlipCategory(blip, data.category) end
    if data.route ~= nil then SetBlipRoute(blip, data.route) end
    if data.routeColor then SetBlipRouteColour(blip, data.routeColor) end

    if data.playerName then
        SetBlipNameToPlayerName(blip, data.playerName)
    else
        setName(blip, data.label or data.name)
    end

    return blip
end

---@param blip number
function xLib.blips.remove(blip)
    if blip and DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
end

---@param items table[]
---@param defaults? table
---@return number[] blips
function xLib.blips.createMany(items, defaults)
    local blips = {}

    if type(items) ~= "table" then
        return blips
    end

    defaults = defaults or {}

    for i = 1, #items do
        local data = {}

        for key, value in pairs(defaults) do
            data[key] = value
        end

        local item = items[i]
        if type(item) ~= "table" then
            item = { coords = item }
        end

        for key, value in pairs(item) do
            data[key] = value
        end

        local blip = xLib.blips.create(data)
        if blip then
            blips[#blips + 1] = blip
        end
    end

    return blips
end

return xLib.blips
