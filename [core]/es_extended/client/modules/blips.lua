local blips = {}

function ESX.CreateBlipInternal(coords, sprite, colour, label, scale, display, shortRange, resource)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipScale(blip, scale)
    SetBlipDisplay(blip, display)
    SetBlipAsShortRange(blip, shortRange)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)

    local handle = ESX.Table.SizeOf(blips) + 1
	blips[handle] = {
        blip = blip,
        resource = resource
    }

    return id
end

function ESX.RemoveBlip(id)
    local blipData = blips[id]

    if blipData then
        RemoveBlip(blipData.blip)

        blips[id] = nil
    end
end

function ESX.SetBlipCoords(id, coords)
    local blipData = blips[id]

    if blipData then 
        SetBlipCoords(blipData.blip, coords.xyz)
    end
end

function ESX.SetBlipColour(id, colour)
    local blipData = blips[id]

    if blipData then 
        SetBlipColour(blipData.blip, colour)
    end
end

function ESX.SetBlipLabel(id, label)
    local blipData = blips[id]

    if blipData then 
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(label)
        EndTextCommandSetBlipName(blipData.blip)
    end
end

function ESX.SetBlipScale(id, scale)
    local blipData = blips[id]

    if blipData then 
        SetBlipScale(blipData.blip, scale)
    end
end

function ESX.SetBlipDisplay(id, display)
    local blipData = blips[id]

    if blipData then 
        SetBlipDisplay(blipData.blip, display)
    end
end

function ESX.SetBlipShortRange(id, shortRange)
    local blipData = blips[id]

    if blipData then 
        SetBlipAsShortRange(blipData.blip, shortRange)
    end
end

AddEventHandler("onResourceStop", function(resource)
    for id, blip in pairs(blips) do
        if blip.resource == resource then
            ESX.RemoveBlip(id)
        end
    end
end)