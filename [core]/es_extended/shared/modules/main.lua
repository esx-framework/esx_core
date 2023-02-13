ESX.Module = {}
local createdModules = {}

local function Exist(key)
    return Core.Modules[key] and true or false
end

function ESX.Module:Add(key, val, overwrite)
    if not overwrite then
        if Exist(key) then
            print('[^1ERROR^7] This module already exist', key)
            return
        end
    end

    Core.Modules[key] = val
    createdModules[GetInvokingResource()] = key
end

function ESX.Module:Remove(key)
    Core.Modules[createdModules[key]] = nil
    createdModules[key] = nil
end

local function Remove(resName)
    if createdModules[resName] then
        ESX.Module:Remove(resName)
    end
end

AddEventHandler('onResourceStop', Remove)