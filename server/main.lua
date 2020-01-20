AddEventHandler('es:playerLoaded', function(playerId, player)
	local tasks = {}

	local userData = {
		accounts = {},
		inventory = {},
		job = {},
		loadout = {},
		playerName = GetPlayerName(playerId),
		coords = nil
	}

	-- Get accounts
	table.insert(tasks, function(cb)
		MySQL.Async.fetchAll('SELECT name, money FROM user_accounts WHERE identifier = @identifier', {
			['@identifier'] = player.getIdentifier()
		}, function(accounts)
			local validAccounts = ESX.Table.Set(Config.Accounts)
			for k,v in ipairs(accounts) do
				if validAccounts[v.name] then
					table.insert(userData.accounts, {
						name  = v.name,
						money = v.money,
						label = Config.AccountLabels[v.name]
					})
				end
			end

			cb()
		end)
	end)

	-- Get inventory
	table.insert(tasks, function(cb)
		MySQL.Async.fetchAll('SELECT item, count FROM user_inventory WHERE identifier = @identifier', {
			['@identifier'] = player.getIdentifier()
		}, function(inventory)
			local tasks2, foundItems = {}, {}

			for k,v in ipairs(inventory) do
				local item = ESX.Items[v.item]

				if item then
					foundItems[v.item] = true

					table.insert(userData.inventory, {
						name = v.item,
						count = v.count,
						label = item.label,
						weight = item.weight,
						usable = ESX.UsableItemsCallbacks[v.item] ~= nil,
						rare = item.rare,
						canRemove = item.canRemove
					})
				else
					print(('[es_extended] [^3WARNING^7] Ignoring invalid item "%s" for "%s"'):format(v.item, player.getIdentifier()))
				end
			end

			for name,item in pairs(ESX.Items) do
				if not foundItems[name] then
					table.insert(userData.inventory, {
						name = name,
						count = 0,
						label = item.label,
						weight = item.weight,
						usable = ESX.UsableItemsCallbacks[name] ~= nil,
						rare = item.rare,
						canRemove = item.canRemove
					})

					local scope = function(item, identifier)
						table.insert(tasks2, function(cb2)
							MySQL.Async.execute('INSERT INTO user_inventory (identifier, item, count) VALUES (@identifier, @item, @count)', {
								['@identifier'] = identifier,
								['@item'] = item,
								['@count'] = 0
							}, function(rowsChanged)
								cb2()
							end)
						end)
					end

					scope(name, player.getIdentifier())
				end
			end

			Async.parallelLimit(tasks2, 5, function(results) end)

			table.sort(userData.inventory, function(a,b)
				return a.label < b.label
			end)

			cb()
		end)

	end)

	-- Get job and loadout
	table.insert(tasks, function(cb)

		local tasks2 = {}

		-- Get job name, grade and coords
		table.insert(tasks2, function(cb2)

			MySQL.Async.fetchAll('SELECT job, job_grade, loadout, position FROM users WHERE identifier = @identifier', {
				['@identifier'] = player.getIdentifier()
			}, function(result)
				local job, grade = result[1].job, tostring(result[1].job_grade)

				if ESX.DoesJobExist(job, grade) then
					local jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[grade]

					userData.job = {}

					userData.job.id    = jobObject.id
					userData.job.name  = jobObject.name
					userData.job.label = jobObject.label

					userData.job.grade        = tonumber(grade)
					userData.job.grade_name   = gradeObject.name
					userData.job.grade_label  = gradeObject.label
					userData.job.grade_salary = gradeObject.salary

					userData.job.skin_male    = {}
					userData.job.skin_female  = {}

					if gradeObject.skin_male then
						userData.job.skin_male = json.decode(gradeObject.skin_male)
					end

					if gradeObject.skin_female then
						userData.job.skin_female = json.decode(gradeObject.skin_female)
					end
				else
					print(('[es_extended] [^3WARNING^7] Ignoring invalid job for %s [job: %s, grade: %s]'):format(player.getIdentifier(), job, grade))

					local job, grade = 'unemployed', '0'
					local jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[grade]

					userData.job = {}

					userData.job.id    = jobObject.id
					userData.job.name  = jobObject.name
					userData.job.label = jobObject.label

					userData.job.grade        = tonumber(grade)
					userData.job.grade_name   = gradeObject.name
					userData.job.grade_label  = gradeObject.label
					userData.job.grade_salary = gradeObject.salary

					userData.job.skin_male    = {}
					userData.job.skin_female  = {}
				end

				if result[1].loadout then
					userData.loadout = json.decode(result[1].loadout)

					-- Compatibility with old loadouts prior to components update
					for k,v in ipairs(userData.loadout) do
						if v.components == nil then
							v.components = {}
						end
					end
				end

				userData.coords = json.decode(result[1].position)
				cb2()
			end)

		end)

		Async.series(tasks2, cb)

	end)

	-- Run Tasks
	Async.parallel(tasks, function(results)
		local xPlayer = CreateExtendedPlayer(player, userData.accounts, userData.inventory, userData.job, userData.loadout, userData.playerName, userData.coords)

		xPlayer.getMissingAccounts(function(missingAccounts)
			if #missingAccounts > 0 then
				for i=1, #missingAccounts, 1 do
					table.insert(xPlayer.accounts, {
						name = missingAccounts[i],
						money = 0,
						label = Config.AccountLabels[missingAccounts[i]]
					})
				end

				xPlayer.createAccounts(missingAccounts)
			end

			ESX.Players[playerId] = xPlayer

			TriggerEvent('esx:playerLoaded', playerId, xPlayer)

			xPlayer.triggerEvent('esx:playerLoaded', {
				identifier = xPlayer.identifier,
				accounts = xPlayer.getAccounts(),
				coords = xPlayer.getCoords(),
				inventory = xPlayer.getInventory(),
				job = xPlayer.getJob(),
				loadout = xPlayer.getLoadout(),
				money = xPlayer.getMoney(),
				maxWeight = xPlayer.maxWeight
			})

			xPlayer.displayMoney(xPlayer.getMoney())
			xPlayer.triggerEvent('esx:createMissingPickups', ESX.Pickups)
		end)
	end)
end)

