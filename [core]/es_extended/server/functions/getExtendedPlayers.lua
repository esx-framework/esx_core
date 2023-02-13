function ESX.GetExtendedPlayers(key, val)
    local xPlayers = {}
    for k, v in pairs(ESX.Players) do
        if key then
            if (key == 'job' and v.job.name == val) or v[key] == val then
                xPlayers[#xPlayers + 1] = v
            end
        else
            xPlayers[#xPlayers + 1] = v
        end
    end
    return xPlayers
end