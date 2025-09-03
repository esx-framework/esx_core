---@class VINGenerator
---@field generate fun(modelHash:number?, owner:string?):string
---@field validate fun(vin:string):boolean
---@field decode fun(vin:string):table

local VIN = {}

-- Check if MySQL is available
local MySQL = MySQL or exports.oxmysql

-- Initialize random seed once
math.randomseed(os.time())

-- VIN Format: WMI (3) + VDS (6) + VIS (8) = 17 characters total
-- Example: 1ES2X3Y4567890123
-- WMI: World Manufacturer Identifier (1ES = ESX Framework)
-- VDS: Vehicle Descriptor Section (includes check digit)
-- VIS: Vehicle Identifier Section (unique serial)

local VIN_LENGTH = 17
local WMI = "1ES" -- ESX Framework identifier
local VALID_CHARS = "0123456789ABCDEFGHJKLMNPRSTUVWXYZ" -- Excluding I, O, Q to avoid confusion

-- Character value mapping for check digit calculation (based on real VIN standard)
local CHAR_VALUES = {
    ["0"] = 0, ["1"] = 1, ["2"] = 2, ["3"] = 3, ["4"] = 4, 
    ["5"] = 5, ["6"] = 6, ["7"] = 7, ["8"] = 8, ["9"] = 9,
    ["A"] = 1, ["B"] = 2, ["C"] = 3, ["D"] = 4, ["E"] = 5, 
    ["F"] = 6, ["G"] = 7, ["H"] = 8, ["J"] = 1, ["K"] = 2,
    ["L"] = 3, ["M"] = 4, ["N"] = 5, ["P"] = 7, ["R"] = 9,
    ["S"] = 2, ["T"] = 3, ["U"] = 4, ["V"] = 5, ["W"] = 6,
    ["X"] = 7, ["Y"] = 8, ["Z"] = 9
}

-- Position weights for check digit calculation
local POSITION_WEIGHTS = {8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2}

---Calculate check digit for VIN validation
---@param vin string
---@return string
local function calculateCheckDigit(vin)
    local sum = 0
    
    for i = 1, VIN_LENGTH do
        if i ~= 9 then -- Skip check digit position
            local char = vin:sub(i, i)
            local value = CHAR_VALUES[char] or 0
            local weight = POSITION_WEIGHTS[i]
            sum = sum + (value * weight)
        end
    end
    
    local remainder = sum % 11
    if remainder == 10 then
        return "X"
    else
        return tostring(remainder)
    end
end

