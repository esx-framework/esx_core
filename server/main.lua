ESX                    = nil
local RegisteredStatus = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('esx:playerLoaded', function(source)

	local _source        = source
	local xPlayer        = ESX.GetPlayerFromId(_source)

	MySQL.Async.fetchAll(
		'SELECT * FROM users WHERE identifier = @identifier',
		{
			['@identifier'] = xPlayer.identifier
		},
		function(result)

			local data = {}

			if result[1].status ~= nil then
				data = json.decode(result[1].status)
			end

			xPlayer.set('status', data)

			TriggerClientEvent('esx_status:load', _source, data)

		end
	)

end)

AddEventHandler('esx:playerDropped', function(source)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	local data   = {}
	local status = xPlayer.get('status')

	MySQL.Async.execute(
		'UPDATE users SET status = @status WHERE identifier = @identifier',
		{
			['@status']     = json.encode(status),
			['@identifier'] = xPlayer.identifier
		}
	)

end)

AddEventHandler('esx_status:getStatus', function(playerId, statusName, cb)

	local xPlayer = ESX.GetPlayerFromId(playerId)
	local status  = xPlayer.get('status')

	for i=1, #status, 1 do
		if status[i].name == statusName then
			cb(status[i])
			break
		end
	end

end)

RegisterServerEvent('esx_status:update')
AddEventHandler('esx_status:update', function(status)
	
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	xPlayer.set('status', status)

end)

function SaveData()

	local xPlayers = ESX.GetPlayers()

	for i=1, #xPlayers, 1 do

		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		local data    = {}
		local status  = xPlayer.get('status')

		MySQL.Async.execute(
			'UPDATE users SET status = @status WHERE identifier = @identifier',
		 	{
		 		['@status']     = json.encode(status),
		 		['@identifier'] = xPlayer.identifier
		 	}
		)
	
	end

	SetTimeout(10 * 60 * 1000, SaveData)

end

SaveData()