ESX.Blips = {}
local Blip = {}

--- @param id string
--- @param label string
--- @param sprite number
--- @param size number
--- @param color number
--- @param circle boolean
--- @param range number
--- @param temporary boolean
function Blip:Add(id, coords, label, sprite, size, color, circle, range, temporary)
    if not id then
        print("[^1ERROR^7] ^5ESX Blips^7 ID missing!")
        return
    end

    if self:Exist(id) then
        print("[^1ERROR^7] ^5ESX Blips^7 blip already exist! ID:", id)
        return
    end

    if not coords then
        print("[^1ERROR^7] ^5ESX Blips^7 coords missing!")
        return
    end

    if not coords.z then coords = vec3(coords.x, coords.y, 0.0) end

    local blip = circle and AddBlipForRadius(coords.x, coords.y, coords.z, range or 100.0) or
        AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipColour(blip, color or 1)
    SetBlipAlpha(blip, 255)

    if not circle then
        SetBlipSprite(blip, sprite or 1)
        SetBlipScale(blip, size or 0.7)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(label or (GetInvokingResource() .. ' ' .. id))
        EndTextCommandSetBlipName(blip)
    end

    ESX.Blips[id] = {
        blip = blip,
        coords = coords,
        temporary = temporary
    }

    TriggerEvent('esx:blipCreated', id)
    TriggerServerEvent('esx:blipCreated', id)
end

--- @param id string
function Blip:Remove(id)
    if type(id) == 'table' then
        for _, data in pairs(id) do
            if not self:Exist(data[1]) then
                print("[^1ERROR^7] ^5ESX Blips^7 blip not exist! ID:", id)
                return
            end

            self:Remove(data[1])
        end

        return
    end

    if not self:Exist(id) then
        print("[^1ERROR^7] ^5ESX Blips^7 blip not exist! ID:", id)
        return
    end

    RemoveBlip(ESX.Blips[id].blip)
    ESX.Blips[id] = nil

    TriggerEvent('esx:blipRemoved', id)
    TriggerServerEvent('esx:blipRemoved', id)
end

--- @param id string
function Blip:SetWayPoint(id)
    if not self:Exist(id) then return end
    SetNewWaypoint(ESX.Blips[id].coords.x, ESX.Blips[id].coords.y)

    TriggerEvent('esx:waypointSet', ESX.Blips[id].coords)
    TriggerServerEvent('esx:waypointSet', ESX.Blips[id].coords)
end

--- @param id string
function Blip:Exist(id)
    if ESX.Blips[id] then
        return true
    end

    return false
end

Core.Modules['blip'] = Blip

-- Events
RegisterNetEvent('esx_blip:Add', function(...)
    Blip:Add(...)
end)

RegisterNetEvent('esx_blip:Remove', function(...)
    Blip:Remove(...)
end)

RegisterNetEvent('esx_blip:SetWayPoint', function(...)
    Blip:SetWayPoint(...)
end)