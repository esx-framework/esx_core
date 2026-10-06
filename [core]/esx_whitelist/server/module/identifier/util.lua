-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local IdentifierUtil = {}

-- Prefixes the resource understands. Unknown prefixes are still accepted
-- by validation (forward compatibility) but are flagged in diagnostics.
IdentifierUtil.KNOWN_PREFIXES = {
    license = true,
    license2 = true,
    steam = true,
    discord = true,
    fivem = true,
    xbl = true,
    live = true,
    ip = true,
}

---Splits "license2:abcdef" into "license2", "abcdef".
---@param identifier string normalized identifier
---@return string? prefix
---@return string? value
function IdentifierUtil.Split(identifier)
    local prefix, value = identifier:match("^([a-z0-9]+):(.+)$")
    return prefix, value
end

---Extracts the first identifier with the wanted prefix.
---@param identifiers string[]
---@param prefix string e.g. "discord"
---@return string? identifier
function IdentifierUtil.FindByPrefix(identifiers, prefix)
    local needle = prefix .. ":"
    local needleLength = #needle
    for i = 1, #identifiers do
        local identifier = identifiers[i]
        if identifier:sub(1, needleLength) == needle then
            return identifier
        end
    end
    return nil
end

return IdentifierUtil
