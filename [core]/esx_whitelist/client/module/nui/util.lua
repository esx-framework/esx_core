-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local NuiUtil = {}

NuiUtil.THEME_DEFAULTS = {
    primaryColor = "#FB9B04",
    secondaryColor = "#252525",
    backgroundColor = "#161616",
    accentColor = "#383838",
    logoUrl = "",
}

local HEX_COLOR <const> = "^#%x%x%x%x%x%x$"

---@param value string
---@param fallback string
---@return string
local function sanitizeColor(value, fallback)
    if type(value) == "string" and value:match(HEX_COLOR) then
        return value
    end
    return fallback
end

---Reads the theme convars with validation and fallbacks.
---@return { primaryColor: string, secondaryColor: string, backgroundColor: string, accentColor: string, logoUrl: string }
function NuiUtil.ReadTheme()
    local theme
    if xLib and xLib.colors and xLib.colors.getESXTheme then
        theme = xLib.colors.getESXTheme(NuiUtil.THEME_DEFAULTS)
    end

    local logoUrl = (theme and theme.logoUrl) or GetConvar("esx:ui:logoUrl", NuiUtil.THEME_DEFAULTS.logoUrl)
    if type(logoUrl) ~= "string" or #logoUrl > 512 or not logoUrl:match("^https?://") then
        logoUrl = ""
    end

    return {
        primaryColor = sanitizeColor((theme and theme.primaryColor) or GetConvar("esx:ui:primaryColor", ""), NuiUtil.THEME_DEFAULTS.primaryColor),
        secondaryColor = sanitizeColor((theme and theme.secondaryColor) or GetConvar("esx:ui:secondaryColor", ""), NuiUtil.THEME_DEFAULTS.secondaryColor),
        backgroundColor = sanitizeColor((theme and theme.backgroundColor) or GetConvar("esx:ui:backgroundColor", ""), NuiUtil.THEME_DEFAULTS.backgroundColor),
        accentColor = sanitizeColor((theme and theme.accentColor) or GetConvar("esx:ui:accentColor", ""), NuiUtil.THEME_DEFAULTS.accentColor),
        logoUrl = logoUrl,
    }
end

return NuiUtil
