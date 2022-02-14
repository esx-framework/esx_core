function CreateStatus(name, default, color, visible, tickCallback)

	local self = {}

	self.val          = default
	self.name         = name
	self.default      = default
	self.color        = color
	self.visible      = visible
	self.tickCallback = tickCallback

	function self._set(k, v)
		self[k] = v
	end

	function self._get(k)
		return self[k]
	end

	function self.onTick()
		self.tickCallback(self)
	end

	function self.set(val)
		self.val = val
	end

	function self.add(val)
		if self.val + val > Config.StatusMax then
			self.val = Config.StatusMax
		else
			self.val = self.val + val
		end
	end

	function self.remove(val)
		if self.val - val < 0 then
			self.val = 0
		else
			self.val = self.val - val
		end
	end

	function self.getPercent()
		return (self.val / Config.StatusMax) * 100
	end

	return self

end
