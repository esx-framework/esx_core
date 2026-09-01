---@diagnostic disable: duplicate-set-field

---@param player number playerId
---@param eventName string
---@param callback function
---@param ... any
---@return nil
function ESX.TriggerClientCallback(player, eventName, callback, ...)
    return xLib.callback(eventName, player, callback, ...)
end

---@param player number playerId
---@param eventName string
---@param ... any
---@return ...
function ESX.AwaitClientCallback(player, eventName, ...)
    return xLib.callback.await(eventName, player, ...)
end

---@param eventName string
---@param callback function
---@return nil
function ESX.RegisterServerCallback(eventName, callback)
    return xLib.callback.registerCompat(eventName, callback)
end

---@param eventName string
---@return boolean
function ESX.DoesServerCallbackExist(eventName)
    return xLib.isCallbackValid(eventName)
end
