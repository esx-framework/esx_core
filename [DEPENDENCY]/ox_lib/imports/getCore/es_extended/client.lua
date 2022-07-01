if not lib.player then lib.player() end

return function(resource)
	local ESX = exports[resource]:getSharedObject()

	RegisterNetEvent('esx:playerLoaded', function(xPlayer)
		ESX.PlayerData = xPlayer
	end)

	RegisterNetEvent('esx:setJob', function(job)
		ESX.PlayerData.job = job
	end)

	local CPlayer = lib.getPlayer()

	function lib.getPlayer()
		return setmetatable({
			id = cache.playerId,
			serverId = cache.serverId,
		}, CPlayer)
	end

	function CPlayer:hasGroup(filter)
		local data = ESX.PlayerData
		local type = type(filter)

		if type == 'string' then
			if data.job.name == filter then
				return data.job.name, data.job.grade
			end
		else
			local tabletype = table.type(filter)

			if tabletype == 'hash' then
				local grade = filter[data.job.name]

				if grade and grade <= data.job.grade then
					return data.job.name, data.job.grade
				end
			elseif tabletype == 'array' then
				for i = 1, #filter do
					if data.job.name == filter[i] then
						return data.job.name, data.job.grade
					end
				end
			end
		end
	end

	player = lib.getPlayer()

	return ESX
end
