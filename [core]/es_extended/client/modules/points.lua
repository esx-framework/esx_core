local points = {}

function ESX.CreatePointInternal(coords, distance, hidden, enter, leave)
	local point = {
		coords = coords,
		distance = distance,
		hidden = hidden,
		enter = enter,
		leave = leave,
		resource = GetInvokingResource()
	}
	local handle = ESX.Table.SizeOf(points) + 1
	points[handle] = point
	return handle
end

function ESX.RemovePointInternal(handle)
	points[handle] = nil
end

function ESX.HidePointInternal(handle, hidden)
	if points[handle] then
		points[handle].hidden = hidden
	end
end

function StartPointsLoop()
	CreateThread(function()
		while true do
			local coords = GetEntityCoords(ESX.PlayerData.ped)
			for handle, point in pairs(points) do
				if not point.hidden and #(coords - point.coords) <= point.distance then
					if not point.nearby then
						points[handle].nearby = true
						points[handle].enter()
					end
				elseif point.nearby then
					points[handle].nearby = false
					points[handle].leave()
				end
			end
			Wait(500)
		end
	end)
end


AddEventHandler('onResourceStop', function(resource)
	for handle, point in pairs(points) do
		if point.resource == resource then
			points[handle] = nil
		end
	end
end)