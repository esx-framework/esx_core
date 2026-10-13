---@class xPoint
---@field coords vector3
---@field hidden? boolean
---@field enter? function
---@field leave? function
---@field inside? function
---@field handle integer
xLib.point = xLib.class()

---@param properties table coords, distance, hidden, enter, leave, inside
function xLib.point:constructor(properties)
    self.coords = properties.coords
    self.hidden = properties.hidden
    self.enter = properties.enter
    self.leave = properties.leave
    self.inside = properties.inside

    self.handle = xLib.points.create(
        properties.coords,
        properties.distance,
        properties.hidden,
        function()
            if self.enter then
                self:enter()
            end
        end,
        function()
            if self.leave then
                self:leave()
            end
        end,
        properties.inside and function(dist)
            self:inside(dist)
        end or nil
    )
end

function xLib.point:delete()
    xLib.points.remove(self.handle)
end

---@param hidden? boolean
function xLib.point:toggle(hidden)
    if hidden == nil then
        hidden = not self.hidden
    end

    self.hidden = hidden
    xLib.points.hide(self.handle, hidden)
end

return xLib.point
