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
function Blip:Add(playerId, id, coords, label, sprite, size, color, circle, range, temporary)
    TriggerClientEvent('esx_blip:Add', playerId, id, coords, label, sprite, size, color, circle, range, temporary)
end

--- @param playerId number
--- @param id string
function Blip:Remove(playerId, id)
    TriggerClientEvent('esx_blip:Remove', playerId, id)
end

--- @param playerId number
--- @param id string
function Blip:SetWayPoint(playerId, id)
    TriggerClientEvent('esx_blip:SetWayPoint', playerId, id)
end

Core.Modules['blip'] = Blip