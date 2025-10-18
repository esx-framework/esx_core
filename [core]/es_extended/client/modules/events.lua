local pickups = {}

RegisterNetEvent("esx:requestModel", function(model)
    ESX.Streaming.RequestModel(model)
end)

RegisterNetEvent("esx:playerLoaded", function(xPlayer, _, skin)
    ESX.PlayerData = xPlayer

    if not Config.Multichar then
        ESX.SpawnPlayer(skin, ESX.PlayerData.coords, function()
            TriggerEvent("esx:onPlayerSpawn")
            TriggerEvent("esx:restoreLoadout")
            TriggerServerEvent("esx:onPlayerSpawn")
            TriggerEvent("esx:loadingScreenOff")
            ShutdownLoadingScreen()
            ShutdownLoadingScreenNui()
        end)
    end

    while not DoesEntityExist(ESX.PlayerData.ped) do
        Wait(20)
    end

    ESX.PlayerLoaded = true

    local timer = GetGameTimer()
    while not HaveAllStreamingRequestsCompleted(ESX.PlayerData.ped) and (GetGameTimer() - timer) < 2000 do
        Wait(0)
    end

    Adjustments:Load()

    ClearPedTasksImmediately(ESX.PlayerData.ped)

    if not Config.Multichar then
        Core.FreezePlayer(false)
    end

    if IsScreenFadedOut() then
        DoScreenFadeIn(500)
    end

    Actions:Init()
    StartPointsLoop()
    StartServerSyncLoops()
    NetworkSetLocalPlayerSyncLookAt(true)
end)

local isFirstSpawn = true
ESX.SecureNetEvent("esx:onPlayerLogout", function()
    ESX.PlayerLoaded = false
    isFirstSpawn = true
end)

ESX.SecureNetEvent("esx:setMaxWeight", function(newMaxWeight)
    ESX.SetPlayerData("maxWeight", newMaxWeight)
end)

ESX.SecureNetEvent("esx:setInventory", function(newInventory)
    ESX.SetPlayerData("inventory", newInventory)
end)

local function onPlayerSpawn()
    ESX.SetPlayerData("ped", PlayerPedId())
    ESX.SetPlayerData("dead", false)
end

AddEventHandler("playerSpawned", onPlayerSpawn)
AddEventHandler("esx:onPlayerSpawn", function()
    onPlayerSpawn()

    if isFirstSpawn then
        isFirstSpawn = false

        if ESX.PlayerData.metadata.health and (ESX.PlayerData.metadata.health > 0 or Config.SaveDeathStatus) then
            SetEntityHealth(ESX.PlayerData.ped, ESX.PlayerData.metadata.health)
        end

        if ESX.PlayerData.metadata.armor and ESX.PlayerData.metadata.armor > 0 then
            SetPedArmour(ESX.PlayerData.ped, ESX.PlayerData.metadata.armor)
        end
    end
end)

AddEventHandler("esx:onPlayerDeath", function()
    ESX.SetPlayerData("ped", PlayerPedId())
    ESX.SetPlayerData("dead", true)
end)

AddEventHandler("skinchanger:modelLoaded", function()
    while not ESX.PlayerLoaded do
        Wait(100)
    end
    TriggerEvent("esx:restoreLoadout")
end)

AddEventHandler("esx:restoreLoadout", function()
    ESX.SetPlayerData("ped", PlayerPedId())

    if not Config.CustomInventory then
        local ammoTypes = {}
        RemoveAllPedWeapons(ESX.PlayerData.ped, true)

        for _, v in ipairs(ESX.PlayerData.loadout) do
            local weaponName = v.name
            local weaponHash = joaat(weaponName)

            GiveWeaponToPed(ESX.PlayerData.ped, weaponHash, 0, false, false)
            SetPedWeaponTintIndex(ESX.PlayerData.ped, weaponHash, v.tintIndex)

            local ammoType = GetPedAmmoTypeFromWeapon(ESX.PlayerData.ped, weaponHash)

            for _, v2 in ipairs(v.components) do
                local componentHash = ESX.GetWeaponComponent(weaponName, v2).hash
                GiveWeaponComponentToPed(ESX.PlayerData.ped, weaponHash, componentHash)
            end

            if not ammoTypes[ammoType] then
                AddAmmoToPed(ESX.PlayerData.ped, weaponHash, v.ammo)
                ammoTypes[ammoType] = true
            end
        end
    end
end)

