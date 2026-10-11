-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@class playerlib
xLib.player = {}

local function toServerId(value)
    local serverId = tonumber(value)

    if not serverId or serverId <= 0 then
        return
    end

    return serverId
end

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
    local z = coords.z or coords[3]

    if not x or not y or not z then
        return
    end

    return vector3(x + 0.0, y + 0.0, z + 0.0)
end

---@param source number|string
---@return number|nil ped
function xLib.player.getPed(source)
    source = toServerId(source)

    if not source then
        return
    end

    local ped = GetPlayerPed(source)

    if not ped or ped == 0 then
        return
    end

    return ped
end

---@param source number|string
---@return vector3|nil coords
function xLib.player.getCoords(source)
    local ped = xLib.player.getPed(source)

    if not ped then
        return
    end

    return GetEntityCoords(ped)
end

---@param source number|string
---@param coords table|vector3
---@return number|nil distance
function xLib.player.distanceToCoords(source, coords)
    local playerCoords = xLib.player.getCoords(source)
    coords = toVector3(coords)

    if not playerCoords or not coords then
        return
    end

    return #(playerCoords - coords)
end

---@param source number|string
---@param coords table|vector3
---@param distance number|string
---@return boolean nearby
---@return number|nil actualDistance
function xLib.player.isNearCoords(source, coords, distance)
    distance = tonumber(distance) or 0

    if distance < 0 then
        return false
    end

    local actualDistance = xLib.player.distanceToCoords(source, coords)

    return actualDistance ~= nil and actualDistance <= distance, actualDistance
end

---@param source number|string
---@param target number|string
---@return number|nil distance
function xLib.player.distanceToPlayer(source, target)
    source = toServerId(source)
    target = toServerId(target)

    if not source or not target or source == target then
        return
    end

    if GetPlayerRoutingBucket(source) ~= GetPlayerRoutingBucket(target) then
        return
    end

    local sourceCoords = xLib.player.getCoords(source)
    local targetCoords = xLib.player.getCoords(target)

    if not sourceCoords or not targetCoords then
        return
    end

    return #(sourceCoords - targetCoords)
end

---@param source number|string
---@param target number|string
---@param distance number|string
---@return boolean nearby
---@return number|nil actualDistance
function xLib.player.isNearPlayer(source, target, distance)
    distance = tonumber(distance) or 0

    if distance < 0 then
        return false
    end

    local actualDistance = xLib.player.distanceToPlayer(source, target)

    return actualDistance ~= nil and actualDistance <= distance, actualDistance
end

---@param source number|string
---@param coordsList table[]
---@param distance number|string
---@return table|vector3|nil coords
---@return number|nil index
---@return number|nil actualDistance
function xLib.player.findNearbyCoords(source, coordsList, distance)
    if type(coordsList) ~= "table" then
        return
    end

    distance = tonumber(distance) or 0

    for i = 1, #coordsList do
        local nearby, actualDistance = xLib.player.isNearCoords(source, coordsList[i], distance)

        if nearby then
            return coordsList[i], i, actualDistance
        end
    end
end

---@param source number|string
---@param coordsList table[]
---@param distance number|string
---@return boolean nearby
---@return number|nil index
---@return number|nil actualDistance
function xLib.player.isNearAnyCoords(source, coordsList, distance)
    local _, index, actualDistance = xLib.player.findNearbyCoords(source, coordsList, distance)

    return index ~= nil, index, actualDistance
end

return xLib.player
