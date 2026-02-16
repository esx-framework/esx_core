local ESX = exports["es_extended"]:getSharedObject()
local isDancing = false
local isAtBar = false
local currentClub = nil

-- Main interaction thread
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())

        for _, club in ipairs(Config.Clubs) do
            local distEntrance = #(playerCoords - club.coords)

            if distEntrance < 50.0 then
                sleep = 0

                -- Club entrance marker
                DrawMarker(
                    1, club.coords.x, club.coords.y, club.coords.z - 1.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    2.0, 2.0, 1.0,
                    255, 0, 128, 100,
                    false, true, 2, nil, nil, false
                )

                if distEntrance < 2.5 then
                    ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to enter ~p~" .. club.name .. "~s~")

                    if IsControlJustReleased(0, 38) then
                        currentClub = club
                        OpenClubMenu(club)
                    end
                end

                -- Bar marker
                local distBar = #(playerCoords - club.barLocation)
                if distBar < 15.0 then
                    DrawMarker(
                        1, club.barLocation.x, club.barLocation.y, club.barLocation.z - 1.0,
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                        1.0, 1.0, 0.8,
                        255, 215, 0, 100,
                        false, true, 2, nil, nil, false
                    )

                    if distBar < 2.0 then
                        ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to order a ~y~drink~s~")

                        if IsControlJustReleased(0, 38) then
                            OpenBarMenu(club)
                        end
                    end
                end

                -- Dance floor detection
                local distDance = #(playerCoords - club.danceFloor)
                if distDance < club.danceRadius then
                    if not isDancing then
                        ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to ~p~dance~s~ | ~INPUT_FRONTEND_CANCEL~ to stop")

                        if IsControlJustReleased(0, 38) then
                            StartDancing()
                        end
                    else
                        if IsControlJustReleased(0, 202) then -- Backspace
                            StopDancing()
                        end
                    end
                elseif isDancing then
                    StopDancing()
                end

                -- DJ Booth
                local distDJ = #(playerCoords - club.djBooth)
                if distDJ < 15.0 then
                    DrawMarker(
                        1, club.djBooth.x, club.djBooth.y, club.djBooth.z - 1.0,
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                        1.0, 1.0, 0.8,
                        128, 0, 255, 100,
                        false, true, 2, nil, nil, false
                    )

                    if distDJ < 2.0 then
                        ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to ~p~DJ a set~s~ and earn bread")

                        if IsControlJustReleased(0, 38) then
                            StartDJSet(club)
                        end
                    end
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

function OpenClubMenu(club)
    local elements = {
        {
            unselectable = true,
            icon = "fas fa-music",
            title = "~p~" .. club.name,
            description = "The hottest spot in TrickEm City"
        },
        {
            unselectable = false,
            icon = "fas fa-glass-martini-alt",
            title = "~y~Hit the Bar",
            value = "bar"
        },
        {
            unselectable = false,
            icon = "fas fa-music",
            title = "~p~Hit the Dance Floor",
            value = "dance"
        },
        {
            unselectable = false,
            icon = "fas fa-headphones",
            title = "~b~DJ a Set (Earn $" .. Config.DJPayPerSet .. ")",
            value = "dj"
        },
    }

    ESX.OpenContext('right', elements, function(menu, element)
        if element.value == "bar" then
            ESX.CloseContext()
            OpenBarMenu(club)
        elseif element.value == "dance" then
            ESX.CloseContext()
            StartDancing()
        elseif element.value == "dj" then
            ESX.CloseContext()
            StartDJSet(club)
        end
    end)
end

function OpenBarMenu(club)
    local elements = {
        {
            unselectable = true,
            icon = "fas fa-cocktail",
            title = "~y~" .. club.name .. " Bar",
            description = "What'll it be, sugar?"
        }
    }

    for _, drink in ipairs(Config.Drinks) do
        table.insert(elements, {
            unselectable = false,
            icon = "fas fa-glass-martini",
            title = drink.name,
            description = "~y~$" .. drink.price,
            value = drink
        })
    end

    ESX.OpenContext('right', elements, function(menu, element)
        local drink = element.value
        ESX.CloseContext()
        TriggerServerEvent('trickem:buyDrink', drink.name, drink.price, drink.health)
    end)
end

function StartDancing()
    if isDancing then return end

    isDancing = true
    local playerPed = PlayerPedId()

    -- Pick a random dance
    local dance = Config.DanceAnims[math.random(#Config.DanceAnims)]

    RequestAnimDict(dance.dict)
    while not HasAnimDictLoaded(dance.dict) do
        Citizen.Wait(100)
    end

    TaskPlayAnim(playerPed, dance.dict, dance.anim, 8.0, -8.0, -1, 1, 0, false, false, false)

    ESX.ShowNotification("~p~Getting down! Press ~s~BACKSPACE~p~ to stop dancing.")
end

function StopDancing()
    if not isDancing then return end

    isDancing = false
    ClearPedTasks(PlayerPedId())
end

function StartDJSet(club)
    ESX.ShowNotification("~p~Spinning some vinyl! Keep the groove going...")

    local playerPed = PlayerPedId()

    -- DJ animation
    RequestAnimDict("anim@amb@nightclub@djs@tale_of_us@")
    local timeout = 0
    while not HasAnimDictLoaded("anim@amb@nightclub@djs@tale_of_us@") and timeout < 50 do
        Citizen.Wait(100)
        timeout = timeout + 1
    end

    if HasAnimDictLoaded("anim@amb@nightclub@djs@tale_of_us@") then
        TaskPlayAnim(playerPed, "anim@amb@nightclub@djs@tale_of_us@", "intm_tou_fist_pump_a", 8.0, -8.0, Config.DJSetDuration, 1, 0, false, false, false)
    end

    Citizen.Wait(Config.DJSetDuration)

    ClearPedTasks(playerPed)
    TriggerServerEvent('trickem:djSetComplete')
    ESX.ShowNotification("~g~Set complete! The crowd loved it. Bread earned!")
end

-- Drink effects
RegisterNetEvent('trickem:drinkEffect')
AddEventHandler('trickem:drinkEffect', function(health)
    local playerPed = PlayerPedId()
    local currentHealth = GetEntityHealth(playerPed)
    SetEntityHealth(playerPed, math.min(200, currentHealth + health))

    -- Drinking animation
    RequestAnimDict("mp_player_intdrink")
    while not HasAnimDictLoaded("mp_player_intdrink") do
        Citizen.Wait(100)
    end
    TaskPlayAnim(playerPed, "mp_player_intdrink", "loop_bottle", 8.0, -8.0, 2000, 49, 0, false, false, false)
end)

-- Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        StopDancing()
    end
end)
