function CreateAddonAccount(name, owner, money)
	local self = {}

	self.name  = name
	self.owner = owner
	self.money = money

	function self.addMoney(m)
		self.money = self.money + m
		self.save()
		TriggerEvent('esx_addonaccount:addMoney', self.name, m)
	end

	function self.removeMoney(m)
		self.money = self.money - m
		self.save()
		TriggerEvent('esx_addonaccount:removeMoney', self.name, m)
	end

	function self.setMoney(m)
		self.money = m
		self.save()
		TriggerEvent('esx_addonaccount:setMoney', self.name, m)
	end

	function self.save()
		if self.owner == nil then
			MySQL.update('UPDATE addon_account_data SET money = ? WHERE account_name = ?', {self.money, self.name})
		else
			MySQL.update('UPDATE addon_account_data SET money = ? WHERE account_name = ? AND owner = ?', {self.money, self.name, self.owner})
		end
		TriggerClientEvent('esx_addonaccount:setMoney', -1, self.name, self.money)
	end

	return self
end
