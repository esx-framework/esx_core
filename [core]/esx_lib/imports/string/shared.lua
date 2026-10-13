---@class stringlib
xLib.string = string

--- Normalize (trim + lowercase)
---@param s string
---@return string
function xLib.string.normalize(s)
    xLib.verify(s, 'string', true)

    local res = s:match("^%s*(.-)%s*$"):lower()

    return res
end

---@param s string
---@return string
function xLib.string.capitalize(s)
    xLib.verify(s, 'string', true)

    local res = s:gsub("^%l", string.upper)

    return res
end

---@param s string
---@return string
function xLib.string.toSnake(s)
    xLib.verify(s, 'string', true)

    local res = s:gsub("%s+", "_"):gsub("([a-z%d])([A-Z])", "%1_%2"):lower()

    return res
end

---@param s string
---@return string
function xLib.string.toCamel(s)
    xLib.verify(s, 'string', true)

    local res = s:lower():gsub("_%a", function(w) return w:sub(2):upper() end)

    return res
end

---@param s string
---@return string
function xLib.string.toPascal(s)
    xLib.verify(s, 'string', true)

    local res = s:gsub("(%a)([%w]*)", function(first, rest)
        return first:upper() .. rest:lower()
    end):gsub("_", "")

    return res
end

---@param s string
---@return string
function xLib.string.escapePattern(s)
    xLib.verify(s, 'string', true)

    local res = s:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")

    return res
end

---@param s string
---@param pattern string
---@return boolean
function xLib.string.matchSafe(s, pattern)
    local ok, result = pcall(string.match, s, pattern)
    return ok and result ~= nil
end

---@param s string
---@param pattern string
---@return string
function xLib.string.before(s, pattern)
    xLib.verify(s, 'string', true)
    local start = s:find(pattern, 1, true)

    if not start then return s end

    return s:sub(1, start - 1)
end

---@param s string
---@param pattern string
---@return string
function xLib.string.after(s, pattern)
    xLib.verify(s, 'string', true)

    local _, finish = s:find(pattern, 1, true)

    if not finish then return s end

    return s:sub(finish + 1)
end


---@param s string
---@param substr string
---@return boolean
function xLib.string.contains(s, substr)
    xLib.verify(s, 'string', true)

    return s:find(substr, 1, true) ~= nil
end

---@param s string
---@param old string
---@param new string
---@return string
function xLib.string.replace(s, old, new)
    xLib.verify(s, 'string', true)

    if type(new) == "string" then
        new = new:gsub("%%", "%%%%")
    end

    local result = s:gsub(xLib.string.escapePattern(old), new)

    return result
end


---@param length number
---@return string
function xLib.string.randomHex(length)
    local t = {}

    for _ = 1, length do
        t[#t + 1] = string.format("%x", math.random(0, 15))
    end

    return table.concat(t)
end

---@return string
function xLib.string.uuid()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"

    local uuid = template:gsub("[xy]", function(c)
        local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
        return string.format("%x", v)
    end)

    return uuid
end

return xLib.string
