-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local pendingCallbacks = {}
local registeredCallbackNames = {}
local compatCallbacks = {}
local timers = {}
local cbEvent = '__xLib_cb_%s'
local DEFAULT_AWAIT_TIMEOUT <const> = 300000
local resource_name = GetCurrentResourceName() --TODO: Add cache

---@return integer|nil
local function getConfiguredTimeout()
    local value = tonumber(GetConvar('xLib:callbackTimeout', GetConvar('esx:callbackTimeout', '')))

    if
        value
        and value == value
        and value > -math.huge
        and value < math.huge
    then
        return math.max(math.floor(value), 0)
    end
end

local configuredTimeout = getConfiguredTimeout()
local awaitTimeout = configuredTimeout or DEFAULT_AWAIT_TIMEOUT

local function createCallbackKey(event)
    local key

    repeat
        key = ('%s:%s:%s'):format(event, GetGameTimer(), xLib.string.randomHex(32))
    until not pendingCallbacks[key]

    return key
end

local function publishValidCallback(name)
    local registration = registeredCallbackNames[name]

    if not registration then return false end

    local ok, accepted = pcall(xLib.setValidCallback, name, true, registration.owner)
    registration.active = ok and accepted == true

    if not ok then
        SetTimeout(1000, function()
            if registeredCallbackNames[name] == registration then
                publishValidCallback(name)
            end
        end)
    end

    return registration.active
end

local function claimCallback(name, cb, owner)
    owner = owner or resource_name
    assert(type(name) == 'string' and name ~= '' and #name <= 200, 'invalid callback name')
    assert(type(cb) == 'function', 'callback must be a function')
    assert(type(owner) == 'string' and owner ~= '' and #owner <= 100, 'invalid callback owner')

    local previous = registeredCallbackNames[name]
    if previous and previous.owner ~= owner then
        error(("callback '%s' is already owned by resource '%s'"):format(name, previous.owner), 3)
    end

    local ok, accepted = pcall(xLib.setValidCallback, name, true, owner)
    if not ok or accepted ~= true then
        error(("unable to claim callback '%s': %s"):format(name, ok and 'name already owned' or tostring(accepted)), 3)
    end

    if previous then
        previous.active = false
        RemoveEventHandler(previous.handler)
    end

    compatCallbacks[name] = nil
    local registration = { owner = owner, active = true }
    registeredCallbackNames[name] = registration

    return registration
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

-- Compat callbacks (via ESX.Register*) belong to another resource while their
-- handlers live here, so they must be removed manually when that resource stops.
AddEventHandler('onClientResourceStop', function(resource)
    for name, registration in pairs(registeredCallbackNames) do
        if resource == 'esx_lib' then registration.active = false end

        if registration.owner == resource then
            registration.active = false
            RemoveEventHandler(registration.handler)
            compatCallbacks[name] = nil
            registeredCallbackNames[name] = nil
            if GetResourceState('esx_lib') == 'started' then
                xLib.setValidCallback(name, false, registration.owner)
            end
        end
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

    local key = createCallbackKey(event)

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

    local timeout = awaitTimeout

    if timeout and timeout > 0 then
        SetTimeout(timeout, function()
            if not pendingCallbacks[key] then
                return
            end

            pendingCallbacks[key] = nil

            local err = ("callback event '%s' timed out"):format(key)
            if promise then
                promise:reject(err)
            elseif cb then
                warn(err)
            end
        end)
    end

    TriggerServerEvent('xLib:validateCallback', event, resource_name, key)
    TriggerServerEvent(cbEvent:format(event), resource_name, key, ...)

    if promise then
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
---The handler is owned by the importing resource's runtime, so FiveM removes
---it automatically when that resource stops.
---@diagnostic disable-next-line: duplicate-set-field
function xLib.callback.register(name, cb)
    local event = cbEvent:format(name)

    local registration = claimCallback(name, cb)
    RegisterNetEvent(event)
    
    registration.handler = AddEventHandler(event, function(resource, key, ...)
        if not registration.active then return end
        TriggerServerEvent(cbEvent:format(resource), key, callbackResponse(pcall(cb, ...)))
    end)
end

---@param name string
---@param cb function
---@param owner? string Resource whose lifetime owns the callback.
---Registers a callback using the old ESX client callback signature: function(cb, ...).
---The handler is created here so it can be removed when the owner resource stops.
function xLib.callback.registerCompat(name, cb, owner)
    local event = cbEvent:format(name)

    local function compatCb(...)
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

        if awaitTimeout > 0 then
            SetTimeout(awaitTimeout, function()
                if not responded then
                    responded = true
                    response:reject(("compat callback '%s' timed out"):format(name))
                end
            end)
        end

        cb(reply, ...)

        return table.unpack(Citizen.Await(response))
    end

    local registration = claimCallback(name, cb, owner)
    RegisterNetEvent(event)
    registration.handler = AddEventHandler(event, function(resource, key, ...)
        if not registration.active then return end
        TriggerServerEvent(cbEvent:format(resource), key, callbackResponse(pcall(compatCb, ...)))
    end)
    compatCallbacks[name] = registration
end

return xLib.callback
