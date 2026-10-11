-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@param key? string Key pair to get specific value of config
---@return unknown Returns the whole config if no key is passed, or a specific value
function ESX.GetConfig(key)
    if key then
        return Config[key]
    end

    return Config
end
