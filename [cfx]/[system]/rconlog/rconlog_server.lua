RconLog({ msgType = 'serverStart', hostname = 'lovely', maxplayers = 32 })

RegisterServerEvent('rlPlayerActivated')

local names = {}

AddEventHandler('rlPlayerActivated', function()
    RconLog({ msgType = 'playerActivated', netID = source, name = GetPlayerName(source), guid = GetPlayerIdentifiers(source)[1], ip = GetPlayerEP(source) })

    names[source] = { name = GetPlayerName(source), id = source }

	if GetHostId() then
		TriggerClientEvent('rlUpdateNames', GetHostId())
	end
end)

RegisterServerEvent('rlUpdateNamesResult')

AddEventHandler('rlUpdateNamesResult', function(res)
    if source ~= tonumber(GetHostId()) then
        print('bad guy')
        return
    end

    for id, data in pairs(res) do
        if data then
            if data.name then
                if not names[id] then
                    names[id] = data
                end

                if names[id].name ~= data.name or names[id].id ~= data.id then
                    names[id] = data

                    RconLog({ msgType = 'playerRenamed', netID = id, name = data.name })
                end
            end
        else
            names[id] = nil
        end
    end
end)

AddEventHandler('playerDropped', function()
    RconLog({ msgType = 'playerDropped', netID = source, name = GetPlayerName(source) })

    names[source] = nil
end)

AddEventHandler('chatMessage', function(netID, name, message)
    RconLog({ msgType = 'chatMessage', netID = netID, name = name, message = message, guid = GetPlayerIdentifiers(netID)[1] })
end)

-- NOTE: DO NOT USE THIS METHOD FOR HANDLING COMMANDS
-- This resource has not been updated to use newer methods such as RegisterCommand.
AddEventHandler('rconCommand', function(commandName, args)
    if commandName == 'status' then
        for netid, data in pairs(names) do
            local guid = GetPlayerIdentifiers(netid)

            if guid and guid[1] and data then
                local ping = GetPlayerPing(netid)

                RconPrint(netid .. ' ' .. guid[1] .. ' ' .. data.name .. ' ' .. GetPlayerEP(netid) .. ' ' .. ping .. "\n")
            end
        end

        CancelEvent()
    elseif commandName:lower() == 'clientkick' then
        local playerId = table.remove(args, 1)
        local msg = table.concat(args, ' ')

        DropPlayer(playerId, msg)

        CancelEvent()
    elseif commandName:lower() == 'tempbanclient' then
        local playerId = table.remove(args, 1)
        local msg = table.concat(args, ' ')

        TempBanPlayer(playerId, msg)

        CancelEvent()
    end
end)
