function CreateAddonAccount(name, owner, money)
	local self = {}

	self.name  = name
	self.owner = owner
	self.money = money

	self.addMoney = function(m)
		self.money = self.money + m
		self.save()

		TriggerClientEvent('esx_addonaccount:setMoney', -1, self.name, self.money)
	end

	self.removeMoney = function(m)
		self.money = self.money - m
		self.save()

		TriggerClientEvent('esx_addonaccount:setMoney', -1, self.name, self.money)
	end

	self.setMoney = function(m)
		self.money = m
		self.save()

		TriggerClientEvent('esx_addonaccount:setMoney', -1, self.name, self.money)
	end

	self.save = function()
		if self.owner == nil then
			exports.oxmysql:update('UPDATE addon_account_data SET money = ? WHERE account_name = ?', {self.money, self.name})
		else
			exports.oxmysql:update('UPDATE addon_account_data SET money = ? WHERE account_name = ? AND owner = ?', {self.money, self.name, self.owner})
		end
	end

	return self
end