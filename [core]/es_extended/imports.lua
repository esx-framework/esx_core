ESX = exports["es_extended"]:getSharedObject()
ESX.currentResourceName = GetCurrentResourceName()

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

if GetResourceState("ox_lib") == "missing" then
    ---@Credits: https://github.com/overextended/ox_lib/blob/master/imports/require/shared.lua - Licensed under the GNU Lesser General Public License v3.0
    local loaded = {}
    local _require = require

    package = {
        path = './?.lua;./?/init.lua',
        preload = {},
        loaded = setmetatable({}, {
            __index = loaded,
            __newindex = function() end,
            __metatable = false,
        })
    }

    ---@param modName string
    ---@return string
    ---@return string
    local function getModuleInfo(modName)
        local resource = modName:match('^@(.-)/.+') --[[@as string?]]

        if resource then
            return resource, modName:sub(#resource + 3)
        end

        local idx = 4 -- call stack depth (kept slightly lower than expected depth "just in case")

        while true do
            local dbgInfo = debug.getinfo(idx, 'S')
            local src = dbgInfo and dbgInfo.source

            if not src then
                return ESX.currentResourceName, modName
            end

            resource = src:match('^@@([^/]+)/.+')

            if resource and not src:find('^@@es_extended/imports') then
                return resource, modName
            end

            idx = idx + 1
        end
    end

    local tempData = {}

    ---@param name string
    ---@param path string
    ---@return string? filename
    ---@return string? errmsg
    ---@diagnostic disable-next-line: duplicate-set-field
    function package.searchpath(name, path)
        local resource, modName = getModuleInfo(name:gsub('%.', '/'))
        local tried = {}

        for template in path:gmatch('[^;]+') do
            local fileName = template:gsub('^%./', ''):gsub('?', modName:gsub('%.', '/') or modName)
            local file = LoadResourceFile(resource, fileName)

            if file then
                tempData[1] = file
                tempData[2] = resource
                return fileName
            end

            tried[#tried + 1] = ("no file '@%s/%s'"):format(resource, fileName)
        end

        return nil, table.concat(tried, "\n\t")
    end

    ---Attempts to load a module at the given path relative to the resource root directory.\
    ---Returns a function to load the module chunk, or a string containing all tested paths.
    ---@param modName string
    ---@param env? table
    local function loadModule(modName, env)
        local fileName, err = package.searchpath(modName, package.path)

        if fileName then
            local file = tempData[1]
            local resource = tempData[2]

            ESX.Table.Wipe(tempData)
            return assert(load(file, ('@@%s/%s'):format(resource, fileName), 't', env or _ENV))
        end

        return nil, err or 'unknown error'
    end

    ---@alias PackageSearcher
    ---| fun(modName: string): function loader
    ---| fun(modName: string): nil, string errmsg

    ---@type PackageSearcher[]
    package.searchers = {
        function(modName)
            local ok, result = pcall(_require, modName)

            if ok then return result end

            return ok, result
        end,
        function(modName)
            if package.preload[modName] ~= nil then
                return package.preload[modName]
            end

            return nil, ("no field package.preload['%s']"):format(modName)
        end,
        function(modName) return loadModule(modName) end,
    }

    ---@param filePath string
    ---@param env? table
    ---@return unknown
    ---Loads and runs a Lua file at the given path. Unlike require, the chunk is not cached for future use.
    function ESX.load(filePath, env)
        if type(filePath) ~= 'string' then
            error(("file path must be a string (received '%s')"):format(filePath), 2)
        end

        local result, err = loadModule(filePath, env)

        if result then return result() end

        error(("file '%s' not found\n\t%s"):format(filePath, err))
    end

    ---@param filePath string
    ---@return table
    ---Loads and decodes a json file at the given path.
    function ESX.loadJson(filePath)
        if type(filePath) ~= 'string' then
            error(("file path must be a string (received '%s')"):format(filePath), 2)
        end

        local resourceSrc, modPath = getModuleInfo(filePath:gsub('%.', '/'))
        local resourceFile = LoadResourceFile(resourceSrc, ('%s.json'):format(modPath))

        if resourceFile then
            return json.decode(resourceFile)
        end

        error(("json file '%s' not found\n\tno file '@%s/%s.json'"):format(filePath, resourceSrc, modPath))
    end

    ---Loads the given module, returns any value returned by the seacher (`true` when `nil`).\
    ---Passing `@resourceName.modName` loads a module from a remote resource.
    ---@param modName string
    ---@return unknown
    function ESX.require(modName)
        if type(modName) ~= 'string' then
            error(("module name must be a string (received '%s')"):format(modName), 3)
        end

        local module = loaded[modName]

        if module == '__loading' then
            error(("^1circular-dependency occurred when loading module '%s'^0"):format(modName), 2)
        end

        if module ~= nil then return module end

        loaded[modName] = '__loading'

        local err = {}

        for i = 1, #package.searchers do
            local result, errMsg = package.searchers[i](modName)
            if result then
                if type(result) == 'function' then result = result() end
                loaded[modName] = result or result == nil

                return loaded[modName]
            end

            err[#err + 1] = errMsg
        end

        error(("%s"):format(table.concat(err, "\n\t")))
    end

    require = ESX.require
end
