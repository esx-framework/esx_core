ESX.OneSync = {}

---@class vector3
---@field x number
---@field y number
---@field z number

local function getNearbyPlayers(source, closest, distance, ignore)
	local result = {}
	local count = 0
	if not distance then distance = 100 end
	if type(source) == 'number' then
		source = GetPlayerPed(source)

		if not source then
			error("Received invalid first argument (source); should be playerId or vector3 coordinates")
		end

		source = GetEntityCoords(GetPlayerPed(source))
	end

	for _, xPlayer in pairs(ESX.Players) do
		if not ignore or not ignore[xPlayer.source] then
			local entity = GetPlayerPed(xPlayer.source)
			local coords = GetEntityCoords(entity)

			if not closest then
				local dist = #(source - coords)
				if dist <= distance then
					count += 1
					result[count] = {id = xPlayer.source, ped = NetworkGetNetworkIdFromEntity(entity), coords = coords, dist = dist}
				end
			else
				local dist = #(source - coords)
				if dist <= (result.dist or distance) then
					result = {id = xPlayer.source, ped = NetworkGetNetworkIdFromEntity(entity), coords = coords, dist = dist}
				end
			end
		end
	end

	return result
end

---@param source vector3|number playerId or vector3 coordinates
---@param maxDistance number
---@param ignore table playerIds to ignore, where the key is playerId and value is true
function ESX.OneSync.GetPlayersInArea(source, maxDistance, ignore)
	return getNearbyPlayers(source, false, maxDistance, ignore)
end

---@param source vector3|number playerId or vector3 coordinates
---@param maxDistance number
---@param ignore table playerIds to ignore, where the key is playerId and value is true
function ESX.OneSync.GetClosestPlayer(source, maxDistance, ignore)
	return getNearbyPlayers(source, true, maxDistance, ignore)
end

---@param model number|string
---@param coords vector3|table
---@param heading number
---@param Properties table
---@param cb function
function ESX.OneSync.SpawnVehicle(model, coords, heading, Properties, cb)
	model = type(model) == 'string' and joaat(model) or model
	Properties = Properties or {}
	local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
	CreateThread(function()
		local player = nil
		for _, playerId in ipairs(GetPlayers()) do
				ESX.GetVehicleType(model, playerId, function(Type)
					local SpawnedEntity = CreateVehicleServerSetter(model, Type, vector, heading)
					Wait(250)
					local NetworkId = NetworkGetNetworkIdFromEntity(SpawnedEntity)
					Properties.NetId = NetworkId
					Entity(SpawnedEntity).state:set('VehicleProperties', Properties, true)
					cb(NetworkId)
				end)
				break
		end
	end)
end


---@param model number|string
---@param coords vector3|table
---@param heading number
---@param cb function
function ESX.OneSync.SpawnObject(model, coords, heading, cb)
	if type(model) == 'string' then model = joaat(model) end
	local coords = type(coords) == "vector3" and coords or vector3(coords.x, coords.y, coords.z)
	CreateThread(function()
		local entity = CreateObject(model, coords, true, true)
		while not DoesEntityExist(entity) do Wait(50) end
		SetEntityHeading(entity, heading)
		cb(NetworkGetNetworkIdFromEntity(entity))
	end)
end

---@param model number|string
---@param coords vector3|table
---@param heading number
---@param cb function
function ESX.OneSync.SpawnPed(model, coords, heading, cb)
	if type(model) == 'string' then model = joaat(model) end
	CreateThread(function()
		local entity = CreatePed(0, model, coords.x, coords.y, coords.z, heading, true, true)
		while not DoesEntityExist(entity) do Wait(50) end
		return entity
	end)
end

---@param model number|string
---@param vehicle number entityId
---@param seat number
---@param cb function
function ESX.OneSync.SpawnPedInVehicle(model, vehicle, seat, cb)
	if type(model) == 'string' then model = joaat(model) end
	CreateThread(function()
		local entity = CreatePedInsideVehicle(vehicle, 1, model, seat, true, true)
		while not DoesEntityExist(entity) do Wait(50) end
		return entity
	end)
end

local function getNearbyEntities(entities, coords, modelFilter, maxDistance, isPed)
	local nearbyEntities = {}
	coords = type(coords) == 'number' and GetEntityCoords(GetPlayerPed(coords)) or vector3(coords.x, coords.y, coords.z)
	for _, entity in pairs(entities) do
		if not isPed or (isPed and not IsPedAPlayer(entity)) then
			if not modelFilter or modelFilter[GetEntityModel(entity)] then
				local entityCoords = GetEntityCoords(entity)
				if not maxDistance or #(coords - entityCoords) <= maxDistance then
					nearbyEntities[#nearbyEntities+1] = NetworkGetNetworkIdFromEntity(entity)
				end
			end
		end
	end

	return nearbyEntities
end

---@param coords vector3
---@param maxDistance number
---@param modelFilter table models to ignore, where the key is the model hash and the value is true
---@return table
function ESX.OneSync.GetPedsInArea(coords, maxDistance, modelFilter)
	return getNearbyEntities(GetAllPeds(), coords, modelFilter, maxDistance, true)
end

---@param coords vector3
---@param maxDistance number
---@param modelFilter table models to ignore, where the key is the model hash and the value is true
---@return table
function ESX.OneSync.GetObjectsInArea(coords, maxDistance, modelFilter)
	return getNearbyEntities(GetAllObjects(), coords, modelFilter, maxDistance)
end

---@param coords vector3
---@param maxDistance number
---@param modelFilter table models to ignore, where the key is the model hash and the value is true
---@return table
function ESX.OneSync.GetVehiclesInArea(coords, maxDistance, modelFilter, cb)
	return getNearbyEntities(GetAllVehicles(), coords, modelFilter, maxDistance)
end

local function getClosestEntity(entities, coords, modelFilter, isPed)
	local distance, closestEntity, closestCoords = maxDistance or 100, nil, nil
	coords = type(coords) == 'number' and GetEntityCoords(GetPlayerPed(coords)) or vector3(coords.x, coords.y, coords.z)

	for _, entity in pairs(entities) do
		if not isPed or (isPed and not IsPedAPlayer(entity)) then
			if not modelFilter or modelFilter[GetEntityModel(entity)] then
				local entityCoords = GetEntityCoords(entity)
				local dist = #(coords - entityCoords)
				if dist < distance then
					closestEntity, distance, closestCoords = entity, dist, entityCoords
				end
			end
		end
	end
	return NetworkGetNetworkIdFromEntity(closestEntity), distance, closestCoords
end

---@param coords vector3
---@param modelFilter table models to ignore, where the key is the model hash and the value is true
---@return number entityId, number distance, vector3 coords
function ESX.OneSync.GetClosestPed(coords, modelFilter)
	return getClosestEntity(GetAllPeds(), coords, modelFilter, true)
end

---@param coords vector3
---@param modelFilter table models to ignore, where the key is the model hash and the value is true
---@return number entityId, number distance, vector3 coords
function ESX.OneSync.GetClosestObject(coords, modelFilter)
	return getClosestEntity(GetAllObjects(), coords, modelFilter)
end

---@param coords vector3
---@param modelFilter table models to ignore, where the key is the model hash and the value is true
---@return number entityId, number distance, vector3 coords
function ESX.OneSync.GetClosestVehicle(coords, modelFilter)
	return getClosestEntity(GetAllVehicles(), coords, modelFilter)
end

ESX.RegisterServerCallback("esx:Onesync:SpawnObject", function(source, cb, model, coords, heading)
	ESX.OneSync.SpawnObject(model, coords, heading, cb)
end)
