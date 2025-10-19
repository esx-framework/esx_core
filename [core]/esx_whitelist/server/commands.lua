---@diagnostic disable: undefined-global, need-check-nil, param-type-mismatch


if Config.InGameCommands then
    RegisterCommand('wl_add', function(source, args)
        if source == 0 then return end
        
        local playerSource = source
        if not IsPlayerAdmin(playerSource) then
            TriggerClientEvent('esx:showNotification', playerSource, '~r~' .. T('no_perms'))
            return
        end
        
        if not args[1] then
            TriggerClientEvent('esx:showNotification', playerSource, '~r~' .. T('usage_wl_add'))
            return
        end
        
        local targetId = tonumber(args[1])
        local targetPlayer = ESX.GetPlayerFromId(targetId)
        
        if not targetPlayer then
            TriggerClientEvent('esx:showNotification', playerSource, '~r~' .. T('player_not_found'))
            return
        end
        
        local targetIdentifiers = GetPlayerIdentifiersFiltered(targetId)
        
        if #targetIdentifiers == 0 then
            TriggerClientEvent('esx:showNotification', playerSource, '~r~' .. T('player_not_found'))
            return
        end
        
        local conditions, params = BuildIdentifierQuery(targetIdentifiers)
        
        MySQL.Async.fetchAll('SELECT w.id, w.whitelisted FROM whitelist w JOIN whitelist_identifiers wi ON w.id = wi.whitelist_id WHERE ' .. conditions, params, function(result)
            if result and #result > 0 then
                if result[1].whitelisted == 1 then
                    TriggerClientEvent('esx:showNotification', playerSource, '~r~' .. T('player_already_wl'))
                    return
                end
                
                local xPlayer = ESX.GetPlayerFromId(playerSource)
                if not xPlayer then return end
                
                MySQL.Async.execute('UPDATE whitelist SET whitelisted = 1, added_by = ? WHERE id = ?', {
                    xPlayer.identifier, result[1].id
                }, function()
                    for _, ident in ipairs(targetIdentifiers) do
                        WhitelistCache[ident] = result[1].id
                    end
                    
                    TriggerClientEvent('esx:showNotification', playerSource, '~g~' .. T('player_added'))
                    TriggerClientEvent('esx:showNotification', targetId, '~g~' .. T('added_to_whitelist'))
                    
                    if GracePeriodPlayers[targetId] then
                        GracePeriodPlayers[targetId] = nil
                        TriggerClientEvent('esx_whitelist:cancelGracePeriod', targetId)
                    end
                end)
            else
                TriggerClientEvent('esx:showNotification', playerSource, '~r~' .. T('player_not_found'))
            end
        end)
    end, false)

    RegisterCommand('wl_check', function(source, args)
        if source == 0 then return end
        
        if not IsPlayerAdmin(source) then
            TriggerClientEvent('esx:showNotification', source, '~r~' .. T('no_perms'))
            return
        end
        
        if not args[1] then
            TriggerClientEvent('esx:showNotification', source, '~r~' .. T('usage_wl_check'))
            return
        end
        
        local targetId = tonumber(args[1])
        local targetPlayer = ESX.GetPlayerFromId(targetId)
        
        if not targetPlayer then
            TriggerClientEvent('esx:showNotification', source, '~r~' .. T('player_not_found'))
            return
        end
        
        local targetIdentifiers = GetPlayerIdentifiersFiltered(targetId)
        
        if #targetIdentifiers == 0 then
            TriggerClientEvent('esx:showNotification', source, '~r~' .. T('player_not_found'))
            return
        end
        
        local conditions, params = BuildIdentifierQuery(targetIdentifiers)
        
        MySQL.Async.fetchAll('SELECT w.whitelisted FROM whitelist w JOIN whitelist_identifiers wi ON w.id = wi.whitelist_id WHERE ' .. conditions, params, function(result)
            local hasWhitelist = result and #result > 0 and result[1].whitelisted == 1
            local targetName = targetPlayer.getName()
            
            if hasWhitelist then
                TriggerClientEvent('esx:showNotification', source, '~g~' .. T('player_has_wl', targetName))
            else
                TriggerClientEvent('esx:showNotification', source, '~r~' .. T('player_no_wl', targetName))
            end
            
            if IsPlayerAdmin(targetId) then
                TriggerClientEvent('esx:showNotification', source, '~b~' .. T('player_is_admin'))
            end
        end)
    end, false)
end

