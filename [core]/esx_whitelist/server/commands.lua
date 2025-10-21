---@diagnostic disable: undefined-global, need-check-nil, param-type-mismatch

if Config.InGameCommands then
    ESX.RegisterCommand('wl_add', 'admin', function(xPlayer, args)
        if not args.id then
            xPlayer.showNotification('~r~Usage: /wl_add [player id]')
            return
        end
        
        local targetId = tonumber(args.id)
        local targetPlayer = ESX.Player(targetId)
        
        if not targetPlayer then
            xPlayer.showNotification('~r~Player not found')
            return
        end
        
        local targetIdentifiers = GetPlayerIdentifiersFiltered(targetId)
        
        if #targetIdentifiers == 0 then
            xPlayer.showNotification('~r~Player not found')
            return
        end
        
        local conditions, params = BuildIdentifierQuery(targetIdentifiers)
        
        MySQL.query('SELECT w.id, w.whitelisted FROM whitelist w JOIN whitelist_identifiers wi ON w.id = wi.whitelist_id WHERE ' .. conditions, params, function(result)
            if result and #result > 0 then
                if result[1].whitelisted == 1 then
                    xPlayer.showNotification('~r~Player already whitelisted')
                    return
                end
                
                local adminIdentifier = xPlayer.getIdentifier()
                
                MySQL.update('UPDATE whitelist SET whitelisted = 1, added_by = ? WHERE id = ?', {
                    adminIdentifier, result[1].id
                }, function()
                    for i = 1, #targetIdentifiers do
                        Whitelist.Cache[targetIdentifiers[i]] = result[1].id
                    end
                    
                    xPlayer.showNotification('~g~Player added to whitelist')
                    targetPlayer.showNotification('~g~You have been added to the whitelist')
                    
                    if Whitelist.GracePeriodPlayers[targetId] then
                        Whitelist.GracePeriodPlayers[targetId] = nil
                        TriggerClientEvent('esx_whitelist:cancelGracePeriod', targetId)
                    end
                end)
            else
                xPlayer.showNotification('~r~Player not found')
            end
        end)
    end, false, {help = 'Add player to whitelist', validate = true, arguments = {
        {name = 'id', help = 'Player ID', type = 'number'}
    }})

    ESX.RegisterCommand('wl_check', 'admin', function(xPlayer, args)
        if not args.id then
            xPlayer.showNotification('~r~Usage: /wl_check [player id]')
            return
        end
        
        local targetId = tonumber(args.id)
        local targetPlayer = ESX.Player(targetId)
        
        if not targetPlayer then
            xPlayer.showNotification('~r~Player not found')
            return
        end
        
        local targetIdentifiers = GetPlayerIdentifiersFiltered(targetId)
        
        if #targetIdentifiers == 0 then
            xPlayer.showNotification('~r~Player not found')
            return
        end
        
        local conditions, params = BuildIdentifierQuery(targetIdentifiers)
        
        MySQL.query('SELECT w.whitelisted FROM whitelist w JOIN whitelist_identifiers wi ON w.id = wi.whitelist_id WHERE ' .. conditions, params, function(result)
            local hasWhitelist = result and #result > 0 and result[1].whitelisted == 1
            local targetName = targetPlayer.getName()
            
            if hasWhitelist then
                xPlayer.showNotification('~g~' .. targetName .. ' is whitelisted')
            else
                xPlayer.showNotification('~r~' .. targetName .. ' is not whitelisted')
            end
            
            if IsPlayerAdmin(targetId) then
                xPlayer.showNotification('~b~This player is an admin')
            end
        end)
    end, false, {help = 'Check whitelist status', validate = true, arguments = {
        {name = 'id', help = 'Player ID', type = 'number'}
    }})
end

