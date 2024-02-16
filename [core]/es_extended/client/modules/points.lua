local Points = {}

---@func fun(coords: vector3, radius: number, data?: any)
function ESX.CreatePoint(data) 
    local Index = #Points+1
    Points[Index] = data
    return Points[Index]
end

CreateThread(function()
    while true do 
        Wait(0)
        local InPoint = false
        local Coords = GetEntityCoords(ESX.PlayerData.Ped)
        for i = 1, #Points do
            local Point = Points[i]
            Point.distance = #(Coords - Point.Coords) 
            if Point.distance < Point.radius then 
                if Point.status and Point.Inside then 
                    Point:Inside()
                    InPoint = true 
                elseif Point.Inside and not Point.inside then 
                    Point.status = true
                    InPoint = true 
                    if Point.Entered then 
                        Point:Entered()
                    end
                end 
            elseif Point.inside then 
                Point.inside = false 
                if Point.Exited then 
                    Point:Exited()
                end
                InPoint = false 
            end
        end 
        if not InPoint then 
            Wait(1500)
        end 
    end
end)


local Point = ESX.CreatePoint({coords = vec(1,1,1), radius = 5})

function Point:Inside() 
    -- Loops
    print(json.encode(self)) -- coords, radius, inside, distance

end 

function Point:Exited()
    -- Tick
    print(json.encode(self)) -- coords, radius, inside, distance
end 

function Point:Entered()
    -- Tick
    print(json.encode(self)) -- coords, radius, inside, distance
end
