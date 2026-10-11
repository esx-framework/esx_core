-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

ESX = {}

exports("getSharedObject", function()
    return ESX
end)

AddEventHandler("esx:getSharedObject", function(cb)
    if ESX.IsFunctionReference(cb) then
        cb(ESX)
    end
end)

-- backwards compatibility (DO NOT TOUCH !)
Config.OxInventory = Config.CustomInventory == "ox"
