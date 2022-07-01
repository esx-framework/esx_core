if not lib.player then lib.player() end

return function(resource)
	local ESX = exports[resource]:getSharedObject()
	-- Eventually add some functions here to simplify the creation of framework-agnostic resources.

	local CPlayer = lib.getPlayer()

	function lib.getPlayer(player)
		player = type(player) == 'table' and player.playerId or ESX.GetPlayerFromId(player)

		if not player then
			error(("'%s' is not a valid player"):format(player))
		end

		return setmetatable(player, CPlayer)
	end

	function CPlayer:hasGroup(filter)
		local type = type(filter)

		if type == 'string' then
			if self.job.name == filter then
				return self.job.name, self.job.grade
			end
		else
			local tabletype = table.type(filter)

			if tabletype == 'hash' then
				local grade = filter[self.job.name]

				if grade and grade <= self.job.grade then
					return self.job.name, self.job.grade
				end
			elseif tabletype == 'array' then
				for i = 1, #filter do
					if self.job.name == filter[i] then
						return self.job.name, self.job.grade
					end
				end
			end
		end
	end

	return ESX
end
