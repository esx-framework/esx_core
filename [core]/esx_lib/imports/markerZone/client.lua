-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@class markerzonelib
xLib.markerZone = {}

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

local function axis(value, key, fallback)
    if type(value) == "vector3" then
        return value[key]
    end

    if type(value) == "table" then
        return value[key] or value[key == "x" and 1 or key == "y" and 2 or 3] or fallback
    end

    return fallback
end

local function drawMarker(marker, coords)
    marker = marker or {}

    local size = marker.size or marker.scale or {}
    local color = marker.color or {}
    local rotation = marker.rotation or marker.rot or {}

    DrawMarker(
        marker.type or marker.markerType or 1,
        coords.x,
        coords.y,
        coords.z,
        axis(marker.direction, "x", 0.0),
        axis(marker.direction, "y", 0.0),
        axis(marker.direction, "z", 0.0),
        axis(rotation, "x", 0.0),
        axis(rotation, "y", 0.0),
        axis(rotation, "z", 0.0),
        axis(size, "x", marker.sizeX or 1.5),
        axis(size, "y", marker.sizeY or 1.5),
        axis(size, "z", marker.sizeZ or 1.0),
        color.r or color[1] or marker.r or 255,
        color.g or color[2] or marker.g or 255,
        color.b or color[3] or marker.b or 255,
        color.a or color[4] or marker.a or 100,
        marker.bobUpAndDown or false,
        marker.faceCamera ~= false,
        marker.p19 or 2,
        marker.rotate or false,
        marker.textureDict,
        marker.textureName,
        marker.drawOnEnts or false
    )
end

---@class MarkerZoneOptions
---@field coords table|vector3
---@field distance? number
---@field drawDistance? number
---@field interactDistance? number
---@field exitDistance? number
---@field marker? table|false
---@field hidden? boolean
---@field canDraw? fun(distance: number): boolean
---@field canInteract? fun(distance: number): boolean
---@field onEnterPoint? fun()
---@field onExitPoint? fun()
---@field onEnter? fun(distance: number)
---@field onExit? fun(distance: number)
---@field onInside? fun(distance: number)

---@param data MarkerZoneOptions
---@return table|nil zone
function xLib.markerZone.create(data)
    if type(data) ~= "table" then
        return
    end

    local coords = toVector3(data.coords)
    if not coords then
        return
    end

    local drawDistance = tonumber(data.drawDistance or data.distance) or 10.0
    local interactDistance = tonumber(data.interactDistance or data.actionDistance or data.enterDistance) or 1.5
    local exitDistance = tonumber(data.exitDistance) or interactDistance
    local marker = data.marker
    local inInteractionRange = false
    local pointNearby = false

    ---@param distance number
    local function leave(distance)
        if inInteractionRange then
            inInteractionRange = false
            if data.onExit then data.onExit(distance) end
        end

        if pointNearby then
            pointNearby = false
            if data.onExitPoint then data.onExitPoint() end
        end
    end

    local handle = xLib.points.create(
        coords,
        drawDistance,
        data.hidden,
        function()
            pointNearby = true
            if data.onEnterPoint then data.onEnterPoint() end
        end,
        function()
            leave(drawDistance)
        end,
        function(distance)
            if marker ~= false and (not data.canDraw or data.canDraw(distance)) then
                drawMarker(marker, coords)
            end

            local activeDistance = inInteractionRange and exitDistance or interactDistance
            local canInteract = distance <= activeDistance and (not data.canInteract or data.canInteract(distance))

            if canInteract then
                if not inInteractionRange then
                    inInteractionRange = true
                    if data.onEnter then data.onEnter(distance) end
                end

                if data.onInside then data.onInside(distance) end
            elseif inInteractionRange then
                inInteractionRange = false
                if data.onExit then data.onExit(distance) end
            end
        end
    )

    xLib.points.startLoop()

    return {
        handle = handle,
        remove = function()
            xLib.points.remove(handle)

            if inInteractionRange or pointNearby then
                local ok, err = pcall(leave, #(GetEntityCoords(PlayerPedId()) - coords))

                if not ok then
                    print(("[^1ERROR^7] markerZone ^5%s^7 errored on remove: %s"):format(handle, err))
                end
            end
        end,
        hide = function(hidden)
            xLib.points.hide(handle, hidden ~= false)
        end,
        show = function()
            xLib.points.hide(handle, false)
        end
    }
end

return xLib.markerZone
