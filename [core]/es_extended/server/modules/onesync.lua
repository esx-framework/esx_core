ESX.OneSync = {}

---@param vehicleModel number|string
---@param coords vector3|table
---@param heading number
---@param vehicleProperties table
---@param cb? fun(netId: number)
---@param vehicleType string?
---@return number? netId
function ESX.OneSync.SpawnVehicle(vehicleModel, coords, heading, vehicleProperties, cb, vehicleType)
    if cb and not ESX.IsFunctionReference(cb) then
        error("Invalid callback function")
    end

    vehicleModel = joaat(vehicleModel)

    local promise = not cb and promise.new()

    local function resolve(result)
        if promise then
            promise:resolve(result)
        elseif cb then
            cb(result)
        end

        return result
    end

    local function reject(err)
        if promise then
            promise:reject(err)
        end
        error(err)
    end

    CreateThread(function()
        if not vehicleType then
            local xPlayer = ESX.GetExtendedPlayers()[1]
            if xPlayer then
                vehicleType = ESX.GetVehicleType(vehicleModel, xPlayer.source)
            end
        end

        if not vehicleType then
            return reject("No players found nearby to check vehicle type! Alternatively, you can specify the vehicle type manually.")
        end

        local createdVehicle = CreateVehicleServerSetter(vehicleModel, vehicleType, coords.x, coords.y, coords.z, heading)
        local tries = 0

        local hasNetOwner = next(xLib.onesync.getClosestPlayer(coords, 300, nil, 0) or {}) ~= nil

        while not createdVehicle or createdVehicle == 0
            or (hasNetOwner and NetworkGetEntityOwner(createdVehicle) == -1)
            or (not hasNetOwner and not DoesEntityExist(createdVehicle)) do
            Wait(200)
            tries = tries + 1
            if tries > 40 then
                return reject(("Could not spawn vehicle - ^5%s^7!"):format(vehicleModel))
            end
        end

        -- luacheck: ignore
        SetEntityOrphanMode(createdVehicle, 2)
        local networkId = NetworkGetNetworkIdFromEntity(createdVehicle)
        Entity(createdVehicle).state:set("VehicleProperties", vehicleProperties, true)

        resolve(networkId)
    end)

    if promise then
        return Citizen.Await(promise)
    end
end

---@param model number|string
---@param coords vector3|table
---@param heading number
---@param cb? fun(netId: number)
---@return number? netId
function ESX.OneSync.SpawnObject(model, coords, heading, cb)
    if type(model) == "string" then
        model = joaat(model)
    end

    local promise = not cb and promise.new()
    local objectCoords = type(coords) == "vector3" and coords or vector3(coords.x, coords.y, coords.z)

    local function resolve(result)
        if promise then
            promise:resolve(result)
        elseif cb then
            cb(result)
        end
    end

    local function reject(err)
        if promise then
            promise:reject(err)
        end
        error(err)
    end

    CreateThread(function()
        local entity = CreateObject(model, objectCoords.x, objectCoords.y, objectCoords.z, true, true, false)
        local tries = 0

        while not DoesEntityExist(entity) do
            Wait(200)
            
            tries = tries + 1

            if tries > 40 then
                return reject(("Could not spawn object - ^5%s^7!"):format(entity))
            end
        end

        local networkId = NetworkGetNetworkIdFromEntity(entity)

        SetEntityHeading(entity, heading)
        resolve(networkId)
    end)

    if promise then
        return Citizen.Await(promise)
    end
end

---@param model number|string
---@param coords vector3|table
---@param heading number
---@param cb? fun(netId: number)
---@return number? netId
function ESX.OneSync.SpawnPed(model, coords, heading, cb)
    if type(model) == "string" then
        model = joaat(model)
    end

    local promise = not cb and promise.new()

    local function resolve(result)
        if promise then
            promise:resolve(result)
        elseif cb then
            cb(result)
        end
    end

    local function reject(err)
        if promise then
            promise:reject(err)
        end
        error(err)
    end

    CreateThread(function()
        local entity = CreatePed(0, model, coords.x, coords.y, coords.z, heading, true, true)
        local tries = 0

        while not DoesEntityExist(entity) do
            Wait(200)

            tries = tries + 1

            if tries > 40 then
                return reject(("Could not spawn ped - ^5%s^7!"):format(model))
            end
        end

        local networkId = NetworkGetNetworkIdFromEntity(entity)
        resolve(networkId)
    end)

    if promise then
        return Citizen.Await(promise)
    end
end

---@param model number|string
---@param vehicle number entityId
---@param seat number
---@param cb? fun(netId: number)
---@return number? netId
function ESX.OneSync.SpawnPedInVehicle(model, vehicle, seat, cb)
    if type(model) == "string" then
        model = joaat(model)
    end

    local promise = not cb and promise.new()

    local function resolve(result)
        if promise then
            promise:resolve(result)
        elseif cb then
            cb(result)
        end
    end

    local function reject(err)
        if promise then
            promise:reject(err)
        end
        error(err)
    end

    CreateThread(function()
        local entity = CreatePedInsideVehicle(vehicle, 1, model, seat, true, true)
        local tries = 0

        while not DoesEntityExist(entity) do
            Wait(200)

            tries = tries + 1

            if tries > 40 then
                reject(("Could not spawn ped - ^5%s^7!"):format(model))
            end
        end

        local networkId = NetworkGetNetworkIdFromEntity(entity)
        resolve(networkId)
    end)

    if promise then
        return Citizen.Await(promise)
    end
end
