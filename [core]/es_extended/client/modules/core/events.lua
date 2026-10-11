-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@param name string
---@param func function
---@return nil
function ESX.SecureNetEvent(name, func)
    local invoker = GetInvokingResource()
    local invokingResource = invoker and invoker ~= "unknown" and invoker or "es_extended"
    if not invokingResource then
        return
    end

    Core.Events[invokingResource] = Core.Events[invokingResource] or {}

    local event = RegisterNetEvent(name, function(...)
        if source == "" then
            return
        end

        local success, result = pcall(func, ...)
        if not success then
            error(("%s"):format(result))
        end
    end)

    Core.Events[invokingResource][#Core.Events[invokingResource] + 1] = event
end

AddEventHandler("onResourceStop", function(resource)
    if not Core.Events[resource] then
        return
    end

    for i = 1, #Core.Events[resource] do
        RemoveEventHandler(Core.Events[resource][i])
    end

    Core.Events[resource] = nil
end)
