--!DISCLAIMER
--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class PointProperties
---@field coords vector3
---@field distance number
---@field onEnter? fun(self: CPoint)
---@field onExit? fun(self: CPoint)
---@field nearby? fun(self: CPoint)
---@field [string] any

---@class CPoint : PointProperties
---@field id number
---@field currentDistance number
---@field isClosest? boolean
---@field remove fun()

---@type table<number, CPoint>
local points = {}
---@type CPoint[]
local nearbyPoints = {}
local nearbyCount = 0
---@type CPoint?
local closestPoint
local tick

local function removePoint(self)
    if closestPoint?.id == self.id then
        closestPoint = nil
    end

    xLib.grid.removeEntry(self)

    points[self.id] = nil
end

CreateThread(function()
    while true do
        local coords = GetEntityCoords(PlayerPedId())
        local newPoints = xLib.grid.getNearbyEntries(coords, function(entry) return entry.remove == removePoint end) --[[@as CPoint[] ]]
        local cellX, cellY = xLib.grid.getCellPosition(coords)
        closestPoint = nil

        for i = 1, nearbyCount do
            local point = nearbyPoints[i]

            if point.inside then
                local distance = #(coords - point.coords)

                if distance > point.radius then
                    if point.onExit then point:onExit() end

                    point.inside = nil
                    point.currentDistance = nil
                end
            end
        end

        if nearbyCount ~= 0 then
            table.wipe(nearbyPoints)
            nearbyCount = 0
        end

        for i = 1, #newPoints do
            local point = newPoints[i]
            local distance = #(coords - point.coords)

            if distance <= point.radius then
                point.currentDistance = distance

                if not closestPoint or distance < (closestPoint.currentDistance or point.radius) then
                    if closestPoint then closestPoint.isClosest = nil end

                    point.isClosest = true
                    closestPoint = point
                end

                nearbyCount += 1
                nearbyPoints[nearbyCount] = point

                if point.onEnter and not point.inside then
                    point.inside = true
                    point:onEnter()
                end
            elseif point.currentDistance then
                if point.onExit then point:onExit() end

                point.inside = nil
                point.currentDistance = nil
            end
        end

        if not tick then
            if nearbyCount ~= 0 then
                tick = true
                CreateThread(function()
                    while tick do
                        for i = nearbyCount, 1, -1 do
                            local point = nearbyPoints[i]

                            if point and point.nearby then
                                point:nearby()
                            end
                        end
                        Wait(0)
                    end
                end)
            end
        elseif nearbyCount == 0 then
            tick = false
        end

        Wait(300)
    end
end)

local function toVector(coords)
    local _type = type(coords)

    if _type ~= 'vector3' then
        if _type == 'table' or _type == 'vector4' then
            return vec3(coords[1] or coords.x, coords[2] or coords.y, coords[3] or coords.z)
        end

        error(("expected type 'vector3' or 'table' (received %s)"):format(_type))
    end

    return coords
end

xLib.points = {}

---@return CPoint
---@overload fun(data: PointProperties): CPoint
---@overload fun(coords: vector3, distance: number, data?: PointProperties): CPoint
function xLib.points.new(...)
    local args = { ... }
    local id = #points + 1
    local self

    -- Support sending a single argument containing point data
    if type(args[1]) == 'table' then
        self = args[1]
        self.id = id
        self.remove = removePoint
    else
        -- Backwards compatibility for original implementation (args: coords, distance, data)
        self = {
            id = id,
            coords = args[1],
            remove = removePoint,
        }
    end

    self.coords = toVector(self.coords)
    self.distance = self.distance or args[2]
    self.radius = self.distance

    if args[3] then
        for k, v in pairs(args[3]) do
            self[k] = v
        end
    end

    xLib.grid.addEntry(self)
    points[id] = self

    return self
end

function xLib.points.getAllPoints() return points end

function xLib.points.getNearbyPoints() return nearbyPoints end

---@return CPoint?
function xLib.points.getClosestPoint() return closestPoint end

---@deprecated
xLib.points.closest = xLib.points.getClosestPoint

return xLib.points