function CreateAddonAccount(name, owner, money)
	local self = {}

	self.name  = name
	self.owner = owner
	self.money = money

	self.addMoney = function(m)
		self.money = self.money + m
		self.save()
	end

	self.removeMoney = function(m)
		self.money = self.money - m
		self.save()
	end

	self.setMoney = function(m)
		self.money = m
		self.save()
	end

	self.save = function()
		if self.owner == nil then
			MySQL.update('UPDATE addon_account_data SET money = ? WHERE account_name = ?', {self.name, self.money})
		else
			MySQL.update('UPDATE addon_account_data SET money = ? WHERE account_name = ? AND owner = ?', {self.name, self.money, self.owner})
		end
		TriggerClientEvent('esx_addonaccount:setMoney', -1, self.name, self.money)
	end

	return self
end