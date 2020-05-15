ESX.Modules['addonaccount'] = {}
local self = ESX.Modules['addonaccount']

self.Ready          = false
self.AccountsIndex  = {}
self.Accounts       = {}
self.SharedAccounts = {}

self.GetAccount = function(name, owner)
	for i=1, #self.Accounts[name], 1 do
		if self.Accounts[name][i].owner == owner then
			return self.Accounts[name][i]
		end
	end
end

self.GetSharedAccount = function(name)
	return self.SharedAccounts[name]
end

self.CreateAddonAccount = function(name, owner, money)

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
			MySQL.Async.execute('UPDATE addon_account_data SET money = @money WHERE account_name = @account_name', {
				['@account_name'] = self.name,
				['@money']        = self.money
			})
		else
			MySQL.Async.execute('UPDATE addon_account_data SET money = @money WHERE account_name = @account_name AND owner = @owner', {
				['@account_name'] = self.name,
				['@money']        = self.money,
				['@owner']        = self.owner
			})
		end
	end

  return self

end
