local blips = {}

function ESX.CreateBlipInternal(coords, sprite, colour, label, scale, display, shortRange, resource)
    local handle = ESX.Table.SizeOf(blips) + 1

    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipScale(blip, scale)
    SetBlipDisplay(blip, display)
    SetBlipAsShortRange(blip, shortRange)

    local TEXT_ENTRY = ("ESX_BLIP_%s"):format(handle)

    AddTextEntry(TEXT_ENTRY, label)

    BeginTextCommandSetBlipName(TEXT_ENTRY)
    EndTextCommandSetBlipName(blip)

    blips[handle] = {
        blip = blip,
        resource = resource
    }

    return handle
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

function ESX.SetBlipSprite(id, sprite)
    local blipData = blips[id]

    if blipData then
        SetBlipSprite(blipData.blip, sprite)
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
        local TEXT_ENTRY = ("ESX_BLIP_%s"):format(blipData.id)

        AddTextEntry(TEXT_ENTRY, label)

        BeginTextCommandSetBlipName(TEXT_ENTRY)
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