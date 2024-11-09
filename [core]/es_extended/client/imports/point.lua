Point = ESX.Class()

function Point:constructor(properties)
	self.coords = properties.coords
	self.hidden = properties.hidden or false
	self.inside = properties.inside or function() end
	self.enter = properties.enter or function() end
	self.leave = properties.leave or function() end
	self.handle = ESX.CreatePointInternal(properties.coords, properties.distance, properties.hidden, function()
		self.nearby = true
		if self.enter then
			self:enter()
		end
		if self.inside then
			CreateThread(function()
				while self.nearby do
					local coords = GetEntityCoords(ESX.PlayerData.ped)
					self.currDistance = #(coords - self.coords)
					self:inside()
					Wait(0)
				end
			end)
		end
	end, function()
		self.nearby = false
		if self.leave then
			self:leave()
		end
	end)
end

function Point:delete()
	ESX.RemovePointInternal(self.handle)
end

function Point:toggle(hidden)
	if hidden == nil then
		hidden = not self.hidden
	end
	self.hidden = hidden
	ESX.HidePointInternal(self.handle, hidden)
end

return Point