---@class tablelib
xLib.table = table

---@class Array: table
xLib.table.array = xLib.class()

local table_unpack = table.unpack
local table_remove = table.remove
local table_clone = table.clone
local table_concat = table.concat
local table_type = table.type

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

        if count > maxIndex then
            return false
        end
    end

    return true
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

--- https://github.com/overextended/ox_lib/blob/master/imports/array/shared.lua
---@private
function xLib.table.array:constructor(...)
    local arr = { ... }

    for i = 1, #arr do
        self[i] = arr[i]
    end
end

---@private
function xLib.table.array:__newindex(index, value)
    if type(index) ~= 'number' then error(("Cannot insert non-number index '%s' into an array."):format(index)) end

    rawset(self, index, value)
end

---Creates a new array from an iteratable value.
---@param iter table | function | string
---@return Array
function xLib.table.array:from(iter)
    local iterType = type(iter)

    if iterType == 'table' then
        return xLib.table.array:new(table_unpack(iter))
    end

    if iterType == 'string' then
        return xLib.table.array:new(string.strsplit('', iter))
    end

    if iterType == 'function' then
        local arr = xLib.table.array:new()
        local length = 0

        for value in iter do
            length += 1
            arr[length] = value
        end

        return arr
    end

    error(('Array.from argument was not a valid iterable value (received %s)'):format(iterType))
end

---Returns the element at the given index, with negative numbers counting backwards from the end of the array.
---@param index number
---@return unknown
function xLib.table.array:at(index)
    if index < 0 then
        index = #self + index + 1
    end

    return self[index]
end

---Create a new array containing the elements of two or more arrays.
---@param ... ArrayLike
function xLib.table.array:merge(...)
    local newArr = table_clone(self)
    local length = #self
    local arrays = { ... }

    for i = 1, #arrays do
        local arr = arrays[i]

        for j = 1, #arr do
            length += 1
            newArr[length] = arr[j]
        end
    end

    return xLib.table.array:new(table_unpack(newArr))
end

---Tests if all elements in an array succeed in passing the provided test function.
---@param testFn fun(element: unknown): boolean
function xLib.table.array:every(testFn)
    for i = 1, #self do
        if not testFn(self[i]) then
            return false
        end
    end

    return true
end

---Sets all elements within a range to the given value and returns the modified array.
---@param value any
---@param start? number
---@param endIndex? number
function xLib.table.array:fill(value, start, endIndex)
    local length = #self
    start = start or 1
    endIndex = endIndex or length

    if start < 1 then start = 1 end
    if endIndex > length then endIndex = length end

    for i = start, endIndex do
        self[i] = value
    end

    return self
end

---Creates a new array containing the elements from an array that pass the test of the provided function.
---@param testFn fun(element: unknown): boolean
function xLib.table.array:filter(testFn)
    local newArr = {}
    local length = 0

    for i = 1, #self do
        local element = self[i]

        if testFn(element) then
            length += 1
            newArr[length] = element
        end
    end

    return xLib.table.array:new(table_unpack(newArr))
end

---Returns the first or last element of an array that passes the provided test function.
---@param testFn fun(element: unknown): boolean
---@param last? boolean
function xLib.table.array:find(testFn, last)
    local a = last and #self or 1
    local b = last and 1 or #self
    local c = last and -1 or 1

    for i = a, b, c do
        local element = self[i]

        if testFn(element) then
            return element
        end
    end
end

---Returns the first or last index of the first element of an array that passes the provided test function.
---@param testFn fun(element: unknown): boolean
---@param last? boolean
function xLib.table.array:findIndex(testFn, last)
    local a = last and #self or 1
    local b = last and 1 or #self
    local c = last and -1 or 1

    for i = a, b, c do
        local element = self[i]

        if testFn(element) then
            return i
        end
    end
end

---Returns the first or last index of the first element of an array that matches the provided value.
---@param value unknown
---@param last? boolean
function xLib.table.array:indexOf(value, last)
    local a = last and #self or 1
    local b = last and 1 or #self
    local c = last and -1 or 1

    for i = a, b, c do
        local element = self[i]

        if element == value then
            return i
        end
    end
