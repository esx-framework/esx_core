Whitelist = {
    Enabled = false,
    GracePeriod = 60,
    KickConnected = false,
    DiscordWebhook = '',
    DiscordEnabled = false,
    DiscordGuildId = '',
    DiscordRoleId = '',
    DiscordBotToken = Config.DiscordBotToken or '',
    Rules = {},
    GracePeriodPlayers = {},
    ManualOverride = false,
    Cache = {}
}

local ruleChangeDebounce = false
local configFile = 'whitelist_config.json'
local webhookCooldown = {}

local DefaultConfig = {
    whitelistEnabled = false,
    gracePeriod = 60,
    kickConnected = false,
    discordWebhook = '',
    discordEnabled = false,
    discordGuildId = '',
    discordRoleId = '',
    rules = {
        {
            id = '1',
            type = 'admin-presence',
            enabled = false,
            priority = 1,
            operator = '<',
            value = 1,
            action = 'enable'
        },
        {
            id = '2',
            type = 'player-count',
            enabled = false,
            priority = 2,
            operator = '>',
            value = 32,
            action = 'enable'
        },
        {
            id = '3',
            type = 'scheduled',
            enabled = false,
            priority = 3,
            startTime = '03:00',
            endTime = '08:00'
        }
    }
}

local function IsPlayerAdmin(source)
    if not source or source == 0 then return true end
    
    local xPlayer = ESX.Player(source)
    if not xPlayer then return false end
    
    local group = xPlayer.getGroup()
    for i = 1, #Config.AdminGroups do
        if group == Config.AdminGroups[i] then
            return true
        end
    end
    
    return false
end

function GetPlayerIdentifiersFiltered(source)
    local identifiers = {}
    local license = GetPlayerIdentifierByType(source, 'license')
    local license2 = GetPlayerIdentifierByType(source, 'license2')
    local steam = GetPlayerIdentifierByType(source, 'steam')
    local discord = GetPlayerIdentifierByType(source, 'discord')
    local xbl = GetPlayerIdentifierByType(source, 'xbl')
    local fivem = GetPlayerIdentifierByType(source, 'fivem')
    
    if license then table.insert(identifiers, 'license:' .. license) end
    if license2 then table.insert(identifiers, 'license2:' .. license2) end
    if steam then table.insert(identifiers, 'steam:' .. steam) end
    if discord then table.insert(identifiers, 'discord:' .. discord) end
    if xbl then table.insert(identifiers, 'xbl:' .. xbl) end
    if fivem then table.insert(identifiers, 'fivem:' .. fivem) end
    
    return identifiers
end

function BuildIdentifierQuery(identifiers)
    local conditions, params = {}, {}
    for i = 1, #identifiers do
        table.insert(conditions, 'wi.identifier = ?')
        table.insert(params, identifiers[i])
    end
    return table.concat(conditions, ' OR '), params
end

local function SendDiscordLog(message, color)
    if not Whitelist.DiscordWebhook or Whitelist.DiscordWebhook == '' or Whitelist.DiscordWebhook == '***CONFIGURED***' then return end
    if not message or message == '' then return end
    
    local currentTime = GetGameTimer()
    if webhookCooldown[message] and currentTime - webhookCooldown[message] < 5000 then return end
    webhookCooldown[message] = currentTime
    
    PerformHttpRequest(Whitelist.DiscordWebhook, function() end, 'POST', json.encode({
        embeds = {{
            title = _U('discord_title'),
            description = message,
            color = color or 3447003,
            timestamp = os.date('!%Y-%m-%dT%H:%M:%S')
        }}
    }), {['Content-Type'] = 'application/json'})
end

local function UpdateWhitelistCache()
    MySQL.query('SELECT DISTINCT w.id, wi.identifier FROM whitelist w JOIN whitelist_identifiers wi ON w.id = wi.whitelist_id WHERE CAST(w.whitelisted AS UNSIGNED) = 1', {}, function(results)
        Whitelist.Cache = {}
        for i = 1, #results do
            Whitelist.Cache[results[i].identifier] = results[i].id
        end
    end)
end

