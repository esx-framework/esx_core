---@alias CustomType 'number' | 'boolean' | 'function' | 'table' | 'string' | 'nil' | 'array' | 'int' | 'uint' | 'float' |  'char' | 'vector3' | 'vector4' | 'ped' | 'playerId' | 'vehicle' | 'prop' | 'class' | 'model'

---Checks if value is an array
---@param value any
---@return boolean
local function isArray(value)
    if type(value) ~= 'table' then
        return false
    end

    local i = 0
    
    for _ in pairs(value) do
        i = i + 1
        if value[i] == nil then
            return false
        end
    end

    return true
end

---Checks if player id is correct.
---@param value any
---@return boolean
local function isPlayerId(value)
    if type(value) ~= 'number' then
        return false
    end

    if xLib.side == 'server' then
        return GetPlayerName(value) ~= nil
    else
        return NetworkIsPlayerActive(value)
    end
end

---Checks if function is callable.
---@param value any
---@return boolean
local function isCallable(value)
    local value_type = type(value)

    if value_type == 'function' then
        return true
    end
    
    if value_type == 'table' then
        local mt = getmetatable(value)

        if mt and mt.__call then
            return true
        end
    end
    
    return false
end

xLib.callback.register('xLib:validateModel', function(model)
    return IsModelValid(model)
end)

local function validateModel(model)
    local players = GetPlayers()
    local source = tonumber(players[math.random(1,#players)])

    return xLib.callback.await('xLib:validateModel', source, false, model)
end

---Make sure value is a valid type
---@param value any
---@param valid_type CustomType
---@return boolean
local function verifyType(value, valid_type)
    if valid_type == 'function' then
        return isCallable(value)
    elseif valid_type == 'array' then
        return isArray(value)
    elseif valid_type == 'int' then
        return math.type(value) == 'integer'
    elseif valid_type == 'float' then
        return math.type(value) == 'float'
    elseif valid_type == 'uint' then
        return math.type(value) == 'integer' and value >= 0
    elseif valid_type == 'char' then 
        return type(value) == 'string' and #value == 1
    elseif valid_type == 'ped' then 
        return GetEntityType(value) == 1
    elseif valid_type == 'vehicle' then 
        return GetEntityType(value) == 2
    elseif valid_type == 'prop' then 
        return GetEntityType(value) == 3
    elseif valid_type == 'playerId' then
        return isPlayerId(value)
    elseif valid_type == 'class' then
        if type(value) ~= 'table' then
            return false
        end

        return getmetatable(value)?._isClass == true
    elseif valid_type == 'model' then
        if xLib.side == "server" then 
            return validateModel(value)
        end

        return IsModelValid(value)
    end

    return type(value) == valid_type
end

---@class VerifyTable
---@field debug VerifyFunction

---@alias VerifyFunction fun(value: any, valid_types: CustomType[] | CustomType, throw_error?: boolean): boolean

---@type VerifyFunction | VerifyTable
xLib.verify = setmetatable({
    fn = function(value, valid_types, throw_error)
        local match = false

        if type(valid_types) == 'table' then
            for i = 1, #valid_types do
                if xLib.verify(value, valid_types[i]) then
                    match = true
                    break
                end
            end

            if throw_error and not match then
                error(('[xLib] Couldn\'t match %s to types %s'):format(value, json.encode(valid_types)))
            else
                return match
            end
        end

        match = verifyType(value, valid_types)

        if throw_error and not match then
            error(('[xLib] Couldn\'t match %s to type %s'):format(value, valid_types))
        else
            return match
        end
    end
}, {
    __index = function(self, k)
        if k == 'debug' and xLib.debug then
            return rawget(self, 'fn'
        )
        elseif k ~= 'debug' then
            return rawget(self, k)
        else 
            return Noop
        end
    end,
    __call = function(self, ...)
        return rawget(self, 'fn')(...)
    end
})

return xLib.verify
