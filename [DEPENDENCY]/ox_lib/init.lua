
-- ox_lib
-- Copyright (C) 2021	Linden <https://github.com/thelindat>

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0.html>

if not _VERSION:find('5.4') then
	error('^1Lua 5.4 must be enabled in the resource manifest!^0', 2)
end

local ox_lib = 'ox_lib'

if not GetResourceState(ox_lib):find('start') then
	error('^1ox_lib should be started before this resource^0', 2)
end

-----------------------------------------------------------------------------------------------
-- Module
-----------------------------------------------------------------------------------------------

local LoadResourceFile = LoadResourceFile
local service = IsDuplicityVersion() and 'server' or 'client'

local function loadModule(self, module)
	local dir = ('imports/%s'):format(module)
	local chunk = LoadResourceFile(ox_lib, ('%s/%s.lua'):format(dir, service))
	local shared = LoadResourceFile(ox_lib, ('%s/shared.lua'):format(dir))

	if shared then
		chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
	end

	if chunk then
		local err
		chunk, err = load(chunk, ('@@ox_lib/%s/%s.lua'):format(module, service))
		if err then
			error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
		else
			local result = chunk() or function() end
			rawset(self, module, result)
			return self[module]
		end
	end
end

-----------------------------------------------------------------------------------------------
-- API
-----------------------------------------------------------------------------------------------

local export = exports[ox_lib]

local function call(self, index, ...)
	local module = rawget(self, index)
	if not module then
		module = loadModule(self, index)

		if not module then
			local function method(...)
				return export[index](nil, ...)
			end

			if not ... then
				rawset(self, index, method)
			end

			return method
		end
	end

	return module
end

lib = setmetatable({
	name = ox_lib,
	service = service,
	exports = {},
	onCache = setmetatable({}, {
		__call = function(self, key, cb)
			self[key] = cb
		end
	})
}, {
	__index = call,
	__call = call,
})

local intervals = {}
--- Dream of a world where this PR gets accepted.
---@param callback function
---@param interval? number
---@param ... any
function SetInterval(callback, interval, ...)
	interval = interval or 0
	assert(type(interval) == 'number', ('Interval must be a number. Received %s'):format(json.encode(interval)))
	local cbType = type(callback)

	if cbType == 'number' and intervals[callback] then
		intervals[callback] = interval or 0
		return
	end

	assert(cbType == 'function', ('Callback must be a function. Received %s'):format(tostring(cbType)))
	local id
	local args = {...}

	Citizen.CreateThreadNow(function(ref)
		id = ref
		intervals[id] = interval or 0
		repeat
			interval = intervals[id]
			Wait(interval)
			callback(table.unpack(args))
		until interval < 0
		intervals[id] = nil
	end)

	return id
end

function ClearInterval(id)
	assert(type(id) == 'number', ('Interval id must be a number. Received %s'):format(json.encode(id)))
	assert(intervals[id], ('No interval exists with id %s'):format(id))
	intervals[id] = -1
end


-----------------------------------------------------------------------------------------------
-- Cache
-----------------------------------------------------------------------------------------------

local ox = GetResourceState('ox_core') ~= 'missing' and setmetatable({}, {
	__index = function()
		return true
	end
}) or {
	groups = GetResourceState('ox_groups') ~= 'missing',
}

local _cache = setmetatable({}, {
	__index = function(self, key)
		return rawset(self, key, export.cache(nil, key) or false)[key]
	end,

	__call = function(self)
		table.wipe(self)

		if ox.groups then
			self.groups = setmetatable({}, {
				__index = function(groups, index)
					groups[index] = GlobalState['group:'..index]
					return groups[index]
				end
			})
		end
	end
})

cache = setmetatable({
	resource = GetCurrentResourceName(),
}, {
	__index = _cache,
	__metatable = _cache
})

if service == 'client' then
	RegisterNetEvent(('%s:notify'):format(cache.resource), function(data)
		if locale then
			if data.title then
				data.title = locale(data.title) or data.title
			end

			if data.description then
				data.description = locale(data.description) or data.description
			end
		end

		return export:notify(data)
	end)

	cache.playerId = PlayerId()
	cache.serverId = GetPlayerServerId(cache.playerId)
else
	local notify = ('%s:notify'):format(cache.resource)

	function lib.notify(source, data)
		TriggerClientEvent(notify, source, data)
	end
end

Citizen.CreateThreadNow(function()
	while true do
		_cache()
		Wait(60000)
	end
end)

AddEventHandler('ox_lib:updateCache', function(data)
	for key, value in pairs(data) do
		if lib.onCache[key] then
			lib.onCache[key](value)
		end

		_cache[key] = value
	end
end)
