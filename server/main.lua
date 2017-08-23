ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('esx_status:registerStatus', 'hunger', 1000000, '#CFAD0F',
	function(status)
		return true
	end,
	function(status)
		status.remove(6000)
	end,
	{remove = 6000}
)

TriggerEvent('esx_status:registerStatus', 'thirst', 1000000, '#0C98F1',
	function(status)
		return true
	end,
	function(status)
		status.remove(7500)
	end,
	{remove = 7500}
)

RegisterServerEvent('esx_basicneeds:resetStatus')
AddEventHandler('esx_basicneeds:resetStatus', function()

	local _source = source

	TriggerEvent('esx_status:getStatus', _source, 'hunger', function(status)
		status.set(500000)
		status.updateClient()
	end)

	TriggerEvent('esx_status:getStatus', _source, 'thirst', function(status)
		status.set(500000)
		status.updateClient()
	end)

end)

ESX.RegisterUsableItem('bread', function(source)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeInventoryItem('bread', 1)

	TriggerEvent('esx_status:getStatus', _source, 'hunger', function(status)

		status.add(200000)
		status.updateClient()

		TriggerClientEvent('esx_basicneeds:onEat', _source)
		TriggerClientEvent('esx:showNotification', _source, _U('used_bread'))

	end)

end)

ESX.RegisterUsableItem('water', function(source)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeInventoryItem('water', 1)

	TriggerEvent('esx_status:getStatus', _source, 'thirst', function(status)

		status.add(200000)
		status.updateClient()

		TriggerClientEvent('esx_basicneeds:onDrink', _source)
		TriggerClientEvent('esx:showNotification', _source, _U('used_water'))

	end)

end)
