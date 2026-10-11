-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@param index string
---@param overrides table
---@return nil
function ESX.RegisterPlayerFunctionOverrides(index, overrides)
    Core.PlayerFunctionOverrides[index] = overrides
end

---@param index string
---@return nil
function ESX.SetPlayerFunctionOverride(index)
    if not index or not Core.PlayerFunctionOverrides[index] then
        return print("[^3WARNING^7] No valid index provided.")
    end

    Config.PlayerFunctionOverride = index
end
