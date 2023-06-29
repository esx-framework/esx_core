local TimeoutCount = 0
local CancelledTimeouts = {}

ESX.SetTimeout = function(msec, cb)
	local id <const> = TimeoutCount + 1

	SetTimeout(msec, function()
		if CancelledTimeouts[id] then
			CancelledTimeouts[id] = nil
			return
		end

		cb()
	end)

	TimeoutCount = id

	return id
end

ESX.ClearTimeout = function(id)
	CancelledTimeouts[id] = true
end
