local Inventory

if Config.OxInventory then
	AddEventHandler('ox_inventory:loadInventory', function(module)
		Inventory = module
	end)
end

function CreateExtendedPlayer(playerId, identifier, group, accounts, inventory, weight, job, loadout, name, coords)
	local self = {}

	self.accounts = accounts
	self.coords = coords
	self.group = group
	self.identifier = identifier
	self.inventory = inventory
	self.job = job
	self.loadout = loadout
	self.name = name
	self.playerId = playerId
	self.source = playerId
	self.variables = {}
	self.weight = weight
	self.maxWeight = Config.MaxWeight
	if Config.Multichar then self.license = 'license'.. identifier:sub(identifier:find(':'), identifier:len()) else self.license = 'license:'..identifier end

	ExecuteCommand(('add_principal identifier.%s group.%s'):format(self.license, self.group))

	function self.triggerEvent(eventName, ...)
		TriggerClientEvent(eventName, self.source, ...)
	end

	function self.setCoords(coords)
		self.updateCoords(coords)
		self.triggerEvent('esx:teleport', coords)
	end

	function self.updateCoords(coords)
		self.coords = {x = ESX.Math.Round(coords.x, 1), y = ESX.Math.Round(coords.y, 1), z = ESX.Math.Round(coords.z, 1), heading = ESX.Math.Round(coords.heading or 0.0, 1)}
	end

	function self.getCoords(vector)
		if vector then
			return vector3(self.coords.x, self.coords.y, self.coords.z)
		else
			return self.coords
		end
	end

	function self.kick(reason)
		DropPlayer(self.source, reason)
	end

	function self.setMoney(money)
		money = ESX.Math.Round(money)
		self.setAccountMoney('money', money)
	end

	function self.getMoney()
		return self.getAccount('money').money
	end

	function self.addMoney(money)
		money = ESX.Math.Round(money)
		self.addAccountMoney('money', money)
	end

	function self.removeMoney(money)
		money = ESX.Math.Round(money)
		self.removeAccountMoney('money', money)
	end

	function self.getIdentifier()
		return self.identifier
	end

	function self.setGroup(newGroup)
		ExecuteCommand(('remove_principal identifier.%s group.%s'):format(self.license, self.group))
		self.group = newGroup
		ExecuteCommand(('add_principal identifier.%s group.%s'):format(self.license, self.group))
	end

	function self.getGroup()
		return self.group
	end

	function self.set(k, v)
		self.variables[k] = v
	end

	function self.get(k)
		return self.variables[k]
	end

	function self.getAccounts(minimal)
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

	function self.getAccount(account)
		for k,v in ipairs(self.accounts) do
			if v.name == account then
				return v
			end
		end
	end

	function self.getInventory(minimal)
		if minimal then
			local minimalInventory = {}

			if not Inventory then
				for k, v in ipairs(self.inventory) do
					if v.count > 0 then
						minimalInventory[v.name] = v.count
					end
				end
			else
				for k, v in pairs(self.inventory) do
					if v.count and v.count > 0 then
						local metadata = v.metadata

						if v.metadata and next(v.metadata) == nil then
							metadata = nil
						end

						minimalInventory[#minimalInventory+1] = {
							name = v.name,
							count = v.count,
							slot = k,
							metadata = metadata
						}
					end
				end
			end

			return minimalInventory
		end

		return self.inventory
	end

	function self.getJob()
		return self.job
	end

	function self.getLoadout(minimal)
		if Inventory then return {} end
		if minimal then
			local minimalLoadout = {}

			for k,v in ipairs(self.loadout) do
				minimalLoadout[v.name] = {ammo = v.ammo}
				if v.tintIndex > 0 then minimalLoadout[v.name].tintIndex = v.tintIndex end

				if #v.components > 0 then
					local components = {}

					for k2,component in ipairs(v.components) do
						if component ~= 'clip_default' then
							components[#components + 1] = component
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

	function self.getName()
		return self.name
	end

	function self.setName(newName)
		self.name = newName
	end

	function self.setAccountMoney(accountName, money)
		if money >= 0 then
			local account = self.getAccount(accountName)

			if account then
				local newMoney = ESX.Math.Round(money)
				account.money = newMoney

				self.triggerEvent('esx:setAccountMoney', account)

				if Inventory and Inventory.accounts[accountName] then
					Inventory.SetItem(self.source, accountName, money)
				end
			end
		end
	end

	function self.addAccountMoney(accountName, money)
		if money > 0 then
			local account = self.getAccount(accountName)

			if account then
				local newMoney = account.money + ESX.Math.Round(money)
				account.money = newMoney

				self.triggerEvent('esx:setAccountMoney', account)

				if Inventory and Inventory.accounts[accountName] then
					Inventory.AddItem(self.source, accountName, money)
				end
			end
		end
	end

	function self.removeAccountMoney(accountName, money)
		if money > 0 then
			local account = self.getAccount(accountName)

			if account then
				local newMoney = account.money - ESX.Math.Round(money)
				account.money = newMoney

				self.triggerEvent('esx:setAccountMoney', account)

				if Inventory and Inventory.accounts[accountName] then
					Inventory.RemoveItem(self.source, accountName, money)
				end
			end
		end
	end

	function self.getInventoryItem(name, metadata)
		if Inventory then
			return Inventory.GetItem(self.source, name, metadata)
		end

		for k,v in ipairs(self.inventory) do
			if v.name == name then
				return v
			end
		end
	end

	function self.addInventoryItem(name, count, metadata, slot)
		if Inventory then
			return Inventory.AddItem(self.source, name, count or 1, metadata, slot)
		end

		local item = self.getInventoryItem(name)

		if item then
			count = ESX.Math.Round(count)
			item.count = item.count + count
			self.weight = self.weight + (item.weight * count)

			TriggerEvent('esx:onAddInventoryItem', self.source, item.name, item.count)
			self.triggerEvent('esx:addInventoryItem', item.name, item.count)
		end
	end

	function self.removeInventoryItem(name, count, metadata, slot)
		if Inventory then
			return Inventory.RemoveItem(self.source, name, count or 1, metadata, slot)
		end

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

	function self.setInventoryItem(name, count, metadata)
		if Inventory then
			return Inventory.SetItem(self.source, name, count, metadata)
		end

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

	function self.getWeight()
		return self.weight
	end

	function self.getMaxWeight()
		return self.maxWeight
	end

	function self.canCarryItem(name, count, metadata)
		if Inventory then
			return Inventory.CanCarryItem(self.source, name, count, metadata)
		end

		local currentWeight, itemWeight = self.weight, ESX.Items[name].weight
		local newWeight = currentWeight + (itemWeight * count)

		return newWeight <= self.maxWeight
	end

	function self.canSwapItem(firstItem, firstItemCount, testItem, testItemCount)
		if Inventory then
			return Inventory.CanSwapItem(self.source, firstItem, firstItemCount, testItem, testItemCount)
		end

		local firstItemObject = self.getInventoryItem(firstItem)
		local testItemObject = self.getInventoryItem(testItem)

		if firstItemObject.count >= firstItemCount then
			local weightWithoutFirstItem = ESX.Math.Round(self.weight - (firstItemObject.weight * firstItemCount))
			local weightWithTestItem = ESX.Math.Round(weightWithoutFirstItem + (testItemObject.weight * testItemCount))

			return weightWithTestItem <= self.maxWeight
		end

		return false
	end

	function self.setMaxWeight(newWeight)
		self.maxWeight = newWeight
		self.triggerEvent('esx:setMaxWeight', self.maxWeight)

		if Inventory then
			return Inventory.Set(self.source, 'maxWeight', newWeight)
		end
	end

	function self.setJob(job, grade)
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

	function self.addWeapon(weaponName, ammo)
		if Inventory then return end

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

	function self.addWeaponComponent(weaponName, weaponComponent)
		if Inventory then return end

		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			local component = ESX.GetWeaponComponent(weaponName, weaponComponent)

			if component then
				if not self.hasWeaponComponent(weaponName, weaponComponent) then
					self.loadout[loadoutNum].components[#self.loadout[loadoutNum].components + 1] = weaponComponent
					self.triggerEvent('esx:addWeaponComponent', weaponName, weaponComponent)
					self.triggerEvent('esx:addInventoryItem', component.label, false, true)
				end
			end
		end
	end

	function self.addWeaponAmmo(weaponName, ammoCount)
		if Inventory then return end

		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			weapon.ammo = weapon.ammo + ammoCount
			self.triggerEvent('esx:setWeaponAmmo', weaponName, weapon.ammo)
		end
	end

	function self.updateWeaponAmmo(weaponName, ammoCount)
		if Inventory then return end

		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			if ammoCount < weapon.ammo then
				weapon.ammo = ammoCount
			end
		end
	end

	function self.setWeaponTint(weaponName, weaponTintIndex)
		if Inventory then return end

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

	function self.getWeaponTint(weaponName)
		if Inventory then return 0 end

		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			return weapon.tintIndex
		end

		return 0
	end

	function self.removeWeapon(weaponName)
		if Inventory then return end

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

	function self.removeWeaponComponent(weaponName, weaponComponent)
		if Inventory then return end

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

	function self.removeWeaponAmmo(weaponName, ammoCount)
		if Inventory then return end

		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			weapon.ammo = weapon.ammo - ammoCount
			self.triggerEvent('esx:setWeaponAmmo', weaponName, weapon.ammo)
		end
	end

	function self.hasWeaponComponent(weaponName, weaponComponent)
		if Inventory then return false end

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

	function self.hasWeapon(weaponName)
		if Inventory then return false end

		for k,v in ipairs(self.loadout) do
			if v.name == weaponName then
				return true
			end
		end

		return false
	end

	function self.hasItem(item, metadata)
		if Inventory then
			return Inventory.GetItem(self.source, name, metadata)
		end

		for k,v in ipairs(self.inventory) do
			if (v.name == name) and (v.count >= 1) then
				return v, v.count
			end
		end

		return false
	end


	function self.getWeapon(weaponName)
		if Inventory then return end

		for k,v in ipairs(self.loadout) do
			if v.name == weaponName then
				return k, v
			end
		end
	end

	function self.showNotification(msg)
		self.triggerEvent('esx:showNotification', msg)
	end

	function self.showHelpNotification(msg, thisFrame, beep, duration)
		self.triggerEvent('esx:showHelpNotification', msg, thisFrame, beep, duration)
	end

	if Inventory then
		self.syncInventory = function(weight, maxWeight, items, money)
			self.weight, self.maxWeight = weight, maxWeight
			self.inventory = items

			if money then
				for k, v in pairs(money) do
					local account = self.getAccount(k)
					if ESX.Math.Round(account.money) ~= v then
						account.money = v
						self.triggerEvent('esx:setAccountMoney', account)
					end
				end
			end
		end
	end

	return self
end
