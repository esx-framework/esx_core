---@class xClass 
---@field new function
---@field constructor function?

---Create or register a class
---@param copy? table
---@return table
function xLib.class(copy)
    xLib.verify(copy, { 'table', 'nil' }, true)

    local class = copy and xLib.table.deepcopy(copy) or {}

    class.__index = class
    class._isClass = true

    setmetatable(class, {
        __newindex = function (_, k,v)
            rawset(class, k, v)
        end
    })

    function class:new(...)
        local obj = setmetatable({}, class)

        if xLib.verify(obj.constructor, 'function') then
            obj:constructor(...)
        end

        return obj
    end

    return class
end

return xLib.class