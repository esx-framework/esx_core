function CreateAddonInventory(name, owner, items)
	local self = {}

	self.name  = name
	self.owner = owner
	self.items = items

	function self.addItem(name, count)
		local item = self.getItem(name)
		item.count = item.count + count
		Wait(100)
		self.saveItem(name, item.count)
	end

	function self.removeItem(name, count)
		local item = self.getItem(name)
		item.count = item.count - count

		self.saveItem(name, item.count)
	end

	function self.setItem(name, count)
		local item = self.getItem(name)
		item.count = count

		self.saveItem(name, item.count)
	end

	function self.getItem(name)
		for i=1, #self.items, 1 do
			if self.items[i].name == name then
				return self.items[i]
			end
		end

		item = {
			name  = name,
			count = 0,
			label = Items[name]
		}

		table.insert(self.items, item)

		if self.owner == nil then
			MySQL.update('INSERT INTO addon_inventory_items (inventory_name, name, count) VALUES (@inventory_name, @item_name, @count)',
			{
				['@inventory_name'] = self.name,
				['@item_name']      = name,
				['@count']          = 0
			})
		else
			MySQL.update('INSERT INTO addon_inventory_items (inventory_name, name, count, owner) VALUES (@inventory_name, @item_name, @count, @owner)',
			{
				['@inventory_name'] = self.name,
				['@item_name']      = name,
				['@count']          = 0,
				['@owner']          = self.owner
			})
		end

		return item
	end

	function self.saveItem(name, count)
		if self.owner == nil then
			MySQL.update('UPDATE addon_inventory_items SET count = @count WHERE inventory_name = @inventory_name AND name = @item_name', {
				['@inventory_name'] = self.name,
				['@item_name']      = name,
				['@count']          = count
			})
		else
			MySQL.update('UPDATE addon_inventory_items SET count = @count WHERE inventory_name = @inventory_name AND name = @item_name AND owner = @owner', {
				['@inventory_name'] = self.name,
				['@item_name']      = name,
				['@count']          = count,
				['@owner']          = self.owner
			})
		end
	end

	return self
end

