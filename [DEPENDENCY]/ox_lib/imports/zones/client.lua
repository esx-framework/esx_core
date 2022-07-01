local glm = require 'glm'
Zones = {}

local function makeTriangles(t)
	local t1, t2
	if t[3] and t[4] then
		t1 = mat(t[1], t[2], t[3])
		t2 = mat(t[2], t[3], t[4])
	else
		t1 = mat(t[1], t[2], t[3] or t[4])
	end
	return t1, t2
end

local function getTriangles(polygon)
	local triangles = {}
	if polygon:isConvex() then
		for i = 2, #polygon - 1 do
			triangles[#triangles + 1] = mat(polygon[1], polygon[i], polygon[i + 1])
		end
		return triangles
	end

	local points = {}
	local sides = {}
	local horizontals = {}
	for i = 1, #polygon do
		local h
		local point = polygon[i]
		local unique = true

		for j = 1, #horizontals do
			if point.y == horizontals[j][1].y then
				h = j
				horizontals[j][#horizontals[j] + 1] = point
				unique = false
				break
			end
		end

		if unique then
			h = #horizontals + 1
			horizontals[h] = {point}
		end

		sides[i] = {polygon[i], polygon[i + 1] or polygon[1]}
		points[polygon[i]] = {side = i, horizontal = h, uses = 0}
	end

	local extremes = { polygon.projectToAxis(polygon, vec(1, 0, 0)) }
	for i = 1, #horizontals do
		local horizontal = horizontals[i]
		local hLineStart, hLineEnd = vec(extremes[1], horizontal[1].yz), vec(extremes[2], horizontal[1].yz)
		for j = 1, #sides do
			local sideStart, sideEnd = sides[j][1], sides[j][2]
			local bool, d, d2 = glm.segment.intersectsSegment(hLineStart, hLineEnd, sideStart, sideEnd)
			if d > 0.001 and d < 0.999 and d2 > 0.001 and d2 < 0.999 then
				local newPoint = glm.segment.getPoint(hLineStart, hLineEnd, d)
				local valid
				for l = 1, #horizontal do
					local point = horizontal[l]
					valid = polygon.contains(polygon, (point + newPoint) / 2, 0.1)
					if valid then
						for m = 1, #sides do
							local sideStart, sideEnd = sides[m][1], sides[m][2]
							local bool, d, d2 = glm.segment.intersectsSegment(point, newPoint, sides[m][1], sides[m][2])
							if d > 0.001 and d < 0.999 and d2 > 0.001 and d2 < 0.999 then
								valid = false
								break
							end
						end
					end
					if valid then
						horizontals[i][#horizontals[i] + 1] = newPoint
						sides[j][#sides[j] + 1] = newPoint
						points[newPoint] = {side = j, horizontal = i, uses = 0}
						break
					end
				end
			end
		end
	end

	local function up(a, b)
		return a.y > b.y
	end

	local function down(a, b)
		return a.y < b.y
	end

	local function right(a, b)
		return a.x > b.x
	end

	local function left(a, b)
		return a.x < b.x
	end

	for i = 1, #sides do
		local side = sides[i]

		local direction = side[1].y - side[2].y
		direction = direction > 0 and up or down
		table.sort(side, direction)

		for j = 1, #side - 1 do
			local a, b = side[j], side[j + 1]
			local aData, bData = points[a], points[b]
			local aPos, bPos
			if aData.horizontal ~= bData.horizontal then
				local aHorizontal, bHorizontal = horizontals[aData.horizontal], horizontals[bData.horizontal]
				local c, d

				if aHorizontal[2] then
					local direction = a.x - (a.x ~= aHorizontal[1].x and aHorizontal[1].x or aHorizontal[2].x)
					direction = direction > 0 and right or left
					table.sort(aHorizontal, direction)

					for l = 1, #aHorizontal do
						if a == aHorizontal[l] then
							aPos = l
						elseif c and aPos then
							break
						else
							c = aHorizontal[l]
						end
					end
				end

				if bHorizontal[2] then
					local direction = b.x - (b.x ~= bHorizontal[1].x and bHorizontal[1].x or bHorizontal[2].x)
					direction = direction > 0 and right or left
					table.sort(bHorizontal, direction)

					for l = 1, #bHorizontal do
						if b == bHorizontal[l] then
							bPos = l
						elseif bPos and d then
							break
						else
							d = bHorizontal[l]
						end
					end
				end

				if aData.uses < 2 then
					if c and d then
						if points[c].side ~= points[d].side then
							local done
							for l = aPos > 1 and aPos - 1 or 1, aPos > #aHorizontal and aPos + 1 or #aHorizontal do
								c = aHorizontal[l]
								if c ~= a then
									for m = bPos > 1 and bPos - 1 or 1, bPos > #bHorizontal and bPos + 1 or #bHorizontal do
										d = bHorizontal[m]
										local sideDifference = points[c].side - points[d].side
										if d ~= b and sideDifference >= -1 and sideDifference <= 1 then
											done = true
											break
										end
									end
								end
								if done then break end
							end
						end
						c = polygon.contains(polygon, (a + c) / 2, 0.1) and c or nil
						d = polygon.contains(polygon, (b + d) / 2, 0.1) and d or nil
					end

					if c and not d then
						for l = aPos > 1 and aPos - 1 or 1, aPos < #aHorizontal and aPos + 1 or #aHorizontal do
							c = aHorizontal[l]
							if c and c ~= a then
								local sideDifference = bData.side - points[c].side
								if sideDifference >= -1 and sideDifference <= 1 then
									break
								end
							end
						end
					elseif d and not c then
						for l = bPos > 1 and bPos - 1 or 1, bPos < #bHorizontal and bPos + 1 or #bHorizontal do
							d = aHorizontal[l]
							if d and d ~= b then
								local sideDifference = aData.side - points[d].side
								if sideDifference >= -1 and sideDifference <= 1 then
									break
								end
							end
						end
					end

					if c or d then
						local t = {a, b, c, d}
						nTriangles = #triangles
						triangles[nTriangles + 1], triangles[nTriangles + 2] = makeTriangles(t)
						if c and d then
							for i = 1, #t do
								points[t[i]].uses += 1
							end
						else
							for k, v in pairs(t) do
								points[v].uses += 2
							end
						end
					end
				end
			else
				aData.uses += 1
				bData.uses += 1
			end
		end
	end
	return triangles
end

local function removeZone(self)
	Zones[self.id] = nil
end

local inside = {}
local insideCount
local tick

CreateThread(function()
	while true do
		Wait(300)
		local coords = GetEntityCoords(cache.ped)
		table.wipe(inside)
		insideCount = 0

		for _, zone in pairs(Zones) do
			local contains = zone:contains(coords)

			if contains then
				if zone.onEnter and not zone.insideZone then
					zone:onEnter()
				end

				if zone.inside then
					insideCount += 1
					inside[insideCount] = zone
				end

				if not zone.insideZone then
					zone.insideZone = true
				end
			elseif zone.insideZone then
				zone.insideZone = false

				if zone.onExit then
					zone:onExit()
				end
			elseif zone.debug then
				insideCount += 1
				inside[insideCount] = zone
			end
		end

		if not tick then
			if insideCount > 0 then
				tick = SetInterval(function()
					for i = 1, insideCount do
						local zone = inside[i]

						if zone.insideZone then
							zone:inside()
						end

						if zone.debug then
							zone:debug()
						end
					end
				end)
			end
		elseif insideCount == 0 then
			tick = ClearInterval(tick)
		end
	end
end)

local DrawLine = DrawLine
local DrawPoly = DrawPoly

local function debugPoly(self)
	for i = 1, #self.triangles do
		local triangle = self.triangles[i]
		DrawPoly(triangle[1], triangle[2], triangle[3], 255, 42, 24, 100)
		DrawPoly(triangle[2], triangle[1], triangle[3], 255, 42, 24, 100)
	end
	for i = 1, #self.polygon do
		local thickness = vec(0, 0, self.thickness / 2)
		DrawLine(self.polygon[i] + thickness, self.polygon[i] - thickness, 255, 42, 24, 225)
		DrawLine(self.polygon[i] + thickness, (self.polygon[i + 1] or self.polygon[1]) + thickness, 255, 42, 24, 225)
		DrawLine(self.polygon[i] - thickness, (self.polygon[i + 1] or self.polygon[1]) - thickness, 255, 42, 24, 225)
	end
end

local function debugSphere(self)
	DrawMarker(28, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, self.radius, self.radius, self.radius, 255, 42, 24, 100, false, false, false, true, false, false, false)
end

local glm_polygon_contains = glm.polygon.contains

local function contains(self, coords)
	return glm_polygon_contains(self.polygon, coords, self.thickness / 4)
end

local function insideSphere(self, coords)
	return #(self.coords - coords) < self.radius
end

return {
	poly = function(data)
		data.id = #Zones + 1
		data.thickness = data.thickness or 4
		data.polygon = glm.polygon.new(data.points)
		data.coords = data.polygon:centroid()
		data.remove = removeZone
		data.contains = contains

		if data.debug then
			data.triangles = getTriangles(data.polygon)
			data.debug = debugPoly
		end

		Zones[data.id] = data
		return data
	end,

	box = function(data)
		data.id = #Zones + 1
		data.size = data.size and data.size / 2 or vec3(2)
		data.thickness = data.size.z * 2 or 4
		data.rotation = quat(data.rotation or 0, vec3(0, 0, 1))
		data.polygon = (data.rotation * glm.polygon.new({
			vec3(data.size.x, data.size.y, 0),
			vec3(-data.size.x, data.size.y, 0),
			vec3(-data.size.x, -data.size.y, 0),
			vec3(data.size.x, -data.size.y, 0),
		}) + data.coords)
		data.remove = removeZone
		data.contains = contains

		if data.debug then
			data.triangles = {makeTriangles({data.polygon[1], data.polygon[2], data.polygon[4], data.polygon[3]})}
			data.debug = debugPoly
		end

		Zones[data.id] = data
		return data
	end,

	sphere = function(data)
		data.id = #Zones + 1
		data.radius = (data.radius or 2) + 0.0
		data.remove = removeZone
		data.contains = insideSphere

		if data.debug then
			data.debug = debugSphere
		end

		Zones[data.id] = data
		return data
	end,
}
