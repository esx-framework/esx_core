-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local ok, result = pcall(function()
    return xLib.require "@esx_whitelist.client.module.whitelist.main"
end)

if not ok then return end
result.init()

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SetNuiFocus(false, false)
    end
end)
