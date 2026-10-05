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
    return length > 0 and ESX.GetRandomString(length - 1) .. Charset[math.random(1, #Charset)] or ""
end
