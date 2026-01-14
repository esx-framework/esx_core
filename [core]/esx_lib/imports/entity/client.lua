xLib.entity = {}

---@param entities table The entities to search through
---@param isPlayerEntities boolean Whether the entities are players
---@param coords? table | vector3 The coords to search from
---@param modelFilter? table The model filter
---@return integer, integer
function xLib.entity.closest(entities, isPlayerEntities, coords, modelFilter)
    local closestEntity, closestEntityDistance, filteredEntities = -1, -1, nil

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        local playerPed = PlayerPedId()
        coords = GetEntityCoords(playerPed)
    end

    if modelFilter then
        filteredEntities = {}

        for currentEntityIndex = 1, #entities do
            if modelFilter[GetEntityModel(entities[currentEntityIndex])] then
                filteredEntities[#filteredEntities + 1] = entities[currentEntityIndex]
            end
        end
    end

    for k, entity in pairs(filteredEntities or entities) do
        local distance = #(coords - GetEntityCoords(entity))

        if closestEntityDistance == -1 or distance < closestEntityDistance then
            closestEntity, closestEntityDistance = isPlayerEntities and k or entity, distance
        end
    end

    return closestEntity, closestEntityDistance
end

---@param entities table The entities to search through
---@param isPlayerEntities boolean Whether the entities are players
---@param coords? table | vector3 The coords to search from
---@param maxDistance number The maximum distance
---@return table
function xLib.entity.EnumerateWithinDistance(entities, isPlayerEntities, coords, maxDistance)
    local nearbyEntities = {}

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        local playerPed = PlayerPedId()
        coords = GetEntityCoords(playerPed)
    end

    for k, entity in pairs(entities) do
        local distance = #(coords - GetEntityCoords(entity))

        if distance <= maxDistance then
            nearbyEntities[#nearbyEntities + 1] = isPlayerEntities and k or entity
        end
    end

    return nearbyEntities
end

---@param entity integer The entity to get the coords of
---@param coords table | vector3 | vector4 The coords to teleport the entity to
---@param cb? function The callback function
function xLib.entity.Teleport(entity, coords, cb)

    if DoesEntityExist(entity) then
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        while not HasCollisionLoadedAroundEntity(entity) do
            Wait(0)
        end

        SetEntityCoords(entity, coords.x, coords.y, coords.z, false, false, false, false)
        SetEntityHeading(entity, coords.w or coords.heading or 0.0)
    end

    if cb then
        cb()
    end
end

return xLib.entity