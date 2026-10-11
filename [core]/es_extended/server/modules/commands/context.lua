-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core.CommandPermissions = Config.CommandPermissions or {}

---@param groups string[]?
---@param commandName string?
---@return string[]
function Core.FilterCommandGroups(groups, commandName)
    if type(groups) == "table" and #groups > 0 then
        return groups
    end

    print(("[^3WARNING^7] Command ^5%s^7 has no entry in ^5Config.CommandPermissions^7, restricting it to ^5admin^7"):format(commandName or "unknown"))

    return { "admin" }
end
