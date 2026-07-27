---@class xtable : tablelib
xLib.table = setmetatable({}, { __index = table })

---@param tbl table
---@return boolean
function xLib.table.isArray(tbl)
    xLib.verify(tbl, "table", true)

    local count, maxIndex = 0, 0

    for k, _ in pairs(tbl) do
        if type(k) ~= "number" or k < 1 or k % 1 ~= 0 then
            return false
        end

        count, maxIndex = count + 1, math.max(maxIndex, k)
    end

    return count == maxIndex
end

---@param tbl table
---@param item any
---@return any
function xLib.table.searchForKey(tbl, item)
    xLib.verify(tbl, "table", true)

    for k, v in pairs(tbl) do
        if v == item then
            return k
        end
    end

    return nil
end

---@param tbl table
---@param item any
---@return boolean
function xLib.table.contains(tbl, item)
    return xLib.table.searchForKey(tbl, item) ~= nil
end

---@param tbl table
---@param filter fun(value:any, key:any):boolean
---@return table
function xLib.table.filter(tbl, filter)
    xLib.verify(tbl, "table", true)
    xLib.verify(filter, "function", true)

    local result = {}

    for k, v in pairs(tbl) do
        if filter(v, k) then
            result[k] = v
        end
    end

    return result
end

---@param tbl table
---@param copies? table
---@return table
function xLib.table.deepcopy(tbl, copies)
    xLib.verify(tbl, "table", true)

    copies = copies or {}

    if copies[tbl] then
        return copies[tbl]
    end

    local copy = {}
    copies[tbl] = copy

    for k, v in pairs(tbl) do
        copy[k] = type(v) == "table" and xLib.table.deepcopy(v, copies) or v

        if type(v) == "table" and getmetatable(v) then
            setmetatable(copy[k], getmetatable(v))
        end
    end

    return copy
end

--- https://github.com/overextended/ox_lib/blob/master/imports/table/shared.lua
---@param t1 table
---@param t2 table
---@param addDuplicateNumbers boolean
---@return table
function xLib.table.merge(t1, t2, addDuplicateNumbers)
    xLib.verify(t1, "table", true)
    xLib.verify(t2, "table", true)
    xLib.verify(addDuplicateNumbers, "boolean", true)

    addDuplicateNumbers = addDuplicateNumbers == nil or addDuplicateNumbers
    for k, v2 in pairs(t2) do
        local v1 = t1[k]
        local type1 = type(v1)
        local type2 = type(v2)

        if type1 == 'table' and type2 == 'table' then
            xLib.table.merge(v1, v2, addDuplicateNumbers)
        elseif addDuplicateNumbers and (type1 == 'number' and type2 == 'number') then
            t1[k] = v1 + v2
        else
            t1[k] = v2
        end
    end

    return t1
end

function xLib.table.dump(tbl)
    if xLib.verify(tbl, 'table') then
        local s = '{ '
        for k,v in pairs(tbl) do
           if type(k) ~= 'number' then k = '"'..k..'"' end
           s = s .. '['..k..'] = ' .. tbl(v) .. ','
        end
        return s .. '} '
     else
        return tostring(tbl)
     end
end

-- nil proof alternative to #table
---@param t table
---@return number
function xLib.table.sizeOf(t)
    local count = 0

    for _, _ in pairs(t) do
        count = count + 1
    end

    return count
end

---@param t table
---@return table
function xLib.table.set(t)
    local set = {}
    for _, v in ipairs(t) do
        set[v] = true
    end
    return set
end

---@param t table
---@param value any
---@return number
function xLib.table.indexOf(t, value)
    for i = 1, #t, 1 do
        if t[i] == value then
            return i
        end
    end

    return -1
end

---@param t table
---@param value any
---@return number
function xLib.table.lastIndexOf(t, value)
    for i = #t, 1, -1 do
        if t[i] == value then
            return i
        end
    end

    return -1
end

---@param t table
---@param cb function
---@return any
function xLib.table.find(t, cb)
    for i = 1, #t, 1 do
        if cb(t[i]) then
            return t[i]
        end
    end

    return nil
end

---@param t table
---@param cb function
---@return number
function xLib.table.findIndex(t, cb)
    for i = 1, #t, 1 do
        if cb(t[i]) then
            return i
        end
    end

    return -1
end

---@param t table
---@param cb function
---@return table
function xLib.table.map(t, cb)
    local newTable = {}

    for i = 1, #t, 1 do
        newTable[i] = cb(t[i], i)
    end

    return newTable
end

---@param t table
---@return table
function xLib.table.reverse(t)
    local newTable = {}

    for i = #t, 1, -1 do
        table.insert(newTable, t[i])
    end

    return newTable
end

---@param t table
---@return table
function xLib.table.clone(t)
    if type(t) ~= "table" then
        return t
    end

    local meta = getmetatable(t)
    local target = {}

    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = xLib.table.clone(v)
        else
            target[k] = v
        end
    end

    setmetatable(target, meta)

    return target
end

---@param t1 table
---@param t2 table
---@return table
function xLib.table.concat(t1, t2)
    local t3 = xLib.table.clone(t1)

    for i = 1, #t2, 1 do
        table.insert(t3, t2[i])
    end

    return t3
end

---@param t table
---@param sep string
---@return string
function xLib.table.join(t, sep)
    local str = ""

    for i = 1, #t, 1 do
        if i > 1 then
            str = str .. (sep or ",")
        end

        str = str .. t[i]
    end

    return str
end

-- Credits: https://github.com/JonasDev99/qb-garages/blob/b0335d67cb72a6b9ac60f62a87fb3946f5c2f33d/server/main.lua#L5
---@param tab table
---@param val any
---@return boolean
function xLib.table.contains(tab, val)
    if type(val) == "table" then
        for _, value in pairs(tab) do
            if xLib.table.contains(val, value) then
                return true
            end
        end
        return false
    else
        for _, value in pairs(tab) do
            if value == val then
                return true
            end
        end
    end
    return false
end

-- Credit: https://stackoverflow.com/a/15706820
-- Description: sort function for pairs
---@param t table
---@param order function
---@return function
function xLib.table.sort(t, order)
    -- collect the keys
    local keys = {}

    for k, _ in pairs(t) do
        keys[#keys + 1] = k
    end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a, b)
            return order(t, a, b)
        end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0

    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

---@param t table
---@return Array
function xLib.table.toArray(t)
    local array = {}
    for _, v in pairs(t) do
        array[#array + 1] = v
    end
    return array
end

---@param t table
---@return table
function xLib.table.wipe(t)
    return table.wipe(t)
end


return xLib.table
