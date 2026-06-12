ESX.Math = {}

-- Fix: seed the PRNG once at module load instead of on every ESX.Math.Random call,
-- which reset the sequence and produced poorly-randomized output.
math.randomseed(GetGameTimer())

---@param value number
---@param numDecimalPlaces? number
---@return number
function ESX.Math.Round(value, numDecimalPlaces)
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
function ESX.Math.GroupDigits(value)
    local left, num, right = string.match(value, "^([^%d]*%d)(%d*)(.-)$")

    return left .. (num:reverse():gsub("(%d%d%d)", "%1" .. TranslateCap("locale_digit_grouping_symbol")):reverse()) .. right
end

---@param value string | number
---@return string | nil
function ESX.Math.Trim(value)
    value = tostring(value)
    return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
end

---@param minRange number
---@param maxRange number
---@return number
function ESX.Math.Random(minRange, maxRange)
    -- Fix: removed per-call math.randomseed; the PRNG is now seeded once at module load
    return math.random(minRange or 1, maxRange or 10)
end

---@param origin vector
---@param target vector
---@return number
function ESX.Math.GetHeadingFromCoords(origin, target)
	local dx = origin.x - target.x
    local dy = origin.y - target.y

    local heading = math.deg(math.atan(dy, dx)) + 90

    return (heading + 360) % 360
end

