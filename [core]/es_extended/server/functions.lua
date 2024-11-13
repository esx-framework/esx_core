---@param msg string
---@return nil
function ESX.Trace(msg)
    if Config.EnableDebug then
        print(("[^2TRACE^7] %s^7"):format(msg))
    end
end

--- Triggers an event for one or more clients.
---@param eventName string The name of the event to trigger.
---@param playerIds table|number If a number, represents a single player ID. If a table, represents an array of player IDs.
---@param ... any Additional arguments to pass to the event handler.
function ESX.TriggerClientEvent(eventName, playerIds, ...)
    if type(playerIds) == "number" then
        TriggerClientEvent(eventName, playerIds, ...)
        return
    end

    local payload = msgpack.pack_args(...)
    local payloadLength = #payload

    for i = 1, #playerIds do
        TriggerClientEventInternal(eventName, playerIds[i], payload, payloadLength)
    end
end

---@param model string|number
---@param player number
---@param cb function
---@diagnostic disable-next-line: duplicate-set-field
function ESX.GetVehicleType(model, player, cb)
    model = type(model) == "string" and joaat(model) or model

    if Core.vehicleTypesByModel[model] then
        return cb(Core.vehicleTypesByModel[model])
    end

    ESX.TriggerClientCallback(player, "esx:GetVehicleType", function(vehicleType)
        Core.vehicleTypesByModel[model] = vehicleType
        cb(vehicleType)
    end, model)
end

if not Config.CustomInventory then
    ---@param itemType string
    ---@param name string
    ---@param count integer
    ---@param label string
    ---@param playerId number
    ---@param components? string | table
    ---@param tintIndex? integer
    ---@param coords? table | vector3
    ---@return nil
    function ESX.CreatePickup(itemType, name, count, label, playerId, components, tintIndex, coords)
        local pickupId = (Core.PickupId == 65635 and 0 or Core.PickupId + 1)
        local xPlayer = ESX.Players[playerId]
        coords = ((type(coords) == "vector3" or type(coords) == "vector4") and coords.xyz or xPlayer.getCoords(true))

        Core.Pickups[pickupId] = { type = itemType, name = name, count = count, label = label, coords = coords }

        if itemType == "item_weapon" then
            Core.Pickups[pickupId].components = components
            Core.Pickups[pickupId].tintIndex = tintIndex
        end

        TriggerClientEvent("esx:createPickup", -1, pickupId, label, coords, itemType, name, components, tintIndex)
        Core.PickupId = pickupId
    end
end