---Generate random character from valid set
---@return string
local function getRandomChar()
    local index = math.random(1, #VALID_CHARS)
    return VALID_CHARS:sub(index, index)
end

---Generate model year code (current year in VIN format)
---@return string
local function getModelYearCode()
    local year = tonumber(os.date("%Y"))
    local yearCodes = {
        ["2024"] = "R", ["2025"] = "S", ["2026"] = "T", ["2027"] = "V",
        ["2028"] = "W", ["2029"] = "X", ["2030"] = "Y", ["2031"] = "1",
        ["2032"] = "2", ["2033"] = "3", ["2034"] = "4", ["2035"] = "5"
    }
    return yearCodes[tostring(year)] or "S" -- Default to 2025
end

---Generate plant code (server identifier)
---@return string
local function getPlantCode()
    -- Use first character of server name or default
    local serverName = GetConvar("sv_hostname", "")
    if serverName and #serverName > 0 then
        local firstChar = serverName:sub(1, 1):upper()
        if VALID_CHARS:find(firstChar, 1, true) then
            return firstChar
        end
    end
    return "X" -- Default plant code
end

---Generate unique serial number
---@return string
local function generateSerial()
    local serial = ""
    for i = 1, 6 do
        serial = serial .. getRandomChar()
    end
    return serial
end

---Generate vehicle descriptor based on model hash
---@param modelHash number?
---@return string
local function generateVDS(modelHash)
    local vds = ""
    
    if modelHash then
        -- Convert model hash to base36 and take first 5 chars
        local hashStr = string.format("%X", modelHash & 0xFFFFF)
        vds = string.sub(hashStr .. "00000", 1, 5)
    else
        -- Generate random VDS if no model provided
        for i = 1, 5 do
            vds = vds .. getRandomChar()
        end
    end
    
    -- Position 9 will be check digit (calculated later)
    return vds .. "0" -- Placeholder for check digit
end

---Generate a new VIN
---@param modelHash number? Optional vehicle model hash
---@param owner string? Optional owner identifier for additional uniqueness
---@return string
function VIN.generate(modelHash, owner)
    -- Build VIN components
    local wmi = WMI                           -- Positions 1-3
    local vds = generateVDS(modelHash)        -- Positions 4-9 (including check digit)
    local yearCode = getModelYearCode()       -- Position 10
    local plantCode = getPlantCode()          -- Position 11
    local serial = generateSerial()           -- Positions 12-17
    
    -- Combine without check digit
    local vinWithoutCheck = wmi .. vds:sub(1, 5) .. "0" .. yearCode .. plantCode .. serial
    
    -- Calculate and insert check digit at position 9
    local checkDigit = calculateCheckDigit(vinWithoutCheck)
    local finalVIN = wmi .. vds:sub(1, 5) .. checkDigit .. yearCode .. plantCode .. serial
    
    return finalVIN
end

---Validate VIN format and check digit
---@param vin string
---@return boolean
function VIN.validate(vin)
    -- Check length
    if not vin or #vin ~= VIN_LENGTH then
        return false
    end
    
    -- Check for invalid characters
    vin = vin:upper()
    for i = 1, #vin do
        local char = vin:sub(i, i)
        if not CHAR_VALUES[char] and char ~= "X" then
            return false
        end
    end
    
    -- Validate check digit
    local checkDigit = vin:sub(9, 9)
    local calculatedDigit = calculateCheckDigit(vin)
    
    return checkDigit == calculatedDigit
end

---Decode VIN to extract information
---@param vin string
---@return table
function VIN.decode(vin)
    if not VIN.validate(vin) then
        return {}
    end
    
    vin = vin:upper()
    
    local yearCodes = {
        ["R"] = 2024, ["S"] = 2025, ["T"] = 2026, ["V"] = 2027,
        ["W"] = 2028, ["X"] = 2029, ["Y"] = 2030, ["1"] = 2031,
        ["2"] = 2032, ["3"] = 2033, ["4"] = 2034, ["5"] = 2035
    }
    
    return {
        wmi = vin:sub(1, 3),                    -- World Manufacturer Identifier
        vds = vin:sub(4, 9),                    -- Vehicle Descriptor Section
        modelYear = yearCodes[vin:sub(10, 10)], -- Model Year
        plantCode = vin:sub(11, 11),            -- Assembly Plant
        serial = vin:sub(12, 17),                -- Serial Number
        isValid = true
    }
end

---Check if VIN exists in database
---@param vin string
---@return boolean
function VIN.exists(vin)
    if not MySQL then
        print("^1[ESX] [VIN] MySQL not available for VIN check^0")
        return false
    end
    local result = MySQL.scalar.await("SELECT 1 FROM `owned_vehicles` WHERE `vin` = ? LIMIT 1", {vin})
    return result ~= nil
end

---Generate unique VIN (ensures no duplicates in database)
---@param modelHash number?
---@param owner string?
---@param maxAttempts number?
---@return string?
function VIN.generateUnique(modelHash, owner, maxAttempts)
    maxAttempts = maxAttempts or 10
    
    for i = 1, maxAttempts do
        local vin = VIN.generate(modelHash, owner)
        if not VIN.exists(vin) then
            return vin
        end
    end
    
    -- If we couldn't generate unique VIN after max attempts, log error
    print(("^1[ESX] [VIN] Failed to generate unique VIN after %d attempts^0"):format(maxAttempts))
    return nil
end

-- Export VIN module
ESX.VIN = VIN
return VIN