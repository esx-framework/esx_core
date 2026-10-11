-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@param value string
---@param ... any
---@return boolean, string?
function ESX.ValidateType(value, ...)
    local types = { ... }
    if #types == 0 then return true end

    local mapType = {}
    for i = 1, #types, 1 do
        local validateType = types[i]
        assert(type(validateType) == "string", "bad argument types, only expected string")
        mapType[validateType] = true
    end

    local valueType = type(value)
    local matches = mapType[valueType] ~= nil

    if not matches then
        local requireTypes = table.concat(types, " or ")
        local errorMessage = ("bad value (%s expected, got %s)"):format(requireTypes, valueType)

        return false, errorMessage
    end

    return true
end

---@param ... any
---@return boolean
function ESX.AssertType(...)
    local matches, errorMessage = ESX.ValidateType(...)

    assert(matches, errorMessage)

    return matches
end

---@param val unknown
function ESX.IsFunctionReference(val)
    local typeVal = type(val)

    return typeVal == "function" or (typeVal == "table" and type(getmetatable(val)?.__call) == "function")
end

---@param str string
---@param allowDigits boolean? Allow numbers if necessary
---@return boolean
function ESX.IsValidLocaleString(str, allowDigits)
    if not ESX.ValidateType(str, "string") then
        return false
    end

    if not utf8.len(str) then
        return false
    end

    local locale = string.lower(Config.Locale)

    local defaultRanges = {
        { 0x0041, 0x005A },
        { 0x0061, 0x007A },
        { 0x0020, 0x0020 },
        { 0x002D, 0x002D },
        { 0x00C0, 0x02AF },
    }

    if allowDigits then
        defaultRanges[#defaultRanges + 1] = { 0x0030, 0x0039 }
    end

    local localeRanges = {
        el = { { 0x0370, 0x03FF } },
        sr = { { 0x0400, 0x04FF } },
        he = { { 0x05D0, 0x05EA } },
        ar = {
            { 0x0620, 0x063F },
            { 0x0641, 0x064A },
            { 0x066E, 0x066F },
            { 0x0671, 0x06D3 },
            { 0x06D5, 0x06D5 },
            { 0x0750, 0x077F },
            { 0x08A0, 0x08BD },
        },
        ["zh-cn"] = { { 0x4E00, 0x9FFF } },
    }

    local validRanges = { table.unpack(defaultRanges) }

    if localeRanges[locale] then
        for i = 1, #localeRanges[locale] do
            validRanges[#validRanges + 1] = localeRanges[locale][i]
        end
    end

    if Config.ValidCharacterSets then
        for charset, enabled in pairs(Config.ValidCharacterSets) do
            if enabled and charset ~= locale and localeRanges[charset] then
                for i = 1, #localeRanges[charset] do
                    validRanges[#validRanges + 1] = localeRanges[charset][i]
                end
            end
        end
    end

    for _, code in utf8.codes(str) do
        local isValid = false

        for i = 1, #validRanges do
            local range = validRanges[i]
            if code >= range[1] and code <= range[2] then
                isValid = true
                break
            end
        end

        if not isValid then
            return false
        end
    end

    return true
end
