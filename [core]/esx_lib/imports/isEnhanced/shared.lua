-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local ENHANCED_GAME_NAMES <const> = {
    ["gta5enhanced"] = true,
    ["gta5_enhanced"] = true
}

local isEnhanced

if IsDuplicityVersion() then
    isEnhanced = ENHANCED_GAME_NAMES[GetConvar("gamename", "gta5")] == true
else
    isEnhanced = type(IsGameEnhancedVersion) == "function" and IsGameEnhancedVersion() == true
end

---@return boolean
return function()
    return isEnhanced
end
