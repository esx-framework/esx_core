local Validation = {}

function Validation.CheckNameFormat(name)
    if ESX.IsValidLocaleString(name) then
        local stringLength = string.len(name)
        return stringLength > 0 and stringLength < Config.MaxNameLength
    end

    return false
end

function Validation.CheckSexFormat(sex)
    if not sex then
        return false
    end
    return sex == "m" or sex == "M" or sex == "f" or sex == "F"
end

function Validation.CheckHeightFormat(height)
    local numHeight = tonumber(height) or 0
    return numHeight >= Config.MinHeight and numHeight <= Config.MaxHeight
end

local function isLeapYear(year)
    return (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0)
end

function Validation.CheckDOBFormat(dob)
    dob = tostring(dob)

    local dayStr, monthStr, yearStr = dob:match("^(%d%d?)/(%d%d?)/(%d%d%d%d)$")
    if not dayStr or not monthStr or not yearStr then
        return false
    end

    local day, month, year = tonumber(dayStr), tonumber(monthStr), tonumber(yearStr)
    if not day or not month or not year then
        return false
    end

    local currentYear = os.date("*t").year
    local minYear = currentYear - Config.MaxAge
    local maxYear = currentYear - 18

    if year < minYear or year > maxYear then return false end
    if month < 1 or month > 12 then return false end

    local daysInMonth = { 31, isLeapYear(year) and 29 or 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    return day >= 1 and day <= daysInMonth[month]
end

Modules.Validation = Validation
return Validation

