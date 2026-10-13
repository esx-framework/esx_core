---@class gamelib
xLib.game = {}

local function isCallable(val)
    local valType = type(val)
    local mt = getmetatable(val)
    return valType == "function" or (valType == "table" and mt ~= nil and type(mt.__call) == "function")
end

---@param ped integer The ped to get the mugshot of
---@param transparent? boolean Whether the mugshot should be transparent
function xLib.game.getPedMugshot(ped, transparent)
    if not DoesEntityExist(ped) then
        return
    end

    local mugshot = transparent and RegisterPedheadshotTransparent(ped) or RegisterPedheadshot(ped)

    while not IsPedheadshotReady(mugshot) do
        Wait(0)
    end

    return mugshot, GetPedheadshotTxdString(mugshot)
end

---@param object integer | string The object to spawn
---@param coords table | vector3 The coords to spawn the object at
---@param cb? function The callback function
---@param networked? boolean Whether the object should be networked
---@return integer | nil
function xLib.game.spawnObject(object, coords, cb, networked)
    local model = type(object) == "number" and object or joaat(object)

    xLib.streaming.requestModel(model)

    local obj = CreateObject(model, coords.x, coords.y, coords.z, networked == nil or networked, false, true)
    return cb and cb(obj) or obj
end

---@param object integer | string The object to spawn
---@param coords table | vector3 The coords to spawn the object at
---@param cb? function The callback function
---@return nil
function xLib.game.spawnLocalObject(object, coords, cb)
    xLib.game.spawnObject(object, coords, cb, false)
end

