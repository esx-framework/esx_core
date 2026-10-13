-- Per-VM client listener for xLib pub/sub. Routes incoming topic data to the
-- handlers registered with xLib.pubsub.on. on() only listens; the player must be
-- subscribed server-side to actually receive anything.

local PUBSUB_EVENT <const> = '__xLib_pubsub' -- must match resource/pubsub/server.lua

-- topic -> array of handlers
local handlers = {}

local pubsub = {}

---Register a handler for a topic. Multiple handlers per topic are allowed.
---@param topic string
---@param handler fun(data: any, topic: string)
function pubsub.on(topic, handler)
    if type(topic) ~= 'string' or type(handler) ~= 'function' then
        return
    end

    local list = handlers[topic]
    if not list then
        list = {}
        handlers[topic] = list
    end
    list[#list + 1] = handler
end

---Remove handlers for a topic. Without a handler argument, removes all of them.
---@param topic string
---@param handler? function
function pubsub.off(topic, handler)
    if not handler then
        handlers[topic] = nil
        return
    end

    local list = handlers[topic]
    if not list then
        return
    end

    for i = #list, 1, -1 do
        if list[i] == handler then
            table.remove(list, i)
        end
    end

    if list[1] == nil then
        handlers[topic] = nil
    end
end

RegisterNetEvent(PUBSUB_EVENT, function(topic, data)
    local list = handlers[topic]
    if not list then
        return
    end

    -- fast path: a topic almost always has a single handler, so skip the copy
    local n = #list
    if n == 1 then
        list[1](data, topic)
        return
    end

    -- snapshot so a handler that calls off() mid-dispatch cannot shift the list
    -- and skip a sibling that has not run yet
    local snapshot = {}
    for i = 1, n do
        snapshot[i] = list[i]
    end

    for i = 1, n do
        snapshot[i](data, topic)
    end
end)

xLib.pubsub = pubsub
return pubsub
