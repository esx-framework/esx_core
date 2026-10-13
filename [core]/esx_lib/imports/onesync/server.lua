---@class onesynclib
xLib.onesync = {}

---@param source number|vector3
---@param closest boolean
---@param distance? number
---@param ignore? table
---@param routingBucket? number
local function getNearbyPlayers(source, closest, distance, ignore, routingBucket)
    local result = {}
    local count = 0
    local playerPed
    local playerCoords
    ignore = ignore or {}

    if not distance then
        distance = 100
    end

    if type(source) == "number" then
        playerPed = GetPlayerPed(source)

        if not source then
            error("Received invalid first argument (source); should be playerId")
        end

        playerCoords = GetEntityCoords(playerPed)

        if not playerCoords then
            error("Received nil value (playerCoords); perhaps source is nil at first place?")
        end
    end

    if type(source) == "vector3" then
        playerCoords = source

        if not playerCoords then
            error("Received nil value (playerCoords); perhaps source is nil at first place?")
        end
    end

    for _, xPlayer in pairs(ESX.Players) do
        if not ignore[xPlayer.source] and (not routingBucket or GetPlayerRoutingBucket(xPlayer.source) == routingBucket) then
            local entity = GetPlayerPed(xPlayer.source)
            local coords = GetEntityCoords(entity)

            if not closest then
                local dist = #(playerCoords - coords)
                if dist <= distance then
                    count = count + 1
                    result[count] = { id = xPlayer.source, ped = NetworkGetNetworkIdFromEntity(entity), coords = coords, dist = dist }
                end
            else
                if xPlayer.source ~= source then
                    local dist = #(playerCoords - coords)
                    if dist <= (result.dist or distance) then
                        result = { id = xPlayer.source, ped = NetworkGetNetworkIdFromEntity(entity), coords = coords, dist = dist }
                    end
                end
            end
        end
    end

    return result
end

---@param source vector3|number playerId or vector3 coordinates
---@param maxDistance number
---@param ignore? table playerIds to ignore, where the key is playerId and value is true
---@param routingBucket? number
function xLib.onesync.getPlayersInArea(source, maxDistance, ignore, routingBucket)
    return getNearbyPlayers(source, false, maxDistance, ignore, routingBucket)
end

---@param source vector3|number playerId or vector3 coordinates
---@param maxDistance number
---@param ignore? table playerIds to ignore, where the key is playerId and value is true
---@param routingBucket? number
function xLib.onesync.getClosestPlayer(source, maxDistance, ignore, routingBucket)
    return getNearbyPlayers(source, true, maxDistance, ignore, routingBucket)
end

local function getNearbyEntities(entities, coords, modelFilter, maxDistance, isPed)
    local nearbyEntities = {}
    coords = type(coords) == "number" and GetEntityCoords(GetPlayerPed(coords)) or vector3(coords.x, coords.y, coords.z)
    for _, entity in pairs(entities) do
        if not isPed or (isPed and not IsPedAPlayer(entity)) then
            if not modelFilter or modelFilter[GetEntityModel(entity)] then
                local entityCoords = GetEntityCoords(entity)
                if not maxDistance or #(coords - entityCoords) <= maxDistance then
                    nearbyEntities[#nearbyEntities + 1] = NetworkGetNetworkIdFromEntity(entity)
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
function xLib.onesync.getPedsInArea(coords, maxDistance, modelFilter)
    return getNearbyEntities(GetAllPeds(), coords, modelFilter, maxDistance, true)
end

---@param coords vector3
---@param maxDistance number
---@param modelFilter table models to ignore, where the key is the model hash and the value is true
---@return table
function xLib.onesync.getObjectsInArea(coords, maxDistance, modelFilter)
    return getNearbyEntities(GetAllObjects(), coords, modelFilter, maxDistance)
end

---@param coords vector3
---@param maxDistance number
---@param modelFilter table | nil models to ignore, where the key is the model hash and the value is true
---@return table
function xLib.onesync.getVehiclesInArea(coords, maxDistance, modelFilter)
    return getNearbyEntities(GetAllVehicles(), coords, modelFilter, maxDistance)
end

local function getClosestEntity(entities, coords, modelFilter, isPed)
    local distance, closestEntity, closestCoords = 100, 0, vector3(0, 0, 0)
    coords = type(coords) == "number" and GetEntityCoords(GetPlayerPed(coords)) or vector3(coords.x, coords.y, coords.z)

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
function xLib.onesync.getClosestPed(coords, modelFilter)
    return getClosestEntity(GetAllPeds(), coords, modelFilter, true)
end

---@param coords vector3
---@param modelFilter table models to ignore, where the key is the model hash and the value is true
---@return number entityId, number distance, vector3 coords
function xLib.onesync.getClosestObject(coords, modelFilter)
    return getClosestEntity(GetAllObjects(), coords, modelFilter)
end

---@param coords vector3
---@param modelFilter table models to ignore, where the key is the model hash and the value is true
---@return number entityId, number distance, vector3 coords
function xLib.onesync.getClosestVehicle(coords, modelFilter)
    return getClosestEntity(GetAllVehicles(), coords, modelFilter)
end

return xLib.onesync
