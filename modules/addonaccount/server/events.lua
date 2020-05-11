local self = ESX.Modules['addonaccount']

AddEventHandler('esx:migrations:ensure', function(register)
  register('addonaccount')
end)

AddEventHandler('esx_addonaccount:getAccount', function(name, owner, cb)

  Citizen.CreateThread(function()

    while not self.Ready do
      Citizen.Wait(0)
    end

    cb(self.GetAccount(name, owner))

  end)

end)

AddEventHandler('esx_addonaccount:getSharedAccount', function(name, cb)

  Citizen.CreateThread(function()

    while not self.Ready do
      Citizen.Wait(0)
    end

    cb(self.GetSharedAccount(name))

  end)

end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)


  Citizen.CreateThread(function()

    while not self.Ready do
      Citizen.Wait(0)
    end

    local addonAccounts = {}

    for i=1, #self.AccountsIndex, 1 do
      local name    = self.AccountsIndex[i]
      local account = GetAccount(name, xPlayer.identifier)

      if account == nil then
        MySQL.Async.execute('INSERT INTO addon_account_data (account_name, money, owner) VALUES (@account_name, @money, @owner)', {
          ['@account_name'] = name,
          ['@money']        = 0,
          ['@owner']        = xPlayer.identifier
        })

        account = self.CreateAddonAccount(name, xPlayer.identifier, 0)
        table.insert(self.Accounts[name], account)
      end

      table.insert(addonAccounts, account)
    end

    xPlayer.set('addonAccounts', addonAccounts)

  end)

end)

MySQL.ready(function()

	local result = MySQL.Sync.fetchAll('SELECT * FROM addon_account')

  for i=1, #result, 1 do

		local name   = result[i].name
		local label  = result[i].label
		local shared = result[i].shared

		local result2 = MySQL.Sync.fetchAll('SELECT * FROM addon_account_data WHERE account_name = @account_name', {
			['@account_name'] = name
		})

    if shared == 0 then

			table.insert(self.AccountsIndex, name)
			self.Accounts[name] = {}

			for j=1, #result2, 1 do
				local addonAccount = CreateAddonAccount(name, result2[j].owner, result2[j].money)
				table.insert(self.Accounts[name], addonAccount)
      end

    else

			local money = nil

			if #result2 == 0 then
				MySQL.Sync.execute('INSERT INTO addon_account_data (account_name, money, owner) VALUES (@account_name, @money, NULL)', {
					['@account_name'] = name,
					['@money']        = 0
				})

				money = 0
			else
				money = result2[1].money
			end

			local addonAccount        = self.CreateAddonAccount(name, nil, money)
      self.SharedAccounts[name] = addonAccount

		end
  end

  self.Ready = true

end)
