-- #TODO: Ox inventory implementation ( Create custom drop)
if not Config.OxInventory then
    function ESX.CreatePickup(type, name, count, label, playerId, components, tintIndex)
        local pickupId = (Core.PickupId == 65635 and 0 or Core.PickupId + 1)
        local xPlayer = ESX.Players[playerId]
        local coords = xPlayer.getCoords()

        Core.Pickups[pickupId] = { type = type, name = name, count = count, label = label, coords = coords }

        if type == 'item_weapon' then
            Core.Pickups[pickupId].components = components
            Core.Pickups[pickupId].tintIndex = tintIndex
        end

        TriggerClientEvent('esx:createPickup', -1, pickupId, label, coords, type, name, components, tintIndex)
        Core.PickupId = pickupId
    end
end
