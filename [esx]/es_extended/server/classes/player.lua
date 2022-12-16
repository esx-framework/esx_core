function CreateExtendedPlayer(playerId, identifier, group, accounts, inventory, weight, job, loadout, name, coords)
	local targetOverrides = Config.PlayerFunctionOverride and Core.PlayerFunctionOverrides[Config.PlayerFunctionOverride] or {}
	local xPlayer = {
		accounts = accounts,
		coords = coords,
		group = group,
		identifier = identifier,
		inventory = inventory,
		job = job,
		loadout = loadout,
		name = name,
		playerId = playerId,
		source = playerId,
		ped = GetPlayerPed(playerId),
		variables = {},
		weight = weight,
		maxWeight = Config.MaxWeight,
		license = Config.Multichar and 'license'.. identifier:sub(identifier:find(':'), identifier:len()) or 'license:'..identifier,

		triggerEvent = function (self, eventName, ...)
			TriggerClientEvent(eventName, self.playerId, ...)
		end,

		updatePed = function(self)
			SetTimeout(1000,function()
				if self.ped ~= GetPlayerPed(self.playerId) then
					self.ped = GetPlayerPed(self.playerId)
					self:triggerEvent('esx:updatePed', self.ped)
					TriggerEvent('esx:updatePed', self.playerId, self.ped)
					Player(self.playerId).state:set("ped", self.ped, true)
				end
				self:updatePed()
			end)
		end,

		getPed = function(self)
			return self.ped
		end,

		setCoords = function(self, coord)
			local vector = type(coord) == "vector4" and coord or type(coord) == "vector3" and vector4(coord, 0.0) or
			vec(coord.x, coord.y, coord.z, coord.w or 0.0)
			SetEntityCoords(self.ped, vector.x, vector.y, vector.z, false, false, false, false)
			SetEntityHeading(self.ped, vector.w)
		end,

		updateCoords = function(self)
			SetTimeout(1000,function()
				if DoesEntityExist(self.ped) then
					local coord = GetEntityCoords(self.ped)
					local distance = #(coord - vector3(self.coords.x, self.coords.y, self.coords.z))
					if distance > 1.5 then
						local heading = GetEntityHeading(self.ped)
						self.coords = {
							x = coords.x,
							y = coords.y,
							z = coords.z,
							heading = heading or 0.0
						}
					end
				end
				self:updateCoords()
			end)
		end,

		getCoords = function(self, vector)
			return vector and vector3(self.coords.x, self.coords.y, self.coords.z) or self.coords
		end,

		kick = function(self, reason)
			DropPlayer(self.playerId, reason)
		end,

		getAccount = function(self, account)
			for i=1, #self.accounts do
				if self.accounts[i].name == account then
					return self.accounts[i]
				end
			end
		end,

		getAccounts = function(self, minimal)
			if minimal then
				local minimalAccounts = {}

				for i=1, #self.accounts do
					minimalAccounts[self.accounts[i].name] = self.accounts[i].money
				end

				return minimalAccounts
			else
				return self.accounts
			end
		end,

		setAccountMoney = function(self, accountName, amount, reason)
			reason = reason or 'unknown'
			if not tonumber(amount) then
				print(('[^1ERROR^7] Tried To Set Account ^5%s^0 For Player ^5%s^0 To An Invalid Number -> ^5%s^7'):format(accountName, self.playerId, amount))
				return
			end
			if amount >= 0 then
				local account = self:getAccount(accountName)

				if account then
					amount = account.round and ESX.Math.Round(amount) or amount
					self.accounts[account.index].money = amount
					self:triggerEvent('esx:setAccountMoney', account)
					TriggerEvent('esx:setAccountMoney', self.playerId, accountName, amount, reason)
				else
					print(('[^1ERROR^7] Tried To Set Invalid Account ^5%s^0 For Player ^5%s^0!'):format(accountName, self.playerId))
				end
			else
				print(('[^1ERROR^7] Tried To Set Account ^5%s^0 For Player ^5%s^0 To An Invalid Number -> ^5%s^7'):format(accountName, self.playerId, amount))
			end
		end,

		addAccountMoney = function(self, accountName, amount, reason)
			reason = reason or 'Unknown'
			if not tonumber(amount) then 
				print(('[^1ERROR^7] Tried To Set Account ^5%s^0 For Player ^5%s^0 To An Invalid Number -> ^5%s^7'):format(accountName, self.playerId, amount))
				return
			end
			if amount > 0 then
				local account = self:getAccount(accountName)
				if account then
					amount = account.round and ESX.Math.Round(amount) or amount
					self.accounts[account.index].money += amount
					self:triggerEvent('esx:setAccountMoney', account)
					TriggerEvent('esx:addAccountMoney', self.playerId, accountName, amount, reason)
				else
					print(('[^1ERROR^7] Tried To Set Add To Invalid Account ^5%s^0 For Player ^5%s^0!'):format(accountName, self.playerId))
				end
			else
				print(('[^1ERROR^7] Tried To Set Account ^5%s^0 For Player ^5%s^0 To An Invalid Number -> ^5%s^7'):format(accountName, self.playerId, amount))
			end
		end,

		removeAccountMoney = function(self, accountName, amount, reason)
			reason = reason or 'Unknown'
			if not tonumber(amount) then 
				print(('[^1ERROR^7] Tried To Set Account ^5%s^0 For Player ^5%s^0 To An Invalid Number -> ^5%s^7'):format(accountName, self.playerId, amount))
				return
			end
			if amount > 0 then
				local account = self:getAccount(accountName)

				if account then
					amount = account.round and ESX.Math.Round(amount) or amount
					self.accounts[account.index].money -= amount
					self:triggerEvent('esx:setAccountMoney', account)
					TriggerEvent('esx:removeAccountMoney', self.playerId, accountName, amount, reason)
				else
					print(('[^1ERROR^7] Tried To Set Add To Invalid Account ^5%s^0 For Player ^5%s^0!'):format(accountName, self.playerId))
				end
			else
				print(('[^1ERROR^7] Tried To Set Account ^5%s^0 For Player ^5%s^0 To An Invalid Number -> ^5%s^7'):format(accountName, self.playerId, amount))
			end
		end,

		setMoney = function (self, amount)
			amount = ESX.Math.Round(amount)
			self:setAccountMoney('money', amount)
		end,

		getMoney = function(self)
			return self:getAccount('money').money
		end,

		addMoney = function(self, amount, reason)
			amount = ESX.Math.Round(amount)
			self:addAccountMoney('money', amount, reason)
		end,

		removeMoney = function(self, amount, reason)
			amount = ESX.Math.Round(amount)
			self:removeAccountMoney('money', amount, reason)
		end,

		getGroup = function(self)
			return self.group
		end,

		setGroup = function(self, newGroup)
			ExecuteCommand(('remove_principal identifier.%s group.%s'):format(self.license, self.group))
			self.group = newGroup
			Player(self.playerId).state:set("group", self.group, true)
			ExecuteCommand(('add_principal identifier.%s group.%s'):format(self.license, self.group))
		end,

		getIdentifier = function(self)
			return self.identifier
		end,

		set = function(self, key, value)
			self.variables[key] = value
			Player(self.playerId).state:set(key, value, true)
		end,

		get = function(self, key)
			return self.variables[key]
		end,

		getJob = function(self)
			return self.job
		end,

		setJob = function(self, jobName, grade)
			grade = tostring(grade)
			local lastJob = json.decode(json.encode(self.job))

			if ESX.DoesJobExist(jobName, grade) then
				local jobObject, gradeObject = ESX.Jobs[jobName], ESX.Jobs[jobName].grades[grade]

				self.job.id = jobObject.id
				self.job.name = jobObject.name
				self.job.label = jobObject.label

				self.job.grade = tonumber(grade)
				self.job.grade_name = gradeObject.name
				self.job.grade_label = gradeObject.label
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

				TriggerEvent('esx:setJob', self.playerId, self.job, lastJob)
				self:triggerEvent('esx:setJob', self.job)
				Player(self.playerId).state:set("job", self.job, true)
			else
				print(('[es_extended] [^3WARNING^7] Ignoring invalid ^5:setJob()^7 usage for ID: ^5%s^7, Job: ^5%s^7'):format(self.playerId, job))
			end
		end,

		getName = function(self)
			return self.name
		end,

		setName = function(self, newName)
			self.name = newName
			Player(self.playerId).state:set("name", newName, true)
		end,

		getWeight = function(self)
			return self.weight
		end,

		getMaxWeight = function(self)
			return self.maxWeight
		end,

		setMaxWeight = function(self, newWeight)
			self.maxWeight = newWeight
			Player(self.playerId).state:set("maxWeight", newWeight, true)
			self:triggerEvent('esx:setMaxWeight', newWeight)
		end,

		getInventory = function(self, minimal)
			if minimal then
				local minimalInventory = {}

				for _, v in ipairs(self.inventory) do
					if v.count > 0 then
						minimalInventory[v.name] = v.count
					end
				end

				return minimalInventory
			end

			return self.inventory
		end,

		getInventoryItem = function(self, item, metadata)
			for _,v in ipairs(self.inventory) do
				if v.name == item then
					return v
				end
			end
		end,

		addInventoryItem = function(self, itemName, count, metadata, slot)
			local item = self:getInventoryItem(itemName)

			if item then
				count = ESX.Math.Round(count)
				item.count = item.count + count
				self.weight = self.weight + (item.weight * count)
				TriggerEvent('esx:onAddInventoryItem', self.playerId, item.name, item.count)
				self:triggerEvent('esx:addInventoryItem', item.name, item.count)
				Player(self.playerId).state:set("weight", self.weight, true)
			end
		end,

		removeInventoryItem = function(self, itemName, count, metadata, slot)
			local item = self:getInventoryItem(itemName)

			if item then
				count = ESX.Math.Round(count)
				local newCount = item.count - count

				if newCount >= 0 then
					item.count = newCount
					self.weight = self.weight - (item.weight * count)
					TriggerEvent('esx:onRemoveInventoryItem', self.playerId, item.name, item.count)
					self:triggerEvent('esx:removeInventoryItem', item.name, item.count)
					Player(self.playerId).state:set("weight", self.weight, true)
				end
			end
		end,

		setInventoryItem = function(self, itemName, count, metadata)
			local item = self:getInventoryItem(itemName)

			if item and count >= 0 then
				count = ESX.Math.Round(count)

				if count > item.count then
					self:addInventoryItem(item.name, count - item.count)
				else
					self:removeInventoryItem(item.name, item.count - count)
				end
			end
		end,

		canCarryItem = function(self, itemName, count, metadata)
			if ESX.Items[itemName] then
				local currentWeight, itemWeight = self.weight, ESX.Items[itemName].weight
				local newWeight = currentWeight + (itemWeight * count)

				return newWeight <= self.maxWeight
			else
				print(('[^3WARNING^7] Item ^5"%s"^7 was used but does not exist!'):format(itemName))
			end
		end,

		canSwapItem = function(self, firstItem, firstItemCount, testItem, testItemCount)
			local firstItemObject = self:getInventoryItem(firstItem)
			local testItemObject = self:getInventoryItem(testItem)

			if firstItemObject.count >= firstItemCount then
				local weightWithoutFirstItem = ESX.Math.Round(self.weight - (firstItemObject.weight * firstItemCount))
				local weightWithTestItem = ESX.Math.Round(weightWithoutFirstItem + (testItemObject.weight * testItemCount))

				return weightWithTestItem <= self.maxWeight
			end

			return false
		end,

		hasItem = function(self, itemName, metadata)
			for _, v in ipairs(self.inventory) do
				if (v.name == itemName) and (v.count >= 1) then
					return v, v.count
				end
			end

			return false
		end,

		getLoadout = function(self, minimal)
			if minimal then
				local minimalLoadout = {}

				for _, v in ipairs(self.loadout) do
					minimalLoadout[v.name] = {ammo = v.ammo}
					if v.tintIndex > 0 then minimalLoadout[v.name].tintIndex = v.tintIndex end

					if #v.components > 0 then
						local components = {}

						for _, component in ipairs(v.components) do
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
		end,

		hasWeapon = function(self, weaponName)
			for _, v in ipairs(self.loadout) do
				if v.name == weaponName then
					return true
				end
			end

			return false
		end,

		getWeapon = function(self, weaponName)
			for k,v in ipairs(self.loadout) do
				if v.name == weaponName then
					return k, v
				end
			end
		end,

		addWeapon = function(self, weaponName, ammo)
			if self:hasWeapon(weaponName) then
				print(('[^1ERROR^7] Player already has this weapon ^5%s'):format(weaponName))
				return
			end

			local weaponLabel = ESX.GetWeaponLabel(weaponName)

			table.insert(self.loadout, {
				name = weaponName,
				ammo = ammo,
				label = weaponLabel,
				components = {},
				tintIndex = 0
			})

			GiveWeaponToPed(self.ped, joaat(weaponName), ammo, false, false)
			self:triggerEvent('esx:addInventoryItem', weaponLabel, false, true)
		end,

		hasWeaponComponent = function(self, weaponName, weaponComponent)
			local loadoutNum, weapon = self:getWeapon(weaponName)
			if not weapon then
				print(('[^1ERROR^7] Weapon not exist ^5%s'):format(weaponName))
				return false
			end

			for _, v in ipairs(weapon.components) do
				if v == weaponComponent then
					return true
				end
			end
			return false
		end,

		addWeaponComponent = function(self, weaponName, weaponComponent)
			local loadoutNum, weapon = self:getWeapon(weaponName)
			if not weapon then
				print(('[^1ERROR^7] Weapon not exist ^5%s'):format(weaponName))
				return
			end

			local component = ESX.GetWeaponComponent(weaponName, weaponComponent)
			if not component then
				print(('[^1ERROR^7] Weapon component not exist ^5%s'):format(weaponComponent))
				return
			end

			if not self:hasWeaponComponent(weaponName, weaponComponent) then
				print(('[^1ERROR^7] Player not owning this component ^5%s'):format(weaponComponent))
				return
			end

			self.loadout[loadoutNum].components[#self.loadout[loadoutNum].components + 1] = weaponComponent
			local componentHash = ESX.GetWeaponComponent(weaponName, weaponComponent).hash
			GiveWeaponComponentToPed(self.ped, joaat(weaponName), componentHash)
			self:triggerEvent('esx:addInventoryItem', component.label, false, true)
		end,

		addWeaponAmmo = function(self, weaponName, ammoCount)
			local loadoutNum, weapon = self:getWeapon(weaponName)

			if not weapon then
				print(('[^1ERROR^7] Weapon not exist ^5%s'):format(weaponName))
				return
			end

			weapon.ammo = weapon.ammo + ammoCount
			SetPedAmmo(self.ped, joaat(weaponName), weapon.ammo)
		end,

		updateWeaponAmmo = function(self, weaponName, ammoCount)
			local loadoutNum, weapon = self:getWeapon(weaponName)

			if not weapon then
				print(('[^1ERROR^7] Weapon not exist ^5%s'):format(weaponName))
				return
			end

			weapon.ammo = ammoCount
		end,

		setWeaponTint = function(self, weaponName, weaponTintIndex)
			local loadoutNum, weapon = self:getWeapon(weaponName)

			if not weapon then
				print(('[^1ERROR^7] Weapon not exist ^5%s'):format(weaponName))
				return
			end

			local weaponNum, weaponObject = ESX.GetWeapon(weaponName)

			if weaponObject.tints and weaponObject.tints[weaponTintIndex] then
				self.loadout[loadoutNum].tintIndex = weaponTintIndex
				self:triggerEvent('esx:setWeaponTint', weaponName, weaponTintIndex)
				self:triggerEvent('esx:addInventoryItem', weaponObject.tints[weaponTintIndex], false, true)
			end
		end,

		getWeaponTint = function(self, weaponName)
			local loadoutNum, weapon = self:getWeapon(weaponName)

			if not weapon then
				print(('[^1ERROR^7] Weapon not exist ^5%s'):format(weaponName))
				return 0
			end

			return weapon.tintIndex
		end,

		removeWeapon = function(self, weaponName)
			local weaponLabel

			for k,v in ipairs(self.loadout) do
				if v.name == weaponName then
					weaponLabel = v.label

					for _, key in ipairs(v.components) do
						self:removeWeaponComponent(weaponName, key)
					end

					table.remove(self.loadout, k)
					break
				end
			end

			if weaponLabel then
				self:triggerEvent('esx:removeWeapon', weaponName)
				self:triggerEvent('esx:removeInventoryItem', weaponLabel, false, true)
			end
		end,

		removeWeaponComponent = function(self, weaponName, weaponComponent)
			local loadoutNum, weapon = self:getWeapon(weaponName)

			if not weapon then
				print(('[^1ERROR^7] Weapon not exist ^5%s'):format(weaponName))
				return
			end

			local component = ESX.GetWeaponComponent(weaponName, weaponComponent)
			if not component then
				print(('[^1ERROR^7] Weapon component not exist ^5%s'):format(weaponComponent))
				return
			end

			if not self:hasWeaponComponent(weaponName, weaponComponent) then
				print(('[^1ERROR^7] Player not owning this component ^5%s'):format(weaponComponent))
				return
			end

			for k,v in ipairs(self.loadout[loadoutNum].components) do
				if v == weaponComponent then
					table.remove(self.loadout[loadoutNum].components, k)
					break
				end
			end

			self:triggerEvent('esx:removeWeaponComponent', weaponName, weaponComponent)
			self:triggerEvent('esx:removeInventoryItem', component.label, false, true)
		end,

		removeWeaponAmmo = function(self, weaponName, ammoCount)
			local loadoutNum, weapon = self:getWeapon(weaponName)

			if not weapon then
				print(('[^1ERROR^7] Weapon not exist ^5%s'):format(weaponName))
				return
			end
			weapon.ammo = weapon.ammo - ammoCount
			self:triggerEvent('esx:setWeaponAmmo', weaponName, weapon.ammo)
		end,

		showNotification = function(self, msg)
			self:triggerEvent('esx:showNotification', msg)
		end,

		showHelpNotification = function(self, msg, thisFrame, beep, duration)
			self:triggerEvent('esx:showHelpNotification', msg, thisFrame, beep, duration)
		end
	}

	ExecuteCommand(('add_principal identifier.%s group.%s'):format(xPlayer.license, xPlayer.group))

	-- StateBag
	local stateBag = Player(xPlayer.playerId).state
	stateBag:set("identifier", xPlayer.identifier, true)
	stateBag:set("license", xPlayer.license, true)
	stateBag:set("job", xPlayer.job, true)
	stateBag:set("group", xPlayer.group, true)
	stateBag:set("name", xPlayer.name, true)
	stateBag:set("ped", xPlayer.ped, true)
	stateBag:set("weight", xPlayer.weight, true)
	stateBag:set("maxWeight", xPlayer.maxWeight, true)

	local tempxPlayer = {}
	for fnName, fn in pairs(xPlayer) do
		if type(fn) == "function" then
			tempxPlayer[fnName] = function(...)
				return fn(xPlayer, ...)
			end
		else
			tempxPlayer[fnName] = fn
		end
    end

	for fnName,fn in pairs(targetOverrides) do
		tempxPlayer[fnName] = fn(tempxPlayer)
	end

	return tempxPlayer
end
