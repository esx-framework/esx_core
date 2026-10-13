-- Per-VM wrapper exposing xLib.pubsub.* on the server; forwards to the shared
-- registry (resource/pubsub/server.lua) through its exports.

local pubsub = {}

---@param src number serverId of the player to add
---@param topic string
---@return boolean added
function pubsub.subscribe(src, topic)
    return xLib.pubsub_subscribe(src, topic)
end

---@param src number
---@param topic string
---@return boolean removed
function pubsub.unsubscribe(src, topic)
    return xLib.pubsub_unsubscribe(src, topic)
end

---@param topic string
---@param data any server-trusted data only
---@return integer count number of players notified
function pubsub.publish(topic, data)
    return xLib.pubsub_publish(topic, data)
end

---@param topic string
---@return number[] serverIds
function pubsub.subscribers(topic)
    return xLib.pubsub_subscribers(topic)
end

---@param src number
---@param topic string
---@return boolean
function pubsub.isSubscribed(src, topic)
    return xLib.pubsub_isSubscribed(src, topic)
end

---@param topic string
---@return integer count
function pubsub.clear(topic)
    return xLib.pubsub_clear(topic)
end

xLib.pubsub = pubsub
return pubsub