local function StartGracePeriod(source, playerName)
    if not source or source == 0 then return end
    if Whitelist.GracePeriod <= 0 then
        DropPlayer(source, _U('kick_message'))
        return
    end
    
    Whitelist.GracePeriodPlayers[source] = {
        endTime = os.time() + Whitelist.GracePeriod,
        playerName = playerName
    }
    
    TriggerClientEvent('esx_whitelist:startGracePeriod', source, Whitelist.GracePeriod)
    
    CreateThread(function()
        Wait(Whitelist.GracePeriod * 1000)
        if Whitelist.GracePeriodPlayers[source] then
            if IsPlayerAdmin(source) then
                Whitelist.GracePeriodPlayers[source] = nil
                return
            end
            DropPlayer(source, _U('kick_message'))
            Whitelist.GracePeriodPlayers[source] = nil
        end
    end)
end

function KickNonWhitelistedPlayers()
    local players = ESX.GetExtendedPlayers()
    for i = 1, #players do
        local xPlayer = players[i]
        if xPlayer and xPlayer.source and not IsPlayerAdmin(xPlayer.source) then
            local hasWhitelist = false
            local identifiers = GetPlayerIdentifiersFiltered(xPlayer.source)
            
            for j = 1, #identifiers do
                if Whitelist.Cache[identifiers[j]] then
                    hasWhitelist = true
                    break
                end
            end
            
            if not hasWhitelist then
                if Whitelist.KickConnected then
                    DropPlayer(xPlayer.source, _U('kick_message'))
                else
                    StartGracePeriod(xPlayer.source, xPlayer.getName())
                end
            end
        end
    end
end

function SaveConfig()
    local data = {
        whitelistEnabled = Whitelist.Enabled,
        gracePeriod = Whitelist.GracePeriod,
        kickConnected = Whitelist.KickConnected,
        discordWebhook = Whitelist.DiscordWebhook,
        discordEnabled = Whitelist.DiscordEnabled,
        discordGuildId = Whitelist.DiscordGuildId,
        discordRoleId = Whitelist.DiscordRoleId,
        rules = Whitelist.Rules
    }
    SaveResourceFile(GetCurrentResourceName(), configFile, json.encode(data, {indent = true}), -1)
end

local function LoadConfig()
    local configData = LoadResourceFile(GetCurrentResourceName(), configFile)
    
    if not configData then
        Whitelist.Enabled = DefaultConfig.whitelistEnabled
        Whitelist.GracePeriod = DefaultConfig.gracePeriod
        Whitelist.KickConnected = DefaultConfig.kickConnected
        Whitelist.DiscordWebhook = DefaultConfig.discordWebhook
        Whitelist.DiscordEnabled = DefaultConfig.discordEnabled
        Whitelist.DiscordGuildId = DefaultConfig.discordGuildId
        Whitelist.DiscordRoleId = DefaultConfig.discordRoleId
        Whitelist.Rules = DefaultConfig.rules
        SaveConfig()
        return true
    end
    
    local success, data = pcall(json.decode, configData)
    
    if not success or not data then
        if Config.Debug then
            print('Whitelist config file corrupted, regenerating with defaults')
        end
        Whitelist.Enabled = DefaultConfig.whitelistEnabled
        Whitelist.GracePeriod = DefaultConfig.gracePeriod
        Whitelist.KickConnected = DefaultConfig.kickConnected
        Whitelist.DiscordWebhook = DefaultConfig.discordWebhook
        Whitelist.DiscordEnabled = DefaultConfig.discordEnabled
        Whitelist.DiscordGuildId = DefaultConfig.discordGuildId
        Whitelist.DiscordRoleId = DefaultConfig.discordRoleId
        Whitelist.Rules = DefaultConfig.rules
        SaveConfig()
        return true
    end
    
    Whitelist.Enabled = data.whitelistEnabled or DefaultConfig.whitelistEnabled
    Whitelist.GracePeriod = data.gracePeriod or DefaultConfig.gracePeriod
    Whitelist.KickConnected = data.kickConnected or DefaultConfig.kickConnected
    Whitelist.DiscordWebhook = data.discordWebhook or DefaultConfig.discordWebhook
    Whitelist.DiscordEnabled = data.discordEnabled or DefaultConfig.discordEnabled
    Whitelist.DiscordGuildId = data.discordGuildId or DefaultConfig.discordGuildId
    Whitelist.DiscordRoleId = data.discordRoleId or DefaultConfig.discordRoleId
    Whitelist.Rules = data.rules or DefaultConfig.rules
    
    return true
