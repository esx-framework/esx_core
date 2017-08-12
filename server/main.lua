ESX                    = nil
local RegisteredStatus = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('esx_status:registerStatus', function(name, default, color, visible, tickCallback, clientAction)

	table.insert(RegisteredStatus, {
		name         = name,
		default      = default,
		color        = color,
		visible      = visible,
		tickCallback = tickCallback,
		clientAction = clientAction
	})

end)

AddEventHandler('esx:playerLoaded', function(source)

	local _source        = source
	local xPlayer        = ESX.GetPlayerFromId(_source)

	MySQL.Async.fetchAll(
		'SELECT * FROM users WHERE identifier = @identifier',
		{
			['@identifier'] = xPlayer.identifier
		},
		function(result)

			local data           = {}
			local savedStatus    = {}

			if result[1].status ~= nil then
				data = json.decode(result[1].status)
			end

			for i=1, #data, 1 do
				savedStatus[data[i].name] = data[i]
			end

			local status = {}

			for i=1, #RegisteredStatus, 1 do
				
				local s       = RegisteredStatus[i]
				local default = nil

				if savedStatus[s.name] ~= nil then
					default = savedStatus[s.name].val
				else
					default = s.default
				end

				table.insert(status, CreateStatus(xPlayer, s.name, default, s.color, s.visible, s.tickCallback, s.clientAction))
			end

			xPlayer.set('status', status)

			TriggerEvent('esx_status:updateClient', _source)

		end
	)

end)

AddEventHandler('esx:playerDropped', function(source)

	local xPlayer = ESX.GetPlayerFromId(source)

	local data   = {}
	local status = xPlayer.get('status')

	for i=1, #status, 1 do
		
		local s = status[i]
		
		table.insert(data, {
			name = s._get('name'),
			val  = s._get('val')
		})
	end 

	MySQL.Async.execute(
		'UPDATE users SET status = @status WHERE identifier = @identifier',
		{
			['@status']     = json.encode(data),
			['@identifier'] = xPlayer.identifier
		}
	)

end)

AddEventHandler('esx_status:getStatus', function(playerId, statusName, cb)

	local xPlayer = ESX.GetPlayerFromId(playerId)
	local status  = xPlayer.get('status')

	for i=1, #status, 1 do
		if status[i]._get('name') == statusName then
			cb(status[i])
			break
		end
	end

end)

AddEventHandler('esx_status:updateClient', function(playerId)

	local xPlayer = ESX.GetPlayerFromId(playerId)
	local data    = {}
	local status  = xPlayer.get('status')

	for i=1, #status, 1 do
		table.insert(data, {
			name         = status[i]._get('name'),
			val          = status[i]._get('val'),
			color        = status[i]._get('color'),
			visible      = status[i]._get('visible')(status[i]),
			clientAction = status[i]._get('clientAction'),
			max          = Config.StatusMax
		})
	end

	TriggerClientEvent('esx_status:update', playerId, data)

end)

function TickStatus()

	local xPlayers = ESX.GetPlayers()

	for k,v in pairs(xPlayers) do

		local status = v.get('status')

		if status ~= nil then

			for i=1, #status, 1 do
				status[i]._get('onTick')()
			end

		end

	end

	SetTimeout(Config.TickTime, TickStatus)

end

function UpdateClients()

	local xPlayers = ESX.GetPlayers()
	
	for k,v in pairs(xPlayers) do
		TriggerEvent('esx_status:updateClient', v.source)
	end

	SetTimeout(Config.UpdateClientTime, UpdateClients)

end

function SaveData()

	local xPlayers = ESX.GetPlayers()

	for k,v in pairs(xPlayers) do

		local data   = {}
		local status = v.get('status')

		for i=1, #status, 1 do
			
			local s = status[i]
			
			table.insert(data, {
				name = s._get('name'),
				val  = s._get('val')
			})
		end 

		MySQL.Async.execute(
			'UPDATE users SET status = @status WHERE identifier = @identifier',
		 	{
		 		['@status']     = json.encode(data),
		 		['@identifier'] = v.identifier
		 	}
		)
	
	end

	SetTimeout(60000, SaveData)

end

TickStatus()
UpdateClients()
SaveData()