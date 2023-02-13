--- @param playerId string
function Core.IsPlayerAdmin(playerId)
    if (IsPlayerAceAllowed(playerId, 'command') or GetConvar('sv_lan', '') == 'true') and true or false then
        return true
    end

    local xPlayer = ESX.Players[playerId]

    if xPlayer then
        if xPlayer.group == 'admin' then
            return true
        end
    end

    return false
end
