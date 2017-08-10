local Charset = {}

for i = 48,  57 do table.insert(Charset, string.char(i)) end
for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

ESX.GetConfig = function()
	return Config
end

ESX.GetRandomString = function(length)

  math.randomseed(os.time())

  if length > 0 then
    return ESX.GetRandomString(length - 1) .. Charset[math.random(1, #Charset)]
  else
    return ''
  end
  
end

ESX.RegisterServerCallback = function(name, cb)
	ESX.ServerCallbacks[name] = cb
end

ESX.TriggerServerCallback = function(name, requestId, source, cb, a, b, c, d, e, f, g ,h ,i ,j ,k, l, m, n, o, p, q, r, s, t, u ,v ,w, x ,y ,z)
	ESX.ServerCallbacks[name](source, cb, a, b, c, d, e, f, g ,h ,i ,j ,k, l, m, n, o, p, q, r, s, t, u ,v ,w, x ,y ,z)
end

ESX.SavePlayer = function(xPlayer, cb)

	local asyncTasks     = {}
	xPlayer.lastPosition = xPlayer.get('coords')

	-- User accounts
	for i=1, #xPlayer.accounts, 1 do

		if ESX.LastPlayerData[xPlayer.source].accounts[xPlayer.accounts[i].name] ~= xPlayer.accounts[i].money then

			table.insert(asyncTasks, function(cb)

				MySQL.Async.execute(
					'UPDATE user_accounts SET `money` = @money WHERE identifier = @identifier AND name = @name',
					{
						['@money']      = xPlayer.accounts[i].money,
						['@identifier'] = xPlayer.identifier,
						['@name']       = xPlayer.accounts[i].name
					},
					function(rowsChanged)
						cb()
					end
				)

			end)

			ESX.LastPlayerData[xPlayer.source].accounts[xPlayer.accounts[i].name] = xPlayer.accounts[i].money

		end

	end

	-- Inventory items
	for i=1, #xPlayer.inventory, 1 do

		if ESX.LastPlayerData[xPlayer.source].items[xPlayer.inventory[i].name] ~= xPlayer.inventory[i].count then

			table.insert(asyncTasks, function(cb)

				MySQL.Async.execute(
					'UPDATE user_inventory SET `count` = @count WHERE identifier = @identifier AND item = @item',
					{
						['@count']      = xPlayer.inventory[i].count,
						['@identifier'] = xPlayer.identifier,
						['@item']       = xPlayer.inventory[i].name
					},
					function(rowsChanged)
						cb()
					end
				)

			end)

			ESX.LastPlayerData[xPlayer.source].items[xPlayer.inventory[i].name] = xPlayer.inventory[i].count

		end

	end

	-- Job, loadout and position
	table.insert(asyncTasks, function(cb)

		MySQL.Async.execute(
			'UPDATE users SET `job` = @job, `job_grade` = @job_grade, `loadout` = @loadout, `position` = @position WHERE identifier = @identifier',
			{
				['@job']        = xPlayer.job.name,
				['@job_grade']  = xPlayer.job.grade,
				['@loadout']    = json.encode(xPlayer.loadout),
				['@position']   = json.encode(xPlayer.lastPosition),
				['@identifier'] = xPlayer.identifier
			},
			function(rowsChanged)
				cb()
			end
		)

	end)

	Async.parallel(asyncTasks, function(results)
		
		RconPrint('[SAVED] ' .. xPlayer.name .. "\n")

		if cb ~= nil then
			cb()
		end

	end)

end

ESX.SavePlayers = function(cb)

	local asyncTasks = {}
	local players    = ESX.GetPlayers()

	for k,v in pairs(players) do
		table.insert(asyncTasks, function(cb)
			ESX.SavePlayer(v, cb)
		end)
	end

	Async.parallelLimit(asyncTasks, 15, function(results)
		
		RconPrint('[SAVED] All players' .. "\n")

		if cb ~= nil then
			cb()
		end

	end)

end

ESX.StartDBSync = function()
	
	function saveData()
		ESX.SavePlayers()
		SetTimeout(60000, saveData)
	end

	SetTimeout(60000, saveData)

end

ESX.GetPlayers = function()
	return ESX.Players
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

ESX.GetWeaponList = function()
	return Config.Weapons
end

ESX.GetWeaponLabel = function(name)
	
	name          = string.upper(name)
	local weapons = ESX.GetWeaponList()
	
	for i=1, #weapons, 1 do
		if weapons[i].name == name then
			return weapons[i].label
		end
	end

end

RegisterServerEvent('esx:clientLog')
AddEventHandler('esx:clientLog', function(msg)
	RconPrint(msg .. "\n")
end)

RegisterServerEvent('esx:triggerServerCallback')
AddEventHandler('esx:triggerServerCallback', function(name, requestId, a, b, c, d, e, f, g ,h ,i ,j ,k, l, m, n, o, p, q, r, s, t, u ,v ,w, x ,y ,z)
	local _source = source
	ESX.TriggerServerCallback(name, requestID, _source, function(a, b, c, d, e, f, g ,h ,i ,j ,k, l, m, n, o, p, q, r, s, t, u ,v ,w, x ,y ,z)
		TriggerClientEvent('esx:serverCallback', _source, requestId, a, b, c, d, e, f, g ,h ,i ,j ,k, l, m, n, o, p, q, r, s, t, u ,v ,w, x ,y ,z)
	end, a, b, c, d, e, f, g ,h ,i ,j ,k, l, m, n, o, p, q, r, s, t, u ,v ,w, x ,y ,z)
end)
