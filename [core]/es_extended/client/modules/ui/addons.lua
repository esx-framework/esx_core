-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core.AddonResourcesState = {
    esx_progressbar = GetResourceState("esx_progressbar") ~= "missing",
    esx_notify = GetResourceState("esx_notify") ~= "missing",
    esx_textui = GetResourceState("esx_textui") ~= "missing",
    esx_context = GetResourceState("esx_context") ~= "missing",
}

function Core.IsResourceFound(resource)
    return Core.AddonResourcesState[resource] or error(("Resource [^5%s^1] is Missing!"):format(resource))
end
