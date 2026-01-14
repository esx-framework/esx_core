--!DISCLAIMER
--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local glm = require 'glm'

---@class ZoneProperties
---@field debug? boolean
---@field debugColour? vector4
---@field onEnter fun(self: CZone)?
---@field onExit fun(self: CZone)?
---@field inside fun(self: CZone)?
---@field [string] any

---@class CZone : PolyZone, BoxZone, SphereZone
---@field id number
---@field __type 'poly' | 'sphere' | 'box'
---@field remove fun(self: self)
---@field setDebug fun(self: CZone, enable?: boolean, colour?: vector)
---@field contains fun(self: CZone, coords?: vector3, updateDistance?: boolean): boolean

---@type table<number, CZone>
local Zones = {}
_ENV.Zones = Zones

local function nextFreePoint(points, b, len)
    for i = 1, len do
        local n = (i + b) % len

        n = n ~= 0 and n or len

        if points[n] then
            return n
        end
    end
end

local function unableToSplit(polygon)
    print('The following polygon is malformed and has failed to be split into triangles for debug')

    for k, v in pairs(polygon) do
        print(k, v)
    end
end

local function getTriangles(polygon)
    local triangles = {}

    if polygon:isConvex() then
        for i = 2, #polygon - 1 do
            triangles[#triangles + 1] = mat(polygon[1], polygon[i], polygon[i + 1])
        end

        return triangles
    end

    if not polygon:isSimple() then
        unableToSplit(polygon)

        return triangles
    end

    local points = {}
    local polygonN = #polygon

    for i = 1, polygonN do
        points[i] = polygon[i]
    end

    local a, b, c = 1, 2, 3
    local zValue = polygon[1].z
    local count = 0

    while polygonN - #triangles > 2 do
        local a2d = polygon[a].xy
        local c2d = polygon[c].xy

        if polygon:containsSegment(vec3(glm.segment2d.getPoint(a2d, c2d, 0.01), zValue), vec3(glm.segment2d.getPoint(a2d, c2d, 0.99), zValue)) then
            triangles[#triangles + 1] = mat(polygon[a], polygon[b], polygon[c])
            points[b] = false

            b = c
            c = nextFreePoint(points, b, polygonN)
        else
            a = b
            b = c
            c = nextFreePoint(points, b, polygonN)
        end

        count += 1

        if count > polygonN and #triangles == 0 then
            unableToSplit(polygon)

            return triangles
        end

        Wait(0)
    end

    return triangles
end

local insideZones = not IsDuplicityVersion() and {} --[[@as table<number, CZone>]]
local exitingZones = not IsDuplicityVersion() and xLib.table.array:new() --[[@as Array<CZone>]]
local enteringZones = not IsDuplicityVersion() and xLib.table.array:new() --[[@as Array<CZone>]]
local nearbyZones = xLib.table.array:new() --[[@as Array<CZone>]]
local glm_polygon_contains = glm.polygon.contains
local tick

---@param zone CZone
local function removeZone(zone)
    Zones[zone.id] = nil

    xLib.grid.removeEntry(zone)

    if IsDuplicityVersion() then return end

    insideZones[zone.id] = nil

    table.remove(exitingZones, exitingZones:indexOf(zone))
    table.remove(enteringZones, enteringZones:indexOf(zone))
end

CreateThread(function()
    if IsDuplicityVersion() then return end

    while true do
        local coords = GetEntityCoords(PlayerPedId())
        local zones = xLib.grid.getNearbyEntries(coords, function(entry) return entry.remove == removeZone end) --[[@as Array<CZone>]]
        local cellX, cellY = xLib.grid.getCellPosition(coords)

        for i = 1, #nearbyZones do
            local zone = nearbyZones[i]

            if zone.insideZone then
                local contains = zone:contains(coords, true)

                if not contains then
                    zone.insideZone = false
                    insideZones[zone.id] = nil

                    if zone.onExit then
                        exitingZones:push(zone)
                    end
                end
            end
        end

        nearbyZones = zones

        for i = 1, #zones do
            local zone = zones[i]
            local contains = zone:contains(coords, true)

            if contains then
                if not zone.insideZone then
                    zone.insideZone = true

                    if zone.onEnter then
                        enteringZones:push(zone)
                    end

                    if zone.inside or zone.debug then
                        insideZones[zone.id] = zone
                    end
                end
            else
                if zone.insideZone then
                    zone.insideZone = false
                    insideZones[zone.id] = nil

                    if zone.onExit then
                        exitingZones:push(zone)
                    end
                end

                if zone.debug then
                    insideZones[zone.id] = zone
                end
            end
        end

        local exitingSize = #exitingZones
        local enteringSize = #enteringZones

        if exitingSize > 0 then
            table.sort(exitingZones, function(a, b)
                return a.distance < b.distance
            end)

            for i = exitingSize, 1, -1 do
                exitingZones[i]:onExit()
            end

            table.wipe(exitingZones)
        end

        if enteringSize > 0 then
            table.sort(enteringZones, function(a, b)
                return a.distance < b.distance
            end)

            for i = 1, enteringSize do
                enteringZones[i]:onEnter()
            end

            table.wipe(enteringZones)
        end

        if not tick then
            if next(insideZones) then
                tick = true
                CreateThread(function()
                    while tick and next(insideZones) do
                        for _, zone in pairs(insideZones) do
                            if zone.debug then
                                zone:debug()
                            
                                if zone.inside and zone.insideZone then
                                    zone:inside()
                                end
                            else
                                zone:inside()
                            end
                        end
                        Wait(0)
                    end
                    tick = nil
                end)
            end
        elseif not next(insideZones) then
            tick = false
        end

        Wait(300)
    end
end)

local DrawLine = DrawLine
local DrawPoly = DrawPoly

local function debugPoly(self)
    for i = 1, #self.triangles do
        local triangle = self.triangles[i]
        DrawPoly(triangle[1].x, triangle[1].y, triangle[1].z, triangle[2].x, triangle[2].y, triangle[2].z, triangle[3].x, triangle[3].y, triangle[3].z,
            self.debugColour.r, self.debugColour.g, self.debugColour.b, self.debugColour.a)
        DrawPoly(triangle[2].x, triangle[2].y, triangle[2].z, triangle[1].x, triangle[1].y, triangle[1].z, triangle[3].x, triangle[3].y, triangle[3].z,
            self.debugColour.r, self.debugColour.g, self.debugColour.b, self.debugColour.a)
    end
    for i = 1, #self.polygon do
        local thickness = vec(0, 0, self.thickness / 2)
        local a = self.polygon[i] + thickness
        local b = self.polygon[i] - thickness
        local c = (self.polygon[i + 1] or self.polygon[1]) + thickness
        local d = (self.polygon[i + 1] or self.polygon[1]) - thickness
        DrawLine(a.x, a.y, a.z, b.x, b.y, b.z, self.debugColour.r, self.debugColour.g, self.debugColour.b, 225)
        DrawLine(a.x, a.y, a.z, c.x, c.y, c.z, self.debugColour.r, self.debugColour.g, self.debugColour.b, 225)
        DrawLine(b.x, b.y, b.z, d.x, d.y, d.z, self.debugColour.r, self.debugColour.g, self.debugColour.b, 225)
        DrawPoly(a.x, a.y, a.z, b.x, b.y, b.z, c.x, c.y, c.z, self.debugColour.r, self.debugColour.g, self.debugColour.b, self.debugColour.a)
        DrawPoly(c.x, c.y, c.z, b.x, b.y, b.z, a.x, a.y, a.z, self.debugColour.r, self.debugColour.g, self.debugColour.b, self.debugColour.a)
        DrawPoly(b.x, b.y, b.z, c.x, c.y, c.z, d.x, d.y, d.z, self.debugColour.r, self.debugColour.g, self.debugColour.b, self.debugColour.a)
        DrawPoly(d.x, d.y, d.z, c.x, c.y, c.z, b.x, b.y, b.z, self.debugColour.r, self.debugColour.g, self.debugColour.b, self.debugColour.a)
    end
end

local function debugSphere(self)
    DrawMarker(28, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, self.radius, self.radius, self.radius, self.debugColour.r,
        ---@diagnostic disable-next-line: param-type-mismatch
        self.debugColour.g, self.debugColour.b, self.debugColour.a, false, false, 0, false, false, false, false)
end

local function contains(self, coords, updateDistance)
    if updateDistance then self.distance = #(self.coords - coords) end

    return glm_polygon_contains(self.polygon, coords, self.thickness / 4)
end

local function insideSphere(self, coords, updateDistance)
    local distance = #(self.coords - coords)

    if updateDistance then self.distance = distance end

    return distance < self.radius
end

local function convertToVector(coords)
    local _type = type(coords)

    if _type ~= 'vector3' then
        if _type == 'table' or _type == 'vector4' then
            return vec3(coords[1] or coords.x, coords[2] or coords.y, coords[3] or coords.z)
        end

        error(("expected type 'vector3' or 'table' (received %s)"):format(_type))
    end

    return coords
end

local function setDebug(self, bool, colour)
    if not bool and insideZones[self.id] then
        insideZones[self.id] = nil
    end

    self.debugColour = bool and
        {
            r = glm.tointeger(colour?.r or self.debugColour?.r or 255),
            g = glm.tointeger(colour?.g or self.debugColour?.g or 42),
            b = glm.tointeger(colour?.b or
                self.debugColour?.b or 24),
            a = glm.tointeger(colour?.a or self.debugColour?.a or 100)
        } or nil

    if not bool and self.debug then
        self.triangles = nil
        self.debug = nil
        return
    end

    if bool and self.debug and self.debug ~= true then return end

    self.triangles = self.__type == 'poly' and getTriangles(self.polygon) or
        self.__type == 'box' and { mat(self.polygon[1], self.polygon[2], self.polygon[3]), mat(self.polygon[1], self.polygon[3], self.polygon[4]) } or nil
    self.debug = self.__type == 'sphere' and debugSphere or debugPoly or nil
end

---@param data ZoneProperties
---@return CZone
local function setZone(data)
    ---@cast data CZone
    data.remove = removeZone
    data.contains = data.contains or contains

    if not IsDuplicityVersion() then
        data.setDebug = setDebug

        if data.debug then
            data.debug = nil

            data:setDebug(true, data.debugColour)
        end
    else
        data.debug = nil
    end

    Zones[data.id] = data
    xLib.grid.addEntry(data)

    return data
end

xLib.zones = {}

---@class PolyZone : ZoneProperties
---@field points vector3[]
---@field thickness? number

---@param data PolyZone
---@return CZone
function xLib.zones.poly(data)
    data.id = #Zones + 1
    data.thickness = data.thickness or 4

    local pointN = #data.points
    local points = table.create(pointN, 0)

    for i = 1, pointN do
        points[i] = convertToVector(data.points[i])
    end

    data.polygon = glm.polygon.new(points)

    if not data.polygon:isPlanar() then
        local zCoords = {}

        for i = 1, pointN do
            local zCoord = points[i].z

            if zCoords[zCoord] then
                zCoords[zCoord] += 1
            else
                zCoords[zCoord] = 1
            end
        end

        local coordsArray = {}

        for coord, count in pairs(zCoords) do
            coordsArray[#coordsArray + 1] = {
                coord = coord,
                count = count
            }
        end

        table.sort(coordsArray, function(a, b)
            return a.count > b.count
        end)

        local zCoord = coordsArray[1].coord
        local averageTo = 1

        for i = 1, #coordsArray do
            if coordsArray[i].count < coordsArray[1].count then
                averageTo = i - 1
                break
            end
        end

        if averageTo > 1 then
            for i = 2, averageTo do
                zCoord += coordsArray[i].coord
            end

            zCoord /= averageTo
        end

        for i = 1, pointN do
            ---@diagnostic disable-next-line: param-type-mismatch
            points[i] = vec3(data.points[i].xy, zCoord)
        end

        data.polygon = glm.polygon.new(points)
    end

    data.coords = data.polygon:centroid()
    data.__type = 'poly'
    data.radius = xLib.table.array.reduce(data.polygon, function(acc, point)
        local distance = #(point - data.coords)
        return distance > acc and distance or acc
    end, 0)

    return setZone(data)
end

---@class BoxZone : ZoneProperties
---@field coords vector3
---@field size? vector3
---@field rotation? number | vector3 | vector4 | matrix

---@param data BoxZone
---@return CZone
function xLib.zones.box(data)
    data.id = #Zones + 1
    data.coords = convertToVector(data.coords)
    data.size = data.size and convertToVector(data.size) / 2 or vec3(2)
    data.thickness = data.size.z * 2
    data.rotation = quat(data.rotation or 0, vec3(0, 0, 1))
    data.__type = 'box'
    data.width = data.size.x * 2
    data.length = data.size.y * 2
    data.polygon = (data.rotation * glm.polygon.new({
        vec3(data.size.x, data.size.y, 0),
        vec3(-data.size.x, data.size.y, 0),
        vec3(-data.size.x, -data.size.y, 0),
        vec3(data.size.x, -data.size.y, 0),
    }) + data.coords)

    return setZone(data)
end

---@class SphereZone : ZoneProperties
---@field coords vector3
---@field radius? number

---@param data SphereZone
---@return CZone
function xLib.zones.sphere(data)
    data.id = #Zones + 1
    data.coords = convertToVector(data.coords)
    data.radius = (data.radius or 2) + 0.0
    data.__type = 'sphere'
    data.contains = insideSphere

    return setZone(data)
end

function xLib.zones.getAllZones() return Zones end

function xLib.zones.getCurrentZones() return insideZones end

function xLib.zones.getNearbyZones() return nearbyZones end

return xLib.zones