---@class pointslib
xLib.points = {}

local points = {}
local insidePoints = {}
local handleCount = 0
local loopStarted = false

---@param coords vector3
---@param distance number
---@param hidden? boolean
---@param enter function
---@param leave function
---@param inside? function
---@return integer handle
function xLib.points.create(coords, distance, hidden, enter, leave, inside)
    handleCount = handleCount + 1
    local handle = handleCount

    points[handle] = {
        coords = coords,
        distance = distance,
        hidden = hidden,
        enter = enter,
        leave = leave,
        inside = inside,
        resource = GetInvokingResource()
    }

    return handle
end

---@param handle integer
function xLib.points.remove(handle)
    points[handle] = nil
    insidePoints[handle] = nil
end

---@param handle integer
---@param hidden boolean
function xLib.points.hide(handle, hidden)
    if points[handle] then
        points[handle].hidden = hidden
    end
end

function xLib.points.startLoop()
    if loopStarted then
        return
    end

    loopStarted = true

    CreateThread(function()
        local lastScan = 0

        while true do
            local coords = GetEntityCoords(PlayerPedId())

            for _, point in pairs(insidePoints) do
                point.inside(#(coords - point.coords))
            end

            local now = GetGameTimer()
            if now - lastScan >= 500 then
                lastScan = now

                for handle, point in pairs(points) do
                    if not point.hidden and #(coords - point.coords) <= point.distance then
                        if not point.nearby then
                            point.nearby = true

                            if point.enter then
                                point.enter()
                            end

                            if point.inside then
                                insidePoints[handle] = point
                            end
                        end
                    elseif point.nearby then
                        point.nearby = false

                        if point.leave then
                            point.leave()
                        end

                        insidePoints[handle] = nil
                    end
                end
            end

            Wait(next(insidePoints) and 0 or 500)
        end
    end)
end

AddEventHandler("onResourceStop", function(resource)
    for handle, point in pairs(points) do
        if point.resource == resource then
            points[handle] = nil
            insidePoints[handle] = nil
        end
    end
end)

return xLib.points
