-- Triggers an event for one or more clients. For an array of players the payload
-- is packed once instead of being re-serialised per client.

---@diagnostic disable: duplicate-set-field

local pack = msgpack.pack_args

---@param eventName string
---@param targets number | number[] a single serverId, or an array of them
---@param ... any
function xLib.triggerClientEvent(eventName, targets, ...)
    if type(targets) == 'number' then
        return TriggerClientEvent(eventName, targets, ...)
    end

    local payload = pack(...)
    local length = #payload
    for i = 1, #targets do
        TriggerClientEventInternal(eventName, targets[i], payload, length)
    end
end
