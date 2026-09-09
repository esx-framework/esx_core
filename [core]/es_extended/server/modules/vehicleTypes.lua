local KVP_KEY <const> = "esx_vehicleTypes"
local KVP_VERSION <const> = 1
local MAX_MODELS <const> = 10000
local MAX_MODEL_LENGTH <const> = 32

local validTypes <const> = {
    automobile = true,
    bike = true,
    boat = true,
    heli = true,
    plane = true,
    submarine = true,
    trailer = true,
    train = true,
}

local storedTypes = {}
local persistQueued = false
local warmedUp = false
local warmingUp = false

---@return nil
local function persistVehicleTypes()
    if persistQueued then
        return
    end

    persistQueued = true

    SetTimeout(1000, function()
        persistQueued = false

        if not next(storedTypes) then
            return DeleteResourceKvp(KVP_KEY)
        end

        SetResourceKvp(KVP_KEY, json.encode({ version = KVP_VERSION, types = storedTypes }))
    end)
end

---@param model number
---@param vehicleType string
---@return nil
function Core.CacheVehicleType(model, vehicleType)
    if not validTypes[vehicleType] then
        return
    end

    Core.vehicleTypesByModel[model] = vehicleType
    storedTypes[tostring(model)] = vehicleType

    persistVehicleTypes()
end

---@return nil
local function restoreVehicleTypes()
    local stored = GetResourceKvpString(KVP_KEY)

    if not stored then
        return
    end

    local ok, decoded = pcall(json.decode, stored)

    if not ok or type(decoded) ~= "table" or decoded.version ~= KVP_VERSION or type(decoded.types) ~= "table" then
        return DeleteResourceKvp(KVP_KEY)
    end

    for model, vehicleType in pairs(decoded.types) do
        model = tonumber(model)

        if model and validTypes[vehicleType] then
            storedTypes[tostring(model)] = vehicleType
            Core.vehicleTypesByModel[model] = vehicleType
        end
    end
end

---@param playerId number
---@return nil
local function refreshVehicleTypes(playerId)
    if warmedUp or warmingUp then
        return
    end

    warmingUp = true

    SetTimeout(20000, function()
        warmingUp = false
    end)

    ESX.TriggerClientCallback(playerId, "esx:GetVehicleTypes", function(types)
        warmingUp = false

        if type(types) ~= "table" then
            return
        end

        warmedUp = true

        local count = 0

        for modelName, vehicleType in pairs(types) do
            if count >= MAX_MODELS then
                break
            end

            if type(modelName) == "string" and #modelName <= MAX_MODEL_LENGTH and validTypes[vehicleType] then
                count = count + 1
                Core.CacheVehicleType(joaat(modelName:lower()), vehicleType)
            end
        end

        ESX.Trace(("Cached ^5%s^7 vehicle types."):format(count))
    end)
end

AddEventHandler("esx:playerLoaded", function(playerId)
    refreshVehicleTypes(playerId)
end)

restoreVehicleTypes()
