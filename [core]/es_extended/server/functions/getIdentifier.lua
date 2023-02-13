function ESX.GetIdentifier(playerId)
    local fxDk = GetConvarInt('sv_fxdkMode', 0)
    if fxDk == 1 then
        return "ESX-DEBUG-LICENCE"
    end
    for k, v in ipairs(GetPlayerIdentifiers(playerId)) do
        if string.match(v, 'license:') then
            local identifier = string.gsub(v, 'license:', '')
            return identifier
        end
    end
end
