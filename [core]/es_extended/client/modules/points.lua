local points = {}

---@param coords vector3
---@param distance number
---@param hidden boolean
---@param enter fun():nil
---@param leave fun():nil
---@return number
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

---@param handle number
function ESX.RemovePointInternal(handle)
	points[handle] = nil
end

---@param handle number
---@param hidden boolean
function ESX.HidePointInternal(handle, hidden)
	if points[handle] then
		points[handle].hidden = hidden
	end
end

function StartPointsLoop()
    CreateThread(function()
        while true do
            local coords = GetEntityCoords(ESX.PlayerData.ped)
            for i, point in pairs(points) do
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
    for i, point in pairs(points) do
        if point.resource == resource then
            points[i] = nil
        end
    end
end)