---@diagnostic disable-next-line: param-type-mismatch
AddStateBagChangeHandler("VehicleProperties", nil, function(bagName, _, value)
    if not value then
        return
    end

    bagName = bagName:gsub("entity:", "")
    local netId = tonumber(bagName)
    if not netId then
        error("Tried to set vehicle properties with invalid netId")
        return
    end

    local tries = 0

    while not NetworkDoesEntityExistWithNetworkId(netId) do
        Wait(200)
        tries = tries + 1
        if tries > 20 then
            return error(("Invalid entity - ^5%s^7!"):format(netId))
        end
    end

    local vehicle = NetToVeh(netId)

    if NetworkGetEntityOwner(vehicle) ~= ESX.playerId then
        return
    end

    ESX.Game.SetVehicleProperties(vehicle, value)
end)

ESX.SecureNetEvent("esx:setAccountMoney", function(account)
    for i = 1, #ESX.PlayerData.accounts do
        if ESX.PlayerData.accounts[i].name == account.name then
            ESX.PlayerData.accounts[i] = account
            break
        end
    end

    ESX.SetPlayerData("accounts", ESX.PlayerData.accounts)
end)

if not Config.CustomInventory then
    ESX.SecureNetEvent("esx:addInventoryItem", function(item, count, showNotification)
        for k, v in ipairs(ESX.PlayerData.inventory) do
            if v.name == item then
                ESX.UI.ShowInventoryItemNotification(true, v.label, count - v.count)
                ESX.PlayerData.inventory[k].count = count
                break
            end
        end

        if showNotification then
            ESX.UI.ShowInventoryItemNotification(true, item, count)
        end
    end)

    ESX.SecureNetEvent("esx:removeInventoryItem", function(item, count, showNotification)
        for i = 1, #ESX.PlayerData.inventory do
            if ESX.PlayerData.inventory[i].name == item then
                ESX.UI.ShowInventoryItemNotification(false, ESX.PlayerData.inventory[i].label, ESX.PlayerData.inventory[i].count - count)
                ESX.PlayerData.inventory[i].count = count
                break
            end
        end

        if showNotification then
            ESX.UI.ShowInventoryItemNotification(false, item, count)
        end
    end)

    ESX.SecureNetEvent("esx:addLoadoutItem", function(weaponName, weaponLabel, ammo)
        table.insert(ESX.PlayerData.loadout, {
            name = weaponName,
            ammo = ammo,
            label = weaponLabel,
            components = {},
            tintIndex = 0,
        })
    end)

    ESX.SecureNetEvent("esx:removeLoadoutItem", function(weaponName, weaponLabel)
        for i = 1, #ESX.PlayerData.loadout do
            if ESX.PlayerData.loadout[i].name == weaponName then
                table.remove(ESX.PlayerData.loadout, i)
                break
            end
        end
    end)

    RegisterNetEvent("esx:addWeapon", function()
        error("event ^5'esx:addWeapon'^1 Has Been Removed. Please use ^5xPlayer.addWeapon^1 Instead!")
    end)


    RegisterNetEvent("esx:addWeaponComponent", function()
        error("event ^5'esx:addWeaponComponent'^1 Has Been Removed. Please use ^5xPlayer.addWeaponComponent^1 Instead!")
    end)

    RegisterNetEvent("esx:setWeaponAmmo", function()
        error("event ^5'esx:setWeaponAmmo'^1 Has Been Removed. Please use ^5xPlayer.addWeaponAmmo^1 Instead!")
    end)

    ESX.SecureNetEvent("esx:setWeaponTint", function(weapon, weaponTintIndex)
        SetPedWeaponTintIndex(ESX.PlayerData.ped, joaat(weapon), weaponTintIndex)
    end)

    RegisterNetEvent("esx:removeWeapon", function()
        error("event ^5'esx:removeWeapon'^1 Has Been Removed. Please use ^5xPlayer.removeWeapon^1 Instead!")
    end)

    ESX.SecureNetEvent("esx:removeWeaponComponent", function(weapon, weaponComponent)
        local componentHash = ESX.GetWeaponComponent(weapon, weaponComponent).hash
        RemoveWeaponComponentFromPed(ESX.PlayerData.ped, joaat(weapon), componentHash)
    end)
end

ESX.SecureNetEvent("esx:setJob", function(Job)
    ESX.SetPlayerData("job", Job)
end)