end

local function evaluateWhitelistRules()
    local activeRules = {}
    for i = 1, #Whitelist.Rules do
        if Whitelist.Rules[i].enabled then
            table.insert(activeRules, Whitelist.Rules[i])
        end
    end
    
    table.sort(activeRules, function(a, b) return a.priority < b.priority end)
    
    for i = 1, #activeRules do
        local rule = activeRules[i]
        
        if rule.type == 'admin-presence' then
            local adminCount = 0
            local players = ESX.GetExtendedPlayers()
            for j = 1, #players do
                if players[j] and players[j].source and IsPlayerAdmin(players[j].source) then
                    adminCount = adminCount + 1
                end
            end
            
            local conditionMet = false
            if rule.operator == '<' then conditionMet = adminCount < rule.value
            elseif rule.operator == '>' then conditionMet = adminCount > rule.value
            elseif rule.operator == '>=' then conditionMet = adminCount >= rule.value
            elseif rule.operator == '==' then conditionMet = adminCount == rule.value
            end
            
            if conditionMet then return rule.action == 'enable' end
            
        elseif rule.type == 'player-count' then
            local playerCount = #ESX.GetExtendedPlayers()
            
            local conditionMet = false
            if rule.operator == '<' then conditionMet = playerCount < rule.value
            elseif rule.operator == '>' then conditionMet = playerCount > rule.value
            elseif rule.operator == '>=' then conditionMet = playerCount >= rule.value
            elseif rule.operator == '==' then conditionMet = playerCount == rule.value
            end
            
            if conditionMet then return rule.action == 'enable' end
            
        elseif rule.type == 'scheduled' then
            local currentMinutes = tonumber(os.date('%H')) * 60 + tonumber(os.date('%M'))
            local startHour, startMin = rule.startTime:match('(%d+):(%d+)')
            local startMinutes = tonumber(startHour) * 60 + tonumber(startMin)
            local endHour, endMin = rule.endTime:match('(%d+):(%d+)')
            local endMinutes = tonumber(endHour) * 60 + tonumber(endMin)
            
            local inRange
            if startMinutes <= endMinutes then
                inRange = currentMinutes >= startMinutes and currentMinutes <= endMinutes
            else
                inRange = currentMinutes >= startMinutes or currentMinutes <= endMinutes
            end
            
            return inRange
        end
    end
    
    return Whitelist.Enabled
end

local function handleRuleChange()
    if Whitelist.ManualOverride or ruleChangeDebounce then return end
    ruleChangeDebounce = true
    
    local newState = evaluateWhitelistRules()
    if newState ~= Whitelist.Enabled then
        Whitelist.Enabled = newState
        
        if Whitelist.Enabled then
            SendDiscordLog(_U('whitelist_enabled_auto'), 15158332)
            KickNonWhitelistedPlayers()
        else
            SendDiscordLog(_U('whitelist_disabled_auto'), 3066993)
            for playerSource in pairs(Whitelist.GracePeriodPlayers) do
                if playerSource and playerSource ~= 0 then
                    Whitelist.GracePeriodPlayers[playerSource] = nil
                    TriggerClientEvent('esx_whitelist:cancelGracePeriod', playerSource)
                end
            end
        end
        
        TriggerClientEvent('esx_whitelist:stateChanged', -1, Whitelist.Enabled)
        SaveConfig()
    end
    
    SetTimeout(5000, function()
        ruleChangeDebounce = false
    end)
end

local function checkDiscordRole(discordId, callback)
    if not Whitelist.DiscordEnabled or Whitelist.DiscordGuildId == '' or Whitelist.DiscordRoleId == '' or not IsValidBotToken(Whitelist.DiscordBotToken) then
        callback(false)
        return
    end
    
    PerformHttpRequest(string.format('https://discord.com/api/v10/guilds/%s/members/%s', Whitelist.DiscordGuildId, discordId), 
    function(statusCode, data)
        if statusCode == 200 then
            local member = json.decode(data)
            if member and member.roles then
                for i = 1, #member.roles do
                    if member.roles[i] == Whitelist.DiscordRoleId then
                        callback(true)
                        return
                    end
                end
            end
        end
        callback(false)
    end, 'GET', '', {
        ['Authorization'] = 'Bot ' .. Whitelist.DiscordBotToken,
        ['Content-Type'] = 'application/json'
    })
