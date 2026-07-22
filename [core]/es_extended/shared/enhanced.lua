local ENHANCED_GAME_NAMES <const> = {
    ["gta5enhanced"] = true,
    ["gta5_enhanced"] = true
}

local isEnhanced

if IsDuplicityVersion() then
    isEnhanced = ENHANCED_GAME_NAMES[GetConvar("gamename", "gta5")] == true
    SetConvarReplicated("esx:enhanced", isEnhanced and "true" or "false")
    print(("[ESX] Edition detected: ^5%s^7"):format(isEnhanced and "Enhanced" or "Legacy"))
else
    isEnhanced = type(IsGameEnhancedVersion) == "function" and IsGameEnhancedVersion() == true
end

---@type boolean
ESX.IsEnhanced = isEnhanced
