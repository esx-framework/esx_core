-- xLib pub/sub: a producer subscribes players to a topic server-side and
-- publishes data pushed only to them. Clients only listen, never subscribe.
-- The registry is shared here (esx_lib server VM). Namespace topics by resource
-- (e.g. "esx_shops:247:stock") so two resources cannot clash on a bare name.

---@diagnostic disable: duplicate-set-field

local PUBSUB_EVENT <const> = '__xLib_pubsub' -- must match imports/pubsub/client.lua
local TOPIC_PATTERN <const> = '^[%w_:%.%-]+$'
local MAX_TOPIC_LEN <const> = 200
local resourceName <const> = GetCurrentResourceName()

-- topic -> set of subscribed serverIds: subs[topic][src] = true
local subs = {}
-- serverId -> set of topics: memberOf[src][topic] = true (O(degree) cleanup on drop)
local memberOf = {}
-- topic -> resource that created it, purged on that resource's onResourceStop
local ownerOf = {}

local function isValidTopic(topic)
    return type(topic) == 'string'
        and #topic > 0
        and #topic <= MAX_TOPIC_LEN
        and topic:match(TOPIC_PATTERN) ~= nil
end

local function isLivePlayer(src)
    -- a connected player has a name; rejects 0, stale or recycled serverIds
    return type(src) == 'number' and src > 0 and GetPlayerName(src) ~= nil
end

local function detach(src, topic)
    local set = subs[topic]
    if set then
        set[src] = nil
        if next(set) == nil then
            subs[topic] = nil
            ownerOf[topic] = nil
        end
    end

    local topics = memberOf[src]
    if topics then
        topics[topic] = nil
        if next(topics) == nil then
            memberOf[src] = nil
        end
    end
end

---Subscribe a player to a topic. Called server-side by the producer resource.
---@param src number serverId of the player to add
---@param topic string
---@return boolean added false if already subscribed or input is invalid
function xLib.pubsub_subscribe(src, topic)
    if not isLivePlayer(src) or not isValidTopic(topic) then
        return false
    end

    local set = subs[topic]
    if set and set[src] then
        return false -- idempotent: already subscribed
    end

    if not set then
        set = {}
        subs[topic] = set
        ownerOf[topic] = GetInvokingResource() or resourceName
    end
    set[src] = true

    local topics = memberOf[src]
    if not topics then
        topics = {}
        memberOf[src] = topics
    end
    topics[topic] = true

    return true
end

---Unsubscribe a player from a topic.
---@param src number
---@param topic string
---@return boolean removed false if it was not subscribed
function xLib.pubsub_unsubscribe(src, topic)
    local set = subs[topic]
    if not set or not set[src] then
        return false -- idempotent
    end
    detach(src, topic)
    return true
end

---Push data to every player subscribed to a topic. Server-trusted data only.
---@param topic string
---@param data any
---@return integer count number of players notified
function xLib.pubsub_publish(topic, data)
    -- no isValidTopic() here on purpose: an invalid topic never created a set,
    -- so the lookup below already returns 0 for it without a regex on the hot path
    local set = subs[topic]
    if not set then
        return 0
    end

    local targets, count = {}, 0
    for src in pairs(set) do
        count = count + 1
        targets[count] = src
    end

    -- packs the payload once for the whole set instead of once per client
    xLib.triggerClientEvent(PUBSUB_EVENT, targets, topic, data)
    return count
end

---@param topic string
---@return number[] serverIds a fresh copy, empty if the topic has no subscribers
function xLib.pubsub_subscribers(topic)
    local set = subs[topic]
    if not set then
        return {}
    end

    local list, i = {}, 0
    for src in pairs(set) do
        i = i + 1
        list[i] = src
    end
    return list
end

---@param src number
---@param topic string
---@return boolean
function xLib.pubsub_isSubscribed(src, topic)
    local set = subs[topic]
    return set ~= nil and set[src] == true
end

---Drop a whole topic and all of its subscribers.
---@param topic string
---@return integer count number of subscribers that were removed
function xLib.pubsub_clear(topic)
    local set = subs[topic]
    if not set then
        return 0
    end

    local count = 0
    for src in pairs(set) do
        local topics = memberOf[src]
        if topics then
            topics[topic] = nil
            if next(topics) == nil then
                memberOf[src] = nil
            end
        end
        count = count + 1
    end

    subs[topic] = nil
    ownerOf[topic] = nil
    return count
end

-- Remove a leaving player from every topic. serverIds are reused by the server,
-- so skipping this would leak a topic's data to whoever inherits the slot.
AddEventHandler('playerDropped', function()
    local src = source
    local topics = memberOf[src]
    if not topics then
        return
    end

    for topic in pairs(topics) do
        local set = subs[topic]
        if set then
            set[src] = nil
            if next(set) == nil then
                subs[topic] = nil
                ownerOf[topic] = nil
            end
        end
    end
    memberOf[src] = nil
end)

-- Purge the topics a stopped producer owned, so a producer restart never leaves
-- orphan subscriptions that keep receiving pushes.
AddEventHandler('onResourceStop', function(stopped)
    if stopped == resourceName then
        return
    end

    local orphaned = {}
    for topic, owner in pairs(ownerOf) do
        if owner == stopped then
            orphaned[#orphaned + 1] = topic
        end
    end

    for i = 1, #orphaned do
        xLib.pubsub_clear(orphaned[i])
    end
end)