AddEventHandler('playerDropped', function(reason)
	local playerId = source
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if xPlayer then
		TriggerEvent('esx:playerDropped', playerId, reason)

		ESX.SavePlayer(xPlayer, function()
			ESX.Players[playerId] = nil
			ESX.LastPlayerData[playerId] = nil
		end)
	end
end)

RegisterNetEvent('esx:updateCoords')
AddEventHandler('esx:updateCoords', function(coords)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer then
		xPlayer.updateCoords(coords)
	end
end)

RegisterNetEvent('esx:giveInventoryItem')
AddEventHandler('esx:giveInventoryItem', function(target, type, itemName, itemCount)
	local playerId = source
	local sourceXPlayer = ESX.GetPlayerFromId(playerId)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if type == 'item_standard' then
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)
		local targetItem = targetXPlayer.getInventoryItem(itemName)

		if itemCount > 0 and sourceItem.count >= itemCount then
			if targetXPlayer.canCarryItem(itemName, itemCount) then
				sourceXPlayer.removeInventoryItem(itemName, itemCount)
				targetXPlayer.addInventoryItem   (itemName, itemCount)

				sourceXPlayer.showNotification(_U('gave_item', itemCount, sourceItem.label, targetXPlayer.name))
				targetXPlayer.showNotification(_U('received_item', itemCount, sourceItem.label, sourceXPlayer.name))
			else
				sourceXPlayer.showNotification(_U('ex_inv_lim', targetXPlayer.name))
			end
		else
			sourceXPlayer.showNotification(_U('imp_invalid_quantity'))
		end
	elseif type == 'item_money' then
		if itemCount > 0 and sourceXPlayer.getMoney() >= itemCount then
			sourceXPlayer.removeMoney(itemCount)
			targetXPlayer.addMoney   (itemCount)

			sourceXPlayer.showNotification(_U('gave_money', ESX.Math.GroupDigits(itemCount), targetXPlayer.name))
			targetXPlayer.showNotification(_U('received_money', ESX.Math.GroupDigits(itemCount), sourceXPlayer.name))
		else
			sourceXPlayer.showNotification(_U('imp_invalid_amount'))
		end
	elseif type == 'item_account' then
		if itemCount > 0 and sourceXPlayer.getAccount(itemName).money >= itemCount then
			sourceXPlayer.removeAccountMoney(itemName, itemCount)
			targetXPlayer.addAccountMoney   (itemName, itemCount)

			sourceXPlayer.showNotification(_U('gave_account_money', ESX.Math.GroupDigits(itemCount), Config.AccountLabels[itemName], targetXPlayer.name))
			targetXPlayer.showNotification(_U('received_account_money', ESX.Math.GroupDigits(itemCount), Config.AccountLabels[itemName], sourceXPlayer.name))
		else
			sourceXPlayer.showNotification(_U('imp_invalid_amount'))
		end
	elseif type == 'item_weapon' then
		if sourceXPlayer.hasWeapon(itemName) then
			local weaponLabel = ESX.GetWeaponLabel(itemName)

			if not targetXPlayer.hasWeapon(itemName) then
				local weaponNum, weapon = sourceXPlayer.getWeapon(itemName)
				itemCount = weapon.ammo

				sourceXPlayer.removeWeapon(itemName)
				targetXPlayer.addWeapon(itemName, itemCount)

				if itemCount > 0 then
					sourceXPlayer.showNotification(_U('gave_weapon_withammo', weaponLabel, itemCount, targetXPlayer.name))
					targetXPlayer.showNotification(_U('received_weapon_withammo', weaponLabel, itemCount, sourceXPlayer.name))
				else
					sourceXPlayer.showNotification(_U('gave_weapon', weaponLabel, targetXPlayer.name))
					targetXPlayer.showNotification(_U('received_weapon', weaponLabel, sourceXPlayer.name))
				end
			else
				sourceXPlayer.showNotification(_U('gave_weapon_hasalready', targetXPlayer.name, weaponLabel))
				targetXPlayer.showNotification(_U('received_weapon_hasalready', sourceXPlayer.name, weaponLabel))
			end
		end
	elseif type == 'item_ammo' then
		if sourceXPlayer.hasWeapon(itemName) then
			if targetXPlayer.hasWeapon(itemName) then
				local weaponNum, weapon = sourceXPlayer.getWeapon(itemName)

				if weapon.ammo >= itemCount then
					sourceXPlayer.removeWeaponAmmo(itemName, itemCount)
					targetXPlayer.addWeaponAmmo(itemName, itemCount)

					sourceXPlayer.showNotification(_U('gave_weapon_ammo', itemCount, weapon.label, targetXPlayer.name))
					targetXPlayer.showNotification(_U('received_weapon_ammo', itemCount, weapon.label, sourceXPlayer.name))
				end
			else
				sourceXPlayer.showNotification(_U('gave_weapon_noweapon', targetXPlayer.name))
				targetXPlayer.showNotification(_U('received_weapon_noweapon', sourceXPlayer.name, weapon.label))
			end
		end
	end
