local serverCallbacks = {}

local clientRequests = {}
local RequestId = 0

---@param eventName string
---@param callback function
ESX.RegisterServerCallback = function(eventName, callback)
  serverCallbacks[eventName] = callback
end

RegisterNetEvent('esx:triggerServerCallback', function(eventName, requestId, invoker, ...)
  if not serverCallbacks[eventName] then
    return print(('[^1ERROR^7] Server Callback not registered, name: ^5%s^7, invoker resource: ^5%s^7'):format(eventName, invoker))
  end

  local source = source

  serverCallbacks[eventName](source, function(...)
    TriggerClientEvent('esx:serverCallback', source, requestId, invoker, ...)
  end, ...)
end)

ESX.TriggerClientCallback = setmetatable({
  ---@param player number?
  ---@param eventName string
  ---@param ... any
  Await = function(player, eventName, ...)
    player = tonumber(player)

    assert(player, 'Argument 1 `player` is not a number!')
    assert(type(eventName) == 'string', 'Argument 2 `eventName` is not a string!')

    local p = promise.new()

    clientRequests[RequestId] = p

    TriggerClientEvent('esx:triggerClientCallback', player, eventName, RequestId, GetInvokingResource() or "unknown", ...)

    RequestId = RequestId + 1

    return Citizen.Await(p)
  end
}, {
  ---@param player number? playerId
  ---@param eventName string
  ---@param callback function
  ---@param ... any
  __call = function(_, player, eventName, callback, ...)
    player = tonumber(player)

    assert(player, 'Argument 1 `player` is not a number!')
    assert(type(eventName) == 'string', 'Argument 2 `eventName` is not a string!')
    assert(type(callback) == 'function', 'Argument 3 `callback` is not a function!')

    clientRequests[RequestId] = callback

    TriggerClientEvent('esx:triggerClientCallback', player, eventName, RequestId, GetInvokingResource() or "unknown", ...)

    RequestId = RequestId + 1
  end
})

RegisterNetEvent('esx:clientCallback', function(requestId, invoker, ...)
  if not clientRequests[requestId] then
    return print(('[^1ERROR^7] Client Callback with requestId ^5%s^7 Was Called by ^5%s^7 but does not exist.'):format(requestId, invoker))
  end

  if type(clientRequests[requestId]) == 'table' then
    clientRequests[requestId]:resolve(...)
    return
  end

  clientRequests[requestId](...)
  clientRequests[requestId] = nil
end)