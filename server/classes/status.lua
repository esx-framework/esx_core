function CreateStatus(xPlayer, name, default, color, visible, tickCallback, clientAction)
		
	local self = {}

	self.val          = default
	self.xPlayer      = xPlayer
	self.name         = name
	self.default      = default
	self.color        = color
	self.visible      = visible
	self.tickCallback = tickCallback
	self.clientAction = clientAction

	self._set = function(k, v)
		self[k] = v
	end

	self._get = function(k)
		return self[k]
	end

	self.onTick = function()
		self.tickCallback(self)
	end

	self.set = function(val)
		self.val = val
	end

	self.add = function(val)
		if self.val + val > Config.StatusMax then
			self.val = Config.StatusMax
		else
			self.val = self.val + val
		end
	end

	self.remove = function(val)
		if self.val - val < 0 then
			self.val = 0
		else
			self.val = self.val - val
		end
	end

	self.getPercent = function()
		return (self.val / Config.StatusMax) * 100
	end

	self.updateClient = function()
		TriggerEvent('esx_status:updateClient', self.xPlayer.source)
	end

	return self

end
