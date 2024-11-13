if not Config.CustomInventory then return end

local pickups = {}

ESX.SecureNetEvent("esx:removePickup", function(pickupId)
    if pickups[pickupId] and pickups[pickupId].obj then
        ESX.Game.DeleteObject(pickups[pickupId].obj)
        pickups[pickupId] = nil
    end
end)

CreateThread(function()
    while true do
        local Sleep = 1500
        local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
        local _, closestDistance = ESX.Game.GetClosestPlayer(playerCoords)

        for pickupId, pickup in pairs(pickups) do
            local distance = #(playerCoords - pickup.coords)

            if distance < 5 then
                Sleep = 0
                local label = pickup.label

                if distance < 1 then
                    if IsControlJustReleased(0, 38) then
                        if IsPedOnFoot(ESX.PlayerData.ped) and (closestDistance == -1 or closestDistance > 3) and not pickup.inRange then
                            pickup.inRange = true

                            local dict, anim = "weapons@first_person@aim_rng@generic@projectile@sticky_bomb@", "plant_floor"
                            ESX.Streaming.RequestAnimDict(dict)
                            TaskPlayAnim(ESX.PlayerData.ped, dict, anim, 8.0, 1.0, 1000, 16, 0.0, false, false, false)
                            RemoveAnimDict(dict)
                            Wait(1000)

                            TriggerServerEvent("esx:onPickup", pickupId)
                            PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                        end
                    end

                    label = ("%s~n~%s"):format(label, TranslateCap("threw_pickup_prompt"))
                end

                local textCoords = pickup.coords + vector3(0.0, 0.0, 0.25)
                ESX.Game.Utils.DrawText3D(textCoords, label, 1.2, 1)
            elseif pickup.inRange then
                pickup.inRange = false
            end
        end
        Wait(Sleep)
    end
end)

ESX.SecureNetEvent("esx:createMissingPickups", function(missingPickups)
    for pickupId, pickup in pairs(missingPickups) do
        TriggerEvent("esx:createPickup", pickupId, pickup.label, vector3(pickup.coords.x, pickup.coords.y, pickup.coords.z - 1.0),
        pickup.type, pickup.name, pickup.components, pickup.tintIndex)
    end
end)

ESX.SecureNetEvent("esx:createPickup", function(pickupId, label, coords, itemType, name, components, tintIndex)
    local function setObjectProperties(object)
        SetEntityAsMissionEntity(object, true, false)
        PlaceObjectOnGroundProperly(object)
        FreezeEntityPosition(object, true)
        SetEntityCollision(object, false, true)

        pickups[pickupId] = {
            obj = object,
            label = label,
            inRange = false,
            coords = coords,
        }
    end

    if itemType == "item_weapon" then
        local weaponHash = joaat(name)
        ESX.Streaming.RequestWeaponAsset(weaponHash)
        local pickupObject = CreateWeaponObject(weaponHash, 50, coords.x, coords.y, coords.z, true, 1.0, 0)
        SetWeaponObjectTintIndex(pickupObject, tintIndex)

        for _, v in ipairs(components) do
            local component = ESX.GetWeaponComponent(name, v)
            if component then
                GiveWeaponComponentToWeaponObject(pickupObject, component.hash)
            end
        end

        setObjectProperties(pickupObject)
    else
        ESX.Game.SpawnLocalObject("prop_money_bag_01", coords, setObjectProperties)
    end
end)
