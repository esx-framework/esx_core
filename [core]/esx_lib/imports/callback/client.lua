--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local pendingCallbacks = {}
local registeredCallbackNames = {}
local timers = {}
local cbEvent = '__xLib_cb_%s'
local callbackTimeout = GetConvarInt('xLib:callbackTimeout', 300000)
local resource_name = GetCurrentResourceName() --TODO: Add cache

local function publishValidCallback(name)
    local ok = pcall(function()
        xLib.setValidCallback(name, true)
    end)

    if not ok then
        SetTimeout(1000, function()
            if registeredCallbackNames[name] then
                publishValidCallback(name)
            end
        end)
    end
end

local function republishValidCallbacks()
    for name in pairs(registeredCallbackNames) do
        publishValidCallback(name)
    end
end

AddEventHandler('onClientResourceStart', function(resource)
    if resource == 'esx_lib' then
        SetTimeout(0, republishValidCallbacks)
    end
end)

RegisterNetEvent(cbEvent:format(resource_name), function(key, ...)
    if source == '' then return end

    local cb = pendingCallbacks[key]

    if not cb then return end

    pendingCallbacks[key] = nil

    cb(...)
end)

---@param event string
---@param delay? number | false prevent the event from being called for the given time
local function eventTimer(event, delay)
    if xLib.verify(delay, 'number') then
        if delay > 0 then
            local time = GetGameTimer()

            if (timers[event] or 0) > time then
                return false
            end

            timers[event] = time + delay
        end
    end

    return true
end

---@param _ any
---@param event string
---@param delay number | false | nil
---@param cb function | false
---@param ... any
---@return ...
local function triggerServerCallback(_, event, delay, cb, ...)
    if not eventTimer(event, delay) then return end

    local key

    repeat
        key = ('%s:%s'):format(event, math.random(0, 100000))
    until not pendingCallbacks[key]

    ---@type promise | false
    local promise = not cb and promise.new()

    pendingCallbacks[key] = function(response, ...)
        if response == 'cb_invalid' then
            response = ("callback '%s' does not exist"):format(event)

            return promise and promise:reject(response) or error(response)
        end

        response = { response, ... }

        if promise then
            return promise:resolve(response)
        end

        if cb then
            cb(table.unpack(response))
        end
    end

    TriggerServerEvent('xLib:validateCallback', event, resource_name, key)
    TriggerServerEvent(cbEvent:format(event), resource_name, key, ...)

    if promise then
        SetTimeout(callbackTimeout, function() promise:reject(("callback event '%s' timed out"):format(key)) end)

        return table.unpack(Citizen.Await(promise))
    end
end

---@overload fun(event: string, delay: number | false, cb: function, ...)
xLib.callback = setmetatable({}, {
    __call = function(_, event, delay, cb, ...)
        if not cb then
            warn(("callback event '%s' does not have a function to callback to and will instead await\nuse xLib.callback.await or a regular event to remove this warning")
                :format(event))
        else
            local cbType = type(cb)

            if cbType == 'table' and getmetatable(cb)?.__call then
                cbType = 'function'
            end

            xLib.verify(cb, 'function', true)
        end

        return triggerServerCallback(_, event, delay, cb, ...)
    end
})

---@param event string
---@param delay? number | false prevent the event from being called for the given time.
---Sends an event to the server and halts the current thread until a response is returned.
---@diagnostic disable-next-line: duplicate-set-field
function xLib.callback.await(event, delay, ...)
    return triggerServerCallback(nil, event, delay, false, ...)
end

local function callbackResponse(success, result, ...)
    if not success then
        if result then
            return print(('^1SCRIPT ERROR: %s^0\n%s'):format(result,
                Citizen.InvokeNative(`FORMAT_STACK_TRACE` & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString()) or ''))
        end

        return false
    end

    return result, ...
end

local pcall = pcall

---@param name string
---@param cb function
---Registers an event handler and callback function to respond to server requests.
---@diagnostic disable-next-line: duplicate-set-field
function xLib.callback.register(name, cb)
    local event = cbEvent:format(name)

    registeredCallbackNames[name] = true
    publishValidCallback(name)

    RegisterNetEvent(event, function(resource, key, ...)
        TriggerServerEvent(cbEvent:format(resource), key, callbackResponse(pcall(cb, ...)))
    end)
end

---@param name string
---@param cb function
---Registers a callback using the old ESX client callback signature: function(cb, ...).
function xLib.callback.registerCompat(name, cb)
    return xLib.callback.register(name, function(...)
        local response = promise.new()
        local responded = false

        local function reply(...)
            local values = { ... }

            if not responded then
                responded = true
                response:resolve(values)
            end

            return table.unpack(values)
        end

        cb(reply, ...)

        return table.unpack(Citizen.Await(response))
    end)
end

return xLib.callback
