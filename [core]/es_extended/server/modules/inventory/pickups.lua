-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

if not Config.CustomInventory then
    local STREAM_DISTANCE <const> = 150.0
    local CELL_SIZE <const> = 100.0
    local CELL_RANGE <const> = math.ceil(STREAM_DISTANCE / CELL_SIZE)

    local PICKUP_TTL_MS <const> = 30 * 60 * 1000
    local MAX_PICKUP_ID <const> = 65635
    local MAX_ACTIVE_PER_PLAYER <const> = 50
    local MAX_ACTIVE_PER_PLAYER_CELL <const> = 25
    local MAX_ACTIVE_PER_CELL <const> = 250
    local MAX_ACTIVE_GLOBAL <const> = 5000

    ---@type table<number, table<string, { entries: table<number, true>, count: number, owners: table<string, number> }>>
    local pickupGrid = {}
    ---@type table<string, number>
    local ownerPickupCounts = {}
    local activePickupCount = 0

    ---@param coords vector3
    ---@param bucket? number
    ---@return number[]
    local function getPlayersInStreamRange(coords, bucket)
        local nearby = xLib.onesync.getPlayersInArea(coords, STREAM_DISTANCE)
        local targets = {}

        for i = 1, #nearby do
            local id = nearby[i].id

            if not bucket or GetPlayerRoutingBucket(id) == bucket then
                targets[#targets + 1] = id
            end
        end

        return targets
    end

    Core.PickupStreamDistance = STREAM_DISTANCE
    Core.GetPickupTargets = getPlayersInStreamRange

    ---@param coords vector3|table
    ---@return string
    local function getCellKey(coords)
        local cx = math.floor(coords.x / CELL_SIZE)
        local cy = math.floor(coords.y / CELL_SIZE)

        return ("%d:%d"):format(cx, cy)
    end

    ---@param coords vector3|table
    ---@return string[]
    local function getCellKeysAround(coords)
        local cx = math.floor(coords.x / CELL_SIZE)
        local cy = math.floor(coords.y / CELL_SIZE)
        local keys = {}

        for dx = -CELL_RANGE, CELL_RANGE do
            for dy = -CELL_RANGE, CELL_RANGE do
                keys[#keys + 1] = ("%d:%d"):format(cx + dx, cy + dy)
            end
        end

        return keys
    end

    ---@param playerId number
    ---@return string
    local function getOwnerKey(playerId)
        return GetPlayerIdentifierByType(tostring(playerId), "license") or ("source:%s"):format(playerId)
    end

    ---@param value any
    ---@return vector3?
    local function toVector3(value)
        local valueType = type(value)

        if valueType == "vector3" or valueType == "vector4" then
            return value.xyz
        end

        if valueType == "table" then
            local x, y, z = tonumber(value.x), tonumber(value.y), tonumber(value.z)

            if x and y and z then
                return vector3(x, y, z)
            end
        end
    end

    ---@param pickupId number
    ---@param pickup table
    local function addPickupToGrid(pickupId, pickup)
        local bucketGrid = pickupGrid[pickup.bucket]

        if not bucketGrid then
            bucketGrid = {}
            pickupGrid[pickup.bucket] = bucketGrid
        end

        local cell = bucketGrid[pickup.cellKey]

        if not cell then
            cell = { entries = {}, count = 0, owners = {} }
            bucketGrid[pickup.cellKey] = cell
        end

        cell.entries[pickupId] = true
        cell.count = cell.count + 1

        if pickup.owner then
            cell.owners[pickup.owner] = (cell.owners[pickup.owner] or 0) + 1
        end
    end

    ---@param pickupId number
    ---@param pickup table
    local function removePickupFromGrid(pickupId, pickup)
        local bucketGrid = pickupGrid[pickup.bucket]

        if not bucketGrid then
            return
        end

        local cell = bucketGrid[pickup.cellKey]

        if not cell then
            return
        end

        if cell.entries[pickupId] then
            cell.entries[pickupId] = nil
            cell.count = cell.count - 1

            if pickup.owner then
                local ownerCount = (cell.owners[pickup.owner] or 1) - 1
                cell.owners[pickup.owner] = ownerCount > 0 and ownerCount or nil
            end
        end

        if cell.count <= 0 then
            bucketGrid[pickup.cellKey] = nil
        end

        if not next(bucketGrid) then
            pickupGrid[pickup.bucket] = nil
        end
    end

    ---@param pickupId number
    ---@param targets? number[]
    local function destroyPickup(pickupId, targets)
        local pickup = Core.Pickups[pickupId]

        if not pickup then
            return
        end

        Core.Pickups[pickupId] = nil
        removePickupFromGrid(pickupId, pickup)

        if pickup.owner then
            local ownerCount = (ownerPickupCounts[pickup.owner] or 1) - 1
            ownerPickupCounts[pickup.owner] = ownerCount > 0 and ownerCount or nil
        end

        activePickupCount = activePickupCount - 1

        if targets and #targets > 0 then
            xLib.triggerClientEvent("esx:removePickup", targets, pickupId)
        end
    end

    ---@param pickupId number
    ---@param notify? boolean | number[]
    Core.RemovePickup = function(pickupId, notify)
        local pickup = Core.Pickups[pickupId]

        if not pickup then
            return
        end

        local targets

        if type(notify) == "table" then
            targets = notify
        elseif notify then
            targets = getPlayersInStreamRange(pickup.coords, pickup.bucket)
        end

        destroyPickup(pickupId, targets)
    end

    ---@param itemType string
    ---@param name string
    ---@param count integer
    ---@param label string
    ---@param playerId? number
    ---@param components? string | table
    ---@param tintIndex? integer
    ---@param coords? table | vector3 | vector4
    ---@param bucket? number
    ---@return number? pickupId
    function ESX.CreatePickup(itemType, name, count, label, playerId, components, tintIndex, coords, bucket)
        local xPlayer = playerId and ESX.GetPlayerFromId(playerId) or nil
        local pickupCoords = toVector3(coords)

        if not pickupCoords then
            if not xPlayer then
                return nil
            end

            pickupCoords = xPlayer.getCoords(true)
        end

        local owner = xPlayer and getOwnerKey(playerId) or nil
        local pickupBucket = tonumber(bucket) or (xPlayer and GetPlayerRoutingBucket(playerId)) or 0

        if activePickupCount >= MAX_ACTIVE_GLOBAL then
            return nil
        end

        local cellKey = getCellKey(pickupCoords)
        local bucketGrid = pickupGrid[pickupBucket]
        local cell = bucketGrid and bucketGrid[cellKey] or nil

        if cell and cell.count >= MAX_ACTIVE_PER_CELL then
            return nil
        end

        if owner then
            if (ownerPickupCounts[owner] or 0) >= MAX_ACTIVE_PER_PLAYER then
                return nil
            end

            if cell and (cell.owners[owner] or 0) >= MAX_ACTIVE_PER_PLAYER_CELL then
                return nil
            end
        end

        local pickupId = Core.PickupId

        repeat
            pickupId = pickupId >= MAX_PICKUP_ID and 0 or pickupId + 1
        until not Core.Pickups[pickupId]

        local pickup = {
            type = itemType,
            name = name,
            count = count,
            label = label,
            coords = pickupCoords,
            bucket = pickupBucket,
            cellKey = cellKey,
            createdAt = GetGameTimer(),
            owner = owner,
        }

        if itemType == "item_weapon" then
            pickup.components = components
            pickup.tintIndex = tintIndex
        end

        Core.Pickups[pickupId] = pickup
        addPickupToGrid(pickupId, pickup)
        activePickupCount = activePickupCount + 1

        if owner then
            ownerPickupCounts[owner] = (ownerPickupCounts[owner] or 0) + 1
        end

        xLib.triggerClientEvent("esx:createPickup", getPlayersInStreamRange(pickupCoords, pickupBucket), pickupId, label, pickupCoords, itemType, name, components, tintIndex)
        Core.PickupId = pickupId

        return pickupId
    end

    RegisterNetEvent("esx:requestPickups", function()
        local playerId = source

        if not Core.InventoryEvents.ConsumeRate("pickup", playerId) then
            return
        end

        local ped = GetPlayerPed(playerId)

        if ped == 0 then
            return
        end

        local playerCoords = GetEntityCoords(ped)
        local bucket = GetPlayerRoutingBucket(playerId)
        local nearbyPickups = {}
        local cellKeys = getCellKeysAround(playerCoords)
        local bucketGrid = pickupGrid[bucket]

        for i = 1, #cellKeys do
            local cell = bucketGrid and bucketGrid[cellKeys[i]] or nil

            if cell then
                for pickupId in pairs(cell.entries) do
                    local pickup = Core.Pickups[pickupId]

                    if pickup and #(playerCoords - pickup.coords) <= STREAM_DISTANCE then
                        nearbyPickups[pickupId] = {
                            label = pickup.label,
                            coords = pickup.coords,
                            type = pickup.type,
                            name = pickup.name,
                            components = pickup.components,
                            tintIndex = pickup.tintIndex,
                        }
                    end
                end
            end
        end

        TriggerClientEvent("esx:createMissingPickups", playerId, nearbyPickups)
    end)

    CreateThread(function()
        while true do
            Wait(60000)

            local now = GetGameTimer()

            for pickupId, pickup in pairs(Core.Pickups) do
                if now - (pickup.createdAt or now) > PICKUP_TTL_MS then
                    destroyPickup(pickupId, getPlayersInStreamRange(pickup.coords, pickup.bucket))
                end
            end
        end
    end)
end