ESX.SecureNetEvent("esx:setGroup", function(group)
    ESX.SetPlayerData("group", group)
end)

if not Config.CustomInventory then
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

    ESX.SecureNetEvent("esx:createMissingPickups", function(missingPickups)
        for pickupId, pickup in pairs(missingPickups) do
            TriggerEvent("esx:createPickup", pickupId, pickup.label, vector3(pickup.coords.x, pickup.coords.y, pickup.coords.z - 1.0), pickup.type, pickup.name, pickup.components, pickup.tintIndex)
        end
    end)
end

ESX.SecureNetEvent("esx:registerSuggestions", function(registeredCommands)
    for name, command in pairs(registeredCommands) do
        if command.suggestion then
            TriggerEvent("chat:addSuggestion", ("/%s"):format(name), command.suggestion.help, command.suggestion.arguments)
        end
    end
end)

if not Config.CustomInventory then
    ESX.SecureNetEvent("esx:removePickup", function(pickupId)
        if pickups[pickupId] and pickups[pickupId].obj then
            ESX.Game.DeleteObject(pickups[pickupId].obj)
            pickups[pickupId] = nil
        end
    end)
end

function StartServerSyncLoops()
    if Config.CustomInventory then return end

    local currentWeapon = {
        ---@type number
        ---@diagnostic disable-next-line: assign-type-mismatch
        hash = `WEAPON_UNARMED`,
        ammo = 0,
    }

    local function updateCurrentWeaponAmmo(weaponName)
        local newAmmo = GetAmmoInPedWeapon(ESX.PlayerData.ped, currentWeapon.hash)

        if newAmmo ~= currentWeapon.ammo then
            currentWeapon.ammo = newAmmo
            TriggerServerEvent("esx:updateWeaponAmmo", weaponName, newAmmo)
        end
    end

    CreateThread(function()
        while ESX.PlayerLoaded do
            currentWeapon.hash = GetSelectedPedWeapon(ESX.PlayerData.ped)

            if currentWeapon.hash ~= `WEAPON_UNARMED` then
                local weaponConfig = ESX.GetWeaponFromHash(currentWeapon.hash)

                if weaponConfig then
                    currentWeapon.ammo = GetAmmoInPedWeapon(ESX.PlayerData.ped, currentWeapon.hash)

                    while GetSelectedPedWeapon(ESX.PlayerData.ped) == currentWeapon.hash do
                        updateCurrentWeaponAmmo(weaponConfig.name)
                        Wait(1000)
                    end

                    updateCurrentWeaponAmmo(weaponConfig.name)
                end
            end
            Wait(250)
        end
    end)

    CreateThread(function()
        local PARACHUTE_OPENING <const> = 1
        local PARACHUTE_OPEN <const> = 2

        while ESX.PlayerLoaded do
            local parachuteState = GetPedParachuteState(ESX.PlayerData.ped)

            if parachuteState == PARACHUTE_OPENING or parachuteState == PARACHUTE_OPEN then
                TriggerServerEvent("esx:updateWeaponAmmo", "GADGET_PARACHUTE", 0)

                while GetPedParachuteState(ESX.PlayerData.ped) ~= -1 do Wait(1000) end
            end
            Wait(500)
        end
    end)
end

if not Config.CustomInventory then
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
end

