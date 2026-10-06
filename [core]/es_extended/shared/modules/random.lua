-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Charset = {}

for i = 48, 57 do
    Charset[#Charset + 1] = string.char(i)
end

for i = 65, 90 do
    Charset[#Charset + 1] = string.char(i)
end

for i = 97, 122 do
    Charset[#Charset + 1] = string.char(i)
end

---@param length number
---@return string
function ESX.GetRandomString(length)
    if not (length > 0) then
        return ""
    end

    if length == math.huge then
        error("length must be finite", 2)
    end

    local characterCount = math.ceil(length)
    local result = {}

    for i = 1, characterCount do
        result[i] = Charset[math.random(1, #Charset)]
    end

    return table.concat(result)
end
