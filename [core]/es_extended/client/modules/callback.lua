---@diagnostic disable: duplicate-set-field

Callbacks = {}

Callbacks.requests = {}
Callbacks.storage = {}
Callbacks.id = 0

function Callbacks:Trigger(event, cb, invoker, ...)
    self.requests[self.id] = cb
    TriggerServerEvent("esx:triggerServerCallback", event, self.id, invoker, ...)

    self.id += 1
end

function Callbacks:Execute(cb, ...)
    local success, errorString = pcall(cb, ...)

    if not success then
        print(("[^1ERROR^7] Failed to execute Callback with RequestId: ^5%s^7"):format(self.currentId))
        error(errorString)
        return
    end
    self.currentId = nil
end

function Callbacks:ServerRecieve(requestId, invoker, ...)
    self.currentId = requestId
    if not self.requests[self.currentId] then
        return error(("Server Callback with requestId ^5%s^1 Was Called by ^5%s^1 but does not exist."):format(self.currentId, invoker))
    end

    local callback = self.requests[self.currentId]

    Callbacks:Execute(callback, ...)
    self.requests[requestId] = nil
end

function Callbacks:Register(name, cb)
    self.storage[name] = cb
end

function Callbacks:ClientRecieve(eventName, requestId, invoker, ...)
    self.currentId = requestId

    if not self.storage[eventName] then
        return error(("Client Callback with requestId ^5%s^1 Was Called by ^5%s^1 but does not exist."):format(eventName, invoker))
    end

    local returnCb = function(...)
        TriggerServerEvent("esx:clientCallback", requestId, invoker, ...)
    end
    local callback = self.storage[eventName]

    Callbacks:Execute(callback, returnCb, ...)
end

---@param eventName string
---@param callback function
---@param ... any
---@return nil
ESX.TriggerServerCallback = function(eventName, callback, ...)
    local invokingResource = GetInvokingResource()
    local invoker = (invokingResource and invokingResource ~= "unknown") and invokingResource or "es_extended"

    Callbacks:Trigger(eventName, callback, invoker, ...)
end

ESX.SecureNetEvent("esx:serverCallback", function(...)
    Callbacks:ServerRecieve(...)
end)

---@param eventName string
---@param callback function
---@return nil
ESX.RegisterClientCallback = function(eventName, callback)
    Callbacks:Register(eventName, callback)
end

ESX.SecureNetEvent("esx:triggerClientCallback", function(...)
    Callbacks:ClientRecieve(...)
end)