if Config.ConsoleCommands then
    RegisterCommand('wl_add', function(source, args)
        if source ~= 0 then return end
        
        if not args[1] then 
            print('Usage: wl_add [identifier]')
            return 
        end
        
        local rawIdentifier = args[1]
        local identifierType, identifierValue = NormalizeIdentifier(rawIdentifier)
        
        if not identifierType or not identifierValue then
            print('Invalid identifier format')
            return
        end
        
        if identifierType == 'ip' then
            print('IP identifiers are not allowed')
            return
        end
        
        local fullIdentifier = identifierType .. ':' .. identifierValue
        
        GetAllPlayerIdentifiers(fullIdentifier, function(allIdentifiers, existingPlayerName, isOnline)
            local playerName = existingPlayerName or 'Pending...'
            
            MySQL.query('SELECT w.id, w.whitelisted FROM whitelist w JOIN whitelist_identifiers wi ON w.id = wi.whitelist_id WHERE wi.identifier = ?', {fullIdentifier}, function(result)
                if result and #result > 0 then
                    if result[1].whitelisted == 1 then
                        print('Player is already whitelisted')
                        return
                    end
                    
                    MySQL.update('UPDATE whitelist SET whitelisted = 1, added_by = ?, player_name = ? WHERE id = ?', {
                        'console', playerName, result[1].id
                    }, function()
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
                        
                        print('Added to whitelist: ' .. playerName .. ' (' .. identifierType .. ')' .. (isOnline and ' [ONLINE]' or ''))
                        
                        if isOnline then
                            NotifyOnlinePlayer(fullIdentifier)
                        end
                    end)
                else
                    MySQL.insert('INSERT INTO whitelist (player_name, whitelisted, added_by) VALUES (?, ?, ?)', {
                        playerName, 1, 'console'
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
                            
                            print('Added to whitelist: ' .. playerName .. ' (' .. identifierType .. ')' .. (isOnline and ' [ONLINE]' or ''))
                            
                            if isOnline then
                                NotifyOnlinePlayer(fullIdentifier)
                            end
                        end
                    end)
                end
            end)
        end)
    end, true)

    RegisterCommand('wl_on', function(source)
        if source ~= 0 then return end
        
        if Whitelist.Enabled then 
            print('Whitelist is already enabled')
            return 
        end
        
        Whitelist.ManualOverride = false
        Whitelist.Enabled = true
        SaveConfig()
        
        print('Whitelist has been enabled')
        SendDiscordLog('Whitelist enabled from console', 15158332)
        
        Wait(2000)
        KickNonWhitelistedPlayers()
        
        TriggerClientEvent('esx_whitelist:stateChanged', -1, Whitelist.Enabled)
    end, true)

    RegisterCommand('wl_off', function(source)
        if source ~= 0 then return end
        
        if not Whitelist.Enabled then 
            print('Whitelist is already disabled')
            return 
        end
        
        Whitelist.ManualOverride = true
        Whitelist.Enabled = false
        SaveConfig()
        
        print('Whitelist has been disabled')
        SendDiscordLog('Whitelist disabled from console', 3066993)
        
        for playerSource in pairs(Whitelist.GracePeriodPlayers) do
            Whitelist.GracePeriodPlayers[playerSource] = nil
            TriggerClientEvent('esx_whitelist:cancelGracePeriod', playerSource)
        end
        
        TriggerClientEvent('esx_whitelist:stateChanged', -1, Whitelist.Enabled)
    end, true)

    RegisterCommand('wl_remove', function(source, args)
        if source ~= 0 then return end
        
        if not args[1] then 
            print('Usage: wl_remove [identifier]')
            return 
        end
        
        local rawIdentifier = args[1]
        local identifierType, identifierValue = NormalizeIdentifier(rawIdentifier)
        
        if not identifierType or not identifierValue then
            print('Invalid identifier format')
            return
        end
        
        if identifierType == 'ip' then
            print('IP identifiers are not allowed')
            return
        end
        
        local fullIdentifier = identifierType .. ':' .. identifierValue
        
        MySQL.query('SELECT w.id, w.whitelisted, w.player_name FROM whitelist w JOIN whitelist_identifiers wi ON w.id = wi.whitelist_id WHERE wi.identifier = ?', {fullIdentifier}, function(result)
            if not result or #result == 0 or result[1].whitelisted == 0 then
                print('Player is not in whitelist')
                return
            end
            
            MySQL.update('UPDATE whitelist SET whitelisted = 0 WHERE id = ?', {result[1].id}, function()
                MySQL.query('SELECT identifier FROM whitelist_identifiers WHERE whitelist_id = ?', {result[1].id}, function(identifiers)
                    for i = 1, #identifiers do
                        Whitelist.Cache[identifiers[i].identifier] = nil
                    end
                    
                    local playerName = result[1].player_name or 'Unknown'
                    print('Removed from whitelist: ' .. playerName .. ' (' .. identifierType .. ')')
                end)
            end)
        end)
    end, true)
end