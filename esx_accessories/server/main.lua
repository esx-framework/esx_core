<<<<<<< HEAD
local Jobs = {}
local LastTime = nil

function RunAt(h, m, cb)
	table.insert(Jobs, {
		h  = h,
		m  = m,
		cb = cb
	})
end

function GetTime()
	local timestamp = os.time()
	local d = os.date('*t', timestamp).wday
	local h = tonumber(os.date('%H', timestamp))
	local m = tonumber(os.date('%M', timestamp))

	return {d = d, h = h, m = m}
end

function OnTime(d, h, m)

	for i=1, #Jobs, 1 do
		if Jobs[i].h == h and Jobs[i].m == m then
			Jobs[i].cb(d, h, m)
		end
	end
end

function Tick()
	local time = GetTime()

	if time.h ~= LastTime.h or time.m ~= LastTime.m then
		OnTime(time.d, time.h, time.m)
		LastTime = time
	end

	SetTimeout(60000, Tick)
end

LastTime = GetTime()

Tick()

AddEventHandler('cron:runAt', function(h, m, cb)
	RunAt(h, m, cb)
=======
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_accessories:pay')
AddEventHandler('esx_accessories:pay', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeMoney(Config.Price)
	TriggerClientEvent('esx:showNotification', source, _U('you_paid', ESX.Math.GroupDigits(Config.Price)))
end)

RegisterServerEvent('esx_accessories:save')
AddEventHandler('esx_accessories:save', function(skin, accessory)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_datastore:getDataStore', 'user_' .. string.lower(accessory), xPlayer.identifier, function(store)
		store.set('has' .. accessory, true)

		local itemSkin = {}
		local item1 = string.lower(accessory) .. '_1'
		local item2 = string.lower(accessory) .. '_2'
		itemSkin[item1] = skin[item1]
		itemSkin[item2] = skin[item2]

		store.set('skin', itemSkin)
	end)
end)

ESX.RegisterServerCallback('esx_accessories:get', function(source, cb, accessory)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_datastore:getDataStore', 'user_' .. string.lower(accessory), xPlayer.identifier, function(store)
		local hasAccessory = (store.get('has' .. accessory) and store.get('has' .. accessory) or false)
		local skin = (store.get('skin') and store.get('skin') or {})

		cb(hasAccessory, skin)
	end)

end)

ESX.RegisterServerCallback('esx_accessories:checkMoney', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	cb(xPlayer.getMoney() >= Config.Price)
>>>>>>> esx_accessories/master
end)
