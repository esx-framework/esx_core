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
local cbEvent = '__xLib_cb_%s'
local callbackResponse
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
local receiverTimeout = configuredTimeout and configuredTimeout > 0 and configuredTimeout or 30000
local incoming = {}
local maxPayload = math.max(1024, GetConvarInt('xLib:callbackMaxPayloadBytes', 65536))

local function payloadSize(args)
    local entries = 0
    local estimate = 0
    local seen = {}

    local function visit(value, depth)
        entries = entries + 1

        if entries > 2048 or depth > 8 then
            return false
        end

        local kind = type(value)

        if kind == 'table' then
            if seen[value] then
                return false
            end

            seen[value] = true

            for key, item in pairs(value) do
                if not visit(key, depth + 1) or not visit(item, depth + 1) then
                    return false
                end
            end

            seen[value] = nil
        elseif kind == 'string' then
            estimate = estimate + #value + 5
        elseif kind == 'number' then
            if value ~= value or value == math.huge or value == -math.huge then
                return false
            end

            estimate = estimate + 9
        elseif kind == 'nil' or kind == 'boolean' then
            estimate = estimate + 1
        elseif kind == 'vector3' or kind == 'vector4' or kind == 'vector2' then
            estimate = estimate + 32
        else
            return false
        end

        return estimate <= maxPayload
    end

    if args.n > 32 or not visit(args, 0) then
        return nil
    end

    local ok, packed = pcall(msgpack.pack_args, table.unpack(args, 1, args.n))

    if not ok or #packed > maxPayload then
        return nil
    end

    return #packed
end

local function runIncoming(cb, playerId, resource, key, args, owner)
    if
        type(resource) ~= 'string'
        or #resource > 100
        or not resource:match('^[%w_%.%-%[%]]+$')
        or type(key) ~= 'string'
        or #key > 300
    then
        return
    end

    local token, canReply = xLib.acquireCallbackBudget(playerId, 0)

    if not token then
        if canReply then
            TriggerClientEvent(cbEvent:format(resource), playerId, key, false)
        end

        return
    end

    local bytes = payloadSize(args)

    if not bytes or not xLib.chargeCallbackBytes(token, bytes) then
        xLib.releaseCallbackBudget(token)
        TriggerClientEvent(cbEvent:format(resource), playerId, key, false)
        return
    end

    local state = {
        source = playerId,
        owner = owner or resource_name,
        token = token,
        cancelled = false,
        deadline = GetGameTimer() + receiverTimeout,
    }

    state.expire = function()
        if state.cancelled then
            return
        end

        state.cancelled = true
        TriggerClientEvent(cbEvent:format(resource), playerId, key, false)

        if state.abort then
            state.abort()
        end
    end

    incoming[token] = state

    local results = table.pack(pcall(cb, playerId, state, table.unpack(args, 1, args.n)))

    incoming[token] = nil
    xLib.releaseCallbackBudget(token)

    if not state.cancelled then
        TriggerClientEvent(
            cbEvent:format(resource),
            playerId,
            key,
            callbackResponse(table.unpack(results, 1, results.n))
        )
    end
end

CreateThread(function()
    while true do
        Wait(250)
        local now = GetGameTimer()

        for _, state in pairs(incoming) do
            if not state.cancelled and now >= state.deadline then
                state.expire()
            end
        end
    end
end)

if configuredTimeout then
    SetConvarReplicated('esx:callbackTimeout', tostring(configuredTimeout))
    SetConvarReplicated('xLib:callbackTimeout', tostring(configuredTimeout))
end

local function createCallbackKey(event, playerId)
    local key

    repeat
        key = ('%s:%s:%s:%s'):format(event, playerId, GetGameTimer(), xLib.string.randomHex(32))
    until not pendingCallbacks[key]

    return key
end

local function expirePendingCallback(key, err)
    local pending = pendingCallbacks[key]

    if not pending then
        return
    end

    pendingCallbacks[key] = nil
    pending.expire(err)
end

local function clearPendingForSource(playerId)
    playerId = tostring(playerId)

    for key, pending in pairs(pendingCallbacks) do
        if pending.source == playerId then
            expirePendingCallback(
                key,
                ("callback event '%s' was cancelled because player %s disconnected"):format(
                    key,
                    playerId
                )
            )
        end
    end
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

    local mt = type(cb) == 'table' and getmetatable(cb)
    assert(type(cb) == 'function' or (type(mt) == 'table' and type(mt.__call) == 'function'), 'callback must be a function')
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

AddEventHandler('onResourceStart', function(resource)
    if resource == 'esx_lib' then
        SetTimeout(0, republishValidCallbacks)
    end
end)