end

local function DetectIdentifierType(value)
    if not value or value == '' then return nil end
    
    value = value:gsub("%s+", "")
    value = value:gsub("^%w+:", "")
    
    local len = #value
    
    if value:find("^[0-9a-fA-F]+%-[0-9a-fA-F]+%-[0-9a-fA-F]+%-[0-9a-fA-F]+%-[0-9a-fA-F]+$") and len == 36 then
        return "license2"
    end
    
    if value:find("^[0-9a-fA-F]+$") and len == 40 then
        return "license"
    end
    
    if value:find("^%d+$") then
        if len >= 17 and len <= 19 then
            return "discord"
        elseif len == 16 then
            return "xbl"
        elseif len >= 6 and len <= 8 then
            return "fivem"
        end
    end
    
    if value:find("^[0-9a-fA-F]+$") and len >= 15 and len <= 17 then
        return "steam"
    end
    
    return nil
end

function NormalizeIdentifier(rawValue)
    if not rawValue or rawValue == '' then return nil, nil end
    
    local cleanValue = rawValue:gsub("%s+", "")
    local providedPrefix, providedValue = cleanValue:match("^(%w+):(.+)$")
    local valueToDetect = providedValue or cleanValue
    local detectedType = DetectIdentifierType(valueToDetect)
    
    if not detectedType then return nil, nil end
    
    return detectedType, valueToDetect
end

function GetAllPlayerIdentifiers(singleIdentifier, callback)
    local idType, idValue = NormalizeIdentifier(singleIdentifier)
    
    if not idType or not idValue then
        callback({}, nil, false)
        return
    end
    
    local fullIdentifier = idType .. ':' .. idValue
    
    local players = ESX.GetExtendedPlayers()
    for i = 1, #players do
        if players[i] and players[i].source then
            local identifiers = GetPlayerIdentifiersFiltered(players[i].source)
            for j = 1, #identifiers do
                if identifiers[j] == fullIdentifier then
                    local playerName = GetPlayerName(players[i].source) or players[i].getName()
                    callback(identifiers, playerName, true)
                    return
                end
            end
        end
    end
    
    MySQL.query([[
        SELECT wi.identifier, w.player_name 
        FROM whitelist_identifiers wi
        JOIN whitelist w ON w.id = wi.whitelist_id
        WHERE wi.whitelist_id = (
            SELECT whitelist_id FROM whitelist_identifiers WHERE identifier = ? LIMIT 1
        )
    ]], {fullIdentifier}, function(results)
        if results and #results > 0 then
            local allIdentifiers = {}
            for i = 1, #results do
                table.insert(allIdentifiers, results[i].identifier)
            end
            callback(allIdentifiers, results[1].player_name, false)
        else
            callback({fullIdentifier}, nil, false)
        end
    end)
end

function NotifyOnlinePlayer(fullIdentifier)
    local players = ESX.GetExtendedPlayers()
    for i = 1, #players do
        if players[i] and players[i].source then
            local onlineIdentifiers = GetPlayerIdentifiersFiltered(players[i].source)
            for j = 1, #onlineIdentifiers do
                if onlineIdentifiers[j] == fullIdentifier then
                    players[i].showNotification('~g~' .. _U('added_to_whitelist'))
                    if Whitelist.GracePeriodPlayers[players[i].source] then
                        Whitelist.GracePeriodPlayers[players[i].source] = nil
                        TriggerClientEvent('esx_whitelist:cancelGracePeriod', players[i].source)
                    end
                    return
                end
            end
        end
    end
