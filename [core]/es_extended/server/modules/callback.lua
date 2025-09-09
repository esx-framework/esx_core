---@diagnostic disable: duplicate-set-field

-- =============================================
-- MARK: Variables
-- =============================================

Callbacks = {}

Callbacks.requests = {}
Callbacks.storage = {}
Callbacks.id = 0

-- =============================================
-- MARK: Internal Functions
-- =============================================

function Callbacks:Register(name, resource, cb)
    self.storage[name] = {
        resource = resource,
        cb = cb
    }
end

function Callbacks:Execute(cb, ...)
    local success, errorString = pcall(cb, ...)

    if not success then
        print(("[^1ERROR^7] Failed to execute Callback with RequestId: ^5%s^7"):format(self.currentId))
        print("^3Callback Error:^7 " .. tostring(errorString))  -- just log, don't throw
        self.currentId = nil
        return
    end

    self.currentId = nil
end

function Callbacks:Trigger(player, event, cb, invoker, ...)
    self.requests[self.id] = {
        await = type(cb) == "boolean",
        cb = cb or promise:new()
    }
    local request = self.requests[self.id]

    TriggerClientEvent("esx:triggerClientCallback", player, event, self.id, invoker, ...)

    self.id += 1

    return request.cb
end

function Callbacks:ServerReceive(player, event, requestId, invoker, ...)
    self.currentId = requestId

    if not self.storage[event] then
        return error(("Server Callback with requestId ^5%s^1 Was Called by ^5%s^1 but does not exist."):format(event, invoker))
    end

    local returnCb = function(...)
        TriggerClientEvent("esx:serverCallback", player, requestId, invoker, ...)
    end
    local callback = self.storage[event].cb

    self:Execute(callback, player, returnCb, ...)
end

function Callbacks:ReceiveClient(requestId, invoker, ...)
    self.currentId = requestId

    if not self.requests[self.currentId] then
        return error(("Client Callback with requestId ^5%s^1 Was Called by ^5%s^1 but does not exist."):format(self.currentId, invoker))
    end

    local callback = self.requests[self.currentId]

    self.requests[requestId] = nil
    if callback.await then
        callback.cb:resolve({ ... })
    else
        self:Execute(callback.cb, ...)
    end
end

-- =============================================
-- MARK: ESX Functions
-- =============================================

---@param player number playerId
---@param eventName string
---@param callback function
---@param ... any
function ESX.TriggerClientCallback(player, eventName, callback, ...)
    local invokingResource = GetInvokingResource()
    local invoker = (invokingResource and invokingResource ~= "unknown") and invokingResource or "es_extended"

    Callbacks:Trigger(player, eventName, callback, invoker, ...)
end

---@param player number playerId
---@param eventName string
---@param ... any
---@return ...
function ESX.AwaitClientCallback(player, eventName, ...)
    local invokingResource = GetInvokingResource()
    local invoker = (invokingResource and invokingResource ~= "unknown") and invokingResource or "es_extended"

    local p = Callbacks:Trigger(player, eventName, false, invoker, ...)
    if not p then return end

    SetTimeout(15000, function()
        if p.state == "pending" then
            p:reject("Server Callback Timed Out")
        end
    end)

    Citizen.Await(p)

    return table.unpack(p.value or {})
end

---@param eventName string
---@param callback function
---@return nil
function ESX.RegisterServerCallback(eventName, callback)
    local invokingResource = GetInvokingResource()
    local invoker = (invokingResource and invokingResource ~= "unknown") and invokingResource or "es_extended"

    Callbacks:Register(eventName, invoker, callback)
end

---@param eventName string
---@return boolean
function ESX.DoesServerCallbackExist(eventName)
    return Callbacks.storage[eventName] ~= nil
end

-- =============================================
-- MARK: Events
-- =============================================

RegisterNetEvent("esx:clientCallback", function(requestId, invoker, ...)
    Callbacks:ReceiveClient(requestId, invoker, ...)
end)

RegisterNetEvent("esx:triggerServerCallback", function(eventName, requestId, invoker, ...)
    local source = source
    Callbacks:ServerReceive(source, eventName, requestId, invoker, ...)
end)

AddEventHandler("onResourceStop", function(resource)
    for k, v in pairs(Callbacks.storage) do
        if v.resource == resource then
            Callbacks.storage[k] = nil
        end
    end
end)
