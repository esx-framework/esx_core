local points = {}

function ESX.CreatePointIntenal(coords, distance, hidden, enter, leave)
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
            for i=1, #points do
                local point = points[i]
                local distance = #(coords - point.coords)
				
                if not point.hidden and distance <= point.distance then
                    if not point.nearby then
                        points[i].nearby = true
                        points[i].enter()
                    end
					point.currentDistance = distance
                elseif point.nearby then
                    points[i].nearby = false
                    points[i].leave()
                end
            end
            Wait(500)
        end
    end)
end


AddEventHandler('onResourceStop', function(resource)
	for i=1, #points do
		if points[i].resource == resource then
			points[i] = nil
		end
	end
end)