end

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local source = source
    if not source or source == 0 then return end
    
    deferrals.defer()
    Wait(0)
    
    deferrals.update(_U('checking_whitelist'))
    
    local realPlayerName = GetPlayerName(source) or playerName
    local identifiers = GetPlayerIdentifiersFiltered(source)
    
    if #identifiers == 0 then
        deferrals.done(_U('kick_message'))
        return
    end
    
    Wait(500)
    
    local conditions, params = BuildIdentifierQuery(identifiers)
    local query = 'SELECT DISTINCT w.id, w.player_name, CAST(w.whitelisted AS UNSIGNED) as whitelisted FROM whitelist w JOIN whitelist_identifiers wi ON w.id = wi.whitelist_id WHERE ' .. conditions
    
    MySQL.query(query, params, function(result)
        local whitelistId
        local existsInDB = result and #result > 0
        
        if existsInDB then
            whitelistId = result[1].id
            
            local queries = {}
            for i = 1, #identifiers do
                local idType = identifiers[i]:match("^(%w+):")
                if idType then
                    table.insert(queries, {
                        query = 'INSERT INTO whitelist_identifiers (whitelist_id, type, identifier) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE whitelist_id = VALUES(whitelist_id)',
                        values = {whitelistId, idType, identifiers[i]}
                    })
                end
            end
            
            if #queries > 0 then
                MySQL.transaction(queries)
            end
            
            MySQL.update('UPDATE whitelist SET player_name = ? WHERE id = ?', {realPlayerName, whitelistId})
        else
            MySQL.insert('INSERT INTO whitelist (player_name, whitelisted) VALUES (?, ?)', {realPlayerName, 0}, function(insertId)
                whitelistId = insertId
                if whitelistId then
                    local queries = {}
                    for i = 1, #identifiers do
                        local idType = identifiers[i]:match("^(%w+):")
                        if idType then
                            table.insert(queries, {
                                query = 'INSERT INTO whitelist_identifiers (whitelist_id, type, identifier) VALUES (?, ?, ?)',
                                values = {whitelistId, idType, identifiers[i]}
                            })
                        end
                    end
                    
                    if #queries > 0 then
                        MySQL.transaction(queries)
                    end
                end
            end)
            Wait(500)
        end
        
        if not Whitelist.Enabled then
            deferrals.done()
            return
        end
        
        if Whitelist.DiscordEnabled then
            local discordId = GetPlayerIdentifierByType(source, 'discord')
            
            if not discordId then
                deferrals.done(_U('kick_message'))
                return
            end
            
            discordId = discordId:gsub('discord:', '')
            
            checkDiscordRole(discordId, function(hasRole)
                if hasRole then
                    MySQL.update('UPDATE whitelist SET whitelisted = 1 WHERE id = ?', {whitelistId}, function()
                        for i = 1, #identifiers do
                            Whitelist.Cache[identifiers[i]] = whitelistId
                        end
                    end)
                    deferrals.done()
                else
                    MySQL.update('UPDATE whitelist SET whitelisted = 0 WHERE id = ?', {whitelistId}, function()
                        for i = 1, #identifiers do
                            Whitelist.Cache[identifiers[i]] = nil
                        end
                    end)
                    deferrals.done(_U('kick_message'))
                end
            end)
        else
            if existsInDB and tonumber(result[1].whitelisted) == 1 then
                for i = 1, #identifiers do
                    Whitelist.Cache[identifiers[i]] = whitelistId
                end
                deferrals.done()
            else
                deferrals.done(_U('kick_message'))
            end
        end
    end)
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer, isNew)
    handleRuleChange()
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
    if Whitelist.GracePeriodPlayers[playerId] then
        Whitelist.GracePeriodPlayers[playerId] = nil
    end
    Wait(1000)
    handleRuleChange()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    LoadConfig()
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS whitelist (
            id INT AUTO_INCREMENT PRIMARY KEY,
            player_name VARCHAR(255) COLLATE utf8mb4_unicode_ci,
            whitelisted TINYINT(1) NOT NULL DEFAULT 0,
            added_by VARCHAR(255) COLLATE utf8mb4_unicode_ci,
            added_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_whitelisted (whitelisted)
        )
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS whitelist_identifiers (
            id INT AUTO_INCREMENT PRIMARY KEY,
            whitelist_id INT NOT NULL,
            type ENUM('steam', 'license', 'license2', 'discord', 'xbl', 'fivem', 'ip') NOT NULL,
            identifier VARCHAR(255) NOT NULL COLLATE utf8mb4_bin,
            FOREIGN KEY (whitelist_id) REFERENCES whitelist(id) ON DELETE CASCADE,
            UNIQUE (type, identifier),
            INDEX idx_identifier (identifier)
        )
    ]])
    
    Wait(1000)
    UpdateWhitelistCache()
    
    local status = Whitelist.Enabled and 'enabled' or 'disabled'
    print('Whitelist system started - Status: ' .. status .. ' - Grace period: ' .. Whitelist.GracePeriod .. 's')
    
    if Whitelist.DiscordEnabled and IsValidBotToken(Whitelist.DiscordBotToken) then
        print('Discord role verification is active')
    end
    
    CreateThread(function()
        while true do
            Wait(30000)
            handleRuleChange()
        end
    end)
    
    if Whitelist.Enabled then
        Wait(5000)
        KickNonWhitelistedPlayers()
    end
