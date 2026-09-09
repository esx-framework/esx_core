---@diagnostic disable: duplicate-set-field

-- =============================================
-- MARK: Variables
-- =============================================

Callbacks = {}

Callbacks.requests = {}
Callbacks.storage = {}
Callbacks.id = 0

local PENDING <const> = 0
local TIMEOUT <const> = GetConvarInt("esx:callbackTimeout", 15000)

-- =============================================
-- MARK: Internal Functions
-- =============================================


function Callbacks:Register(name, resource, cb)
    self.storage[name] = {
        resource = resource,
        cb = cb
    }
end

function Callbacks:Execute(cb, id, ...)
    local success, errorString = pcall(cb, ...)

    if not success then
        print(("[^1ERROR^7] Failed to execute Callback with RequestId: ^5%s^7"):format(id))
        error(errorString)
        return
    end
end

function Callbacks:Expire(requestId)
    local request = self.requests[requestId]

    if not request then
        return
    end

    self.requests[requestId] = nil

    if request.await and request.cb.state == PENDING then
        request.cb:reject("Server Callback Timed Out")
    end
end

function Callbacks:Trigger(event, cb, invoker, ...)
    local requestId = self.id
    local request = {
        await = type(cb) == "boolean",
        cb = cb or promise:new()
    }

    self.requests[requestId] = request

    TriggerServerEvent("esx:triggerServerCallback", event, requestId, invoker, ...)

    self.id += 1

    SetTimeout(TIMEOUT, function()
        self:Expire(requestId)
    end)

    return request.cb
end

function Callbacks:ServerRecieve(requestId, invoker, ...)
    if not self.requests[requestId] then
        return error(("Server Callback with requestId ^5%s^1 Was Called by ^5%s^1 but does not exist."):format(requestId, invoker))
    end

    local callback = self.requests[requestId]

    self.requests[requestId] = nil

    if callback.await then
        callback.cb:resolve({ ... })
    else
        self:Execute(callback.cb, requestId, ...)
    end
end

function Callbacks:ClientRecieve(eventName, requestId, invoker, ...)
    if not self.storage[eventName] then
        return error(("Client Callback with requestId ^5%s^1 Was Called by ^5%s^1 but does not exist."):format(eventName, invoker))
    end

    local returnCb = function(...)
        TriggerServerEvent("esx:clientCallback", requestId, invoker, ...)
    end
    local callback = self.storage[eventName].cb

    self:Execute(callback, requestId, returnCb, ...)
end

-- =============================================
-- MARK: ESX Functions
-- =============================================

---@param eventName string
---@param callback function
---@param ... any
---@return nil
function ESX.TriggerServerCallback(eventName, callback, ...)
    local invokingResource = GetInvokingResource()
    local invoker = (invokingResource and invokingResource ~= "unknown") and invokingResource or "es_extended"

    Callbacks:Trigger(eventName, callback, invoker, ...)
end

---@param eventName string
---@param ... any
---@return ...
function ESX.AwaitServerCallback(eventName, ...)
    local invokingResource = GetInvokingResource()
    local invoker = (invokingResource and invokingResource ~= "unknown") and invokingResource or "es_extended"

    local p = Callbacks:Trigger(eventName, false, invoker, ...)
    if not p then return end

    Citizen.Await(p)

    return table.unpack(p.value)
end

function ESX.RegisterClientCallback(eventName, callback)
    local invokingResource = GetInvokingResource()
    local invoker = (invokingResource and invokingResource ~= "Unknown") and invokingResource or "es_extended"

    Callbacks:Register(eventName, invoker, callback)
end

---@param eventName string
---@return boolean
function ESX.DoesClientCallbackExist(eventName)
    return Callbacks.storage[eventName] ~= nil
end

-- =============================================
-- MARK: Events
-- =============================================

ESX.SecureNetEvent("esx:serverCallback", function(...)
    Callbacks:ServerRecieve(...)
end)

ESX.SecureNetEvent("esx:triggerClientCallback", function(...)
    Callbacks:ClientRecieve(...)
end)

AddEventHandler("onResourceStop", function(resource)
    for k, v in pairs(Callbacks.storage) do
        if v.resource == resource then
            Callbacks.storage[k] = nil
        end
    end
end)