----- Admin commands from esx_adminplus
RegisterNetEvent("esx:tpm", function()
    local GetEntityCoords = GetEntityCoords
    local GetGroundZFor_3dCoord = GetGroundZFor_3dCoord
    local GetFirstBlipInfoId = GetFirstBlipInfoId
    local DoesBlipExist = DoesBlipExist
    local DoScreenFadeOut = DoScreenFadeOut
    local GetBlipInfoIdCoord = GetBlipInfoIdCoord
    local GetVehiclePedIsIn = GetVehiclePedIsIn

    ESX.TriggerServerCallback("esx:isUserAdmin", function(admin)
        if not admin then
            return
        end
        local blipMarker = GetFirstBlipInfoId(8)
        if not DoesBlipExist(blipMarker) then
            ESX.ShowNotification(TranslateCap("tpm_nowaypoint"), "error")
            return "marker"
        end

        -- Fade screen to hide how clients get teleported.
        DoScreenFadeOut(650)
        while not IsScreenFadedOut() do
            Wait(0)
        end

        local ped, coords = ESX.PlayerData.ped, GetBlipInfoIdCoord(blipMarker)
        local vehicle = GetVehiclePedIsIn(ped, false)
        local oldCoords = GetEntityCoords(ped)

        -- Unpack coords instead of having to unpack them while iterating.
        -- 825.0 seems to be the max a player can reach while 0.0 being the lowest.
        local x, y, groundZ, Z_START = coords["x"], coords["y"], 850.0, 950.0
        local found = false
        FreezeEntityPosition(vehicle > 0 and vehicle or ped, true)

        for i = Z_START, 0, -25.0 do
            local z = i
            if (i % 2) ~= 0 then
                z = Z_START - i
            end

            NewLoadSceneStart(x, y, z, x, y, z, 50.0, 0)
            local curTime = GetGameTimer()
            while IsNetworkLoadingScene() do
                if GetGameTimer() - curTime > 1000 then
                    break
                end
                Wait(0)
            end
            NewLoadSceneStop()
            SetPedCoordsKeepVehicle(ped, x, y, z)

            while not HasCollisionLoadedAroundEntity(ped) do
                RequestCollisionAtCoord(x, y, z)
                if GetGameTimer() - curTime > 1000 then
                    break
                end
                Wait(0)
            end

            -- Get ground coord. As mentioned in the natives, this only works if the client is in render distance.
            found, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
            if found then
                Wait(0)
                SetPedCoordsKeepVehicle(ped, x, y, groundZ)
                break
            end
            Wait(0)
        end

        -- Remove black screen once the loop has ended.
        DoScreenFadeIn(650)
        FreezeEntityPosition(vehicle > 0 and vehicle or ped, false)

        if not found then
            -- If we can't find the coords, set the coords to the old ones.
            -- We don't unpack them before since they aren't in a loop and only called once.
            SetPedCoordsKeepVehicle(ped, oldCoords["x"], oldCoords["y"], oldCoords["z"] - 1.0)
            ESX.ShowNotification(TranslateCap("tpm_success"), "success")
        end

        -- If Z coord was found, set coords in found coords.
        SetPedCoordsKeepVehicle(ped, x, y, groundZ)
        ESX.ShowNotification(TranslateCap("tpm_success"), "success")
    end)
end)

local noclipActive = false
local noclipEntity = nil
local followCamMode = true
local speedIndex = 1
local currentSpeed = 0.2
local yOffset, zOffset, hOffset = 0.5, 0.2, 3

-- cached config values
local controls = Config.Noclip.controls
local speedOptions = Config.Noclip.speeds

--- Toggles noclip state for the given entity
---@param entity number? Entity handle to apply noclip settings to
---@param isActive boolean Whether noclip should be enabled or disabled
local function toggleNoclip(entity, isActive)
    if not entity or not DoesEntityExist(entity) then return end

    SetEntityAlpha(entity, isActive and 102 or 255, false)
    SetEntityCollision(entity, not isActive, not isActive)
    FreezeEntityPosition(entity, isActive)
    SetEntityInvincible(entity, isActive)
    SetEntityVisible(entity, not isActive, isActive)

    local ped = ESX.PlayerData.ped
    SetEveryoneIgnorePlayer(ped, isActive)
    SetPoliceIgnorePlayer(ped, isActive)
    LocalPlayer.state:set('inNoclip', isActive, true)
end

local function cycleSpeed()
    if not noclipActive then return end

    speedIndex = speedIndex % #speedOptions + 1
    currentSpeed = speedOptions[speedIndex]
    ESX.ShowNotification(TranslateCap("noclip_new_speed", currentSpeed))
end

local function handleMovement()
    if not noclipEntity or not DoesEntityExist(noclipEntity) then return end

    local yMove, zMove = 0.0, 0.0
    local isForward = false
    local hasMovement = false

    if IsDisabledControlPressed(0, controls.forward) then
        yMove = yOffset
        isForward = true
        hasMovement = true
    elseif IsDisabledControlPressed(0, controls.backward) then
        yMove = -yOffset
        hasMovement = true
    end

    if not followCamMode then
        if IsDisabledControlPressed(0, controls.up) then
            zMove = zOffset
            hasMovement = true
        elseif IsDisabledControlPressed(0, controls.down) then
            zMove = -zOffset
            hasMovement = true
        end

        if IsDisabledControlPressed(0, controls.left) then
            SetEntityHeading(noclipEntity, GetEntityHeading(noclipEntity) + hOffset)
        elseif IsDisabledControlPressed(0, controls.right) then
            SetEntityHeading(noclipEntity, GetEntityHeading(noclipEntity) - hOffset)
        end
    else
        if hasMovement then
            local pitch = GetGameplayCamRelativePitch()
            zMove = isForward and (pitch * 0.01) or (pitch * -0.01)
        end
    end

    if not hasMovement then return end

    local speedMult = currentSpeed + 0.3

    local heading = GetEntityHeading(noclipEntity)
    local newPos = GetOffsetFromEntityInWorldCoords(noclipEntity, 0.0, yMove * speedMult, zMove * speedMult)

    SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
    SetEntityRotation(noclipEntity, 0.0, 0.0, 0.0, 0, false)

    if followCamMode then
        SetEntityHeading(noclipEntity, GetGameplayCamRelativeHeading())
    else
        SetEntityHeading(noclipEntity, heading)
    end

    SetEntityCoordsNoOffset(noclipEntity, newPos.x, newPos.y, newPos.z, true, true, true)