end)

ESX.RegisterServerCallback('esx_whitelist:getConfig', function(source, cb)
    if not source or source == 0 or not IsPlayerAdmin(source) then
        cb(nil)
        return
    end
    
    local file = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. Config.Locale .. '.json')
    local localeTranslations = file and json.decode(file) or {}
    
    cb({
        whitelistEnabled = Whitelist.Enabled,
        gracePeriod = Whitelist.GracePeriod,
        kickConnected = Whitelist.KickConnected,
        discordWebhook = Whitelist.DiscordWebhook ~= '' and '***CONFIGURED***' or '',
        discordEnabled = Whitelist.DiscordEnabled,
        discordGuildId = Whitelist.DiscordGuildId,
        discordRoleId = Whitelist.DiscordRoleId,
        rules = Whitelist.Rules,
        locale = Config.Locale,
        translations = localeTranslations,
        hasBotToken = Whitelist.DiscordEnabled and IsValidBotToken(Whitelist.DiscordBotToken)
    })
end)

ESX.RegisterServerCallback('esx_whitelist:getWhitelistEntries', function(source, cb)
    if not source or source == 0 or not IsPlayerAdmin(source) then
        cb({})
        return
    end
    
    MySQL.query([[
        SELECT w.id, w.player_name, CAST(w.whitelisted AS UNSIGNED) as whitelisted,
               GROUP_CONCAT(wi.identifier SEPARATOR '|') as identifiers
        FROM whitelist w
        LEFT JOIN whitelist_identifiers wi ON w.id = wi.whitelist_id
        GROUP BY w.id
        ORDER BY w.whitelisted DESC, w.id ASC
    ]], {}, function(results)
        if not results then
            cb({})
            return
        end
        
        local entries = {}
        for i = 1, #results do
            local row = results[i]
            local identifiers = {}
            if row.identifiers then
                for identifier in string.gmatch(row.identifiers, '[^|]+') do
                    table.insert(identifiers, identifier)
                end
            end
            
            table.insert(entries, {
                id = row.id,
                identifiers = identifiers,
                playerName = row.player_name or 'Unknown',
                whitelisted = row.whitelisted
            })
        end
        
        cb(entries)
    end)
end)

ESX.RegisterServerCallback('esx_whitelist:updateConfig', function(source, cb, config)
    local playerSource = source
    if not playerSource or playerSource == 0 or not IsPlayerAdmin(playerSource) then
        cb(false)
        return
    end
    
    if config.discordEnabled and not IsValidBotToken(Whitelist.DiscordBotToken) then
        TriggerClientEvent('esx:showNotification', playerSource, '~r~Discord bot token not configured')
        cb(false)
        return
    end
    
    if config.discordEnabled and (not config.discordGuildId or config.discordGuildId == '' or not config.discordRoleId or config.discordRoleId == '') then
        TriggerClientEvent('esx:showNotification', playerSource, '~r~Discord configuration incomplete')
        cb(false)
        return
    end
    
    local oldState = Whitelist.Enabled
    local xPlayer = ESX.Player(playerSource)
    local playerName = xPlayer and xPlayer.getName() or 'Unknown'
    
    if config.discordWebhook and config.discordWebhook ~= '' and config.discordWebhook ~= '***CONFIGURED***' then
        if string.match(config.discordWebhook, '^https://discord.com/api/webhooks/') or 
           string.match(config.discordWebhook, '^https://discordapp.com/api/webhooks/') then
            Whitelist.DiscordWebhook = config.discordWebhook
        end
    end
    
    Whitelist.Enabled = config.whitelistEnabled
    Whitelist.GracePeriod = config.gracePeriod
    Whitelist.KickConnected = config.kickConnected
    Whitelist.DiscordEnabled = config.discordEnabled
    Whitelist.DiscordGuildId = config.discordGuildId
    Whitelist.DiscordRoleId = config.discordRoleId
    Whitelist.Rules = config.rules
    Whitelist.ManualOverride = false
    
    SaveConfig()
    
    if Whitelist.Enabled and not oldState then
        SendDiscordLog(string.format('Whitelist enabled by %s', playerName), 15158332)
        Wait(2000)
        KickNonWhitelistedPlayers()
    elseif not Whitelist.Enabled and oldState then
        SendDiscordLog(string.format('Whitelist disabled by %s', playerName), 3066993)
        for src in pairs(Whitelist.GracePeriodPlayers) do
            if src and src ~= 0 then
                Whitelist.GracePeriodPlayers[src] = nil
                TriggerClientEvent('esx_whitelist:cancelGracePeriod', src)
            end
        end
    end
    
    TriggerClientEvent('esx_whitelist:stateChanged', -1, Whitelist.Enabled)
    TriggerClientEvent('esx:showNotification', playerSource, '~g~Configuration saved')
    cb(true)
end)

