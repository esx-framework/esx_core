---@class ESXCooldown
ESX.Cooldown = {}

---@type table<number, table<string, integer>>
local cooldowns = {}

---Returns the remaining cooldown time in milliseconds (0 if not on cooldown)
---@param source number|string
---@param key string
---@return integer
function ESX.Cooldown.GetRemaining(source, key)
    source = tonumber(source)
    local expires = source and cooldowns[source] and cooldowns[source][key]
    if not expires then
        return 0
    end

    local remaining = expires - GetGameTimer()
    if remaining <= 0 then
        cooldowns[source][key] = nil
        return 0
    end

    return remaining
end

---Returns true if the player is currently on cooldown for the given key
---@param source number|string
---@param key string
---@return boolean
function ESX.Cooldown.Check(source, key)
    return ESX.Cooldown.GetRemaining(source, key) > 0
end

---Starts a cooldown for the player
---@param source number|string
---@param key string
---@param ms integer duration in milliseconds
function ESX.Cooldown.Set(source, key, ms)
    source = tonumber(source)
    assert(source, "ESX.Cooldown.Set: invalid source")
    assert(type(key) == "string", "ESX.Cooldown.Set: key must be a string")
    assert(type(ms) == "number" and ms > 0, "ESX.Cooldown.Set: ms must be a positive number")

    cooldowns[source] = cooldowns[source] or {}
    cooldowns[source][key] = GetGameTimer() + ms
end

---Checks the cooldown and starts it if the player is allowed to proceed
---@param source number|string
---@param key string
---@param ms integer duration in milliseconds
---@return boolean allowed
---@return integer remaining milliseconds left when not allowed
function ESX.Cooldown.Try(source, key, ms)
    local remaining = ESX.Cooldown.GetRemaining(source, key)
    if remaining > 0 then
        return false, remaining
    end

    ESX.Cooldown.Set(source, key, ms)
    return true, 0
end

---Clears one cooldown key, or all cooldowns of the player if no key is given
---@param source number|string
---@param key? string
function ESX.Cooldown.Clear(source, key)
    source = tonumber(source)
    if not source or not cooldowns[source] then
        return
    end

    if key then
        cooldowns[source][key] = nil
    else
        cooldowns[source] = nil
    end
end

AddEventHandler("playerDropped", function()
    cooldowns[source] = nil
end)
