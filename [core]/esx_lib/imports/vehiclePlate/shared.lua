-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@class vehicleplatelib
xLib.vehiclePlate = {}

local NumberCharset = {}
local LetterCharset = {}
local reservedPlates = {}
local RESERVATION_MS <const> = 30000

for i = 48, 57 do NumberCharset[#NumberCharset + 1] = string.char(i) end
for i = 65, 90 do LetterCharset[#LetterCharset + 1] = string.char(i) end

local function trim(value)
    return tostring(value):match("^%s*(.*%S)") or ""
end

local function getRandomChunk(charset, length)
    local value = ""
    length = tonumber(length) or 0

    for _ = 1, length do
        value = value .. charset[math.random(1, #charset)]
    end

    return value
end

---@class VehiclePlateNormalizeOptions
---@field maxLength? number
---@field uppercase? boolean
---@field compact? boolean
---@field allowEmpty? boolean
---@field pattern? string
---@field coerce? boolean

---@param plate any
---@param options? VehiclePlateNormalizeOptions
---@return string|nil
function xLib.vehiclePlate.normalize(plate, options)
    if plate == nil then
        return
    end

    options = options or {}

    if type(plate) ~= "string" then
        if not options.coerce then
            return
        end

        plate = tostring(plate)
    end

    plate = trim(plate)

    if options.compact then
        plate = plate:gsub("%s+", "")
    end

    if options.uppercase ~= false then
        plate = plate:upper()
    end

    if plate == "" and not options.allowEmpty then
        return
    end

    local maxLength = tonumber(options.maxLength or 8)
    if maxLength and maxLength > 0 and #plate > maxLength then
        return
    end

    if options.pattern and not plate:match(options.pattern) then
        return
    end

    return plate
end

---@param length number
---@return string
function xLib.vehiclePlate.randomLetters(length)
    return getRandomChunk(LetterCharset, length)
end

---@param length number
---@return string
function xLib.vehiclePlate.randomNumbers(length)
    return getRandomChunk(NumberCharset, length)
end

---@class VehiclePlateGenerateOptions: VehiclePlateNormalizeOptions
---@field prefix? string
---@field suffix? string
---@field letters? number
---@field numbers? number
---@field useSpace? boolean

---@param options? VehiclePlateGenerateOptions
---@return string|nil
function xLib.vehiclePlate.generate(options)
    options = options or {}

    local prefix = options.prefix or ""
    local suffix = options.suffix or ""
    local letters = xLib.vehiclePlate.randomLetters(options.letters or options.letterCount or 3)
    local numbers = xLib.vehiclePlate.randomNumbers(options.numbers or options.numberCount or 3)
    local separator = options.useSpace and " " or ""

    return xLib.vehiclePlate.normalize(("%s%s%s%s%s"):format(prefix, letters, separator, numbers, suffix), options)
end

---@param options? VehiclePlateGenerateOptions|fun(plate: string): boolean
---@param exists? fun(plate: string): boolean
---@return string|nil
function xLib.vehiclePlate.generateUnique(options, exists)
    if type(options) == "function" and not exists then
        exists = options
        options = {}
    end

    options = options or {}
    local attempts = tonumber(options.attempts or 30) or 30
    local now = GetGameTimer()

    for plate, expiresAt in pairs(reservedPlates) do
        if expiresAt <= now then
            reservedPlates[plate] = nil
        end
    end

    for _ = 1, attempts do
        local plate = xLib.vehiclePlate.generate(options)

        if plate and not reservedPlates[plate] then
            reservedPlates[plate] = GetGameTimer() + RESERVATION_MS

            if not exists or not exists(plate) then
                return plate
            end

            reservedPlates[plate] = nil
        end
    end
end

---@param left any
---@param right any
---@param options? VehiclePlateNormalizeOptions
---@return boolean
function xLib.vehiclePlate.equals(left, right, options)
    left = xLib.vehiclePlate.normalize(left, options)
    right = xLib.vehiclePlate.normalize(right, options)

    return left ~= nil and right ~= nil and left == right
end

---@param vehicle number
---@param plate any
---@param options? VehiclePlateNormalizeOptions
---@return boolean
function xLib.vehiclePlate.matchesVehicle(vehicle, plate, options)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        return false
    end

    return xLib.vehiclePlate.equals(GetVehicleNumberPlateText(vehicle) or "", plate, options)
end

return xLib.vehiclePlate
