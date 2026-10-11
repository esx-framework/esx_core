-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@param playerId number | string
---@return string, number
function ESX.GetIdentifier(playerId)
    local fxDk = GetConvarInt("sv_fxdkMode", 0)
    if fxDk == 1 then
        return "ESX-DEBUG-LICENCE", 0
    end

    playerId = tostring(playerId)

    local identifierType = Config.Identifier
    local identifier = GetPlayerIdentifierByType(playerId, identifierType)

    assert(identifier, ("[ESX] GetIdentifier failed: no identifier found for playerId %s with type '%s'"):format(playerId, identifierType))

    return identifier:gsub(("%s:"):format(identifierType), "")
end

-- Generates a unique 9-digit SSN in dashed format (XXX-XX-XXXX).
---@param skipUniqueCheck boolean?
---@return string
function Core.generateSSN(skipUniqueCheck)
    local reservedSSNs = {
        ["078-05-1120"] = true,
        ["219-09-9999"] = true,
        ["123-45-6789"] = true,
    }

    while true do
        local area = math.random(1, 899)
        if area == 666 then
            goto continue
        end

        local group = math.random(1, 99)
        local serial = math.random(1, 9999)

        if area == 987 and group == 65 and serial >= 4320 and serial <= 4329 then
            goto continue
        end

        local candidate = string.format("%03d-%02d-%04d", area, group, serial)

        if reservedSSNs[candidate] then
            goto continue
        end

        if skipUniqueCheck then
            return candidate
        end

        local exists = MySQL.scalar.await("SELECT 1 FROM `users` WHERE `ssn` = ? LIMIT 1", { candidate })

        if not exists then
            return candidate
        end

        ::continue::
    end
end