ESX.RegisterServerCallback('esx_whitelist:testWebhook', function(source, cb)
    local playerSource = source
    if not playerSource or playerSource == 0 or not IsPlayerAdmin(playerSource) then
        cb(false)
        return
    end
    
    local xPlayer = ESX.Player(playerSource)
    local playerName = xPlayer and xPlayer.getName() or 'Unknown'
    SendDiscordLog(string.format('Webhook test by %s', playerName), 3447003)
    cb(true)
end)

ESX.RegisterServerCallback('esx_whitelist:managePlayer', function(source, cb, data)
    local playerSource = source
    if not playerSource or playerSource == 0 then
        cb(false, 'No permission')
        return
    end
    
    if not IsPlayerAdmin(playerSource) then
        cb(false, 'No permission')
        return
    end
    
    local xPlayer = ESX.Player(playerSource)
    if not xPlayer then
        cb(false, 'Error getting player data')
        return
    end
    
    local adminIdentifier = xPlayer.getIdentifier()
    if not adminIdentifier then
        cb(false, 'Error getting admin identifier')
        return
    end
    
    local rawIdentifier = data.identifier
    local action = data.action
    
    if not rawIdentifier or rawIdentifier == '' then
        cb(false, 'Invalid identifier')
        return
    end
    
    local identifierType, identifierValue = NormalizeIdentifier(rawIdentifier)
    
    if not identifierType or not identifierValue then
        cb(false, 'Invalid identifier format')
        return
    end
    
    if identifierType == 'ip' then
        cb(false, 'IP identifiers not allowed')
        return
    end
    
    local fullIdentifier = identifierType .. ':' .. identifierValue
    
    if action == 'add' then
        GetAllPlayerIdentifiers(fullIdentifier, function(allIdentifiers, existingPlayerName, isOnline)
            local playerName = existingPlayerName or 'Pending...'
            
            MySQL.query('SELECT w.id, w.whitelisted FROM whitelist w JOIN whitelist_identifiers wi ON w.id = wi.whitelist_id WHERE wi.identifier = ?', {fullIdentifier}, function(result)
                if result and #result > 0 then
                    if result[1].whitelisted == 1 then
                        cb(false, 'Player already whitelisted')
                        return
                    end
                    
                    MySQL.update('UPDATE whitelist SET whitelisted = 1, added_by = ?, player_name = ? WHERE id = ?', {
                        adminIdentifier, playerName, result[1].id
                    }, function(affectedRows)
                        local queries = {}
                        for i = 1, #allIdentifiers do
                            local idType = allIdentifiers[i]:match("^(%w+):")
                            if idType then
                                table.insert(queries, {
                                    query = 'INSERT INTO whitelist_identifiers (whitelist_id, type, identifier) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE whitelist_id = VALUES(whitelist_id)',
                                    values = {result[1].id, idType, allIdentifiers[i]}
                                })
                            end
                        end
                        
                        if #queries > 0 then
                            MySQL.transaction(queries, function(success)
                                if success then
                                    for i = 1, #allIdentifiers do
                                        Whitelist.Cache[allIdentifiers[i]] = result[1].id
                                    end
                                end
                            end)
                        end
                        
                        SendDiscordLog(string.format('%s added %s to whitelist', xPlayer.getName(), playerName .. ' (' .. identifierType .. ')'), 3066993)
                        
                        if isOnline then
                            NotifyOnlinePlayer(fullIdentifier)
                        end
                        
                        cb(true, 'Player added successfully')
                    end)
                else
                    MySQL.insert('INSERT INTO whitelist (player_name, whitelisted, added_by) VALUES (?, ?, ?)', {
                        playerName, 1, adminIdentifier
                    }, function(insertId)
                        if insertId then
                            local queries = {}
                            for i = 1, #allIdentifiers do
                                local idType = allIdentifiers[i]:match("^(%w+):")
                                if idType then
                                    table.insert(queries, {
                                        query = 'INSERT INTO whitelist_identifiers (whitelist_id, type, identifier) VALUES (?, ?, ?)',
                                        values = {insertId, idType, allIdentifiers[i]}
                                    })
                                end
                            end
                            
                            if #queries > 0 then
                                MySQL.transaction(queries, function(success)
                                    if success then
                                        for i = 1, #allIdentifiers do
                                            Whitelist.Cache[allIdentifiers[i]] = insertId
                                        end
                                    end
                                end)
                            end
                            
                            SendDiscordLog(string.format('%s added %s to whitelist', xPlayer.getName(), playerName .. ' (' .. identifierType .. ')'), 3066993)
                            
                            if isOnline then
                                NotifyOnlinePlayer(fullIdentifier)
                            end
                            
                            cb(true, 'Player added successfully')
                        else
                            cb(false, 'Error inserting into database')
                        end
                    end)
                end
            end)
        end)
        
    elseif action == 'remove' then
        MySQL.query('SELECT w.id, w.whitelisted FROM whitelist w JOIN whitelist_identifiers wi ON w.id = wi.whitelist_id WHERE wi.identifier = ?', {fullIdentifier}, function(result)
            if not result or #result == 0 or result[1].whitelisted == 0 then
                cb(false, 'Player not in whitelist')
                return
            end
            
            MySQL.update('UPDATE whitelist SET whitelisted = 0 WHERE id = ?', {result[1].id}, function(affectedRows)
                MySQL.query('SELECT identifier FROM whitelist_identifiers WHERE whitelist_id = ?', {result[1].id}, function(identifiers)
                    for i = 1, #identifiers do
                        Whitelist.Cache[identifiers[i].identifier] = nil
                    end
                    
                    SendDiscordLog(string.format('%s removed %s from whitelist', xPlayer.getName(), fullIdentifier), 15158332)
                    cb(true, 'Player removed successfully')
                end)
            end)
        end)
    else
        cb(false, 'Invalid action')
    end
end)


