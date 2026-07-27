---@class pointslib
xLib.points = {}

local points = {}
local insidePoints = {}
local handleCount = 0

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
    CreateThread(function()
        local lastScan = 0

        while true do
            local coords = GetEntityCoords(PlayerPedId())

            for handle, point in pairs(insidePoints) do
                if not pcall(point.inside, #(coords - point.coords)) then
                    insidePoints[handle] = nil
                    print(("[^1ERROR^7] point ^5%s^7 from ^5%s^7 errored on inside"):format(handle, point.resource))
                end
            end

            local now = GetGameTimer()
            if now - lastScan >= 500 then
                lastScan = now

                for handle, point in pairs(points) do
                    if not point.hidden and #(coords - point.coords) <= point.distance then
                        if not point.nearby then
                            point.nearby = true

                            if point.enter and not pcall(point.enter) then
                                print(("[^1ERROR^7] point ^5%s^7 from ^5%s^7 errored on enter"):format(handle, point.resource))
                            end

                            if point.inside then
                                insidePoints[handle] = point
                            end
                        end
                    elseif point.nearby then
                        point.nearby = false

                        if point.leave and not pcall(point.leave) then
                            print(("[^1ERROR^7] point ^5%s^7 from ^5%s^7 errored on leave"):format(handle, point.resource))
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
