xLib = xLib or {}
xLib.math = xLib.math or {}

local math_max = math.max
local math_min = math.min
local math_floor = math.floor
local math_ceil = math.ceil
local math_asin = math.asin
local math_atan = math.atan 
local math_pi = math.pi
local string_format = string.format
local SCALAR_PATTERN = "[-%d%.]+"

-- Utility function to validate and convert to number
local function toNumber(val, context)
    local num = tonumber(val)
    if not num then
        error(("Invalid numeric input: %s in %s"):format(tostring(val), context or "operation"), 2)
    end
    return num
end

--- Clamps a value between optional min and max bounds.
--- @param value number The value to clamp
--- @param min number|nil Minimum bound
--- @param max number|nil Maximum bound
--- @return number The clamped value
function xLib.math.clamp(value, min, max)
    value = toNumber(value, "clamp")
    if min and max then
        min, max = toNumber(min), toNumber(max)
        if min > max then min, max = max, min end
        return math_max(min, math_min(max, value))
    elseif min then
        return math_max(toNumber(min), value)
    elseif max then
        return math_min(toNumber(max), value)
    end
    return value
end

--- Converts input to number.
--- @param value any Input value
--- @param min number|nil Minimum bound
--- @param max number|nil Maximum bound
--- @param round boolean|nil Round to nearest integer
--- @return number
function xLib.math.toNumber(value, min, max, round)
    local num = toNumber(value, "toNumber")
    
    if round then
        num = num >= 0 and math_floor(num + 0.5) or math_ceil(num - 0.5)
    end
    
    return xLib.math.clamp(num, min, max)
end

