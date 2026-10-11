-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@class colorslib
local colors = rawget(xLib, "colors")
xLib.colors = type(colors) == "table" and colors or {}

xLib.colors.brand = GetConvar("esx:brand-color", "#FB9B04")
xLib.colors.darkest = GetConvar("esx:darkest-color", "#161616")
xLib.colors.dark = GetConvar("esx:dark-color", "#252525")
xLib.colors.mid = GetConvar("esx:mid-color", "#383838")
xLib.colors.light = GetConvar("esx:light-color", "#969696")
xLib.colors.lightest = GetConvar("esx:lightest-color", "#F2F2F2")

---@param defaults? table
---@return table
function xLib.colors.getESXTheme(defaults)
    defaults = defaults or {}

    return {
        primaryColor = GetConvar("esx:ui:primaryColor", defaults.primaryColor or xLib.colors.brand),
        secondaryColor = GetConvar("esx:ui:secondaryColor", defaults.secondaryColor or xLib.colors.dark),
        backgroundColor = GetConvar("esx:ui:backgroundColor", defaults.backgroundColor or xLib.colors.darkest),
        accentColor = GetConvar("esx:ui:accentColor", defaults.accentColor or xLib.colors.mid),
        logoUrl = GetConvar("esx:ui:logoUrl", defaults.logoUrl or "")
    }
end