---@param vehicle integer The vehicle to delete
---@return nil
function xLib.game.deleteVehicle(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

---@param object integer The object to delete
---@return nil
function xLib.game.deleteObject(object)
    SetEntityAsMissionEntity(object, false, true)
    DeleteObject(object)
end

---@param vehicleModel integer | string The vehicle to spawn
---@param coords table | vector3 The coords to spawn the vehicle at
---@param heading number The heading of the vehicle
---@param cb? fun(vehicle: number) The callback function
---@param networked? boolean Whether the vehicle should be networked
---@return number? vehicle
function xLib.game.spawnVehicle(vehicleModel, coords, heading, cb, networked)
    if cb and not isCallable(cb) then
        error("Invalid callback function")
    end

    local model = type(vehicleModel) == "number" and vehicleModel or joaat(vehicleModel)
    local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
    local isNetworked = networked == nil or networked

    local playerCoords = GetEntityCoords(PlayerPedId())
    if not vector or not playerCoords then
        return
    end

    local dist = #(playerCoords - vector)
    if dist > 424 then -- Onesync infinity Range (https://docs.fivem.net/docs/scripting-reference/onesync/)
        local executingResource = GetInvokingResource() or "Unknown"
        return error(("Resource ^5%s^1 Tried to spawn vehicle on the client but the position is too far away (Out of onesync range)."):format(executingResource))
    end

    local promise = not cb and promise.new()
    CreateThread(function()
        local modelHash = xLib.streaming.requestModel(model)
        if not modelHash then
            if promise then
                promise:reject(("Tried to spawn invalid vehicle - ^5%s^7!"):format(model))
                return
            end
            error(("Tried to spawn invalid vehicle - ^5%s^7!"):format(model))
        end

        local vehicle = CreateVehicle(model, vector.x, vector.y, vector.z, heading, isNetworked, true)

        if networked then
            local id = NetworkGetNetworkIdFromEntity(vehicle)
            SetNetworkIdCanMigrate(id, true)
            SetEntityAsMissionEntity(vehicle, true, true)
        end
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetVehicleNeedsToBeHotwired(vehicle, false)
        SetModelAsNoLongerNeeded(model)
        SetVehRadioStation(vehicle, "OFF")

        RequestCollisionAtCoord(vector.x, vector.y, vector.z)
        while not HasCollisionLoadedAroundEntity(vehicle) do
            Wait(0)
        end

        if promise then
            promise:resolve(vehicle)
        elseif cb then
            cb(vehicle)
        end
    end)

    if promise then
        return Citizen.Await(promise)
    end
end

---@param vehicle integer The vehicle to spawn
---@param coords table | vector3 The coords to spawn the vehicle at
---@param heading number The heading of the vehicle
---@param cb? function The callback function
---@return nil
function xLib.game.spawnLocalVehicle(vehicle, coords, heading, cb)
    xLib.game.spawnVehicle(vehicle, coords, heading, cb, false)
end

---@param vehicle integer The vehicle to check
---@return boolean
function xLib.game.isVehicleEmpty(vehicle)
    return GetVehicleNumberOfPassengers(vehicle) == 0 and IsVehicleSeatFree(vehicle, -1)
end

---@return table
function xLib.game.getObjects() -- Leave the function for compatibility
    return GetGamePool("CObject")
end

---@param onlyOtherPeds? boolean Whether to exlude the player ped
---@return table
function xLib.game.getPeds(onlyOtherPeds)
    local pool = GetGamePool("CPed")

    if onlyOtherPeds then
        local myPed = PlayerPedId()
        for i = 1, #pool do
            if pool[i] == myPed then
                table.remove(pool, i)
                break
            end
        end
    end

    return pool
end

---@return table
function xLib.game.getVehicles() -- Leave the function for compatibility
    return GetGamePool("CVehicle")
end

---@param onlyOtherPlayers? boolean Whether to exclude the player
---@param returnKeyValue? boolean Whether to return the key value pair
---@param returnPeds? boolean Whether to return the peds
---@return table
function xLib.game.getPlayers(onlyOtherPlayers, returnKeyValue, returnPeds)
    local players = {}
    local active = GetActivePlayers()

    for i = 1, #active do
        local currentPlayer = active[i]
        local ped = GetPlayerPed(currentPlayer)

        if DoesEntityExist(ped) and ((onlyOtherPlayers and currentPlayer ~= PlayerId()) or not onlyOtherPlayers) then
            if returnKeyValue then
                players[currentPlayer] = ped
            else
                players[#players + 1] = returnPeds and ped or currentPlayer
            end
        end
    end

    return players
end

---@param coords? table | vector3 The coords to get the closest object to
---@param modelFilter? table The model filter
---@return integer, integer
function xLib.game.getClosestObject(coords, modelFilter)
    return xLib.entity.closest(xLib.game.getObjects(), false, coords, modelFilter)
end

---@param coords? table | vector3 The coords to get the closest ped to
---@param modelFilter? table The model filter
---@return integer, integer
function xLib.game.getClosestPed(coords, modelFilter)
    return xLib.entity.closest(xLib.game.getPeds(true), false, coords, modelFilter)
end

---@param coords? table | vector3 The coords to get the closest player to
---@return integer, integer
function xLib.game.getClosestPlayer(coords)
    return xLib.entity.closest(xLib.game.getPlayers(true, true), true, coords, nil)
end

---@param coords? table | vector3 The coords to get the closest vehicle to
---@param modelFilter? table The model filter
---@return integer, integer
function xLib.game.getClosestVehicle(coords, modelFilter)
    return xLib.entity.closest(xLib.game.getVehicles(), false, coords, modelFilter)
end

---@param coords table | vector3 The coords to search from
---@param maxDistance number The max distance to search within
---@return table
function xLib.game.getPlayersInArea(coords, maxDistance)
    return xLib.entity.EnumerateWithinDistance(xLib.game.getPlayers(true, true), true, coords, maxDistance)
end

---@param coords table | vector3 The coords to search from
---@param maxDistance number The max distance to search within
---@return table
function xLib.game.getVehiclesInArea(coords, maxDistance)
    return xLib.entity.EnumerateWithinDistance(xLib.game.getVehicles(), false, coords, maxDistance)
end

---@param coords table | vector3 The coords to search from
---@param maxDistance number The max distance to search within
---@return boolean
function xLib.game.isSpawnPointClear(coords, maxDistance)
    return #xLib.game.getVehiclesInArea(coords, maxDistance) == 0
end

---@return integer | nil, vector3 | nil
function xLib.game.getVehicleInDirection()
    local _, hit, coords, _, _, entity = xLib.Raycast.FromScreen(5, 10, PlayerPedId())
    if hit and IsEntityAVehicle(entity) then
        return entity, coords
    end
end

local function round(value, numDecimalPlaces)
    if numDecimalPlaces then
        local power = 10 ^ numDecimalPlaces
        return math.floor((value * power) + 0.5) / power
    else
        return math.floor(value + 0.5)
    end
end

local function trim(value)
    value = tostring(value)
    return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
end

---@param vehicle integer The vehicle to get the properties of
---@return table | nil
function xLib.game.getVehicleProperties(vehicle)
    if not DoesEntityExist(vehicle) then
        return
    end

    ---@type number | number[], number | number[]
    local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    local dashboardColor = GetVehicleDashboardColor(vehicle)
    local interiorColor = GetVehicleInteriorColour(vehicle)

    if GetIsVehiclePrimaryColourCustom(vehicle) then
        colorPrimary = { GetVehicleCustomPrimaryColour(vehicle) }
    end

    if GetIsVehicleSecondaryColourCustom(vehicle) then
        colorSecondary = { GetVehicleCustomSecondaryColour(vehicle) }
    end

    local hasCustomXenonColor, customXenonColorR, customXenonColorG, customXenonColorB = GetVehicleXenonLightsCustomColor(vehicle)
    local customXenonColor = nil
    if hasCustomXenonColor then
        customXenonColor = { customXenonColorR, customXenonColorG, customXenonColorB }
    end

    local extras = {}
    for extraId = 0, 20 do
        if DoesExtraExist(vehicle, extraId) then
            extras[tostring(extraId)] = IsVehicleExtraTurnedOn(vehicle, extraId)
        end
    end

    local doorsBroken, windowsBroken, tyreBurst = {}, {}, {}
    local numWheels = tostring(GetVehicleNumberOfWheels(vehicle))

    local TyresIndex = { -- Wheel index list according to the number of vehicle wheels.
        ["2"] = { 0, 4 }, -- Bike and cycle.
        ["3"] = { 0, 1, 4, 5 }, -- Vehicle with 3 wheels (get for wheels because some 3 wheels vehicles have 2 wheels on front and one rear or the reverse).
        ["4"] = { 0, 1, 4, 5 }, -- Vehicle with 4 wheels.
        ["6"] = { 0, 1, 2, 3, 4, 5 }, -- Vehicle with 6 wheels.
    }

    if TyresIndex[numWheels] then
        for _, idx in pairs(TyresIndex[numWheels]) do
            tyreBurst[tostring(idx)] = IsVehicleTyreBurst(vehicle, idx, false)
        end
    end

    for windowId = 0, 7 do -- 13
        RollUpWindow(vehicle, windowId) --fix when you put the car away with the window down
        windowsBroken[tostring(windowId)] = not IsVehicleWindowIntact(vehicle, windowId)
    end

    local numDoors = GetNumberOfVehicleDoors(vehicle)
    if numDoors and numDoors > 0 then
        for doorsId = 0, numDoors do
            doorsBroken[tostring(doorsId)] = IsVehicleDoorDamaged(vehicle, doorsId)
        end
    end

    return {
        model = GetEntityModel(vehicle),
        doorsBroken = doorsBroken,
        windowsBroken = windowsBroken,
        tyreBurst = tyreBurst,
        tyresCanBurst = GetVehicleTyresCanBurst(vehicle),
        plate = trim(GetVehicleNumberPlateText(vehicle)),
        plateIndex = GetVehicleNumberPlateTextIndex(vehicle),

        bodyHealth = round(GetVehicleBodyHealth(vehicle), 1),
        engineHealth = round(GetVehicleEngineHealth(vehicle), 1),
        tankHealth = round(GetVehiclePetrolTankHealth(vehicle), 1),

        fuelLevel = round(GetVehicleFuelLevel(vehicle), 1),
        dirtLevel = round(GetVehicleDirtLevel(vehicle), 1),
        color1 = colorPrimary,
        color2 = colorSecondary,

        pearlescentColor = pearlescentColor,
        wheelColor = wheelColor,

        dashboardColor = dashboardColor,
        interiorColor = interiorColor,

        wheels = GetVehicleWheelType(vehicle),
        windowTint = GetVehicleWindowTint(vehicle),
        xenonColor = GetVehicleXenonLightsColor(vehicle),
        customXenonColor = customXenonColor,

        neonEnabled = { IsVehicleNeonLightEnabled(vehicle, 0), IsVehicleNeonLightEnabled(vehicle, 1), IsVehicleNeonLightEnabled(vehicle, 2), IsVehicleNeonLightEnabled(vehicle, 3) },

        neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
        extras = extras,
        tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),

        modSpoilers = GetVehicleMod(vehicle, 0),
        modFrontBumper = GetVehicleMod(vehicle, 1),
        modRearBumper = GetVehicleMod(vehicle, 2),
        modSideSkirt = GetVehicleMod(vehicle, 3),
        modExhaust = GetVehicleMod(vehicle, 4),
        modFrame = GetVehicleMod(vehicle, 5),
        modGrille = GetVehicleMod(vehicle, 6),
        modHood = GetVehicleMod(vehicle, 7),
        modFender = GetVehicleMod(vehicle, 8),
        modRightFender = GetVehicleMod(vehicle, 9),
        modRoof = GetVehicleMod(vehicle, 10),
        modRoofLivery = GetVehicleRoofLivery(vehicle),

        modEngine = GetVehicleMod(vehicle, 11),
        modBrakes = GetVehicleMod(vehicle, 12),
        modTransmission = GetVehicleMod(vehicle, 13),
        modHorns = GetVehicleMod(vehicle, 14),
        modSuspension = GetVehicleMod(vehicle, 15),
        modArmor = GetVehicleMod(vehicle, 16),

        modTurbo = IsToggleModOn(vehicle, 18),
        modSmokeEnabled = IsToggleModOn(vehicle, 20),
        modXenon = IsToggleModOn(vehicle, 22),

        modFrontWheels = GetVehicleMod(vehicle, 23),
        modCustomFrontWheels = GetVehicleModVariation(vehicle, 23),
        modBackWheels = GetVehicleMod(vehicle, 24),
        modCustomBackWheels = GetVehicleModVariation(vehicle, 24),

        modPlateHolder = GetVehicleMod(vehicle, 25),
        modVanityPlate = GetVehicleMod(vehicle, 26),
        modTrimA = GetVehicleMod(vehicle, 27),
        modOrnaments = GetVehicleMod(vehicle, 28),
        modDashboard = GetVehicleMod(vehicle, 29),
        modDial = GetVehicleMod(vehicle, 30),
        modDoorSpeaker = GetVehicleMod(vehicle, 31),
        modSeats = GetVehicleMod(vehicle, 32),
        modSteeringWheel = GetVehicleMod(vehicle, 33),
        modShifterLeavers = GetVehicleMod(vehicle, 34),
        modAPlate = GetVehicleMod(vehicle, 35),
        modSpeakers = GetVehicleMod(vehicle, 36),
        modTrunk = GetVehicleMod(vehicle, 37),
        modHydrolic = GetVehicleMod(vehicle, 38),
        modEngineBlock = GetVehicleMod(vehicle, 39),
        modAirFilter = GetVehicleMod(vehicle, 40),
        modStruts = GetVehicleMod(vehicle, 41),
        modArchCover = GetVehicleMod(vehicle, 42),
        modAerials = GetVehicleMod(vehicle, 43),
        modTrimB = GetVehicleMod(vehicle, 44),
        modTank = GetVehicleMod(vehicle, 45),
        modWindows = GetVehicleMod(vehicle, 46),
        modLivery = GetVehicleMod(vehicle, 48) == -1 and GetVehicleLivery(vehicle) or GetVehicleMod(vehicle, 48),
        modLightbar = GetVehicleMod(vehicle, 49),
    }
end

---@param vehicle integer The vehicle to set the properties of
---@param props table The properties to set
---@return nil
function xLib.game.setVehicleProperties(vehicle, props)
    if not DoesEntityExist(vehicle) then
        return
    end
    local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    SetVehicleModKit(vehicle, 0)

    if props.tyresCanBurst ~= nil then
        SetVehicleTyresCanBurst(vehicle, props.tyresCanBurst)
    end

    if props.plate ~= nil then
        SetVehicleNumberPlateText(vehicle, props.plate)
    end
    if props.plateIndex ~= nil then
        SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
    end
    if props.bodyHealth ~= nil then
        SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
    end
    if props.engineHealth ~= nil then
        SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
    end
    if props.tankHealth ~= nil then
        SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0)
    end
    if props.fuelLevel ~= nil then
        SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
    end
    if props.dirtLevel ~= nil then
        SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
    end
    if props.color1 ~= nil then
        if type(props.color1) == "table" then
            SetVehicleCustomPrimaryColour(vehicle, props.color1[1], props.color1[2], props.color1[3])
        else
            SetVehicleColours(vehicle, props.color1, colorSecondary)
        end
    end
    if props.color2 ~= nil then
        if type(props.color2) == "table" then
            SetVehicleCustomSecondaryColour(vehicle, props.color2[1], props.color2[2], props.color2[3])
        else
            SetVehicleColours(vehicle, type(props.color1) == "number" and props.color1 or colorPrimary, props.color2)
        end
    end
    if props.pearlescentColor ~= nil then
        SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
    end

    if props.interiorColor ~= nil then
        SetVehicleInteriorColor(vehicle, props.interiorColor)
    end

    if props.dashboardColor ~= nil then
        SetVehicleDashboardColor(vehicle, props.dashboardColor)
    end

    if props.wheelColor ~= nil then
        SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor)
    end
    if props.wheels ~= nil then
        SetVehicleWheelType(vehicle, props.wheels)
    end
    if props.windowTint ~= nil then
        SetVehicleWindowTint(vehicle, props.windowTint)
    end

    if props.neonEnabled ~= nil then
        SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
        SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
        SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
        SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
    end

    if props.extras ~= nil then
        for extraId, enabled in pairs(props.extras) do
            extraId = tonumber(extraId)
            if extraId then
                SetVehicleExtra(vehicle, extraId, not enabled)
            end
        end
    end

    if props.neonColor ~= nil then
        SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
    end
    if props.xenonColor ~= nil then
        SetVehicleXenonLightsColor(vehicle, props.xenonColor)
    end
    if props.customXenonColor ~= nil then
        SetVehicleXenonLightsCustomColor(vehicle, props.customXenonColor[1], props.customXenonColor[2], props.customXenonColor[3])
    end
    if props.modSmokeEnabled ~= nil then
        ToggleVehicleMod(vehicle, 20, true)
    end
    if props.tyreSmokeColor ~= nil then
        SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
    end
    if props.modSpoilers ~= nil then
        SetVehicleMod(vehicle, 0, props.modSpoilers, false)
    end
    if props.modFrontBumper ~= nil then
        SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
    end
    if props.modRearBumper ~= nil then
        SetVehicleMod(vehicle, 2, props.modRearBumper, false)
    end
    if props.modSideSkirt ~= nil then
        SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
    end
    if props.modExhaust ~= nil then
        SetVehicleMod(vehicle, 4, props.modExhaust, false)
    end
    if props.modFrame ~= nil then
        SetVehicleMod(vehicle, 5, props.modFrame, false)
    end
    if props.modGrille ~= nil then
        SetVehicleMod(vehicle, 6, props.modGrille, false)
    end
    if props.modHood ~= nil then
        SetVehicleMod(vehicle, 7, props.modHood, false)
    end
    if props.modFender ~= nil then
        SetVehicleMod(vehicle, 8, props.modFender, false)
    end
    if props.modRightFender ~= nil then
        SetVehicleMod(vehicle, 9, props.modRightFender, false)
    end
    if props.modRoof ~= nil then
        SetVehicleMod(vehicle, 10, props.modRoof, false)
    end

    if props.modRoofLivery ~= nil then
        SetVehicleRoofLivery(vehicle, props.modRoofLivery)
    end

    if props.modEngine ~= nil then
        SetVehicleMod(vehicle, 11, props.modEngine, false)
    end
    if props.modBrakes ~= nil then
        SetVehicleMod(vehicle, 12, props.modBrakes, false)
    end
    if props.modTransmission ~= nil then
        SetVehicleMod(vehicle, 13, props.modTransmission, false)
    end
    if props.modHorns ~= nil then
        SetVehicleMod(vehicle, 14, props.modHorns, false)
    end
    if props.modSuspension ~= nil then
        SetVehicleMod(vehicle, 15, props.modSuspension, false)
    end
    if props.modArmor ~= nil then
        SetVehicleMod(vehicle, 16, props.modArmor, false)
    end
    if props.modTurbo ~= nil then
        ToggleVehicleMod(vehicle, 18, props.modTurbo)
    end
    if props.modXenon ~= nil then
        ToggleVehicleMod(vehicle, 22, props.modXenon)
    end
    if props.modFrontWheels ~= nil then
        SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomFrontWheels)
    end
    if props.modBackWheels ~= nil then
        SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomBackWheels)
    end
    if props.modPlateHolder ~= nil then
        SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
    end
    if props.modVanityPlate ~= nil then
        SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
    end
    if props.modTrimA ~= nil then
        SetVehicleMod(vehicle, 27, props.modTrimA, false)
    end
    if props.modOrnaments ~= nil then
        SetVehicleMod(vehicle, 28, props.modOrnaments, false)
    end
    if props.modDashboard ~= nil then
        SetVehicleMod(vehicle, 29, props.modDashboard, false)
    end
    if props.modDial ~= nil then
        SetVehicleMod(vehicle, 30, props.modDial, false)
    end
    if props.modDoorSpeaker ~= nil then
        SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
    end
    if props.modSeats ~= nil then
        SetVehicleMod(vehicle, 32, props.modSeats, false)
    end
    if props.modSteeringWheel ~= nil then
        SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
    end
    if props.modShifterLeavers ~= nil then
        SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
    end
    if props.modAPlate ~= nil then
        SetVehicleMod(vehicle, 35, props.modAPlate, false)
    end
    if props.modSpeakers ~= nil then
        SetVehicleMod(vehicle, 36, props.modSpeakers, false)
    end
    if props.modTrunk ~= nil then
        SetVehicleMod(vehicle, 37, props.modTrunk, false)
    end
    if props.modHydrolic ~= nil then
        SetVehicleMod(vehicle, 38, props.modHydrolic, false)
    end
    if props.modEngineBlock ~= nil then
        SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
    end
    if props.modAirFilter ~= nil then
        SetVehicleMod(vehicle, 40, props.modAirFilter, false)
    end
    if props.modStruts ~= nil then
        SetVehicleMod(vehicle, 41, props.modStruts, false)
    end
    if props.modArchCover ~= nil then
        SetVehicleMod(vehicle, 42, props.modArchCover, false)
    end
    if props.modAerials ~= nil then
        SetVehicleMod(vehicle, 43, props.modAerials, false)
    end
    if props.modTrimB ~= nil then
        SetVehicleMod(vehicle, 44, props.modTrimB, false)
    end
    if props.modTank ~= nil then
        SetVehicleMod(vehicle, 45, props.modTank, false)
    end
    if props.modWindows ~= nil then
        SetVehicleMod(vehicle, 46, props.modWindows, false)
    end

    if props.modLivery ~= nil then
        SetVehicleMod(vehicle, 48, props.modLivery, false)
        SetVehicleLivery(vehicle, props.modLivery)
    end

    if props.windowsBroken ~= nil then
        for k, v in pairs(props.windowsBroken) do
            if v then
                k = tonumber(k)
                if k then
                    RemoveVehicleWindow(vehicle, k)
                end
            end
        end
    end

    if props.doorsBroken ~= nil then
        for k, v in pairs(props.doorsBroken) do
            if v then
                k = tonumber(k)
                if k then
                    SetVehicleDoorBroken(vehicle, k, true)
                end
            end
        end
    end

    if props.tyreBurst ~= nil then
        for k, v in pairs(props.tyreBurst) do
            if v then
                k = tonumber(k)
                if k then
                    SetVehicleTyreBurst(vehicle, k, true, 1000.0)
                end
            end
        end
    end
end

return xLib.game
