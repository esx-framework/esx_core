if not lib.player then lib.player() end

return function(resource)
	local QBCore = exports[resource]:GetCoreObject()
	-- Eventually add some functions here to simplify the creation of framework-agnostic resources.

	local CPlayer = lib.getPlayer()

	function lib.getPlayer(player)
		player = type(player) == 'table' and player.playerId or QBCore.Functions.GetPlayer(player)

		if not player then
			error(("'%s' is not a valid player"):format(player))
		end

		return setmetatable(player, CPlayer)
	end

	local groups = { 'job', 'gang' }

	function CPlayer:hasGroup(filter)
		local type = type(filter)

		if type == 'string' then
			for i = 1, #groups do
				local data = self.PlayerData[groups[i]]

				if data.name == filter then
					return data.name, data.grade.level
				end
			end
		else
			local tabletype = table.type(filter)

			if tabletype == 'hash' then
				for i = 1, #groups do
					local data = self.PlayerData[groups[i]]
					local grade = filter[data.name]

					if grade and grade <= data.grade.level then
						return data.name, data.grade.level
					end
				end
			elseif tabletype == 'array' then
				for i = 1, #filter do
					local group = filter[i]

					for j = 1, #groups do
						local data = self.PlayerData[groups[j]]

						if data.name == group then
							return data.name, data.grade.level
						end
					end
				end
			end
		end
	end

	return QBCore
end
