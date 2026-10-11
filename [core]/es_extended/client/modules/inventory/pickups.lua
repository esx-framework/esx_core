-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

if Config.CustomInventory then
    return
end

local STREAM_DISTANCE <const> = 150.0
local REQUEST_DISTANCE <const> = 75.0

local pickups = {}
local lastRequestCoords

local function removePickup(pickupId)
    local pickup = pickups[pickupId]

    if not pickup then
        return
    end

    if pickup.obj then
        xLib.game.deleteObject(pickup.obj)
    end

    pickups[pickupId] = nil
end

local function requestPickups(playerCoords)
    lastRequestCoords = playerCoords
    TriggerServerEvent("esx:requestPickups")
end

---@param pickupId integer
---@param label string
---@param coords vector3
---@param itemType string
---@param name string
---@param components? string[]
---@param tintIndex? integer
local function spawnPickup(pickupId, label, coords, itemType, name, components, tintIndex)
    if pickups[pickupId] then
        return
    end

    local entry = {
        label = label,
        inRange = false,
        coords = coords,
    }

    pickups[pickupId] = entry

    local function setObjectProperties(object)
        if pickups[pickupId] ~= entry then
            xLib.game.deleteObject(object)
            return
        end

        SetEntityAsMissionEntity(object, true, false)
        PlaceObjectOnGroundProperly(object)
        FreezeEntityPosition(object, true)
        SetEntityCollision(object, false, true)

        entry.obj = object
    end

    if itemType == "item_weapon" then
        local weaponHash = joaat(name)
        xLib.streaming.requestWeaponAsset(weaponHash)
        local pickupObject = CreateWeaponObject(weaponHash, 50, coords.x, coords.y, coords.z, true, 1.0, 0)
        SetWeaponObjectTintIndex(pickupObject, tintIndex)

        for _, componentName in ipairs(components or {}) do
            local component = ESX.GetWeaponComponent(name, componentName)
            if component then
                GiveWeaponComponentToWeaponObject(pickupObject, component.hash)
            end
        end

        setObjectProperties(pickupObject)
    else
        xLib.game.spawnLocalObject("prop_money_bag_01", coords, setObjectProperties)
    end
end

ESX.SecureNetEvent("esx:createPickup", spawnPickup)

ESX.SecureNetEvent("esx:createMissingPickups", function(missingPickups)
    for pickupId, pickup in pairs(missingPickups) do
        spawnPickup(pickupId, pickup.label, vector3(pickup.coords.x, pickup.coords.y, pickup.coords.z - 1.0), pickup.type, pickup.name, pickup.components, pickup.tintIndex)
    end
end)

ESX.SecureNetEvent("esx:removePickup", removePickup)

RegisterNetEvent("esx:playerLoaded", function()
    lastRequestCoords = nil
end)

CreateThread(function()
    while true do
        local sleep = 1500

        if ESX.PlayerData.ped then
            local playerCoords = GetEntityCoords(ESX.PlayerData.ped)

            if not lastRequestCoords or #(playerCoords - lastRequestCoords) > REQUEST_DISTANCE then
                requestPickups(playerCoords)
            end

            for pickupId, pickup in pairs(pickups) do
                local distance = #(playerCoords - pickup.coords)

                if distance > STREAM_DISTANCE then
                    removePickup(pickupId)
                elseif distance < 5 then
                    sleep = 0
                    local label = pickup.label

                    if distance < 1 then
                        if IsControlJustReleased(0, 38) then
                            local _, closestDistance = xLib.game.getClosestPlayer(playerCoords)

                            if IsPedOnFoot(ESX.PlayerData.ped) and (closestDistance == -1 or closestDistance > 3) and not pickup.inRange then
                                pickup.inRange = true

                                local dict, anim = "weapons@first_person@aim_rng@generic@projectile@sticky_bomb@", "plant_floor"
                                xLib.streaming.requestAnimDict(dict)
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
        end

        Wait(sleep)
    end
end)
