local RequestId = 0
local serverRequests = {}

local clientCallbacks = {}

ESX.TriggerServerCallback = setmetatable({
  ---@param eventName string
  ---@param ... any
  Await = function(eventName, ...)
    assert(type(eventName) == 'string', 'Argument 1 `eventName` is not a string!')
    local p = promise.new()

    serverRequests[RequestId] = p

    TriggerServerEvent('esx:triggerServerCallback', eventName, RequestId, GetInvokingResource() or "unknown", ...)

    RequestId = RequestId + 1

    return Citizen.Await(p)
  end
}, {
  ---@param eventName string
  ---@param callback function
  ---@param ... any
  __call = function(_, eventName, callback, ...)
    assert(type(eventName) == 'string', 'Argument 1 `eventName` is not a string!')
    assert(type(callback) == 'function', 'Argument 2 `callback` is not a function!')

    serverRequests[RequestId] = callback

    TriggerServerEvent('esx:triggerServerCallback', eventName, RequestId, GetInvokingResource() or "unknown", ...)

    RequestId = RequestId + 1
  end
})

RegisterNetEvent('esx:serverCallback', function(requestId, invoker, ...)
  if not serverRequests[requestId] then
    return print(('[^1ERROR^7] Server Callback with requestId ^5%s^7 Was Called by ^5%s^7 but does not exist.'):format(requestId, invoker))
  end

  if type(serverRequests[requestId]) == 'table' then
    serverRequests[requestId]:resolve(...)
    return
  end

  serverRequests[requestId](...)
  serverRequests[requestId] = nil
end)

---@param eventName string
---@param callback function
ESX.RegisterClientCallback = function(eventName, callback)
  clientCallbacks[eventName] = callback
end

RegisterNetEvent('esx:triggerClientCallback', function(eventName, requestId, invoker, ...)
  if not clientCallbacks[eventName] then
    return print(('[^1ERROR^7] Client Callback not registered, name: ^5%s^7, invoker resource: ^5%s^7'):format(eventName, invoker))
  end

  clientCallbacks[eventName](function(...)
    TriggerServerEvent('esx:clientCallback', requestId, invoker, ...)
  end, ...)
end)