end)

RegisterNetEvent('esx:removeInventoryItem')
AddEventHandler('esx:removeInventoryItem', function(type, itemName, itemCount)
	local playerId = source
	local xPlayer = ESX.GetPlayerFromId(source)

	if type == 'item_standard' then
		if itemCount == nil or itemCount < 1 then
			xPlayer.showNotification(_U('imp_invalid_quantity'))
		else
			local xItem = xPlayer.getInventoryItem(itemName)

			if (itemCount > xItem.count or xItem.count < 1) then
				xPlayer.showNotification(_U('imp_invalid_quantity'))
			else
				xPlayer.removeInventoryItem(itemName, itemCount)
				local pickupLabel = ('~y~%s~s~ [~b~%s~s~]'):format(xItem.label, itemCount)
				ESX.CreatePickup('item_standard', itemName, itemCount, pickupLabel, playerId)
				xPlayer.showNotification(_U('threw_standard', itemCount, xItem.label))
			end
		end
	elseif type == 'item_money' then
		if itemCount == nil or itemCount < 1 then
			xPlayer.showNotification(_U('imp_invalid_amount'))
		else
			local playerCash = xPlayer.getMoney()

			if (itemCount > playerCash or playerCash < 1) then
				xPlayer.showNotification(_U('imp_invalid_amount'))
			else
				xPlayer.removeMoney(itemCount)
				local pickupLabel = ('~y~%s~s~ [~g~%s~s~]'):format(_U('cash'), _U('locale_currency', ESX.Math.GroupDigits(itemCount)))
				ESX.CreatePickup('item_money', 'money', itemCount, pickupLabel, playerId)
				xPlayer.showNotification(_U('threw_money', ESX.Math.GroupDigits(itemCount)))
			end
		end
	elseif type == 'item_account' then
		if itemCount == nil or itemCount < 1 then
			xPlayer.showNotification(_U('imp_invalid_amount'))
		else
			local account = xPlayer.getAccount(itemName)

			if (itemCount > account.money or account.money < 1) then
				xPlayer.showNotification(_U('imp_invalid_amount'))
			else
				xPlayer.removeAccountMoney(itemName, itemCount)
				local pickupLabel = ('~y~%s~s~ [~g~%s~s~]'):format(account.label, _U('locale_currency', ESX.Math.GroupDigits(itemCount)))
				ESX.CreatePickup('item_account', itemName, itemCount, pickupLabel, playerId)
				xPlayer.showNotification(_U('threw_account', ESX.Math.GroupDigits(itemCount), string.lower(account.label)))
			end
		end
	elseif type == 'item_weapon' then
		itemName = string.upper(itemName)

		if xPlayer.hasWeapon(itemName) then
			local weaponNum, weapon = xPlayer.getWeapon(itemName)
			xPlayer.removeWeapon(itemName)

			local pickupLabel = ('~y~%s~s~ [~g~%s~s~ ammo]'):format(weapon.label, weapon.ammo)
			ESX.CreatePickup('item_weapon', itemName, weapon.ammo, pickupLabel, playerId, weapon.components)

			if weapon.ammo > 0 then
				xPlayer.showNotification(_U('threw_weapon_ammo', weapon.label, weapon.ammo))
			else
				xPlayer.showNotification(_U('threw_weapon', weapon.label))
			end
		end
	end
end)