-- Compat callbacks (via ESX.Register*) belong to another resource while their
-- handlers live here, so they must be removed manually when that resource stops.
AddEventHandler('onResourceStop', function(resource)
    for token, state in pairs(incoming) do
        if state.owner == resource then
            state.cancelled = true

            if state.abort then
                state.abort()
            end
        end
    end

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
    local pending = pendingCallbacks[key]

    if not pending then
        return
    end

    if pending.source ~= tostring(source) then
        return
    end

    pendingCallbacks[key] = nil

    pending.cb(...)
end)

AddEventHandler('playerDropped', function()
    clearPendingForSource(source)

    for token, state in pairs(incoming) do
        if state.source == source then
            state.cancelled = true

            if state.abort then
                state.abort()
            end
        end
    end
end)

---@param _ any
---@param event string
---@param playerId number
---@param cb function|false
---@param ... any
---@return ...
local function triggerClientCallback(_, event, playerId, cb, ...)
    xLib.verify(playerId, 'playerId', true)

    local key = createCallbackKey(event, playerId)

    ---@type promise | false
    local promise = not cb and promise.new()

    pendingCallbacks[key] = {
        source = tostring(playerId),
        cb = function(response, ...)
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
        end,
        expire = function(err)
            if promise then
                promise:reject(err)
            elseif cb then
                warn(err)
            end
        end,
    }

    local timeout = awaitTimeout

    if timeout and timeout > 0 then
        SetTimeout(timeout, function()
            expirePendingCallback(key, ("callback event '%s' timed out"):format(key))
        end)
    end

    TriggerClientEvent('xLib:validateCallback', playerId, event, resource_name, key)
    TriggerClientEvent(cbEvent:format(event), playerId, resource_name, key, ...)

    if promise then
        return table.unpack(Citizen.Await(promise))
    end
end

---@overload fun(event: string, playerId: number, cb: function, ...)
xLib.callback = setmetatable({}, {
    __call = function(_, event, playerId, cb, ...)
        if not cb then
            warn(
                ("callback event '%s' does not have a function to callback to and will instead await\nuse xLib.callback.await or a regular event to remove this warning"):format(
                    event
                )
            )
        else
            local cbType = type(cb)

            if cbType == 'table' and getmetatable(cb)?.__call then
                cbType = 'function'
            end

            xLib.verify(cb, 'function', true)
        end

        return triggerClientCallback(_, event, playerId, cb, ...)
    end,
})

---@param event string
---@param playerId number
--- Sends an event to a client and halts the current thread until a response is returned.
---@diagnostic disable-next-line: duplicate-set-field
function xLib.callback.await(event, playerId, ...)
    return triggerClientCallback(nil, event, playerId, false, ...)
end

callbackResponse = function(success, result, ...)
    if not success then
        if result then
            print(
                ('^1SCRIPT ERROR: %s^0\n%s'):format(
                    result,
                    Citizen.InvokeNative(
                        `FORMAT_STACK_TRACE` & 0xFFFFFFFF,
                        nil,
                        0,
                        Citizen.ResultAsString()
                    ) or ''
                )
            )
        end

        return false
    end

    return result, ...
end

local pcall = pcall

---@param name string
---@param cb function
---Registers an event handler and callback function to respond to client requests.
---The handler is owned by the importing resource's runtime, so FiveM removes
---it automatically when that resource stops.
---@diagnostic disable-next-line: duplicate-set-field
function xLib.callback.register(name, cb)
    local event = cbEvent:format(name)

    local registration = claimCallback(name, cb)
    RegisterNetEvent(event)

    registration.handler = AddEventHandler(event, function(resource, key, ...)
        if not registration.active then return end
        runIncoming(function(playerId, state, ...)
            return cb(playerId, ...)
        end, source, resource, key, table.pack(...))
    end)
end

---@param name string
---@param cb function
---@param owner? string Resource whose lifetime owns the callback.
---Registers a callback using the old ESX server callback signature: function(source, cb, ...).
---The handler is created here so it can be removed when the owner resource stops.
function xLib.callback.registerCompat(name, cb, owner)
    local event = cbEvent:format(name)

    local function compatCb(source, state, ...)
        local response = promise.new()
        local responded = false

        local function reply(...)
            local values = table.pack(...)

            if not responded then
                responded = true
                response:resolve(values)
            end

            return table.unpack(values, 1, values.n)
        end

        state.abort = function()
            reply(false)
        end

        cb(source, reply, ...)

        local values = Citizen.Await(response)
        return table.unpack(values, 1, values.n)
    end

    local registration = claimCallback(name, cb, owner)
    RegisterNetEvent(event)

    registration.handler = AddEventHandler(event, function(resource, key, ...)
        if not registration.active then return end
        runIncoming(compatCb, source, resource, key, table.pack(...), registration.owner)
    end)
    
    compatCallbacks[name] = registration
end

return xLib.callback
