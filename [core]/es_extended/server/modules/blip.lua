local Blip = {}

--- @param playerId number
--- @param id string
--- @param label string
--- @param sprite number
--- @param size number
--- @param color number
--- @param circle boolean
--- @param range number
--- @param temporary boolean
--- @param fadeIn boolean
function Blip:Add(playerId, id, coords, label, sprite, size, color, circle, range, temporary, fadeIn)
    TriggerClientEvent('esx_blip:Add', playerId, id, coords, label, sprite, size, color, circle, range, temporary, fadeIn)
end

--- @param playerId number
--- @param id string
--- @param fadeOut boolean
function Blip:Remove(playerId, id, fadeOut)
    TriggerClientEvent('esx_blip:Remove', playerId, id, fadeOut)
end

--- @param playerId number
--- @param id string
function Blip:SetWayPoint(playerId, id)
    TriggerClientEvent('esx_blip:SetWayPoint', playerId, id)
end

--- @param playerId number
--- @param id string
function Blip:Show(playerId, id)
    TriggerClientEvent('esx_blip:Show', playerId, id)
end

--- @param playerId number
--- @param id string
function Blip:Hide(playerId, id)
    TriggerClientEvent('esx_blip:Hide', playerId, id)
end

Core.Modules['blip'] = Blip