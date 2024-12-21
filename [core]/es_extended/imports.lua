ESX = exports["es_extended"]:getSharedObject()

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
        ESX.PlayerLoaded = true
    end)

    ESX.SecureNetEvent("esx:onPlayerLogout", function()
        ESX.PlayerLoaded = false
        ESX.PlayerData = {}
    end)
end


local basePath = ('%s/dynamicModules'):format(IsDuplicityVersion() and 'server' or 'client')
local loadedModules = {}

--- Load a module by its name. Make sure the specified resource has the module loaded via files {} in fxmanifest.lua (e.g files { 'modules/myModule.lua' })
--- @param moduleName string The name of the module to load
--- @param path? string Optional. A sub-path relative to the resource's root or nil to use the default basePath
--- @param resourceName? string Optional. The resource name to load the module from. Default is 'es_extended'
--- @return unknown | boolean: Returns the result of the module or true if successful
function ESX.LoadModule(moduleName, path, resourceName)
    ESX.AssertType(moduleName, 'string', 'moduleName should be a string.')
    if path then
        ESX.AssertType(path, 'string', 'path should be a string.')
    end
    if resourceName then
        ESX.AssertType(resourceName, 'string', 'customResource should be a string.')
    end

    resourceName = resourceName or 'es_extended'

    local moduleKey = ('%s-%s'):format(moduleName, path or '')
    if loadedModules[moduleKey] then
        print(('Module %s is already loaded'):format(moduleName))
        return true
    end

    local modulePath = path and ('%s/%s.lua'):format(path, moduleName) or ('%s/%s.lua'):format(basePath, moduleName)

    local moduleCode = LoadResourceFile(resourceName, modulePath)
    assert(moduleCode, 'moduleCode is nil, make sure your module path is correct. Note: Client-side modules can not be loaded from the server-side.')

    local func, err = load(moduleCode, ('@@%s/%s'):format(resourceName, modulePath))
    assert(func, ('Failed to load module %s: %s'):format(moduleName, err))

    local success, result = pcall(func)
    assert(success, ('Failed to execute module %s: %s'):format(moduleName, result))

    loadedModules[moduleKey] = true

    return result or true
end