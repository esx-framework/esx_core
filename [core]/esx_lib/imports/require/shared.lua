--!DISCLAIMER
--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local LOADED <const> = {}
local TEMP_DATA <const> = {}

local _require = require --original lua function

package = {
    path = './?.lua;./?/init.lua',
    preload = {},
    loaded = setmetatable({}, {
        __index = LOADED,
        __newindex = Noop,
        __metatable = false,
    })
}

---Gets the resource name and the module's relative path
---@param name string -- module name
---@return string, string
local function getModuleInfo(name)
    local resource = name:match('^@(.-)/.+') -- if name is for example @esx_lib/imports/require/initl.lua it will capture ESX_LIB

    if resource then
        return resource, name:sub(#resource + 3) -- returns the path without script name
    end

    local idx = 4-- call stack depth (kept slightly lower than expected depth "just in case")
    --- When indexing source of 4 it returns @@esx_lib/imports/require
    --- When indexing source of 5 it returns for example @@esx_test/client.lua
    --- Used for identifing resource name.

    while true do
        local src = debug.getinfo(idx, 'S')?.source

        if not src then
            error(('Couldn\'t find a source for "%s"'):format(name))
        end

        resource = src:match('^@@([^/]+)/.+') -- returns resource name

        if resource and not src:find('^@@esx_lib/imports/require') then
            return resource, name
        end

        idx += 1
    end
end

---Searcher for a accessable path
---@param name string
---@param path string
---@return string?, string? -- filename, error message
---@diagnostic disable-next-line: duplicate-set-field
function package.searchpath(name, path)
    local resource, module_name = getModuleInfo(name:gsub('%.', '/'))

    local tried <const> = {}

    for template in path:gmatch('[^;]+') do
        local file_name = template:gsub('^%./', ''):gsub('?', module_name:gsub('%.', '/') or module_name)

        local file = LoadResourceFile(resource, file_name)

        if file then
            TEMP_DATA[1] = file
            TEMP_DATA[2] = resource

            return file_name
        end

        tried[#tried+1] = ('no file "@%s/%s"'):format(resource, file_name)
    end

    return nil, table.concat(tried, '\n\t')
end

---Loads module
---@param name string
---@param env? unknown
---@return function?, string?
local function loadModule(name, env)
    local file_name, err = package.searchpath(name, package.path)
    
    if file_name then
        local file = TEMP_DATA[1]
        local resource = TEMP_DATA[2]

        table.wipe(TEMP_DATA)

        return assert(load(file, ('@@%s/%s'):format(resource, file_name), 't', env or _ENV))
    end

    return nil, err or 'unknown error'
end

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias PackageSearcher
---| fun(name: string): function loader
---| fun(name: string): nil|false , string error message
---| fun(name: string): function?, string?

---@type PackageSearcher[]
package.searchers = {
    function (name)
        local ok, result = pcall(_require, name)

        if ok then
            return result
        end

        return ok, result
    end,
    function (name)
        if package.preload[name] ~= nil then
            return package.preload[name]
        end

        return nil, ('no field package.preload["%s"]'):format(name)
    end,
    function(name)
        return loadModule(name)
    end,
}

---Loads and runs a Lua file at the given path. Unlike require, the chunk is not cached for future use.
---@param file_path string
---@param env? unknown
function xLib.load(file_path, env)
    xLib.verify(file_path, 'string', true)

    local result, err = loadModule(file_path, env)

    if result then
        return result()
    end

    error(('file "%s" not found\n\t%s'):format(file_path, err))
end

---Loads and decodes a json file at the given path.
---@param file_path string
function xLib.loadJson(file_path)
    xLib.verify(file_path, 'string', true)

    local res_source, mod_path = getModuleInfo(file_path:gsub('%.', '/'))

    local res_file  = LoadResourceFile(res_source, ('%s.json'):format(mod_path))

    if res_file then
        return json.decode(res_file)
    end

    error(('json file "%s" not found\n\tno file "%s/%s.json"'):format(file_path, res_source, mod_path))
end

---Loads the given module, returns any value returned by the seacher (`true` when `nil`).\
---Passing `@resourceName.modName` loads a module from a remote resource.
---@param name string
---@return unknown
function xLib.require(name)
    xLib.verify(name, 'string', true)

    local module = LOADED[name]

    if module == 'loading' then
        error(('^1circular-dependency occurred when loading module "%s"^0'):format(name))
    end

    if module ~= nil then return module end

    LOADED[name] = 'loading'

    local err = {}

    for i = 1, #package.searchers do
        local result, err_msg = package.searchers[i](name)

        if result then
            if type(result) == 'function' then result = result() end
            LOADED[name] = result or result == nil

            return LOADED[name]
        end


        err[#err + 1] = err_msg
    end

    error(('%s'):format(table.concat(err, '\n\t')))
end

return xLib.require