end

---Executes the provided function for each element in an array.
---@param cb fun(element: unknown)
function xLib.table.array:forEach(cb)
    for i = 1, #self do
        cb(self[i])
    end
end

---Determines if a given element exists inside an array.
---@param element unknown The value to find in the array.
---@param fromIndex? number The position in the array to begin searching from.
function xLib.table.array:includes(element, fromIndex)
    for i = (fromIndex or 1), #self do
        if self[i] == element then return true end
    end

    return false
end

---Concatenates all array elements into a string, seperated by commas or the specified seperator.
---@param seperator? string
function xLib.table.array:join(seperator)
    return table_concat(self, seperator or ',')
end

---Create a new array containing the results from calling the provided function on every element in an array.
---@param cb fun(element: unknown, index: number, array: self): unknown
function xLib.table.array:map(cb)
    local arr = {}

    for i = 1, #self do
        arr[i] = cb(self[i], i, self)
    end

    return xLib.table.array:new(table_unpack(arr))
end

---Removes the last element from an array and returns the removed element.
function xLib.table.array:pop()
    return table_remove(self)
end

---Adds the given elements to the end of an array and returns the new array length.
---@param ... any
function xLib.table.array:push(...)
    local elements = { ... }
    local length = #self

    for i = 1, #elements do
        length += 1
        self[length] = elements[i]
    end

    return length
end

---The "reducer" function is applied to every element within an array, with the previous element's result serving as the accumulator.
---If an initial value is provided, it's used as the accumulator for index 1; otherwise, index 1 itself serves as the initial value, and iteration begins from index 2.
---@generic T
---@param reducer fun(accumulator: T, currentValue: T, index?: number): T
---@param initialValue? T
---@param reverse? boolean Iterate over the array from right-to-left.
---@return T
function xLib.table.array:reduce(reducer, initialValue, reverse)
    local length = #self
    local initialIndex = initialValue and 1 or 2
    local accumulator = initialValue or self[1]

    if reverse then
        for i = initialIndex, length do
            local index = length - i + initialIndex
            accumulator = reducer(accumulator, self[index], index)
        end
    else
        for i = initialIndex, length do
            accumulator = reducer(accumulator, self[i], i)
        end
    end

    return accumulator
end

---Reverses the elements inside an array.
function xLib.table.array:reverse()
    local i, j = 1, #self

    while i < j do
        self[i], self[j] = self[j], self[i]
        i += 1
        j -= 1
    end

    return self
end

---Removes the first element from an array and returns the removed element.
function xLib.table.array:shift()
    return table_remove(self, 1)
end

---Creates a shallow copy of a portion of an array as a new array.
---@param start? number
---@param finish? number
function xLib.table.array:slice(start, finish)
    local length = #self
    start = start or 1
    finish = finish or length

    if start < 0 then start = length + start + 1 end
    if finish < 0 then finish = length + finish + 1 end
    if start < 1 then start = 1 end
    if finish > length then finish = length end

    local arr = xLib.table.array:new()
    local index = 0

    for i = start, finish do
        index += 1
        arr[index] = self[i]
    end

    return arr
end

---Creates a new array with reversed elements from the given array.
function xLib.table.array:toReversed()
    local reversed = xLib.table.array:new()

    for i = #self, 1, -1 do
        reversed:push(self[i])
    end

    return reversed
end

---Inserts the given elements to the start of an array and returns the new array length.
---@param ... any
function xLib.table.array:unshift(...)
    local elements = { ... }
    local length = #self
    local eLength = #elements

    for i = length, 1, -1 do
        self[i + eLength] = self[i]
    end

    for i = 1, #elements do
        self[i] = elements[i]
    end

    return length + eLength
end

---Returns true if the given table is an instance of array or an array-like table.
---@param tbl ArrayLike
---@return boolean
function xLib.table.array.isArray(tbl)
    local tableType = table_type(tbl)
    
    if not tableType then return false end
    
    if tableType == 'array' or tableType == 'empty' then
        return true
    end
    
    local mt = getmetatable(tbl)
    return mt and mt == xLib.table.array
end

return xLib.table
