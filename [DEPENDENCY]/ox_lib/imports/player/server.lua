local CPlayer = {}

function CPlayer:__index(index, ...)
	local method = CPlayer[index]

	if method then
		return function(...)
			return method(self, ...)
		end
	end
end

function CPlayer:getCoords(update)
	if update or not self.coords then
		self.coords = GetEntityCoords(self.getPed())
	end

	return self.coords
end

function CPlayer:getDistance(coords)
	return #(self:getCoords() - coords)
end

function CPlayer:getPed()
	if update or not self.ped then
		self.ped = GetPlayerPed(self.source)
	end

	return self.ped
end

function lib.getPlayer()
	return CPlayer
end