end

local function noclipThread()
    CreateThread(function()
        local allowedKeys = Config.Noclip.allowedKeys
        local switchKey = Config.Noclip.controls.switchMode
        local lastToggleTime = 0

        while noclipActive do
            local currentTime = GetGameTimer()

            DisableAllControlActions(0)
            
            for i = 1, #allowedKeys do
                local key = allowedKeys[i]
                EnableControlAction(key[1], key[2], true)
            end

            if IsDisabledControlJustPressed(0, switchKey) then
                followCamMode = not followCamMode
                ESX.ShowNotification(TranslateCap("noclip_mode_toggled", followCamMode and Translate("enabled") or Translate("disabled")))
                Wait(100)
            end

            SetLocalPlayerVisibleLocally(true);
            handleMovement()

            if currentTime - lastToggleTime >= 1000 then
                toggleNoclip(noclipEntity, true)
                lastToggleTime = currentTime
            end

            Wait(0)
        end
    end)
end

RegisterNetEvent("esx:noclip", function()
    ESX.TriggerServerCallback("esx:isUserAdmin", function(admin)
        if not admin then
            return
        end

        if noclipActive then
            noclipActive = false
            toggleNoclip(noclipEntity, false)
            return
        end

        noclipActive = true
        noclipEntity = ESX.PlayerData.vehicle or ESX.PlayerData.ped
        toggleNoclip(noclipEntity, true)
        noclipThread()

        if noclipActive then
            ESX.ShowNotification(TranslateCap("noclip_message", Translate("enabled")), "success")
        else
            ESX.ShowNotification(TranslateCap("noclip_message", Translate("disabled")), "error")
        end
    end)
end)

-- cycling speed
ESX.RegisterInput('cyclenoclipspeed', 'Cycle Noclip Speed', 'keyboard', Config.Noclip.controls.cycleNoclipSpeed, cycleSpeed)

RegisterNetEvent("esx:killPlayer", function()
    SetEntityHealth(ESX.PlayerData.ped, 0)
end)

RegisterNetEvent("esx:repairPedVehicle", function()
    local ped = ESX.PlayerData.ped
    local vehicle = GetVehiclePedIsIn(ped, false)
    SetVehicleEngineHealth(vehicle, 1000)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleFixed(vehicle)
    SetVehicleDirtLevel(vehicle, 0)
end)

RegisterNetEvent("esx:freezePlayer", function(input)
    if input == "freeze" then
        SetEntityCollision(ESX.PlayerData.ped, false, false)
        FreezeEntityPosition(ESX.PlayerData.ped, true)
        SetPlayerInvincible(ESX.playerId, true)
    elseif input == "unfreeze" then
        SetEntityCollision(ESX.PlayerData.ped, true, true)
        FreezeEntityPosition(ESX.PlayerData.ped, false)
        SetPlayerInvincible(ESX.playerId, false)
    end
end)

ESX.RegisterClientCallback("esx:GetVehicleType", function(cb, model)
    cb(ESX.GetVehicleTypeClient(model))
end)

ESX.SecureNetEvent('esx:updatePlayerData', function(key, val)
    ESX.SetPlayerData(key, val)
end)

---@param command string
ESX.SecureNetEvent("esx:executeCommand", function(command)
    ExecuteCommand(command)
end)

AddEventHandler("onResourceStop", function(resource)
    if Core.Events[resource] then
        for i = 1, #Core.Events[resource] do
            RemoveEventHandler(Core.Events[resource][i])
        end
    end
end)
