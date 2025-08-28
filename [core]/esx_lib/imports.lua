--! DISCLAIMER
--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

-- Const Variables
local CONTEXT<const> = IsDuplicityVersion() and 'server' or 'client'
local LIB_NAME<const> = 'esx_lib'

-- xLib class for Language Server
---@class xLib
---@field name string
---@field side 'server' | 'client'


-------------------------------------------------
--- Core functions for modules
-------------------------------------------------

--- Function that returns nothing
local function noop() end

---Loads a module into memory
---@param self xLib
---@param name string -- module name
local function loadModule(self, name)
    local directory = ('imports/%s'):format(name)
    local chunk = LoadResourceFile(LIB_NAME, ('%s/%s.lua'):format(directory, CONTEXT)) -- returns a raw lua code as a string (SERVER/CLIENT side)
    local shared_chunk = LoadResourceFile(LIB_NAME, ('%s/shared.lua'):format(directory)) -- returns a raw lua code as a string (SHARED)

    if shared_chunk then
        chunk = chunk and ('%s\n%s'):format(shared_chunk, chunk) or shared_chunk -- creates a string with shared and client/server code combined
    end

    if not chunk then
        -- Early exit if the code doesn't exist 
        return false
    end

    -- Second argument is a chunk name
    local fn, err = load(chunk, ('@%s/imports/%s/%s.lua'):format(LIB_NAME, name, CONTEXT))

    if not fn or err then
        if shared_chunk then
            print(('[%s] Found an error while importing - %s! Try updating %s to the latest version!'):format(LIB_NAME,
                name, LIB_NAME))

            -- Tries to load only shared.lua
            fn, err = load(shared_chunk, ('@%s/imports/%s/%s.lua'):format(LIB_NAME, name, 'shared'))
        end

        if not fn or err then
            return error(('Completly field importing module - %s; error - %s'):format(name, err))
        end
    end

end

---Function that is responsible for lazy loading
---@param self xLib
---@param index string -- name of the function/key that is called
---@param ... unknown -- function params
local function call(self, index, ...)
    local module = rawget(self, index) -- uses rawget not to trigger any metamethods

    -- Module Loading
    if not module then
        self[index] = noop -- to prevent module from loading again if doesn't exists.

        module = loadModule(self, index)

        if not module then
            error(('[%s] Tried to access an invalid module - %s!'):format(LIB_NAME, index))
        end
    end

    return module
end


-------------------------------------------------
--- Environment Setup
-------------------------------------------------


-- Creation of xLib object
---@class xLib
local xLib = setmetatable({
    name = LIB_NAME,
    side = CONTEXT
}, {
    -- Lazy Loading - loads module only when accessed
    __index = call,
    __call = call,
})

-- Allows to xLib to be accessible in resource that imports a lib
_ENV.xLib = xLib