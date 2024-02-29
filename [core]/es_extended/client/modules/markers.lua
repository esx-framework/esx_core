local Markers = {}

---@func fun(coords: vector3, radius: number, data?: any)
function ESX.CreateMarker(data) 
    local coords = data.coords

    if type(coords) ~= 'vector3' then 
        if coords.x and coords.y and coords.z then 
            data.coords = vec3(coords.x, coords.y, coords.z)
        elseif coords[1] and coords[2] and coords[3] then 
            data.coords = vec3(coords[1], coords[2], coords[3])    
        end
    end

    local Index = #Markers+1
    Markers[Index] = data
    return Markers[Index]
end

function ESX.GetNearestMarker()
    local Nearest
    local Distance = 9999
    for i = 1, #Markers do 
        local Marker = Markers[i]
        local dist = Marker.distance
        if dist < Distance then 
            Distance = dist
            Nearest = Marker
        end 
    end 
    return Nearest, Distance
end 

function ESX.GetMarkersInRange(min, max)
    local List = {}    
    for i = 1, #Markers do 
        local Marker = Markers[i]
        local Distance = Marker.distance
        if Distance >= min and Distance <= max then 
            List[#List+1] = Marker
        end
    end 

    return List
end

function Markers:Run(index)
    CreateThread(function()
        local Marker = self[index]
        while Marker.running do 
            Wait(0)
            Marker:Inside()
        end 
    end)
end x

CreateThread(function()
    while true do 
        Wait(1500)
        local Coords = GetEntityCoords(ESX.PlayerData.Ped)
        for i = 1, #Markers do
            local Marker = Markers[i]
            Marker.distance = #(Coords - Marker.coords) 
            if Marker.distance < Marker.radius then 
                if Marker.status and Marker.Inside and not Marker.running then 
                    Marker.running = true
                    Markers:Run(i)
                elseif not Marker.status then 
                    Marker.status = true
                    if Marker.Entered then 
                        Marker:Entered()
                    end
                end 
            elseif Marker.status then 
                Marker.status = false 
                if Marker.Exited then 
                    Marker:Exited()
                end
                Marker.running = false
            end
        end 
    end
end)

local Marker = ESX.CreateMarker({coords = vec(1,1,1), radius = 5})

function Marker:Inside() 
    -- Loops
    print(json.encode(self)) -- coords, radius, inside, distance

end 

function Marker:Exited()
    -- Tick
    print(json.encode(self)) -- coords, radius, inside, distance
end 

function Marker:Entered()
    -- Tick
    print(json.encode(self)) -- coords, radius, inside, distance
end
