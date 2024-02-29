local markers = {}

---@func fun(coords: vector3, radius: number, data?: any)
function ESX.createMarker(data) 
    local coords = data.coords

    if type(coords) ~= 'vector3' then 
        if coords.x and coords.y and coords.z then 
            data.coords = vec3(coords.x, coords.y, coords.z)
        elseif coords[1] and coords[2] and coords[3] then 
            data.coords = vec3(coords[1], coords[2], coords[3])    
        end
    end

    local index = #markers+1
    markers[index] = data
    return markers[index]
end

function ESX.getNearestMarker()
    local nearest
    local distance = 9999
    for i = 1, #markers do 
        local marker = markers[i]
        local dist = marker.distance
        if dist < distance then 
            distance = dist
            nearest = marker
        end 
    end 
    return nearest, distance
end 

function ESX.getMarkersInRange(min, max)
    local list = {}    
    for i = 1, #markers do 
        local marker = markers[i]
        local distance = marker.distance
        if distance >= min and distance <= max then 
            list[#list+1] = marker
        end
    end 

    return list
end

function markers:run(index)
    local marker = self[index]
    while marker.running do 
        Wait(0)
        marker:inside()
    end 
end 

CreateThread(function()
    while true do 
        Wait(1500)
        local coords = GetEntityCoords(ESX.PlayerData.Ped)
        for i = 1, #markers do
            local marker = markers[i]
            marker.distance = #(coords - marker.coords) 
            if marker.distance < marker.radius then 
                if marker.status and marker.inside and not marker.running then 
                    marker.running = true
                    markers:run(i)
                elseif not marker.status then 
                    marker.status = true
                    if marker.entered then 
                        marker:Entered()
                    end
                end 
            elseif marker.status then 
                marker.status = false 
                if marker.exited then 
                    marker:Exited()
                end
                marker.running = false
            end
        end 
    end
end)

local marker = ESX.createMarker({coords = vec(1,1,1), radius = 5})

function marker:inside() 
    -- Loops
    print(json.encode(self)) -- coords, radius, inside, distance

end 

function marker:exited()
    -- Tick
    print(json.encode(self)) -- coords, radius, inside, distance
end 

function marker:entered()
    -- Tick
    print(json.encode(self)) -- coords, radius, inside, distance
end
