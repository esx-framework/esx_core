---@diagnostic disable: undefined-global

WhitelistEnabled = false
GracePeriod = 60
KickConnected = false
DiscordWebhook = ''
DiscordEnabled = false
DiscordGuildId = ''
DiscordRoleId = ''
DiscordBotToken = Config.DiscordBotToken or ''
Rules = {}
GracePeriodPlayers = {}
ManualOverride = false
WhitelistCache = {}
Names = {}

local ruleChangeDebounce = false
local configFile = 'whitelist_config.json'
local translations = {}
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

function T(key, ...)
    local str = translations[key]
    if not str then return key end
    if ... then
        local success, result = pcall(string.format, str, ...)
        return success and result or str
    end
    return str
end

function IsPlayerAdmin(source)
    if not source or source == 0 then return true end
    
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    local group = xPlayer.getGroup()
    for _, adminGroup in ipairs(Config.AdminGroups) do
        if group == adminGroup then return true end
    end
    
    return false
end

function GetPlayerIdentifiersFiltered(source)
    local identifiers = {}
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local identifier = GetPlayerIdentifier(source, i)
        if identifier and not string.match(identifier, 'ip:') then
            table.insert(identifiers, identifier)
        end
    end
    return identifiers
end

function BuildIdentifierQuery(identifiers)
    local conditions, params = {}, {}
    for _, identifier in ipairs(identifiers) do
        table.insert(conditions, 'wi.identifier = ?')
        table.insert(params, identifier)
    end
    return table.concat(conditions, ' OR '), params
end

local function SendDiscordLog(message, color)
    if not DiscordWebhook or DiscordWebhook == '' or DiscordWebhook == '***CONFIGURED***' then return end
    if not message or message == '' then return end
    
    local currentTime = GetGameTimer()
    if webhookCooldown[message] and currentTime - webhookCooldown[message] < 5000 then return end
    webhookCooldown[message] = currentTime
    
    PerformHttpRequest(DiscordWebhook, function() end, 'POST', json.encode({
        embeds = {{
            title = T('discord_title'),
            description = message,
            color = color or 3447003,
            timestamp = os.date('!%Y-%m-%dT%H:%M:%S')
        }}
    }), {['Content-Type'] = 'application/json'})
end

function UpdateWhitelistCache()
    MySQL.Async.fetchAll('SELECT DISTINCT w.id, wi.identifier FROM whitelist w JOIN whitelist_identifiers wi ON w.id = wi.whitelist_id WHERE CAST(w.whitelisted AS UNSIGNED) = 1', {}, function(results)
        WhitelistCache = {}
        for _, row in ipairs(results or {}) do
            WhitelistCache[row.identifier] = row.id
        end
    end)
end

local function StartGracePeriod(source, playerName)
    if not source or source == 0 then return end
    if GracePeriod <= 0 then
        DropPlayer(source, T('kick_message'))
        return
    end
    
    GracePeriodPlayers[source] = {
        endTime = os.time() + GracePeriod,
        playerName = playerName
    }
    
    TriggerClientEvent('esx_whitelist:startGracePeriod', source, GracePeriod)
    
    CreateThread(function()
        Wait(GracePeriod * 1000)
        if GracePeriodPlayers[source] then
            if IsPlayerAdmin(source) then
                GracePeriodPlayers[source] = nil
                return
            end
            DropPlayer(source, T('kick_message'))
            GracePeriodPlayers[source] = nil
        end
    end)
end

function KickNonWhitelistedPlayers()
    local players = ESX.GetExtendedPlayers()
    for _, xPlayer in pairs(players) do
        if xPlayer and xPlayer.source and not IsPlayerAdmin(xPlayer.source) then
            local hasWhitelist = false
            local identifiers = GetPlayerIdentifiersFiltered(xPlayer.source)
            
            for _, identifier in ipairs(identifiers) do
                if WhitelistCache[identifier] then
                    hasWhitelist = true
                    break
                end
            end
            
            if not hasWhitelist then
                if KickConnected then
                    DropPlayer(xPlayer.source, T('kick_message'))
                else
                    StartGracePeriod(xPlayer.source, xPlayer.getName())
                end
            end
        end
    end
