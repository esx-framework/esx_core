-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

xLib.addKeybind({
    name = "esx_interact",
    description = "Interact",
    defaultMapper = "keyboard",
    defaultKey = "e",
    onPressed = function()
        TriggerEvent("xLib:interact")
    end
})
