-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local esxVersion = 'v1.14.2'

Core.Migrations = Core.Migrations or {}
Core.Migrations[esxVersion] = Core.Migrations[esxVersion] or {}

if GetResourceKvpInt(('esx_migration:%s'):format(esxVersion)) == 1 then
    return
end

---@return boolean restartRequired
Core.Migrations[esxVersion].billingTargetLength = function()
    return xLib.schema.widenVarchar('billing', 'target', 60)
end
