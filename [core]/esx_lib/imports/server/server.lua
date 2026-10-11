-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@class serverlib
xLib.server = {}

---@param source number|string
---@return vector3|nil coords
function xLib.server.getPlayerCoords(source)
    return xLib.player.getCoords(source)
end

---@param source number|string
---@param coords table|vector3
---@return number|nil distance
function xLib.server.distanceToCoords(source, coords)
    return xLib.player.distanceToCoords(source, coords)
end

---@param source number|string
---@param coords table|vector3
---@param distance number|string
---@return boolean nearby
---@return number|nil actualDistance
function xLib.server.isPlayerNearCoords(source, coords, distance)
    return xLib.player.isNearCoords(source, coords, distance)
end

---@param source number|string
---@param target number|string
---@return number|nil distance
function xLib.server.distanceToPlayer(source, target)
    return xLib.player.distanceToPlayer(source, target)
end

---@param source number|string
---@param target number|string
---@param distance number|string
---@return boolean nearby
---@return number|nil actualDistance
function xLib.server.isPlayerNearPlayer(source, target, distance)
    return xLib.player.isNearPlayer(source, target, distance)
end

---@param source number|string
---@param coordsList table[]
---@param distance number|string
---@return boolean nearby
---@return number|nil index
---@return number|nil actualDistance
function xLib.server.isPlayerNearAnyCoords(source, coordsList, distance)
    return xLib.player.isNearAnyCoords(source, coordsList, distance)
end

return xLib.server
