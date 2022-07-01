local safePositions = {}

RegisterNetEvent('money:allowPickupNear')

AddEventHandler('money:allowPickupNear', function(pedId)
    local entity = NetworkGetEntityFromNetworkId(pedId)

    Wait(250)

    if not DoesEntityExist(entity) then
        return
    end

    if GetEntityHealth(entity) > 100 then
        return
    end

    local coords = GetEntityCoords(entity)
    safePositions[pedId] = coords
end)

RegisterNetEvent('money:tryPickup')

AddEventHandler('money:tryPickup', function(entity)
    if not safePositions[entity] then
        return
    end

    local source = source
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if #(safePositions[entity] - coords) < 2.5 then
        exports['money']:addMoney(source, 'cash', 40)
    end

    safePositions[entity] = nil
end)

AddEventHandler('entityRemoved', function(entity)
    safePositions[entity] = nil
end)