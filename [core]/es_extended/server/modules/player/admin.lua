-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@param playerSrc number
---@return boolean
function Core.IsPlayerAdmin(playerSrc)
    if type(playerSrc) ~= "number" then
        return false
    end

    if IsPlayerAceAllowed(playerSrc --[[@as string]], "command") or GetConvar("sv_lan", "") == "true" then
        return true
    end

    local xPlayer = ESX.GetPlayerFromId(playerSrc)
    return xPlayer and Config.AdminGroups[xPlayer.getGroup()] or false
end
