local events = {}
local timers = {}
local cbEvent = ('__ox_cb_%s')

RegisterNetEvent(cbEvent:format(cache.resource), function(key, ...)
	local cb = events[key]
	return cb and cb(...)
end)

---@param event string
---@param delay number prevent the event from being called for the given time
local function eventTimer(event, delay)
	if delay and type(delay) == 'number' and delay > 0 then
		local time = GetGameTimer()

		if (timers[event] or 0) > time then
			return false
		end

		timers[event] = time + delay
	end

	return true
end

---@param _ any
---@param event string
---@param delay number
---@param cb function
---@param ... unknown
---@return unknown
local function triggerServerCallback(_, event, delay, cb, ...)
	if not eventTimer(event, delay) then return end

	local key

	repeat
		key = ('%s:%s'):format(event, math.random(0, 100000))
	until not events[key]

	TriggerServerEvent(cbEvent:format(event), cache.resource, key, ...)

	local promise = not cb and promise.new()

	events[key] = function(response)
		events[key] = nil

		if promise then
			return promise:resolve(response)
		end

		cb(table.unpack(response))
	end

	if promise then
		return table.unpack(Citizen.Await(promise))
	end
end

---@overload fun(event: string, delay: number, cb: function, ...)
local callback = setmetatable({}, {
	__call = triggerServerCallback
})

---@param event string
---@param delay number prevent the event from being called for the given time
--- Sends an event to the server and halts the current thread until a response is returned.
function callback.await(event, delay, ...)
	return triggerServerCallback(_, event, delay, false, ...)
end

---@param name string
---@param cb function
--- Registers an event handler and callback function to respond to server requests.
function callback.register(name, cb)
	RegisterNetEvent(cbEvent:format(name), function(resource, key, ...)
		TriggerServerEvent(cbEvent:format(resource), key, { cb(...) })
	end)
end

return callback