end

function SaveConfig()
    local data = {
        whitelistEnabled = WhitelistEnabled,
        gracePeriod = GracePeriod,
        kickConnected = KickConnected,
        discordWebhook = DiscordWebhook,
        discordEnabled = DiscordEnabled,
        discordGuildId = DiscordGuildId,
        discordRoleId = DiscordRoleId,
        rules = Rules
    }
    SaveResourceFile(GetCurrentResourceName(), configFile, json.encode(data, {indent = true}), -1)
end

local function LoadConfig()
    local configData = LoadResourceFile(GetCurrentResourceName(), configFile)
    
    if not configData then
        WhitelistEnabled = DefaultConfig.whitelistEnabled
        GracePeriod = DefaultConfig.gracePeriod
        KickConnected = DefaultConfig.kickConnected
        DiscordWebhook = DefaultConfig.discordWebhook
        DiscordEnabled = DefaultConfig.discordEnabled
        DiscordGuildId = DefaultConfig.discordGuildId
        DiscordRoleId = DefaultConfig.discordRoleId
        Rules = DefaultConfig.rules
        SaveConfig()
        return true
    end
    
    local success, data = pcall(json.decode, configData)
    
    if not success or not data then
        print('[WL] ^3Config corrupted, regenerating^0')
        WhitelistEnabled = DefaultConfig.whitelistEnabled
        GracePeriod = DefaultConfig.gracePeriod
        KickConnected = DefaultConfig.kickConnected
        DiscordWebhook = DefaultConfig.discordWebhook
        DiscordEnabled = DefaultConfig.discordEnabled
        DiscordGuildId = DefaultConfig.discordGuildId
        DiscordRoleId = DefaultConfig.discordRoleId
        Rules = DefaultConfig.rules
        SaveConfig()
        return true
    end
    
    WhitelistEnabled = data.whitelistEnabled or DefaultConfig.whitelistEnabled
    GracePeriod = data.gracePeriod or DefaultConfig.gracePeriod
    KickConnected = data.kickConnected or DefaultConfig.kickConnected
    DiscordWebhook = data.discordWebhook or DefaultConfig.discordWebhook
    DiscordEnabled = data.discordEnabled or DefaultConfig.discordEnabled
    DiscordGuildId = data.discordGuildId or DefaultConfig.discordGuildId
    DiscordRoleId = data.discordRoleId or DefaultConfig.discordRoleId
    Rules = data.rules or DefaultConfig.rules
    
    return true
end

local function WatchConfigFile()
    CreateThread(function()
        local lastContent = LoadResourceFile(GetCurrentResourceName(), configFile)
        while true do
            Wait(30000)
            local currentContent = LoadResourceFile(GetCurrentResourceName(), configFile)
            if currentContent and currentContent ~= lastContent then
                lastContent = currentContent
                if LoadConfig() then
                    if WhitelistEnabled then
                        Wait(2000)
                        KickNonWhitelistedPlayers()
                    end
                    TriggerClientEvent('esx_whitelist:stateChanged', -1, WhitelistEnabled)
                end
            end
        end
    end)
end

local function evaluateWhitelistRules()
    local activeRules = {}
    for _, rule in ipairs(Rules) do
        if rule.enabled then
            table.insert(activeRules, rule)
        end
    end
    
    table.sort(activeRules, function(a, b) return a.priority < b.priority end)
    
    for _, rule in ipairs(activeRules) do
        if rule.type == 'admin-presence' then
            local adminCount = 0
            for _, xPlayer in pairs(ESX.GetExtendedPlayers()) do
                if xPlayer and xPlayer.source and IsPlayerAdmin(xPlayer.source) then
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
    
    return WhitelistEnabled
end

