local self = ESX.Modules['addoninventory']

AddEventHandler('esx_addoninventory:getInventory', function(name, owner, cb)

  Citizen.CreateThread(function()

    while not self.Ready do
      Citizen.Wait(0)
    end

    cb(self.GetInventory(name, owner))

  end)

end)

AddEventHandler('esx_addoninventory:getSharedInventory', function(name, cb)

  Citizen.CreateThread(function()

    while not self.Ready do
      Citizen.Wait(0)
    end

    cb(self.GetSharedInventory(name))

  end)

end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)

  Citizen.CreateThread(function()

    while not self.Ready do
      Citizen.Wait(0)
    end

    local addonInventories = {}

    for i=1, #self.InventoriesIndex, 1 do
      local name      = self.InventoriesIndex[i]
      local inventory = self.GetInventory(name, xPlayer.identifier)

      if inventory == nil then
        inventory = self.CreateAddonInventory(name, xPlayer.identifier, {})
        table.insert(self.Inventories[name], inventory)
      end

      table.insert(addonInventories, inventory)
    end

    xPlayer.set('addonInventories', addonInventories)

  end)

end)

MySQL.ready(function()

  local items = MySQL.Sync.fetchAll('SELECT * FROM items')

	for i=1, #items, 1 do
		self.Items[items[i].name] = items[i].label
	end

	local result = MySQL.Sync.fetchAll('SELECT * FROM addon_inventory')

	for i=1, #result, 1 do
		local name   = result[i].name
		local label  = result[i].label
		local shared = result[i].shared

		local result2 = MySQL.Sync.fetchAll('SELECT * FROM addon_inventory_items WHERE inventory_name = @inventory_name', {
			['@inventory_name'] = name
		})

		if shared == 0 then

			table.insert(self.InventoriesIndex, name)

			self.Inventories[name] = {}
			local items       = {}

			for j=1, #result2, 1 do
				local itemName  = result2[j].name
				local itemCount = result2[j].count
				local itemOwner = result2[j].owner

				if items[itemOwner] == nil then
					items[itemOwner] = {}
				end

				table.insert(items[itemOwner], {
					name  = itemName,
					count = itemCount,
					label = Items[itemName]
				})
			end

			for k,v in pairs(items) do
				local addonInventory = CreateAddonInventory(name, k, v)
				table.insert(self.Inventories[name], addonInventory)
			end

		else
			local items = {}

			for j=1, #result2, 1 do
				table.insert(items, {
					name  = result2[j].name,
					count = result2[j].count,
					label = self.Items[result2[j].name]
				})
			end

			local addonInventory = self.CreateAddonInventory(name, nil, items)
			self.SharedInventories[name] = addonInventory
		end
  end

  self.Ready = true

end)
