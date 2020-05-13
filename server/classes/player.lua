function CreateExtendedPlayer(data)

  local self = {}

	self.source    = data.playerId
  self.maxWeight = Config.MaxWeight

  for k,v in pairs(data) do
    self[k] = v
  end

	ExecuteCommand(('add_principal identifier.license:%s group.%s'):format(self.identifier, self.group))

	self.triggerEvent = function(eventName, ...)
		TriggerClientEvent(eventName, self.source, ...)
	end

	self.setCoords = function(coords)
		self.updateCoords(coords)
		self.triggerEvent('esx:teleport', coords)
	end

	self.updateCoords = function(coords)
		self.coords = {x = ESX.Math.Round(coords.x, 1), y = ESX.Math.Round(coords.y, 1), z = ESX.Math.Round(coords.z, 1), heading = ESX.Math.Round(coords.heading or 0.0, 1)}
	end

	self.getCoords = function(vector)
		if vector then
			return vector3(self.coords.x, self.coords.y, self.coords.z)
		else
			return self.coords
		end
	end

	self.kick = function(reason)
		DropPlayer(self.source, reason)
	end

	self.setMoney = function(money)
		money = ESX.Math.Round(money)
		self.setAccountMoney('money', money)
	end

	self.getMoney = function()
		return self.getAccount('money').money
	end

	self.addMoney = function(money)
		money = ESX.Math.Round(money)
		self.addAccountMoney('money', money)
	end

	self.removeMoney = function(money)
		money = ESX.Math.Round(money)
		self.removeAccountMoney('money', money)
	end

	self.getIdentifier = function()
		return self.identifier
	end

	self.setGroup = function(newGroup)
		ExecuteCommand(('remove_principal identifier.license:%s group.%s'):format(self.identifier, self.group))
		self.group = newGroup
		ExecuteCommand(('add_principal identifier.license:%s group.%s'):format(self.identifier, self.group))
	end

	self.getGroup = function()
		return self.group
	end

	self.set = function(k, v)
		self[k] = v
	end

	self.get = function(k)
		return self[k]
	end

	self.getAccounts = function(minimal)
		if minimal then
			local minimalAccounts = {}

			for k,v in ipairs(self.accounts) do
				minimalAccounts[v.name] = v.money
			end

			return minimalAccounts
		else
			return self.accounts
		end
	end

	self.getAccount = function(account)
		for k,v in ipairs(self.accounts) do
			if v.name == account then
				return v
			end
		end
	end

	self.getInventory = function(minimal)
		if minimal then
			local minimalInventory = {}

			for k,v in ipairs(self.inventory) do
				if v.count > 0 then
					minimalInventory[v.name] = v.count
				end
			end

			return minimalInventory
		else
			return self.inventory
		end
	end

	self.getJob = function()
		return self.job
	end

	self.getLoadout = function(minimal)
		if minimal then
			local minimalLoadout = {}

			for k,v in ipairs(self.loadout) do
				minimalLoadout[v.name] = {ammo = v.ammo}
				if v.tintIndex > 0 then minimalLoadout[v.name].tintIndex = v.tintIndex end

				if #v.components > 0 then
					local components = {}

					for k2,component in ipairs(v.components) do
						if component ~= 'clip_default' then
							table.insert(components, component)
						end
					end

					if #components > 0 then
						minimalLoadout[v.name].components = components
					end
				end
			end

			return minimalLoadout
		else
			return self.loadout
		end
	end

	self.getName = function()
		return self.name
	end

	self.setName = function(newName)
		self.name = newName
	end

	self.setAccountMoney = function(accountName, money)
		if money >= 0 then
			local account = self.getAccount(accountName)

			if account then
				local prevMoney = account.money
				local newMoney = ESX.Math.Round(money)
				account.money = newMoney

				self.triggerEvent('esx:setAccountMoney', account)
			end
		end
	end

	self.addAccountMoney = function(accountName, money)
		if money > 0 then
			local account = self.getAccount(accountName)

			if account then
				local newMoney = account.money + ESX.Math.Round(money)
				account.money = newMoney

				self.triggerEvent('esx:setAccountMoney', account)
			end
		end
	end

	self.removeAccountMoney = function(accountName, money)
		if money > 0 then
			local account = self.getAccount(accountName)

			if account then
				local newMoney = account.money - ESX.Math.Round(money)
				account.money = newMoney

				self.triggerEvent('esx:setAccountMoney', account)
			end
		end
	end

	self.getInventoryItem = function(name)
		for k,v in ipairs(self.inventory) do
			if v.name == name then
				return v
			end
		end

		return
	end

	self.addInventoryItem = function(name, count)
		local item = self.getInventoryItem(name)

		if item then
			count = ESX.Math.Round(count)
			item.count = item.count + count
			self.weight = self.weight + (item.weight * count)

			TriggerEvent('esx:onAddInventoryItem', self.source, item.name, item.count)
			self.triggerEvent('esx:addInventoryItem', item.name, item.count)
		end
	end

	self.removeInventoryItem = function(name, count)
		local item = self.getInventoryItem(name)

		if item then
			count = ESX.Math.Round(count)
			local newCount = item.count - count

			if newCount >= 0 then
				item.count = newCount
				self.weight = self.weight - (item.weight * count)

				TriggerEvent('esx:onRemoveInventoryItem', self.source, item.name, item.count)
				self.triggerEvent('esx:removeInventoryItem', item.name, item.count)
			end
		end
	end

	self.setInventoryItem = function(name, count)
		local item = self.getInventoryItem(name)

		if item and count >= 0 then
			count = ESX.Math.Round(count)

			if count > item.count then
				self.addInventoryItem(item.name, count - item.count)
			else
				self.removeInventoryItem(item.name, item.count - count)
			end
		end
	end

	self.getWeight = function()
		return self.weight
	end

	self.getMaxWeight = function()
		return self.maxWeight
	end

	self.canCarryItem = function(name, count)
		local currentWeight, itemWeight = self.weight, ESX.Items[name].weight
		local newWeight = currentWeight + (itemWeight * count)

		return newWeight <= self.maxWeight
	end

  self.maxCarryItem = function(name)
		local count = 0
		local currentWeight, itemWeight = self.getWeight(), ESX.Items[name].weight
		local newWeight = self.maxWeight - currentWeight

		-- math.max(0, ... to prevent bad programmers
		return math.max(0, math.floor(newWeight / itemWeight))
	end

	self.canSwapItem = function(firstItem, firstItemCount, testItem, testItemCount)
		local firstItemObject = self.getInventoryItem(firstItem)
		local testItemObject = self.getInventoryItem(testItem)

		if firstItemObject.count >= firstItemCount then
			local weightWithoutFirstItem = ESX.Math.Round(self.weight - (firstItemObject.weight * firstItemCount))
			local weightWithTestItem = ESX.Math.Round(weightWithoutFirstItem + (testItemObject.weight * testItemCount))

			return weightWithTestItem <= self.maxWeight
		end

		return false
	end

	self.setMaxWeight = function(newWeight)
		self.maxWeight = newWeight
		self.triggerEvent('esx:setMaxWeight', self.maxWeight)
	end

	self.setJob = function(job, grade)
		grade = tostring(grade)
		local lastJob = json.decode(json.encode(self.job))

		if ESX.DoesJobExist(job, grade) then
			local jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[grade]

			self.job.id    = jobObject.id
			self.job.name  = jobObject.name
			self.job.label = jobObject.label

			self.job.grade        = tonumber(grade)
			self.job.grade_name   = gradeObject.name
			self.job.grade_label  = gradeObject.label
			self.job.grade_salary = gradeObject.salary

			if gradeObject.skin_male then
				self.job.skin_male = json.decode(gradeObject.skin_male)
			else
				self.job.skin_male = {}
			end

			if gradeObject.skin_female then
				self.job.skin_female = json.decode(gradeObject.skin_female)
			else
				self.job.skin_female = {}
			end

			TriggerEvent('esx:setJob', self.source, self.job, lastJob)
			self.triggerEvent('esx:setJob', self.job)
		else
			print(('[es_extended] [^3WARNING^7] Ignoring invalid .setJob() usage for "%s"'):format(self.identifier))
		end
	end

	self.addWeapon = function(weaponName, ammo)
		if not self.hasWeapon(weaponName) then
			local weaponLabel = ESX.GetWeaponLabel(weaponName)

			table.insert(self.loadout, {
				name = weaponName,
				ammo = ammo,
				label = weaponLabel,
				components = {},
				tintIndex = 0
			})

			self.triggerEvent('esx:addWeapon', weaponName, ammo)
			self.triggerEvent('esx:addInventoryItem', weaponLabel, false, true)
		end
	end

	self.addWeaponComponent = function(weaponName, weaponComponent)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			local component = ESX.GetWeaponComponent(weaponName, weaponComponent)

			if component then
				if not self.hasWeaponComponent(weaponName, weaponComponent) then
					table.insert(self.loadout[loadoutNum].components, weaponComponent)
					self.triggerEvent('esx:addWeaponComponent', weaponName, weaponComponent)
					self.triggerEvent('esx:addInventoryItem', component.label, false, true)
				end
			end
		end
	end

	self.addWeaponAmmo = function(weaponName, ammoCount)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			weapon.ammo = weapon.ammo + ammoCount
			self.triggerEvent('esx:setWeaponAmmo', weaponName, weapon.ammo)
		end
	end

	self.updateWeaponAmmo = function(weaponName, ammoCount)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			if ammoCount < weapon.ammo then
				weapon.ammo = ammoCount
			end
		end
	end

	self.setWeaponTint = function(weaponName, weaponTintIndex)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			local weaponNum, weaponObject = ESX.GetWeapon(weaponName)

			if weaponObject.tints and weaponObject.tints[weaponTintIndex] then
				self.loadout[loadoutNum].tintIndex = weaponTintIndex
				self.triggerEvent('esx:setWeaponTint', weaponName, weaponTintIndex)
				self.triggerEvent('esx:addInventoryItem', weaponObject.tints[weaponTintIndex], false, true)
			end
		end
	end

	self.getWeaponTint = function(weaponName)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			return weapon.tintIndex
		end

		return 0
	end

	self.removeWeapon = function(weaponName)
		local weaponLabel

		for k,v in ipairs(self.loadout) do
			if v.name == weaponName then
				weaponLabel = v.label

				for k2,v2 in ipairs(v.components) do
					self.removeWeaponComponent(weaponName, v2)
				end

				table.remove(self.loadout, k)
				break
			end
		end

		if weaponLabel then
			self.triggerEvent('esx:removeWeapon', weaponName)
			self.triggerEvent('esx:removeInventoryItem', weaponLabel, false, true)
		end
	end

	self.removeWeaponComponent = function(weaponName, weaponComponent)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			local component = ESX.GetWeaponComponent(weaponName, weaponComponent)

			if component then
				if self.hasWeaponComponent(weaponName, weaponComponent) then
					for k,v in ipairs(self.loadout[loadoutNum].components) do
						if v == weaponComponent then
							table.remove(self.loadout[loadoutNum].components, k)
							break
						end
					end

					self.triggerEvent('esx:removeWeaponComponent', weaponName, weaponComponent)
					self.triggerEvent('esx:removeInventoryItem', component.label, false, true)
				end
			end
		end
	end

	self.removeWeaponAmmo = function(weaponName, ammoCount)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			weapon.ammo = weapon.ammo - ammoCount
			self.triggerEvent('esx:setWeaponAmmo', weaponName, weapon.ammo)
		end
	end

	self.hasWeaponComponent = function(weaponName, weaponComponent)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			for k,v in ipairs(weapon.components) do
				if v == weaponComponent then
					return true
				end
			end

			return false
		else
			return false
		end
	end

	self.hasWeapon = function(weaponName)
		for k,v in ipairs(self.loadout) do
			if v.name == weaponName then
				return true
			end
		end

		return false
	end

	self.getWeapon = function(weaponName)
		for k,v in ipairs(self.loadout) do
			if v.name == weaponName then
				return k, v
			end
		end

		return
	end

	self.showNotification = function(msg, flash, saveToBrief, hudColorIndex)
		self.triggerEvent('esx:showNotification', msg, flash, saveToBrief, hudColorIndex)
	end

	self.showHelpNotification = function(msg, thisFrame, beep, duration)
		self.triggerEvent('esx:showHelpNotification', msg, thisFrame, beep, duration)
	end

  self.serialize = function()

    local data = {
      accounts   = self.getAccounts(),
      coords     = self.getCoords(),
      identifier = self.getIdentifier(),
      inventory  = self.getInventory(),
      job        = self.getJob(),
      loadout    = self.getLoadout(),
      maxWeight  = self.getMaxWeight(),
      money      = self.getMoney()
    }

    TriggerEvent('esx:player:serialize', self, function(extraData)

      for k,v in pairs(extraData) do
        data[k] = v
      end

    end)

    return data

  end

  self.serializeDB = function()

    local job = self.getJob()

    local data = {
      identifier = self.getIdentifier(),
      accounts   = json.encode(self.getAccounts(true)),
      group      = self.getGroup(),
      inventory  = json.encode(self.getInventory(true)),
      job        = job.name,
      job_grade  = job.grade,
      loadout    = json.encode(self.getLoadout(true)),
      position   = json.encode(self.getCoords())
    }

    TriggerEvent('esx:player:serialize:db', self, function(extraData)

      for k,v in pairs(extraData) do
        data[k] = v
      end

    end)

    return data

  end

  TriggerEvent('esx:player:create', self)  -- You can hook this event to extend xPlayer

  return self

end

function LoadExtendedPlayer(identifier, playerId, cb)

  MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', { ['@identifier'] = identifier }, function(result)

    local tasks = {}

    local userData = {
      playerId   = playerId,
      identifier = identifier,
      weight     = 0,
    }

    for entryName, entryValue in pairs(result[1]) do

      TriggerEvent('esx:player:load:' .. entryName, identifier, playerId, result[1], userData, function(task)
        tasks[#tasks + 1] = task
      end)

    end

    Async.parallelLimit(tasks, 5, function(results)

      for i=1, #results, 1 do

        local result = results[i]

        for k,v in pairs(result) do
          userData[k] = v
        end

      end

      local xPlayer = CreateExtendedPlayer(userData)

      ESX.Players[playerId] = xPlayer

      TriggerEvent('esx:playerLoaded', playerId, xPlayer)

      xPlayer.triggerEvent('esx:playerLoaded', xPlayer.serialize())
      xPlayer.triggerEvent('esx:createMissingPickups', ESX.Pickups)
      xPlayer.triggerEvent('esx:registerSuggestions', ESX.RegisteredCommands)

      if cb ~= nil then
        cb()
      end

    end)

  end)

end

AddEventHandler('esx:player:load:accounts', function(identifier, playerId, row, userData, addTask)

  addTask(function(cb)

    local data          = {}
    local foundAccounts = {}

    if row.accounts and row.accounts ~= '' then

      local accounts = json.decode(row.accounts)

      for account, money in pairs(accounts) do
        foundAccounts[account] = money
      end

    end

    for account, label in pairs(Config.Accounts) do

      table.insert(data, {
        name = account,
        money = foundAccounts[account] or Config.StartingAccountMoney[account] or 0,
        label = label
      })

    end

    cb({accounts = data})

  end)

end)

AddEventHandler('esx:player:load:job', function(identifier, playerId, row, userData, addTask)

  addTask(function(cb)

    local data                   = {}
    local jobObject, gradeObject = {}, {}

    if ESX.DoesJobExist(row.job, row.job_grade) then
      jobObject, gradeObject = ESX.Jobs[row.job], ESX.Jobs[row.job].grades[tostring(row.job_grade)]
    else

      print(('[es_extended] [^3WARNING^7] Ignoring invalid job for %s [job: %s, grade: %s]'):format(identifier, job, grade))

      job, grade = 'unemployed', '0'
      jobObject, gradeObject = ESX.Jobs[row.job], ESX.Jobs[row.job].grades[tostring(rrow.job_grade)]

    end

    data.id    = jobObject.id
    data.name  = jobObject.name
    data.label = jobObject.label

    data.grade        = row.job_grade
    data.grade_name   = gradeObject.name
    data.grade_label  = gradeObject.label
    data.grade_salary = gradeObject.salary

    data.skin_male   = {}
    data.skin_female = {}

    if gradeObject.skin_male   then data.skin_male   = json.decode(gradeObject.skin_male)   end
    if gradeObject.skin_female then data.skin_female = json.decode(gradeObject.skin_female) end

    cb({job = data})

  end)

end)

AddEventHandler('esx:player:load:inventory', function(identifier, playerId, row, userData, addTask)

  addTask(function(cb)

    local data = {
      weight    = userData.weight,
      inventory = {}
    }

    local foundItems = {}

    if row.inventory and row.inventory ~= '' then

      local inventory = json.decode(row.inventory)

      for name,count in pairs(inventory) do

        local item = ESX.Items[name]

        if item then
          foundItems[name] = count
        else
          print(('[es_extended] [^3WARNING^7] Ignoring invalid item "%s" for "%s"'):format(name, identifier))
        end
      end

    end

    for name,item in pairs(ESX.Items) do

      local count = foundItems[name] or 0

      if count > 0 then
        data.weight = data.weight + (item.weight * count)
      end

      table.insert(data.inventory, {
        name      = name,
        count     = count,
        label     = item.label,
        weight    = item.weight,
        usable    = ESX.UsableItemsCallbacks[name] ~= nil,
        rare      = item.rare,
        canRemove = item.canRemove
      })

    end

    table.sort(data.inventory, function(a, b)
      return a.label < b.label
    end)

    cb(data)

  end)

end)

AddEventHandler('esx:player:load:group', function(identifier, playerId, row, userData, addTask)

  addTask(function(cb)

    local data = {}

    if row.group then
      data = row.group
    else
      data.group = 'user'
    end

    cb({group = data})

  end)

end)

AddEventHandler('esx:player:load:loadout', function(identifier, playerId, row, userData, addTask)

  addTask(function(cb)

    local data = {}

    if row.loadout and row.loadout ~= '' then

      local loadout = json.decode(row.loadout)

      for name,weapon in pairs(loadout) do

        local label = ESX.GetWeaponLabel(name)

        if label then

          if not weapon.components then weapon.components = {} end
          if not weapon.tintIndex  then weapon.tintIndex  = 0  end

          table.insert(data, {
            name       = name,
            ammo       = weapon.ammo,
            label      = label,
            components = weapon.components,
            tintIndex  = weapon.tintIndex
          })

        end
      end

    end

    cb({loadout = data})

  end)

end)

AddEventHandler('esx:player:load:position', function(identifier, playerId, row, userData, addTask)

  addTask(function(cb)

    local data = {}

    if row.position and row.position ~= '' then
      data = json.decode(row.position)
    else
      print('[es_extended] [^3WARNING^7] Column "position" in "users" table is missing required default value. Using backup coords, fix your database.')
      data = {x = -269.4, y = -955.3, z = 31.2, heading = 205.8}
    end

    cb({coords = data})

  end)

end)