RegisterNetEvent('esx:useItem')
AddEventHandler('esx:useItem', function(itemName)
	local xPlayer = ESX.GetPlayerFromId(source)
	local count = xPlayer.getInventoryItem(itemName).count

	if count > 0 then
		ESX.UseItem(source, itemName)
	else
		xPlayer.showNotification(_U('act_imp'))
	end
end)

RegisterNetEvent('esx:onPickup')
AddEventHandler('esx:onPickup', function(id)
	local pickup, xPlayer, success = ESX.Pickups[id], ESX.GetPlayerFromId(source)

	if pickup then
		if pickup.type == 'item_standard' then
			if xPlayer.canCarryItem(pickup.name, pickup.count) then
				xPlayer.addInventoryItem(pickup.name, pickup.count)
				success = true
			else
				xPlayer.showNotification(_U('threw_cannot_pickup'))
			end
		elseif pickup.type == 'item_money' then
			success = true
			xPlayer.addMoney(pickup.count)
		elseif pickup.type == 'item_account' then
			success = true
			xPlayer.addAccountMoney(pickup.name, pickup.count)
		elseif pickup.type == 'item_weapon' then
			if xPlayer.hasWeapon(pickup.name) then
				xPlayer.showNotification(_U('threw_weapon_already'))
			else
				success = true
				xPlayer.addWeapon(pickup.name, pickup.count)

				for k,v in ipairs(pickup.components) do
					xPlayer.addWeaponComponent(pickup.name, v)
				end
			end
		end

		if success then
			ESX.Pickups[id] = nil
			TriggerClientEvent('esx:removePickup', -1, id)
		end
	end
end)

ESX.RegisterServerCallback('esx:getPlayerData', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	cb({
		identifier   = xPlayer.identifier,
		accounts     = xPlayer.getAccounts(),
		inventory    = xPlayer.getInventory(),
		job          = xPlayer.getJob(),
		loadout      = xPlayer.getLoadout(),
		money        = xPlayer.getMoney()
	})
end)

ESX.RegisterServerCallback('esx:getOtherPlayerData', function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(target)

	cb({
		identifier   = xPlayer.identifier,
		accounts     = xPlayer.getAccounts(),
		inventory    = xPlayer.getInventory(),
		job          = xPlayer.getJob(),
		loadout      = xPlayer.getLoadout(),
		money        = xPlayer.getMoney()
	})
end)

ESX.RegisterServerCallback('esx:getPlayerNames', function(source, cb, players)
	players[source] = nil

	for playerId,v in pairs(players) do
		local xPlayer = ESX.GetPlayerFromId(playerId)

		if xPlayer then
			players[playerId] = xPlayer.getName()
		else
			players[playerId] = nil
		end
	end

	cb(players)
end)

ESX.StartDBSync()
ESX.StartPayCheck()