local function handleRuleChange()
    if ManualOverride or ruleChangeDebounce then return end
    ruleChangeDebounce = true
    
    local newState = evaluateWhitelistRules()
    if newState ~= WhitelistEnabled then
        WhitelistEnabled = newState
        
        if WhitelistEnabled then
            SendDiscordLog(T('whitelist_enabled_auto'), 15158332)
            KickNonWhitelistedPlayers()
        else
            SendDiscordLog(T('whitelist_disabled_auto'), 3066993)
            for playerSource, _ in pairs(GracePeriodPlayers) do
                if playerSource and playerSource ~= 0 then
                    GracePeriodPlayers[playerSource] = nil
                    TriggerClientEvent('esx_whitelist:cancelGracePeriod', playerSource)
                end
            end
        end
        
        TriggerClientEvent('esx_whitelist:stateChanged', -1, WhitelistEnabled)
        SaveConfig()
    end
    
    SetTimeout(5000, function()
        ruleChangeDebounce = false
    end)
end

local function checkDiscordRole(discordId, callback)
    if not DiscordEnabled or DiscordGuildId == '' or DiscordRoleId == '' or not IsValidBotToken(DiscordBotToken) then
        callback(false)
        return
    end
    
    PerformHttpRequest(string.format('https://discord.com/api/v10/guilds/%s/members/%s', DiscordGuildId, discordId), 
    function(statusCode, data)
        if statusCode == 200 then
            local member = json.decode(data)
            if member and member.roles then
                for _, roleId in ipairs(member.roles) do
                    if roleId == DiscordRoleId then
                        callback(true)
                        return
                    end
                end
            end
        end
        callback(false)
    end, 'GET', '', {
        ['Authorization'] = 'Bot ' .. DiscordBotToken,
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
    
    for _, xPlayer in pairs(ESX.GetExtendedPlayers()) do
        if xPlayer and xPlayer.source then
            local identifiers = GetPlayerIdentifiersFiltered(xPlayer.source)
            for _, playerIdentifier in ipairs(identifiers) do
                if playerIdentifier == fullIdentifier then
                    local playerName = GetPlayerName(xPlayer.source) or xPlayer.getName()
                    callback(identifiers, playerName, true)
                    return
                end
            end
        end
    end
    
    MySQL.Async.fetchAll([[
        SELECT wi.identifier, w.player_name 
        FROM whitelist_identifiers wi
        JOIN whitelist w ON w.id = wi.whitelist_id
        WHERE wi.whitelist_id = (
            SELECT whitelist_id FROM whitelist_identifiers WHERE identifier = ? LIMIT 1
        )
    ]], {fullIdentifier}, function(results)
        if results and #results > 0 then
            local allIdentifiers = {}
            for _, row in ipairs(results) do
                table.insert(allIdentifiers, row.identifier)
            end
            callback(allIdentifiers, results[1].player_name, false)
        else
            callback({fullIdentifier}, nil, false)
        end
    end)
end

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local source = source
    if not source or source == 0 then return end
    
    deferrals.defer()
    Wait(0)
    
    deferrals.update(T('checking_whitelist'))
    
    local realPlayerName = GetPlayerName(source) or playerName
    local identifiers = GetPlayerIdentifiersFiltered(source)
    
    if #identifiers == 0 then
        deferrals.done(T('kick_message'))
        return
    end
    
    Wait(500)
    
    local conditions, params = BuildIdentifierQuery(identifiers)
    local query = 'SELECT DISTINCT w.id, w.player_name, CAST(w.whitelisted AS UNSIGNED) as whitelisted FROM whitelist w JOIN whitelist_identifiers wi ON w.id = wi.whitelist_id WHERE ' .. conditions
    
    MySQL.Async.fetchAll(query, params, function(result)
        local whitelistId
        local existsInDB = result and #result > 0
        
        if existsInDB then
            whitelistId = result[1].id
            for _, identifier in ipairs(identifiers) do
                local idType = identifier:match("^(%w+):")
                if idType then
                    MySQL.query('INSERT INTO whitelist_identifiers (whitelist_id, type, identifier) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE whitelist_id = VALUES(whitelist_id)', {
                        whitelistId, idType, identifier
                    })
                end
            end
            MySQL.Async.execute('UPDATE whitelist SET player_name = ? WHERE id = ?', {realPlayerName, whitelistId})
        else
            MySQL.query('INSERT INTO whitelist (player_name, whitelisted) VALUES (?, ?)', {realPlayerName, 0}, function(insertResult)
                whitelistId = insertResult and insertResult.insertId
                if whitelistId then
                    for _, identifier in ipairs(identifiers) do
                        local idType = identifier:match("^(%w+):")
                        if idType then
                            MySQL.query('INSERT INTO whitelist_identifiers (whitelist_id, type, identifier) VALUES (?, ?, ?)', {
                                whitelistId, idType, identifier
                            })
                        end
                    end
                end
            end)
            Wait(500)
        end
        
        if not WhitelistEnabled then
            deferrals.done()
            return
        end
        
        if DiscordEnabled then
            local discord = nil
            for _, id in pairs(identifiers) do
                if string.match(id, 'discord:') then
                    discord = id:gsub('discord:', '')
                    break
                end
            end
            
            if not discord then
                deferrals.done(T('kick_message'))
                return
            end
            
            checkDiscordRole(discord, function(hasRole)
                if hasRole then
                    MySQL.Async.execute('UPDATE whitelist SET whitelisted = 1 WHERE id = ?', {whitelistId}, function()
                        for _, identifier in ipairs(identifiers) do
                            WhitelistCache[identifier] = whitelistId
                        end
                    end)
                    deferrals.done()
                else
                    MySQL.Async.execute('UPDATE whitelist SET whitelisted = 0 WHERE id = ?', {whitelistId}, function()
                        for _, identifier in ipairs(identifiers) do
                            WhitelistCache[identifier] = nil
                        end
                    end)
                    deferrals.done(T('kick_message'))
                end
            end)
        else
            if existsInDB and tonumber(result[1].whitelisted) == 1 then
                for _, identifier in ipairs(identifiers) do
                    WhitelistCache[identifier] = whitelistId
                end
                deferrals.done()
            else
                deferrals.done(T('kick_message'))
            end
        end
    end)
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer, isNew)
    handleRuleChange()
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
    if GracePeriodPlayers[playerId] then
        GracePeriodPlayers[playerId] = nil
    end
    Wait(1000)
    handleRuleChange()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    local file = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. Config.Locale .. '.json')
    if file then
        translations = json.decode(file)
    end
    
    LoadConfig()
    
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS whitelist (
            id INT AUTO_INCREMENT PRIMARY KEY,
            player_name VARCHAR(255) COLLATE utf8mb4_unicode_ci,
            whitelisted TINYINT(1) NOT NULL DEFAULT 0,
            added_by VARCHAR(255) COLLATE utf8mb4_unicode_ci,
            added_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_whitelisted (whitelisted)
        )
    ]])
    
    MySQL.Async.execute([[
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
    WatchConfigFile()
    
    print('^2[ESX Whitelist]^0 Started ^7|^0 Status: ^' .. (WhitelistEnabled and '2ON' or '1OFF') .. '^0 ^7|^0 Grace: ^3' .. GracePeriod .. 's^0')
    
    if DiscordEnabled and IsValidBotToken(DiscordBotToken) then
        print('^2[ESX Whitelist]^0 Discord verification: ^2Enabled^0')
    end
    
    CreateThread(function()
        while true do
            Wait(30000)
            handleRuleChange()
        end
    end)
    
    if WhitelistEnabled then
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
        whitelistEnabled = WhitelistEnabled,
        gracePeriod = GracePeriod,
        kickConnected = KickConnected,
        discordWebhook = DiscordWebhook ~= '' and '***CONFIGURED***' or '',
        discordEnabled = DiscordEnabled,
        discordGuildId = DiscordGuildId,
        discordRoleId = DiscordRoleId,
        rules = Rules,
        locale = Config.Locale,
        translations = localeTranslations,
        hasBotToken = DiscordEnabled and IsValidBotToken(DiscordBotToken)
    })
end)

