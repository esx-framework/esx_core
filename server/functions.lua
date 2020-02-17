ESX.Trace = function(msg)
	if Config.EnableDebug then
		print(('[es_extended] [^2TRACE^7] %s^7'):format(msg))
	end
end

ESX.SetTimeout = function(msec, cb)
	local id = ESX.TimeoutCount + 1

	SetTimeout(msec, function()
		if ESX.CancelledTimeouts[id] then
			ESX.CancelledTimeouts[id] = nil
		else
			cb()
		end
	end)

	ESX.TimeoutCount = id

	return id
end

ESX.RegisterCommand = function(name, group, cb, allowConsole, suggestion)
	if type(name) == 'table' then
		for k,v in ipairs(name) do
			ESX.RegisterCommand(v, group, cb, allowConsole, suggestion)
		end

		return
	end

	if ESX.RegisteredCommands[name] then
		print(('[es_extended] [^3WARNING^7] An command "%s" is already registered'):format(name))
	else
		if suggestion then
			if not suggestion.arguments then suggestion.arguments = {} end
			if not suggestion.help then suggestion.help = '' end
		end

		ESX.RegisteredCommands[name] = {group = group, cb = cb, allowConsole = allowConsole, suggestion = suggestion}

		RegisterCommand(name, function(playerId, args, rawCommand)
			local command = ESX.RegisteredCommands[name]

			if not command.allowConsole and playerId == 0 then
				print('[es_extended] [^3WARNING^7] That command can not be run from console')
			else
				local xPlayer, error = ESX.GetPlayerFromId(playerId), nil

				if command.suggestion then
					if command.suggestion.validate then
						if #args ~= #command.suggestion.arguments then
							error = ('Argument count mismatch (passed %s, wanted %s)'):format(#args, #command.suggestion.arguments)
						end
					end

					if not error and command.suggestion.arguments then
						local newArgs = {}

						for k,v in ipairs(command.suggestion.arguments) do
							if v.type then
								if v.type == 'number' then
									local newArg = tonumber(args[k])

									if newArg then
										newArgs[v.name] = newArg
									else
										error = ('Argument #%s type mismatch (passed string, wanted number)'):format(k)
									end
								elseif v.type == 'player' then
									local targetPlayer = tonumber(args[k])

									if targetPlayer then
										local xTargetPlayer = ESX.GetPlayerFromId(targetPlayer)

										if xTargetPlayer then
											newArgs[v.name] = xTargetPlayer
										else
											error = 'Player not online'
										end
									else
										error = ('Argument #%s type mismatch (passed string, wanted number)'):format(k)
									end
								elseif v.type == 'string' then
									newArgs[v.name] = args[k]
								elseif v.type == 'item' then
									if ESX.Items[args[k]] then
										newArgs[v.name] = args[k]
									else
										error = _U('invalid_item')
									end
								elseif v.type == 'weapon' then
									if ESX.GetWeapon(args[k]) then
										newArgs[v.name] = string.upper(args[k])
									else
										error = 'Invalid weapon'
									end
								elseif v.type == 'any' then
									newArgs[v.name] = args[k]
								end
							end

							if error then break end
						end

						args = newArgs
					end
				end

				if error then
					if playerId == 0 then
						print(('[es_extended] [^3WARNING^7] %s^7'):format(error))
					else
						xPlayer.triggerEvent('chat:addMessage', {args = {'^1SYSTEM', error}})
					end
				else
					cb(xPlayer, args, function(msg)
						if playerId == 0 then
							print(('[es_extended] [^3WARNING^7] %s^7'):format(msg))
						else
							xPlayer.triggerEvent('chat:addMessage', {args = {'^1SYSTEM', msg}})
						end
					end)
				end
			end
		end, true)

		ExecuteCommand(('add_ace group.%s command.%s allow'):format(group, name))
	end
end

ESX.ClearTimeout = function(id)
	ESX.CancelledTimeouts[id] = true
end

ESX.RegisterServerCallback = function(name, cb)
	ESX.ServerCallbacks[name] = cb
end

ESX.TriggerServerCallback = function(name, requestId, source, cb, ...)
	if ESX.ServerCallbacks[name] ~= nil then
		ESX.ServerCallbacks[name](source, cb, ...)
	else
		print(('[es_extended] [^3WARNING^7] Server callback "%s" does not exist. Make sure that the server sided file really is loading, an error in that file might cause it to not load.'):format(name))
	end
end

ESX.SavePlayer = function(xPlayer, cb)
	local asyncTasks = {}

	-- User accounts
	for k,v in ipairs(xPlayer.accounts) do
		if ESX.LastPlayerData[xPlayer.source].accounts[v.name] ~= v.money then
			table.insert(asyncTasks, function(cb)
				MySQL.Async.execute('UPDATE user_accounts SET money = @money WHERE identifier = @identifier AND name = @name', {
					['@money'] = v.money,
					['@identifier'] = xPlayer.identifier,
					['@name'] = v.name
				}, function(rowsChanged)
					cb()
				end)
			end)

			ESX.LastPlayerData[xPlayer.source].accounts[v.name] = v.money
		end
	end

	-- Job, loadout, inventory and position
	table.insert(asyncTasks, function(cb)
		MySQL.Async.execute('UPDATE users SET job = @job, job_grade = @job_grade, loadout = @loadout, position = @position, inventory = @inventory WHERE identifier = @identifier', {
			['@job'] = xPlayer.job.name,
			['@job_grade'] = xPlayer.job.grade,
			['@loadout'] = json.encode(xPlayer.getLoadout()),
			['@position'] = json.encode(xPlayer.getCoords()),
			['@identifier'] = xPlayer.identifier,
			['@inventory'] = json.encode(xPlayer.getInventory(true))
		}, function(rowsChanged)
			cb()
		end)
	end)

	Async.parallel(asyncTasks, function(results)
		print(('[es_extended] [^2INFO^7] Saved player "%s^7"'):format(xPlayer.getName()))

		if cb ~= nil then
			cb()
		end
	end)
end

ESX.SavePlayers = function(cb)
	local asyncTasks = {}
	local xPlayers   = ESX.GetPlayers()

	for i=1, #xPlayers, 1 do
		table.insert(asyncTasks, function(cb)
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			ESX.SavePlayer(xPlayer, cb)
		end)
	end

	Async.parallelLimit(asyncTasks, 8, function(results)
		print(('[es_extended] [^2INFO^7] Saved %s player(s)'):format(#xPlayers))
		if cb ~= nil then
			cb()
		end
	end)
end

ESX.StartDBSync = function()
	function saveData()
		ESX.SavePlayers()
		SetTimeout(10 * 60 * 1000, saveData)
	end

	SetTimeout(10 * 60 * 1000, saveData)
end

ESX.GetPlayers = function()
	local sources = {}

	for k,v in pairs(ESX.Players) do
		table.insert(sources, k)
	end

	return sources
end

ESX.GetPlayerFromId = function(source)
	return ESX.Players[tonumber(source)]
end

ESX.GetPlayerFromIdentifier = function(identifier)
	for k,v in pairs(ESX.Players) do
		if v.identifier == identifier then
			return v
		end
	end
end

ESX.RegisterUsableItem = function(item, cb)
	ESX.UsableItemsCallbacks[item] = cb
end

ESX.UseItem = function(source, item)
	ESX.UsableItemsCallbacks[item](source)
end

ESX.GetItemLabel = function(item)
	if ESX.Items[item] ~= nil then
		return ESX.Items[item].label
	end
end

ESX.CreatePickup = function(type, name, count, label, playerId, components, tintIndex)
	local pickupId = (ESX.PickupId == 65635 and 0 or ESX.PickupId + 1)
	local xPlayer = ESX.GetPlayerFromId(playerId)

	ESX.Pickups[pickupId] = {
		type  = type,
		name  = name,
		count = count,
		label = label,
		coords = xPlayer.getCoords(),
	}

	if type == 'item_weapon' then
		ESX.Pickups[pickupId].components = components
		ESX.Pickups[pickupId].tintIndex = tintIndex
	end

	TriggerClientEvent('esx:createPickup', -1, pickupId, label, playerId, type, name, components, tintIndex)
	ESX.PickupId = pickupId
end

ESX.DoesJobExist = function(job, grade)
	grade = tostring(grade)

	if job and grade then
		if ESX.Jobs[job] and ESX.Jobs[job].grades[grade] then
			return true
		end
	end

	return false
end
