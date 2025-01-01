ESX = exports["es_extended"]:getSharedObject()
_resourceName = GetCurrentResourceName()

OnPlayerData = function (key, val, last) end

if not IsDuplicityVersion() then -- Only register this event for the client
    AddEventHandler("esx:setPlayerData", function(key, val, last)
        if GetInvokingResource() == "es_extended" then
            ESX.PlayerData[key] = val
            if OnPlayerData then
                OnPlayerData(key, val, last)
            end
        end
    end)

    RegisterNetEvent("esx:playerLoaded", function(xPlayer)
        ESX.PlayerData = xPlayer
        while not ESX.PlayerData.ped or not DoesEntityExist(ESX.PlayerData.ped) do Wait(0) end
        ESX.PlayerLoaded = true
    end)

    ESX.SecureNetEvent("esx:onPlayerLogout", function()
        ESX.PlayerLoaded = false
        ESX.PlayerData = {}
    end)

    local external = {{"Class", "class.lua"}, {"Point", "point.lua"}}
    for i=1, #external do
        local module = external[i]
        local path = string.format("client/imports/%s", module[2])

        local file = LoadResourceFile("es_extended", path)
        if file then
            local fn, err = load(file, ('@@es_extended/%s'):format(path))

            if not fn or err then
                return error(('\n^1Error importing module (%s)'):format(external[i]))
            end

            ESX[module[1]] = fn()
        else
            return error(('\n^1Error loading module (%s)'):format(external[i]))
        end
    end
end

if not lib?.require then
    local cachedModules = {} ---@type table<string, any>
    local loadingModules = {} ---@type table<string, true?>

    ---@param modulePath string
    ---@return string
    local function getResourceNameFromModulePath(modulePath)
        local externalResourceName = modulePath:match("^@(.-)%.")
        if externalResourceName then
            return externalResourceName
        end

        return _resourceName
    end

    ---@param modulePath string
    ---@return string, number
    local function getModuleFilePath(modulePath)
        if modulePath:sub(1, 1) == "@" then
            modulePath = modulePath:sub(modulePath:find("%.") + 1)
        end

        return modulePath:gsub("%.", "/")
    end

    ---@param modulePath string
    ---@return any
    function require(modulePath)
        assert(type(modulePath) == "string", "Module path must be a string")

        if loadingModules[modulePath] then
            error(("Circular dependency detected for module '%s'."):format(modulePath))
        end

        if cachedModules[modulePath] then
            return cachedModules[modulePath]
        end

        loadingModules[modulePath] = true

        local resourceName = getResourceNameFromModulePath(modulePath)
        local moduleFilePath = getModuleFilePath(modulePath)
        local moduleFileContent = LoadResourceFile(resourceName, moduleFilePath .. ".lua")

        if not moduleFileContent then
            loadingModules[modulePath] = nil
            error(("Module '%s' not found in resource '%s'."):format(moduleFilePath, resourceName))
        end

        local chunk, err = load(moduleFileContent, ("@%s/%s"):format(resourceName, moduleFilePath), "t")

        if not chunk then
            loadingModules[modulePath] = nil
            error(("Failed to load module '%s': %s"):format(moduleFilePath, err))
        end

        local result = chunk()

        cachedModules[modulePath] = result ~= nil and result or true
        loadingModules[modulePath] = nil

        return result
    end
end
