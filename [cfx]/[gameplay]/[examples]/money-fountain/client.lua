-- add text entries for all the help types we have
AddTextEntry('FOUNTAIN_HELP', 'This fountain currently contains $~1~.~n~Press ~INPUT_PICKUP~ to obtain $~1~.~n~Press ~INPUT_DETONATE~ to place $~1~.')
AddTextEntry('FOUNTAIN_HELP_DRAINED', 'This fountain currently contains $~1~.~n~Press ~INPUT_DETONATE~ to place $~1~.')
AddTextEntry('FOUNTAIN_HELP_BROKE', 'This fountain currently contains $~1~.~n~Press ~INPUT_PICKUP~ to obtain $~1~.')
AddTextEntry('FOUNTAIN_HELP_BROKE_N_DRAINED', 'This fountain currently contains $~1~.')
AddTextEntry('FOUNTAIN_HELP_INUSE', 'This fountain currently contains $~1~.~n~You can use it again in ~a~.')

-- upvalue aliases so that we will be fast if far away
local Wait = Wait
local GetEntityCoords = GetEntityCoords
local PlayerPedId = PlayerPedId

-- timer, don't tick as frequently if we're far from any money fountain
local relevanceTimer = 500

CreateThread(function()
    local pressing = false

    while true do
        Wait(relevanceTimer)

        local coords = GetEntityCoords(PlayerPedId())

        for _, data in pairs(moneyFountains) do
            -- if we're near this fountain
            local dist = #(coords - data.coords)

            -- near enough to draw
            if dist < 40 then
                -- ensure per-frame tick
                relevanceTimer = 0

                DrawMarker(29, data.coords.x, data.coords.y, data.coords.z, 0, 0, 0, 0.0, 0, 0, 1.0, 1.0, 1.0, 0, 150, 0, 120, false, true, 2, false, nil, nil, false)
            else
                -- put the relevance timer back to the way it was
                relevanceTimer = 500
            end

            -- near enough to use
            if dist < 1 then
                -- are we able to use it? if not, display appropriate help
                local player = LocalPlayer
                local nextUse = player.state['fountain_nextUse']

                -- GetNetworkTime is synced for everyone
                if nextUse and nextUse >= GetNetworkTime() then
                    BeginTextCommandDisplayHelp('FOUNTAIN_HELP_INUSE')
                    AddTextComponentInteger(GlobalState['fountain_' .. data.id])
                    AddTextComponentSubstringTime(math.tointeger(nextUse - GetNetworkTime()), 2 | 4) -- seconds (2), minutes (4)
                    EndTextCommandDisplayHelp(0, false, false, 1000)
                else
                    -- handle inputs for pickup/place
                    if not pressing then
                        if IsControlPressed(0, 38 --[[ INPUT_PICKUP ]]) then
                            TriggerServerEvent('money_fountain:tryPickup', data.id)
                            pressing = true
                        elseif IsControlPressed(0, 47 --[[ INPUT_DETONATE ]]) then
                            TriggerServerEvent('money_fountain:tryPlace', data.id)
                            pressing = true
                        end
                    else
                        if not IsControlPressed(0, 38 --[[ INPUT_PICKUP ]]) and 
                           not IsControlPressed(0, 47 --[[ INPUT_DETONATE ]]) then
                            pressing = false
                        end
                    end

                    -- decide the appropriate help message
                    local youCanSpend = (player.state['money_cash'] or 0) >= data.amount
                    local fountainCanSpend = GlobalState['fountain_' .. data.id] >= data.amount

                    local helpName

                    if youCanSpend and fountainCanSpend then
                        helpName = 'FOUNTAIN_HELP'
                    elseif youCanSpend and not fountainCanSpend then
                        helpName = 'FOUNTAIN_HELP_DRAINED'
                    elseif not youCanSpend and fountainCanSpend then
                        helpName = 'FOUNTAIN_HELP_BROKE'
                    else
                        helpName = 'FOUNTAIN_HELP_BROKE_N_DRAINED'
                    end

                    -- and print it
                    BeginTextCommandDisplayHelp(helpName)
                    AddTextComponentInteger(GlobalState['fountain_' .. data.id])

                    if fountainCanSpend then
                        AddTextComponentInteger(data.amount)
                    end

                    if youCanSpend then
                        AddTextComponentInteger(data.amount)
                    end

                    EndTextCommandDisplayHelp(0, false, false, 1000)
                end
            end
        end
    end
end)