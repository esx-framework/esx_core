---@diagnostic disable: duplicate-set-field

---@param eventName string
---@param callback function
---@param ... any
---@return nil
function ESX.TriggerServerCallback(eventName, callback, ...)
    return xLib.callback(eventName, false, callback, ...)
end

---@param eventName string
---@param ... any
---@return ...
function ESX.AwaitServerCallback(eventName, ...)
    return xLib.callback.await(eventName, false, ...)
end

---@param eventName string
---@param callback function
---@return nil
function ESX.RegisterClientCallback(eventName, callback)
    return xLib.callback.registerCompat(eventName, callback)
end

---@param eventName string
---@return boolean
function ESX.DoesClientCallbackExist(eventName)
    return xLib.isCallbackValid(eventName)
end
