---@diagnostic disable: lowercase-global
xLib = setmetatable({
    name = 'esx_lib',
    side = IsDuplicityVersion() and 'server' or 'client'
}, {
    __newindex = function(self, key, fn)
        rawset(self, key, fn)

        if debug.getinfo(2, 'S').short_src:find('@esx_lib/resource') then
            exports(key, fn)
        end
    end,

    __index = function(self, key)
        local dir = ('imports/%s'):format(key)
        local chunk = LoadResourceFile(self.name, ('%s/%s.lua'):format(dir, self.side))

        local shared = LoadResourceFile(self.name, ('%s/shared.lua'):format(dir))

        if shared then
            chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
        end

        if chunk then
            local fn, err = load(chunk, ('@@esx_lib/%s/%s.lua'):format(key, self.side))

            if not fn or err then
                return error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
            end

            rawset(self, key, fn() or Noop)

            return self[key]
        end
    end
})

require = xLib.require