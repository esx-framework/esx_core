local Instances = {}

function GetInstancedPlayers()

	local players = {}

	for k,v in pairs(Instances) do
		for i=1, #v.players, 1 do
			table.insert(players, v.players[i])
		end
	end

	return players

end

function CreateInstance(player)
	
	Instances[player] = {
		host    = player,
		players = {player}
	}

	TriggerClientEvent('instance:onData', player, Instances[player])
	TriggerClientEvent('instance:onInstancedPlayersData', -1, GetInstancedPlayers())

end

function CloseInstance(instance)

	for i=1, #Instances[instance].players, 1 do
		TriggerClientEvent('instance:onData', Instances[instance].players[i], {})
	end

	Instances[instance] = nil

	TriggerClientEvent('instance:onInstancedPlayersData', -1, GetInstancedPlayers())

end

function AddPlayerToInstance(instance, player)
	
	local found = false

	for i=1, #Instances[instance].players, 1 do
		if Instances[instance].players[i] == player then
			found = true
			break
		end
	end

	if not found then
		table.insert(Instances[instance].players, player)
	end

	for i=1, #Instances[instance].players, 1 do
		TriggerClientEvent('instance:onData', Instances[instance].players[i], Instances[instance])
	end

	TriggerClientEvent('instance:onInstancedPlayersData', -1, GetInstancedPlayers())

end

function RemovePlayerFromInstance(instance, player)

	if Instances[instance].host == player then
		
		CloseInstance(instance)
	
	else

		for i=1, #Instances[instance].players, 1 do
			if Instances[instance].players[i] == player then
				Instances[instance].players[i] = nil
			end
		end

		TriggerClientEvent('instance:onData', player, {})

		for i=1, #Instances[instance].players, 1 do
			TriggerClientEvent('instance:onData', Instances[instance].players[i], Instances[instance])
		end

		TriggerClientEvent('instance:onInstancedPlayersData', -1, GetInstancedPlayers())

	end

end

function InvitePlayerToInstance(instance, player, pos)
	TriggerClientEvent('instance:onInvite', player, instance, pos)
end

RegisterServerEvent('instance:create')
AddEventHandler('instance:create', function()
	CreateInstance(source)
end)

RegisterServerEvent('instance:close')
AddEventHandler('instance:close', function()
	CloseInstance(source)
end)

RegisterServerEvent('instance:enter')
AddEventHandler('instance:enter', function(instance)
	AddPlayerToInstance(instance, source)
end)

RegisterServerEvent('instance:leave')
AddEventHandler('instance:leave', function(instance)
	RemovePlayerFromInstance(instance, source)
end)

RegisterServerEvent('instance:invite')
AddEventHandler('instance:invite', function(instance, player, pos)
	InvitePlayerToInstance(instance, player, pos)
end)

TriggerEvent('es:addCommand', 'instance_create', function(source, args, user)
	CreateInstance(source)
end)

TriggerEvent('es:addCommand', 'instance_invite', function(source, args, user)
	InvitePlayerToInstance(tonumber(args[2]), tonumber(args[3]), {
		x = tonumber(args[4]),
		y = tonumber(args[5]),
		z = tonumber(args[6]),
	})
end)

TriggerEvent('es:addCommand', 'instance_enter', function(source, args, user)
	AddPlayerToInstance(source, tonumber(args[2]))
end)
