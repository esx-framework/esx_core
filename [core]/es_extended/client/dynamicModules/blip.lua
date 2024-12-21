-- inspired by: https://github.com/esx-framework/esx_core/pull/1490

local blips = {}

---@class ESXBlip
---@field coords vector3 Blip coordinates
---@field sprite number Blip sprite. See https://docs.fivem.net/docs/game-references/blips/#blips
---@field label string Blip display name/label
---@field color? number Blip color. See https://docs.fivem.net/docs/game-references/blips/#blip-colors
---@field scale? number Blip scale. Defaults to 1.0
---@field display? number Blip display type. Defaults to 4
---@field shortRange? boolean Is Blip short range. Defaults to true

--- Used to create static blips on the map. Blips are removed when the resource that created them is stopped.
---@param blipData ESXBlip
---@return number: The blip id. The blip can later be removed with DeleteBlip by passing the blip id as the first argument.
function CreateBlip(blipData)
    ESX.AssertType(blipData, 'table')
    ESX.AssertType(blipData.coords, 'vector3')
    ESX.AssertType(blipData.sprite, 'number')
    ESX.AssertType(blipData.label, 'string')

    local handle = ESX.Table.SizeOf(blips) + 1

    local blip = AddBlipForCoord(blipData.coords.x, blipData.coords.y, blipData.coords.z)

    SetBlipSprite(blip, blipData.sprite)
    SetBlipColour(blip, blipData.color or 1)
    SetBlipScale(blip, blipData.scale or 1.0)
    SetBlipDisplay(blip, blipData.display or 4)
    SetBlipAsShortRange(blip, blipData.shortRange or true)

    local textEntry = ("esxBlip:%s"):format(handle)

    AddTextEntry(textEntry, blipData.label)

    BeginTextCommandSetBlipName(textEntry)
    EndTextCommandSetBlipName(blip)

    blips[handle] = {
        blipHandle = blip,
        resource = GetInvokingResource()
    }

    return handle
end

---@param blipId number The blip id that is provided when creating the blip with CreateBlip
function DeleteBlip(blipId)
    local blip = blips[blipId]

    if blip then
        RemoveBlip(blip.blipHandle)
        blips[blipId] = nil
    end
end

local function onResourceStop(resourceName)
    for blipId, blipData in pairs(blips) do
        if blipData.resource == resourceName then
            DeleteBlip(blipId)
        end
    end
end
AddEventHandler('onResourceStop', onResourceStop)