Config.DiscordBotToken = "YOUR_DISCORD_BOT_TOKEN_HERE"

local function IsValidBotToken(token)
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
    
    for i = 1, #invalid do
        if token == invalid[i] then
            return false
        end
    end
    
    return true
end

local function GetPlayerDiscord(src)
    local discordId = GetPlayerIdentifierByType(src, 'discord')
    
    if not discordId then
        return 'Unknown'
    end
    
    discordId = discordId:gsub('discord:', '')
    
    local promise = promise.new()
    local name = nil
    
    PerformHttpRequest("https://discordapp.com/api/users/" .. discordId, function(statusCode, data)
        if statusCode == 200 then
            local decoded = json.decode(data or "{}")
            if decoded and decoded.global_name then
                name = decoded.global_name
            end
        end
        promise:resolve()
    end, "GET", "", {
        Authorization = "Bot " .. Config.DiscordBotToken
    })
    
    Citizen.Await(promise)
    
    return name or 'Unknown'
end

_G.IsValidBotToken = IsValidBotToken
_G.GetPlayerDiscord = GetPlayerDiscord