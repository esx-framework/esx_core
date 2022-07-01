local cache = {}
cache.playerId = PlayerId()
cache.serverId = GetPlayerServerId(cache.playerId)

local GetVehiclePedIsIn = GetVehiclePedIsIn
local GetPedInVehicleSeat = GetPedInVehicleSeat
local GetVehicleMaxNumberOfPassengers = GetVehicleMaxNumberOfPassengers

function cache:getVehicle()
	local vehicle = GetVehiclePedIsIn(self.ped, false)
	if vehicle > 0 then
		self:set('vehicle', vehicle)

		if not cache.seat or GetPedInVehicleSeat(vehicle, cache.seat) ~= cache.ped then
			for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
				if GetPedInVehicleSeat(vehicle, i) == self.ped then
					return self:set('seat', i)
				end
			end
		end
	else
		self:set('vehicle', false)
		self:set('seat', false)
	end
end

local update = {}

function cache:set(key, value)
	if value ~= self[key] then
		self[key] = value
		update[key] = value
		return true
	end
end

local GetEntityCoords = GetEntityCoords

CreateThread(function()
	local num = 1
	while true do
		num += 1
		cache:set('ped', PlayerPedId())

		if num > 1 then
			cache.coords = GetEntityCoords(cache.ped)
			cache:getVehicle()
			num = 0
		end

		if next(update) then
			TriggerEvent('ox_lib:updateCache', update)
			table.wipe(update)
		end

		Wait(100)
	end
end)

function lib.cache(key)
	return cache[key]
end

_ENV.cache = cache
