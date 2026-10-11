-- SPDX-License-Identifier: GPL-3.0-only
local storing = {}

exports('StoreJobVehicle', function(playerId, plates, locations)
    local player = ESX.GetPlayerFromId(playerId)

    if not player or type(plates) ~= 'table' or #plates < 1 or #plates > 32 then
        return false
    end

    local job = player.getJob()

    if job.onDuty == false then
        return false
    end

    local ped = GetPlayerPed(playerId)

    if ped == 0 then
        return false
    end

    local coords, near = GetEntityCoords(ped), false

    for _, location in pairs(locations or {}) do
        for _, category in ipairs({ 'Vehicles', 'Helicopters' }) do
            for _, garage in ipairs(location[category] or {}) do
                if garage.Spawner and #(coords - garage.Spawner) <= 35.0 then
                    near = true
                end
            end
        end
    end

    if not near then
        return false
    end

    local allowed = {}

    for _, value in ipairs(plates) do
        local plate = xLib.vehiclePlate.normalize(value)

        if plate then
            allowed[plate] = true
        end
    end

    for _, entity in ipairs(GetAllVehicles()) do
        local plate = xLib.vehiclePlate.normalize(GetVehicleNumberPlateText(entity))

        if
            allowed[plate]
            and not storing[plate]
            and DoesEntityExist(entity)
            and GetEntityRoutingBucket(entity) == GetPlayerRoutingBucket(playerId)
            and #(GetEntityCoords(entity) - coords) <= 30.0
        then
            storing[plate] = true

            local ok, result = pcall(function()
                local row = MySQL.single.await(
                    [[SELECT vehicle FROM owned_vehicles
                    WHERE owner = ? AND plate = ? AND job = ? AND stored = 0]],
                    { player.identifier, plate, job.name }
                )

                if not row or not DoesEntityExist(entity) then
                    return false
                end

                local decoded, props = pcall(json.decode, row.vehicle or '')
                local currentPed = GetPlayerPed(playerId)

                if
                    ESX.GetPlayerFromId(playerId) ~= player
                    or currentPed == 0
                    or #(GetEntityCoords(entity) - GetEntityCoords(currentPed)) > 30.0
                    or GetEntityRoutingBucket(entity) ~= GetPlayerRoutingBucket(playerId)
                    or not decoded
                    or props.model ~= GetEntityModel(entity)
                then
                    return false
                end

                for seat = -1, 15 do
                    if GetPedInVehicleSeat(entity, seat) ~= 0 then
                        return false
                    end
                end

                DeleteEntity(entity)

                local deadline = GetGameTimer() + 2000

                while DoesEntityExist(entity) and GetGameTimer() < deadline do
                    Wait(0)
                end

                if DoesEntityExist(entity) then
                    return false
                end

                local changed = MySQL.update.await(
                    [[UPDATE owned_vehicles SET stored = 1
                    WHERE owner = ? AND plate = ? AND job = ? AND stored = 0]],
                    { player.identifier, plate, job.name }
                )

                return changed == 1 and plate or false
            end)

            storing[plate] = nil

            if not ok then
                print('[es_extended] Job vehicle storage failed: ' .. tostring(result))
            end

            if ok and result then
                return result
            end
        end
    end

    return false
end)
