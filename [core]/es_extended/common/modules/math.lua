ESX.Math = {}

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

---@param value string
---@return string | nil
function ESX.Math.Trim(value)
    return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
end

---@param minRange number
---@param maxRange number
---@return number
function ESX.Math.Random(minRange, maxRange)
    math.randomseed(GetGameTimer())
    return math.random(minRange or 1, maxRange or 10)
end

