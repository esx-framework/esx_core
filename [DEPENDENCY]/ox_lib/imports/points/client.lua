local points = {}

local function removePoint(self)
	points[self.id] = nil
end

local nearby = {}
local closest
local tick

CreateThread(function()
	while true do
		local coords = GetEntityCoords(cache.ped)
		Wait(300)
		closest = nil
		table.wipe(nearby)

		for _, point in pairs(points) do
			local distance = #(coords - point.coords)

			if distance <= point.distance then
				point.currentDistance = distance

				if distance < (closest?.currentDistance or point.distance) then
					closest = point
				end

				if point.nearby then
					nearby[#nearby + 1] = point
				end

				if point.onEnter and not point.inside then
					point.inside = true
					point:onEnter()
				end
			elseif point.currentDistance then
				if point.onExit then point:onExit() end
				point.inside = nil
				point.currentDistance = nil
			end
		end

		if not tick then
			if #nearby > 0 then
				tick = SetInterval(function()
					for i = 1, #nearby do
						nearby[i]:nearby()
					end
				end)
			end
		elseif #nearby == 0 then
			tick = ClearInterval(tick)
		end
	end
end)

return {
	new = function(...)
		local args = {...}
		local id = #points + 1
		local self

		-- Support sending a single argument containing point data
		if type(args[1]) == 'table' then
			self = args[1]
			self.id = id
			self.remove = removePoint
		else
			-- Backwards compatibility for original implementation (args: coords, distance, data)
			self = {
				id = id,
				coords = args[1],
				remove = removePoint,
			}
		end


		self.distance = self.distance or args[2]

		if args[3] then
			for k, v in pairs(args[3]) do
				self[k] = v
			end
		end

		points[id] = self

		return self
	end,

	closest = function()
		return closest
	end
}