ESX.RegisterServerCallback('esx_whitelist:getWhitelistEntries', function(source, cb)
    if not source or source == 0 or not IsPlayerAdmin(source) then
        cb({})
        return
    end
    
    MySQL.Async.fetchAll([[
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
        for _, row in ipairs(results) do
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

RegisterNetEvent('esx_whitelist:updateConfig', function(config)
    local playerSource = source
    if not playerSource or playerSource == 0 or not IsPlayerAdmin(playerSource) then return end
    
    if config.discordEnabled and not IsValidBotToken(DiscordBotToken) then
        TriggerClientEvent('esx:showNotification', playerSource, '~r~' .. T('discord_no_token'))
        return
    end
    
    if config.discordEnabled and (not config.discordGuildId or config.discordGuildId == '' or not config.discordRoleId or config.discordRoleId == '') then
        TriggerClientEvent('esx:showNotification', playerSource, '~r~' .. T('discord_missing_config'))
        return
    end
    
    local oldState = WhitelistEnabled
    local xPlayer = ESX.GetPlayerFromId(playerSource)
    
    if config.discordWebhook and config.discordWebhook ~= '' and config.discordWebhook ~= '***CONFIGURED***' then
        if string.match(config.discordWebhook, '^https://discord.com/api/webhooks/') or 
           string.match(config.discordWebhook, '^https://discordapp.com/api/webhooks/') then
            DiscordWebhook = config.discordWebhook
        end
    end
    
    WhitelistEnabled = config.whitelistEnabled
    GracePeriod = config.gracePeriod
    KickConnected = config.kickConnected
    DiscordEnabled = config.discordEnabled
    DiscordGuildId = config.discordGuildId
    DiscordRoleId = config.discordRoleId
    Rules = config.rules
    ManualOverride = false
    
    SaveConfig()
    
    if WhitelistEnabled and not oldState then
        SendDiscordLog(T('whitelist_enabled_manual', xPlayer and xPlayer.getName() or 'Unknown'), 15158332)
        Wait(2000)
        KickNonWhitelistedPlayers()
    elseif not WhitelistEnabled and oldState then
        SendDiscordLog(T('whitelist_disabled_manual', xPlayer and xPlayer.getName() or 'Unknown'), 3066993)
        for src, _ in pairs(GracePeriodPlayers) do
            if src and src ~= 0 then
                GracePeriodPlayers[src] = nil
                TriggerClientEvent('esx_whitelist:cancelGracePeriod', src)
            end
        end
    end
    
    TriggerClientEvent('esx_whitelist:stateChanged', -1, WhitelistEnabled)
    TriggerClientEvent('esx:showNotification', playerSource, '~g~' .. T('config_saved'))
end)

RegisterNetEvent('esx_whitelist:updateWebhook', function(webhook)
    local playerSource = source
    if not playerSource or playerSource == 0 or not IsPlayerAdmin(playerSource) then return end
    if webhook == '' or webhook == '***CONFIGURED***' then return end
    
    if not string.match(webhook, '^https://discord.com/api/webhooks/') and 
       not string.match(webhook, '^https://discordapp.com/api/webhooks/') then
        TriggerClientEvent('esx:showNotification', playerSource, '~r~' .. T('webhook_invalid'))
        return
    end
    
    DiscordWebhook = webhook
    SaveConfig()
    
    TriggerClientEvent('esx:showNotification', playerSource, '~g~' .. T('webhook_updated'))
end)

RegisterNetEvent('esx_whitelist:testWebhook', function()
    local playerSource = source
    if not playerSource or playerSource == 0 or not IsPlayerAdmin(playerSource) then return end
    local xPlayer = ESX.GetPlayerFromId(playerSource)
    SendDiscordLog(T('webhook_test', xPlayer and xPlayer.getName() or 'Unknown'), 3447003)
end)

RegisterNetEvent('esx_whitelist:managePlayer', function(data)
    local playerSource = source
    if not playerSource or playerSource == 0 then return end
    
    if not IsPlayerAdmin(playerSource) then
        TriggerClientEvent('esx:showNotification', playerSource, '~r~' .. T('no_perms'))
        return
    end
    
    local xPlayer = ESX.GetPlayerFromId(playerSource)
    if not xPlayer then return end
    
    local rawIdentifier = data.identifier
    local action = data.action
    
    if not rawIdentifier or rawIdentifier == '' then
        TriggerClientEvent('esx:showNotification', playerSource, '~r~' .. T('invalid_identifier'))
        return
    end
    
    local identifierType, identifierValue = NormalizeIdentifier(rawIdentifier)
    
    if not identifierType or not identifierValue then
        TriggerClientEvent('esx:showNotification', playerSource, '~r~' .. T('invalid_identifier_format'))
        return
    end
    
    if identifierType == 'ip' then
        TriggerClientEvent('esx:showNotification', playerSource, '~r~' .. T('ip_not_allowed'))
        return
    end
    
    local fullIdentifier = identifierType .. ':' .. identifierValue
    
    if action == 'add' then
        GetAllPlayerIdentifiers(fullIdentifier, function(allIdentifiers, existingPlayerName, isOnline)
            local playerName = existingPlayerName or 'Pending...'
            
            MySQL.Async.fetchAll('SELECT w.id, w.whitelisted FROM whitelist w JOIN whitelist_identifiers wi ON w.id = wi.whitelist_id WHERE wi.identifier = ?', {fullIdentifier}, function(result)
                if result and #result > 0 then
                    if result[1].whitelisted == 1 then
                        TriggerClientEvent('esx:showNotification', playerSource, '~r~' .. T('player_already_wl'))
                        return
                    end
                    
                    MySQL.Async.execute('UPDATE whitelist SET whitelisted = 1, added_by = ?, player_name = ? WHERE id = ?', {
                        xPlayer.identifier, playerName, result[1].id
                    }, function()
                        for _, id in ipairs(allIdentifiers) do
                            local idType = id:match("^(%w+):")
                            if idType then
                                MySQL.Async.execute('INSERT INTO whitelist_identifiers (whitelist_id, type, identifier) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE whitelist_id = VALUES(whitelist_id)', {
                                    result[1].id, idType, id
                                }, function()
                                    WhitelistCache[id] = result[1].id
                                end)
                            end
                        end
                        
                        TriggerClientEvent('esx:showNotification', playerSource, '~g~' .. T('player_added_ui'))
                        SendDiscordLog(T('discord_player_added', xPlayer.getName(), playerName .. ' (' .. identifierType .. ')'), 3066993)
                        
                        if isOnline then
                            for _, xPlayerOnline in pairs(ESX.GetExtendedPlayers()) do
                                if xPlayerOnline and xPlayerOnline.source then
                                    local onlineIdentifiers = GetPlayerIdentifiersFiltered(xPlayerOnline.source)
                                    for _, onlineId in ipairs(onlineIdentifiers) do
                                        if onlineId == fullIdentifier then
                                            TriggerClientEvent('esx:showNotification', xPlayerOnline.source, '~g~' .. T('added_to_whitelist'))
                                            if GracePeriodPlayers[xPlayerOnline.source] then
                                                GracePeriodPlayers[xPlayerOnline.source] = nil
                                                TriggerClientEvent('esx_whitelist:cancelGracePeriod', xPlayerOnline.source)
                                            end
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end)
                else
                    MySQL.query('INSERT INTO whitelist (player_name, whitelisted, added_by) VALUES (?, ?, ?)', {
                        playerName, 1, xPlayer.identifier
                    }, function(insertResult)
                        local insertId = insertResult and insertResult.insertId
                        if insertId then
                            for _, id in ipairs(allIdentifiers) do
                                local idType = id:match("^(%w+):")
                                if idType then
                                    MySQL.query('INSERT INTO whitelist_identifiers (whitelist_id, type, identifier) VALUES (?, ?, ?)', {
                                        insertId, idType, id
                                    }, function()
                                        WhitelistCache[id] = insertId
                                    end)
                                end
                            end
                            
                            TriggerClientEvent('esx:showNotification', playerSource, '~g~' .. T('player_added_ui'))
                            SendDiscordLog(T('discord_player_added', xPlayer.getName(), playerName .. ' (' .. identifierType .. ')'), 3066993)
                            
                            if isOnline then
                                for _, xPlayerOnline in pairs(ESX.GetExtendedPlayers()) do
                                    if xPlayerOnline and xPlayerOnline.source then
                                        local onlineIdentifiers = GetPlayerIdentifiersFiltered(xPlayerOnline.source)
                                        for _, onlineId in ipairs(onlineIdentifiers) do
                                            if onlineId == fullIdentifier then
                                                TriggerClientEvent('esx:showNotification', xPlayerOnline.source, '~g~' .. T('added_to_whitelist'))
                                                if GracePeriodPlayers[xPlayerOnline.source] then
                                                    GracePeriodPlayers[xPlayerOnline.source] = nil
                                                    TriggerClientEvent('esx_whitelist:cancelGracePeriod', xPlayerOnline.source)
                                                end
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
        end)
        
    elseif action == 'remove' then
        MySQL.Async.fetchAll('SELECT w.id, w.whitelisted FROM whitelist w JOIN whitelist_identifiers wi ON w.id = wi.whitelist_id WHERE wi.identifier = ?', {fullIdentifier}, function(result)
            if not result or #result == 0 or result[1].whitelisted == 0 then
                TriggerClientEvent('esx:showNotification', playerSource, '~r~' .. T('player_not_in_wl'))
                return
            end
            
            MySQL.Async.execute('UPDATE whitelist SET whitelisted = 0 WHERE id = ?', {result[1].id}, function()
                MySQL.Async.fetchAll('SELECT identifier FROM whitelist_identifiers WHERE whitelist_id = ?', {result[1].id}, function(identifiers)
                    for _, row in ipairs(identifiers) do
                        WhitelistCache[row.identifier] = nil
                    end
                    TriggerClientEvent('esx:showNotification', playerSource, '~g~' .. T('player_removed_ui'))
                    SendDiscordLog(T('discord_player_removed', xPlayer.getName(), fullIdentifier), 15158332)
                end)
            end)
        end)
    end
end)

RegisterNetEvent('esx_whitelist:toggleWhitelistStatus', function(data)
    local playerSource = source
    if not playerSource or playerSource == 0 or not IsPlayerAdmin(playerSource) then return end
    
    local xPlayer = ESX.GetPlayerFromId(playerSource)
    if not xPlayer then return end
    
    MySQL.Async.execute('UPDATE whitelist SET whitelisted = ? WHERE id = ?', {data.status, data.id}, function()
        MySQL.Async.fetchAll('SELECT identifier FROM whitelist_identifiers WHERE whitelist_id = ?', {data.id}, function(result)
            if result and #result > 0 then
                for _, row in ipairs(result) do
                    if data.status == 1 then
                        WhitelistCache[row.identifier] = data.id
                    else
                        WhitelistCache[row.identifier] = nil
                    end
                end
            end
            
            TriggerClientEvent('esx:showNotification', playerSource, '~g~' .. (data.status == 1 and T('player_added_ui') or T('player_removed_ui')))
            SendDiscordLog(T(data.status == 1 and 'discord_player_added' or 'discord_player_removed', xPlayer.getName(), 'ID: ' .. data.id), data.status == 1 and 3066993 or 15158332)
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