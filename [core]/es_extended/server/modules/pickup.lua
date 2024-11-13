Core.Pickups = {}
Core.PickupId = 0

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

    RegisterNetEvent("esx:onPickup", function(pickupId)
        local pickup, xPlayer, success = Core.Pickups[pickupId], ESX.GetPlayerFromId(source)

        if not pickup then return end

        local playerPickupDistance = #(pickup.coords - xPlayer.getCoords(true))
        if playerPickupDistance > 5.0 then
            print(("[^3WARNING^7] Player Detected Cheating (Out of range pickup): ^5%s^7"):format(xPlayer.getIdentifier()))
            return
        end

        if pickup.type == "item_standard" then
            if not xPlayer.canCarryItem(pickup.name, pickup.count) then
                return xPlayer.showNotification(TranslateCap("threw_cannot_pickup"))
            end

            xPlayer.addInventoryItem(pickup.name, pickup.count)
            success = true
        elseif pickup.type == "item_account" then
            success = true
            xPlayer.addAccountMoney(pickup.name, pickup.count, "Picked up")
        elseif pickup.type == "item_weapon" then
            if xPlayer.hasWeapon(pickup.name) then
                return xPlayer.showNotification(TranslateCap("threw_weapon_already"))
            end

            success = true
            xPlayer.addWeapon(pickup.name, pickup.count)
            xPlayer.setWeaponTint(pickup.name, pickup.tintIndex)

            for _, v in ipairs(pickup.components) do
                xPlayer.addWeaponComponent(pickup.name, v)
            end
        end

        if success then
            Core.Pickups[pickupId] = nil
            TriggerClientEvent("esx:removePickup", -1, pickupId)
        end
    end)
end
