xLib.Raycast = {}
xLib.Raycast.__index = xLib.Raycast

local unpack = table.unpack
local GetShapeTestResultIncludingMaterial = GetShapeTestResultIncludingMaterial
local StartShapeTestLosProbe = StartShapeTestLosProbe
local GetWorldCoordFromScreenCoord = GetWorldCoordFromScreenCoord

---@param shape integer The shape test handle to wait for
---@return boolean, table, table, integer, integer
function xLib.Raycast.GetShapeTestResult(shape)
    local handle, hit, coords, normal, material, entity

    repeat
        handle, hit, coords, normal, material, entity = GetShapeTestResultIncludingMaterial(shape)
        Wait(0)
    until handle ~= 1

    return hit, coords, normal, material, entity
end

---@param depth number The raycast distance
---@vararg any Additional arguments to pass to shape test
---@return table, boolean, table, table, integer, integer
function xLib.Raycast.FromScreen(depth, ...)
    local worldCoords, normalVector = GetWorldCoordFromScreenCoord(0.5, 0.5)
    local origin = worldCoords + normalVector
    local target = worldCoords + normalVector * depth
    return target, xLib.Raycast.GetShapeTestResult(StartShapeTestLosProbe(origin.x, origin.y, origin.z, target.x, target.y, target.z, ...))
end

-- Start continuous raycasting
---@param depth number The raycast distance
---@vararg any Additional arguments to pass to shape test
function xLib.Raycast.Start(depth, ...)
    local self = setmetatable({}, xLib.Raycast)

    self.refreshRate = refreshRate
    self.depth = depth
    self.args = {...}

    self.active = true

    self._thread = CreateThread(function()
        while self.active do
            local target, hit, coords, normal, material, entity = xLib.Raycast.FromScreen(self.depth, unpack(self.args))
            self.result = {
                hit = hit,
                coords = coords,
                normal = normal,
                material = material,
                entity = entity,
            }
            Wait(1)
        end
    end)

    return self
end

-- Stop raycasting
function xLib.Raycast:Stop()
    if not self and not self.active then return end
    self.active = false
    if self._thread then
        self._thread = nil
    end
end

-- Check if the raycating is active
---@return boolean
function xLib.Raycast:IsActive()
    if not self and not self.active then return end
    return self.active
end

return xLib.Raycast
