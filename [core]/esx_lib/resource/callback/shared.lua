--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local registeredCallbacks = {}
local resource_name = GetCurrentResourceName() --TODO: Add cache
local IS_DEBUG <const> = GetConvar("xLib:debug", "false") == "true"


AddEventHandler('onResourceStop', function(resourceName)
    if resource_name == resourceName then return end

    for callbackName, resource in pairs(registeredCallbacks) do
        if resource == resourceName then
            registeredCallbacks[callbackName] = nil
        end
    end
end)

---For internal use only.
---Sets a callback event as registered to a specific resource, preventing it from
---being overwritten. Any unknown callbacks will return an error to the caller.
---@param callbackName string
---@param isValid boolean
function xLib.setValidCallback(callbackName, isValid)
    local resourceName = GetInvokingResource() or resource_name
    local callbackResource = registeredCallbacks[callbackName]

    if callbackResource then
        if not isValid then
            registeredCallbacks[callbackName] = nil
            return
        end

        if callbackResource == resourceName then return end

        if IS_DEBUG then
            local errMessage = ("^1resource '%s' attempted to overwrite callback '%s' owned by resource '%s'^0"):format(resourceName, callbackName, callbackResource)

            print(('^1SCRIPT ERROR: %s^0\n%s'):format(errMessage,
                Citizen.InvokeNative(`FORMAT_STACK_TRACE` & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString()) or ''))
        end

        return
    end

    if IS_DEBUG then
        print(("set valid callback '%s' for resource '%s'"):format(callbackName, resourceName))
    end

    registeredCallbacks[callbackName] = resourceName
end

function xLib.isCallbackValid(callbackName)
    return registeredCallbacks[callbackName] ~= nil
end

local cbEvent = '__xLib_cb_%s'

RegisterNetEvent('xLib:validateCallback', function(callbackName, invokingResource, key)
    if registeredCallbacks[callbackName] then return end

    local event = cbEvent:format(invokingResource)

    if GetGameName() == 'fxserver' then
        return TriggerClientEvent(event, source, key, 'cb_invalid')
    end

    TriggerServerEvent(event, key, 'cb_invalid')
end)
