-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@param msg string
---@return nil
function ESX.Trace(msg)
    if Config.EnableDebug then
        print(("[^2TRACE^7] %s^7"):format(msg))
    end
end
