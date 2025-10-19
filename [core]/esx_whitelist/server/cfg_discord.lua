---@diagnostic disable: undefined-global, need-check-nil, param-type-mismatch

Config.DiscordBotToken = "YOUR_DISCORD_BOT_TOKEN_HERE"

function IsValidBotToken(token)
    if not token or token == '' or #token < 50 or not string.match(token, '%.') then
        return false
    end
    
    local invalid = { 
        'TU_TOKEN_AQUI', 
        'YOUR_TOKEN_HERE', 
        'YOUR_BOT_TOKEN', 
        'DISCORD_BOT_TOKEN', 
        'YOUR_DISCORD_BOT_TOKEN_HERE' 
    }
    
    for _, v in ipairs(invalid) do
        if token == v then return false end
    end
    
    return true
end

function GetPlayerDiscord(src)
    if not Names[src] then
        local discord = nil
        
        for i = 0, GetNumPlayerIdentifiers(src) - 1 do
            local license = GetPlayerIdentifier(src, i)
            if string.sub(license, 1, string.len("discord:")) == "discord:" then
                discord = license
                break
            end
        end
        
        local name = nil
        
        if discord then
            discord = string.sub(discord, 9, string.len(discord))
            local p = promise.new()
            
            PerformHttpRequest("https://discordapp.com/api/users/" .. discord, function(statusCode, data)
                if statusCode == 200 then
                    data = json.decode(data or "{}")
                    if data.global_name then
                        name = data.global_name
                    end
                end
                p:resolve()
            end, "GET", "", {
                Authorization = "Bot " .. Config.DiscordBotToken
            })
            
            Citizen.Await(p)
        end
        
        Names[src] = name or "Unknown"
    end
    return Names[src]
end