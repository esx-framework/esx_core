-- shared logic file for map manager - don't call any subsystem-specific functions here
mapFiles = {}

function addMap(file, owningResource)
    if not mapFiles[owningResource] then
        mapFiles[owningResource] = {}
    end

    table.insert(mapFiles[owningResource], file)
end

undoCallbacks = {}

function loadMap(res)
    if mapFiles[res] then
        for _, file in ipairs(mapFiles[res]) do
            parseMap(file, res)
        end
    end
end

function unloadMap(res)
    if undoCallbacks[res] then
        for _, cb in ipairs(undoCallbacks[res]) do
            cb()
        end

        undoCallbacks[res] = nil
        mapFiles[res] = nil
    end
end

function parseMap(file, owningResource)
    if not undoCallbacks[owningResource] then
        undoCallbacks[owningResource] = {}
    end

    local env = {
        math = math, pairs = pairs, ipairs = ipairs, next = next, tonumber = tonumber, tostring = tostring,
        type = type, table = table, string = string, _G = env,
        vector3 = vector3, quat = quat, vec = vec, vector2 = vector2
    }

    TriggerEvent('getMapDirectives', function(key, cb, undocb)
        env[key] = function(...)
            local state = {}

            state.add = function(k, v)
                state[k] = v
            end

            local result = cb(state, ...)
            local args = table.pack(...)

            table.insert(undoCallbacks[owningResource], function()
                undocb(state)
            end)

            return result
        end
    end)

    local mt = {
        __index = function(t, k)
            if rawget(t, k) ~= nil then return rawget(t, k) end

            -- as we're not going to return nothing here (to allow unknown directives to be ignored)
            local f = function()
                return f
            end

            return function() return f end
        end
    }

    setmetatable(env, mt)
    
    local fileData = LoadResourceFile(owningResource, file)
    local mapFunction, err = load(fileData, file, 't', env)

    if not mapFunction then
        Citizen.Trace("Couldn't load map " .. file .. ": " .. err .. " (type of fileData: " .. type(fileData) .. ")\n")
        return
    end

    mapFunction()
end