if Config.ConsoleCommands then
    RegisterCommand('wl_add', function(source, args)
        if source ~= 0 then return end
        
        if not args[1] then 
            print('^3[WL]^0 Usage: ^7wl_add [identifier]^0')
            return 
        end
        
        local rawIdentifier = args[1]
        local identifierType, identifierValue = NormalizeIdentifier(rawIdentifier)
        
        if not identifierType or not identifierValue then
            print('^1[WL]^0 Invalid identifier format')
            return
        end
        
        if identifierType == 'ip' then
            print('^1[WL]^0 IP identifiers not allowed')
            return
        end
        
        local fullIdentifier = identifierType .. ':' .. identifierValue
        
        GetAllPlayerIdentifiers(fullIdentifier, function(allIdentifiers, existingPlayerName, isOnline)
            local playerName = existingPlayerName or 'Pending...'
            
            MySQL.Async.fetchAll('SELECT w.id, w.whitelisted FROM whitelist w JOIN whitelist_identifiers wi ON w.id = wi.whitelist_id WHERE wi.identifier = ?', {fullIdentifier}, function(result)
                if result and #result > 0 then
                    if result[1].whitelisted == 1 then
                        print('^3[WL]^0 Player already whitelisted')
                        return
                    end
                    
                    MySQL.Async.execute('UPDATE whitelist SET whitelisted = 1, added_by = ?, player_name = ? WHERE id = ?', {
                        'console', playerName, result[1].id
                    }, function()
                        for _, id in ipairs(allIdentifiers) do
                            local idType = id:match("^(%w+):")
                            if idType then
                                MySQL.query('INSERT INTO whitelist_identifiers (whitelist_id, type, identifier) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE whitelist_id = VALUES(whitelist_id)', {
                                    result[1].id, idType, id
                                }, function()
                                    WhitelistCache[id] = result[1].id
                                end)
                            end
                        end
                        print('^2[WL]^0 Added: ^7' .. playerName .. '^0 (^3' .. identifierType .. '^0)' .. (isOnline and ' ^2[ONLINE]^0' or ''))
                        
                        if isOnline then
                            for _, xPlayerOnline in pairs(ESX.GetExtendedPlayers()) do
                                if xPlayerOnline and xPlayerOnline.source then
                                    local onlineIdentifiers = GetPlayerIdentifiersFiltered(xPlayerOnline.source)
                                    for _, onlineId in ipairs(onlineIdentifiers) do
                                        if onlineId == fullIdentifier then
                                            TriggerClientEvent('esx:showNotification', xPlayerOnline.source, '~g~You have been added to the whitelist')
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
                        playerName, 1, 'console'
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
                            print('^2[WL]^0 Added: ^7' .. playerName .. '^0 (^3' .. identifierType .. '^0)' .. (isOnline and ' ^2[ONLINE]^0' or ''))
                            
                            if isOnline then
                                for _, xPlayerOnline in pairs(ESX.GetExtendedPlayers()) do
                                    if xPlayerOnline and xPlayerOnline.source then
                                        local onlineIdentifiers = GetPlayerIdentifiersFiltered(xPlayerOnline.source)
                                        for _, onlineId in ipairs(onlineIdentifiers) do
                                            if onlineId == fullIdentifier then
                                                TriggerClientEvent('esx:showNotification', xPlayerOnline.source, '~g~You have been added to the whitelist')
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
    end, true)

    RegisterCommand('wl_on', function(source)
        if source ~= 0 then return end
        
        if WhitelistEnabled then 
            print('^3[WL]^0 Already enabled')
            return 
        end
        
        ManualOverride = false
        WhitelistEnabled = true
        SaveConfig()
        
        print('^2[WL]^0 Whitelist ^2enabled^0')
        SendDiscordLog('Whitelist enabled from console', 15158332)
        
        Wait(2000)
        KickNonWhitelistedPlayers()
        
        TriggerClientEvent('esx_whitelist:stateChanged', -1, WhitelistEnabled)
    end, true)

    RegisterCommand('wl_off', function(source)
        if source ~= 0 then return end
        
        if not WhitelistEnabled then 
            print('^3[WL]^0 Already disabled')
            return 
        end
        
        ManualOverride = true
        WhitelistEnabled = false
        SaveConfig()
        
        print('^1[WL]^0 Whitelist ^1disabled^0')
        SendDiscordLog('Whitelist disabled from console', 3066993)
        
        for playerSource, _ in pairs(GracePeriodPlayers) do
            GracePeriodPlayers[playerSource] = nil
            TriggerClientEvent('esx_whitelist:cancelGracePeriod', playerSource)
        end
        
        TriggerClientEvent('esx_whitelist:stateChanged', -1, WhitelistEnabled)
    end, true)

    RegisterCommand('wl_remove', function(source, args)
        if source ~= 0 then return end
        
        if not args[1] then 
            print('^3[WL]^0 Usage: ^7wl_remove [identifier]^0')
            return 
        end
        
        local rawIdentifier = args[1]
        local identifierType, identifierValue = NormalizeIdentifier(rawIdentifier)
        
        if not identifierType or not identifierValue then
            print('^1[WL]^0 Invalid identifier format')
            return
        end
        
        if identifierType == 'ip' then
            print('^1[WL]^0 IP identifiers not allowed')
            return
        end
        
        local fullIdentifier = identifierType .. ':' .. identifierValue
        
        MySQL.Async.fetchAll('SELECT w.id, w.whitelisted, w.player_name FROM whitelist w JOIN whitelist_identifiers wi ON w.id = wi.whitelist_id WHERE wi.identifier = ?', {fullIdentifier}, function(result)
            if not result or #result == 0 or result[1].whitelisted == 0 then
                print('^3[WL]^0 Player not in whitelist')
                return
            end
            
            MySQL.Async.execute('UPDATE whitelist SET whitelisted = 0 WHERE id = ?', {result[1].id}, function()
                MySQL.Async.fetchAll('SELECT identifier FROM whitelist_identifiers WHERE whitelist_id = ?', {result[1].id}, function(identifiers)
                    for _, row in ipairs(identifiers) do
                        WhitelistCache[row.identifier] = nil
                    end
                    
                    local playerName = result[1].player_name or 'Unknown'
                    print('^1[WL]^0 Removed: ^7' .. playerName .. '^0 (^3' .. identifierType .. '^0)')
                end)
            end)
        end)
    end, true)
end