local Markers = {}

---@func fun(coords: vector3, radius: number, data?: any)
function ESX.CreateMarker(data) 
    local Index = #Points+1
    Markers[Index] = data
    return Markers[Index]
end

CreateThread(function()
    while true do 
        Wait(0)
        local InPoint = false
        local Coords = GetEntityCoords(ESX.PlayerData.Ped)
        for i = 1, #Markers do
            local Marker = Markers[i]
            Marker.distance = #(Coords - Marker.Coords) 
            if Marker.distance < Marker.radius then 
                if Marker.status and Marker.Inside then 
                    Marker:Inside()
                    InPoint = true 
                elseif Marker.Inside and not Marker.status then 
                    Marker.status = true
                    InPoint = true 
                    if Marker.Entered then 
                        Marker:Entered()
                    end
                end 
            elseif Marker.inside then 
                Marker.status = false 
                if Marker.Exited then 
                    Marker:Exited()
                end
                InPoint = false 
            end
        end 
        if not InPoint then 
            Wait(1500)
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
