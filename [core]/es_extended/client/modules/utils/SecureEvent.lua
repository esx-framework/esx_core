Core.Events = {}

---@param name string
---@param func function
---@return nil
function ESX.SecureNetEvent(name, func)
    local invoker = GetInvokingResource()
    local invokingResource = invoker and invoker ~= 'unknown' and invoker or 'es_extended'
    if not invokingResource then
        return
    end

    if not Core.Events[invokingResource] then
        Core.Events[invokingResource] = {}
    end

    local event = RegisterNetEvent(name, function(...)
        local source = source
        if source ~= 65535 then return end

        local success, result = pcall(func, ...)
        if not success then
            result = result or ("Unknown error occurred in event ^5%s^1"):format(name)
            error(result)
        end
    end)

    local eventIndex = #Core.Events[invokingResource] + 1
    Core.Events[invokingResource][eventIndex] = event
end

AddEventHandler("onResourceStop", function(resource)
    if Core.Events[resource] then
        for i = 1, #Core.Events[resource] do
            RemoveEventHandler(Core.Events[resource][i])
        end
    end
end)