ESX.RegisterServerCallback('esx_whitelist:toggleWhitelistStatus', function(source, cb, data)
    local playerSource = source
    if not playerSource or playerSource == 0 or not IsPlayerAdmin(playerSource) then
        cb(false)
        return
    end
    
    local xPlayer = ESX.Player(playerSource)
    local playerName = xPlayer and xPlayer.getName() or 'Unknown'
    
    MySQL.update('UPDATE whitelist SET whitelisted = ? WHERE id = ?', {data.status, data.id}, function(affectedRows)
        MySQL.query('SELECT identifier FROM whitelist_identifiers WHERE whitelist_id = ?', {data.id}, function(result)
            if result and #result > 0 then
                for i = 1, #result do
                    if data.status == 1 then
                        Whitelist.Cache[result[i].identifier] = data.id
                    else
                        Whitelist.Cache[result[i].identifier] = nil
                    end
                end
            end
            
            local action = data.status == 1 and 'added player to whitelist' or 'removed player from whitelist'
            SendDiscordLog(string.format('%s %s (ID: %s)', playerName, action, data.id), data.status == 1 and 3066993 or 15158332)
            cb(true)
        end)
    end)
end)

ESX.RegisterServerCallback('esx_whitelist:detectIdentifier', function(source, cb, rawValue)
    local idType, idValue = NormalizeIdentifier(rawValue)
    cb({
        type = idType,
        value = idValue,
        valid = idType ~= nil and idValue ~= nil
    })
end)