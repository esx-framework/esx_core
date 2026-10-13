xLib.timeout = {}

local TimeoutCount = 0
local CancelledTimeouts = {}

---@param msec number
---@param cb function
---@return number
xLib.timeout.setTimeout = function(msec, cb)
    xLib.verify(cb, "function", true)
    
    local id <const> = TimeoutCount + 1

    SetTimeout(msec, function()
        if CancelledTimeouts[id] then
            CancelledTimeouts[id] = nil
            return
        end
        cb()
    end)

    TimeoutCount = id

    return id
end

---@param id number
---@return nil
xLib.timeout.clearTimeout = function(id)
    CancelledTimeouts[id] = true
end

return xLib.timeout
