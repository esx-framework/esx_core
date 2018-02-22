ESX                  = nil
local AccountsIndex  = {}
local Accounts       = {}
local SharedAccounts = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('onMySQLReady', function ()

	local result = MySQL.Sync.fetchAll('SELECT * FROM addon_account')

	for i=1, #result, 1 do

		local name   = result[i].name
		local label  = result[i].label
		local shared = result[i].shared

		local result2 = MySQL.Sync.fetchAll(
			'SELECT * FROM addon_account_data WHERE account_name = @account_name',
			{
				['@account_name'] = name
			}
		)

		if shared == 0 then

			table.insert(AccountsIndex, name)
			
			Accounts[name] = {}
			
			for j=1, #result2, 1 do

				local addonAccount = CreateAddonAccount(name, result2[j].owner, result2[j].money)

				table.insert(Accounts[name], addonAccount)

			end

		else

			local money = nil

			if #result2 == 0 then

				MySQL.Sync.execute(
					'INSERT INTO addon_account_data (account_name, money, owner) VALUES (@account_name, @money, NULL)',
					{
						['@account_name'] = name,
						['@money']        = 0
					}
				)

				money = 0

			else
				money = result2[1].money
			end

			local addonAccount   = CreateAddonAccount(name, nil, money)
			SharedAccounts[name] = addonAccount

		end

	end

end)

function GetAccount(name, owner)
	for i=1, #Accounts[name], 1 do
		if Accounts[name][i].owner == owner then
			return Accounts[name][i]
		end
	end
end

function GetSharedAccount(name)
	return SharedAccounts[name]
end

AddEventHandler('esx_addonaccount:getAccount', function(name, owner, cb)
	cb(GetAccount(name, owner))
end)

AddEventHandler('esx_addonaccount:getSharedAccount', function(name, cb)
	cb(GetSharedAccount(name))
end)

AddEventHandler('esx:playerLoaded', function(source)
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	local addonAccounts = {}

	for i=1, #AccountsIndex, 1 do

		local name    = AccountsIndex[i]
		local account = GetAccount(name, xPlayer.identifier)

		if account == nil then

			MySQL.Async.execute(
				'INSERT INTO addon_account_data (account_name, money, owner) VALUES (@account_name, @money, @owner)',
				{
					['@account_name'] = name,
					['@money']        = 0,
					['@owner']        = xPlayer.identifier
				}
			)

			account = CreateAddonAccount(name, xPlayer.identifier, 0)
			table.insert(Accounts[name], account)
		end

		table.insert(addonAccounts, account)

	end

	xPlayer.set('addonAccounts', addonAccounts)

end)
