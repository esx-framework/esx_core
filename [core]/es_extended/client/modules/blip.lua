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
--- @param fadeIn boolean
function Blip:Add(id, coords, label, sprite, size, color, circle, range, temporary, fadeIn)
    if not id then
        print("[^1ERROR^7] ^5ESX Blips^7 ID missing!")
        return
    end

    if self:Exist(id) then
        return
    end

    if not coords then
        print("[^1ERROR^7] ^5ESX Blips^7 coords missing!")
        return
    end

    if not coords.z then coords = vec3(coords.x, coords.y, 0.0) end

    local blip = circle and AddBlipForRadius(coords.x, coords.y, coords.z, range or 100.0) or AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipColour(blip, color or 1)
    SetBlipAlpha(blip, fadeIn and 0 or 255)

    if not circle then
        SetBlipSprite(blip, sprite or 1)
        SetBlipScale(blip, size or 0.7)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(label or ('unknown ' .. id))
        EndTextCommandSetBlipName(blip)
    end

    if fadeIn then
        self:Show(id)
    end

    ESX.Blips[id] = {
        blip = blip,
        coords = coords,
        temporary = temporary,
        hidden = fadeIn and true or false
    }

    TriggerEvent('esx:blipCreated', id)
    TriggerServerEvent('esx:blipCreated', id)
end

--- @param id string
--- @param fadeOut boolean
function Blip:Remove(id, fadeOut)
    if type(id) == 'table' then
        for _, data in pairs(id) do
            if not self:Exist(data[1]) then
                print("[^1ERROR^7] ^5ESX Blips^7 blip not even exist!", id)
                return
            end

            self:Remove(data[1], data[2])
        end

        return
    end

    if not self:Exist(id) then return end

    if fadeOut then
        self:Hide(id)
        while not ESX.Blips[id].hidden do
            Wait(100)
        end
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
    if ESX.Blips[id] then return true end
    print("[^1ERROR^7] ^5ESX Blips^7 blip not exist! ID:", id)
    return false
end

--- @param id string
function Blip:Show(id)
    CreateThread(function()
        local blipAlpha = 0
        while blipAlpha ~= 2550 do
            blipAlpha = blipAlpha + 1
            if blipAlpha > 2550 then break end
            local alpha = math.floor(blipAlpha / 10)
            SetBlipAlpha(ESX.Blips[id].blip, alpha)
            Wait(1)
        end
        ESX.Blips[id].hidden = false
    end)
end

--- @param id string
function Blip:Hide(id)
    CreateThread(function()
        local blipAlpha = 2550
        while blipAlpha ~= 0 do
            blipAlpha = blipAlpha - 1
            if blipAlpha < 0 then break end
            local alpha = math.floor(blipAlpha / 10)
            SetBlipAlpha(ESX.Blips[id].blip, alpha)
            Wait(1)
        end
        ESX.Blips[id].hidden = true
    end)
end

Core.Modules['blip'] = Blip