--- Converts input string to multiple numbers.
--- @param input string|number Input string or number (e.g., "1,2,3" or 1)
--- @param min number|nil Minimum bound
--- @param max number|nil Maximum bound
--- @param round boolean|nil Round to nearest integer
--- @return number ... Unpacked numbers
function xLib.math.toScalars(input, min, max, round)
    local results = {}
    for val in tostring(input):gmatch(SCALAR_PATTERN) do
        results[#results + 1] = xLib.math.toNumber(val, min, max, round)
    end
    return table.unpack(results)
end

--- Converts input to a vector (table).
--- @param input string|number|table Input value
--- @param min number|nil Minimum bound
--- @param max number|nil Maximum bound
--- @param round boolean|nil Round to nearest integer
--- @return table Vector table
function xLib.math.toVector(input, min, max, round)
    local results = {}
    local inputType = type(input)

    if inputType == "table" then
        for _, val in ipairs(input) do
            results[#results + 1] = xLib.math.toNumber(val, min, max, round)
        end
    elseif inputType == "string" or inputType == "number" then
        for val in tostring(input):gmatch(SCALAR_PATTERN) do
            results[#results + 1] = xLib.math.toNumber(val, min, max, round)
        end
    else
        error(("Invalid input type for toVector: %s"):format(inputType), 2)
    end

    return results
end

--- Converts a surface normal to a rotation vector (pitch, yaw, roll).
--- @param normal table {x, y, z} Normal vector components
--- @return table {pitch, yaw, roll} Rotation in degrees
function xLib.math.normalToRotation(normal)
    local x, y, z = toNumber(normal.x, "normalToRotation"), toNumber(normal.y, "normalToRotation"), toNumber(normal.z, "normalToRotation")
    local pitch = math_asin(-z) * (180 / math_pi)
    local yaw = math_atan(y, x) * (180 / math_pi) 
    return { pitch = pitch, yaw = yaw, roll = 0 }
end

--- Converts input to RGBA values (0-255, rounded).
--- @param input string|number|table Input value
--- @return table|number RGBA table or single number
function xLib.math.toRGBA(input)
    return xLib.math.toVector(input, 0, 255, true)
end

--- Converts hex color string to normalized RGBA (0-1).
--- @param hex string Hex color (e.g., "#FF0000" or "#FF0000FF")
--- @return number r Red (0-1)
--- @return number g Green (0-1)
--- @return number b Blue (0-1)
--- @return number a Alpha (0-1)
function xLib.math.hexToRGBA(hex)
    hex = hex:gsub("#", "")
    local len = #hex
    if len ~= 6 and len ~= 8 then
        error(("Invalid hex color format: %s"):format(hex), 2)
    end

    local r = toNumber("0x" .. hex:sub(1, 2), "hexToRGBA") / 255
    local g = toNumber("0x" .. hex:sub(3, 4), "hexToRGBA") / 255
    local b = toNumber("0x" .. hex:sub(5, 6), "hexToRGBA") / 255
    local a = len == 8 and toNumber("0x" .. hex:sub(7, 8), "hexToRGBA") / 255 or 1
    return r, g, b, a
end

--- Converts RGBA (0-1) to hex color string.
--- @param r number Red (0-1)
--- @param g number Green (0-1)
--- @param b number Blue (0-1)
--- @param a number|nil Alpha (0-1)
--- @return string Hex color string
function xLib.math.toHex(r, g, b, a)
    r = xLib.math.clamp(math_floor(toNumber(r, "toHex") * 255), 0, 255)
    g = xLib.math.clamp(math_floor(toNumber(g, "toHex") * 255), 0, 255)
    b = xLib.math.clamp(math_floor(toNumber(b, "toHex") * 255), 0, 255)
    if a then
        a = xLib.math.clamp(math_floor(toNumber(a, "toHex") * 255), 0, 255)
        return string_format("#%02X%02X%02X%02X", r, g, b, a)
    end
    return string_format("#%02X%02X%02X", r, g, b)
end

--- Formats a number with grouped digits.
--- @param number number Number to format
--- @param separator string|nil Separator (default: ",")
--- @return string Formatted string
function xLib.math.groupDigits(number, separator)
    separator = separator or ","
    local formatted = tostring(toNumber(number, "groupDigits"))
    local k
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1" .. separator .. "%2")
        if k == 0 then break end
    end
    return formatted
end

--- Rounds a number to specified decimal places.
--- @param num number Number to round
--- @param decimalPlaces number|nil Decimal places (default: 0)
--- @return number Rounded number
function xLib.math.round(num, decimalPlaces)
    local num = toNumber(num, "round")
    local mult = 10^(decimalPlaces or 0)
    if num < 0 then
        return math_ceil(num * mult - 0.5) / mult
    end
    return math_floor(num * mult + 0.5) / mult
end

--- Linearly interpolates between two values.
--- @param start number Start value
--- @param goal number End value
--- @param percent number Interpolation factor (0-1)
--- @return number Interpolated value
function xLib.math.interpolate(start, goal, percent)
    start, goal, percent = toNumber(start, "interpolate"), toNumber(goal, "interpolate"), xLib.math.clamp(toNumber(percent, "interpolate"), 0, 1)
    return start + (goal - start) * percent
end


--- Performs linear interpolation between two values based on t (0-1).
--- @param a number Start value
--- @param b number End value
--- @param t number Interpolation factor (0-1)
--- @return number Interpolated value
function xLib.math.lerp(a, b, t)
    return a + (b - a) * xLib.math.clamp(t, 0, 1)
end

--- Calculates the inverse linear interpolation factor of a value between a and b.
--- @param a number Start value
--- @param b number End value
--- @param value number Value to evaluate
--- @return number Interpolation factor (0-1)
function xLib.math.inverseLerp(a, b, value)
    return (value - a) / (b - a)
end

--- Remaps a value from one range to another.
--- @param value number Value to remap
--- @param inMin number Input range minimum
--- @param inMax number Input range maximum
--- @param outMin number Output range minimum
--- @param outMax number Output range maximum
--- @return number Remapped value
function xLib.math.remap(value, inMin, inMax, outMin, outMax)
    local t = xLib.math.inverseLerp(inMin, inMax, value)
    return xLib.math.lerp(outMin, outMax, t)
end

----------------------------------------------------------------------------------------------


-- Rounds a number to the nearest integer or specified decimal places.
---@param value number
---@param numDecimalPlaces? number
---@return number
function xLib.math.Round(value, numDecimalPlaces)
    if numDecimalPlaces then
        local power = 10 ^ numDecimalPlaces
        return math.floor((value * power) + 0.5) / power
    else
        return math.floor(value + 0.5)
    end
end

-- credit http://richard.warburton.it
---@param value number
---@return string
function xLib.math.GroupDigits(value)
    local left, num, right = string.match(value, "^([^%d]*%d)(%d*)(.-)$")

    return left .. (num:reverse():gsub("(%d%d%d)", "%1" .. TranslateCap("locale_digit_grouping_symbol")):reverse()) .. right
end

---@param value string | number
---@return string | nil
function xLib.math.Trim(value)
    value = tostring(value)
    return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
end

---@param minRange number
---@param maxRange number
---@return number
function xLib.math.Random(minRange, maxRange)
    math.randomseed(GetGameTimer())
    return math.random(minRange or 1, maxRange or 10)
end

---@param origin vector
---@param target vector
---@return number
function xLib.math.GetHeadingFromCoords(origin, target)
	local dx = origin.x - target.x
    local dy = origin.y - target.y

    local heading = math.deg(math.atan(dy, dx)) + 90

    return (heading + 360) % 360
end

return xLib.math