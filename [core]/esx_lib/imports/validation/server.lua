-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@param source number|string
---@return boolean
function xLib.validation.player(source)
    return xLib.player.getPed(source) ~= nil
end

---@param source number|string
---@param coords table|vector3
---@param distance number|string
---@return boolean nearby
---@return number|nil actualDistance
function xLib.validation.playerNearCoords(source, coords, distance)
    return xLib.player.isNearCoords(source, coords, distance)
end

---@param source number|string
---@param target number|string
---@param distance number|string
---@return boolean nearby
---@return number|nil actualDistance
function xLib.validation.playerNearPlayer(source, target, distance)
    return xLib.player.isNearPlayer(source, target, distance)
end

return xLib.validation
