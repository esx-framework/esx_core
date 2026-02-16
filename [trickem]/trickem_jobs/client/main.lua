local ESX = exports["es_extended"]:getSharedObject()
local PlayerData = ESX.GetPlayerData()
local isWorking = false
local currentFare = nil

-- Track player data changes
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

-- Main thread for job markers and interactions
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())

        for jobName, jobData in pairs(Config.Jobs) do
            local signupDist = #(playerCoords - jobData.signupLocation)

            if signupDist < 30.0 then
                sleep = 0

                -- Draw marker at signup location
                DrawMarker(
                    1, jobData.signupLocation.x, jobData.signupLocation.y, jobData.signupLocation.z - 1.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    1.5, 1.5, 1.0,
                    Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a,
                    false, true, 2, nil, nil, false
                )

                if signupDist < Config.InteractionDistance then
                    ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to talk to the ~o~" .. jobData.label .. "~s~ manager")

                    if IsControlJustReleased(0, 38) then
                        OpenJobMenu(jobName, jobData)
                    end
                end
            end

            -- Draw sell location markers for applicable jobs
            if jobData.sellLocation then
                local sellDist = #(playerCoords - jobData.sellLocation)
                if sellDist < 20.0 then
                    sleep = 0
                    DrawMarker(
                        1, jobData.sellLocation.x, jobData.sellLocation.y, jobData.sellLocation.z - 1.0,
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                        1.5, 1.5, 1.0,
                        0, 200, 0, 100,
                        false, true, 2, nil, nil, false
                    )

                    if sellDist < Config.InteractionDistance then
                        ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to ~g~sell your goods~s~")

                        if IsControlJustReleased(0, 38) then
                            TriggerServerEvent('trickem:sellGoods', jobName)
                        end
                    end
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

function OpenJobMenu(jobName, jobData)
    local elements = {}

    if PlayerData.job and PlayerData.job.name == jobName then
        -- Already employed - show work options
        table.insert(elements, {
            unselectable = true,
            icon = "fas fa-briefcase",
            title = "~o~" .. jobData.label,
            description = "You're clocked in, baby!"
        })

        if jobName == "taxi" then
            table.insert(elements, {
                unselectable = false,
                icon = "fas fa-taxi",
                title = "~y~Start shift - Grab a cab",
                value = "taxi_start"
            })
            table.insert(elements, {
                unselectable = false,
                icon = "fas fa-stop",
                title = "~r~End shift",
                value = "taxi_end"
            })
        elseif jobName == "fisherman" then
            table.insert(elements, {
                unselectable = false,
                icon = "fas fa-fish",
                title = "~y~Go fishing",
                value = "fish_start"
            })
        elseif jobName == "lumberjack" then
            table.insert(elements, {
                unselectable = false,
                icon = "fas fa-tree",
                title = "~y~Start chopping",
                value = "lumber_start"
            })
        elseif jobName == "miner" then
            table.insert(elements, {
                unselectable = false,
                icon = "fas fa-gem",
                title = "~y~Start mining",
                value = "mine_start"
            })
        end

        table.insert(elements, {
            unselectable = false,
            icon = "fas fa-sign-out-alt",
            title = "~r~Quit this gig",
            value = "quit"
        })
    else
        -- Not employed here
        table.insert(elements, {
            unselectable = true,
            icon = "fas fa-briefcase",
            title = "~o~" .. jobData.label,
            description = "Looking for work? We're hiring, dig?"
        })
        table.insert(elements, {
            unselectable = false,
            icon = "fas fa-handshake",
            title = "~g~Sign up for this gig",
            value = "signup"
        })
    end

    ESX.OpenContext('right', elements, function(menu, element)
        if element.value == "signup" then
            ESX.CloseContext()
            TriggerServerEvent('trickem:signupJob', jobName)
        elseif element.value == "quit" then
            ESX.CloseContext()
            TriggerServerEvent('trickem:quitJob')
        elseif element.value == "taxi_start" then
            ESX.CloseContext()
            StartTaxiShift(jobData)
        elseif element.value == "taxi_end" then
            ESX.CloseContext()
            EndTaxiShift()
        elseif element.value == "fish_start" then
            ESX.CloseContext()
            StartFishing(jobData)
        elseif element.value == "lumber_start" then
            ESX.CloseContext()
            StartLumberjack(jobData)
        elseif element.value == "mine_start" then
            ESX.CloseContext()
            StartMining(jobData)
        end
    end)
end

-- TAXI JOB
local taxiVehicle = nil
local taxiBlip = nil

function StartTaxiShift(jobData)
    if taxiVehicle and DoesEntityExist(taxiVehicle) then
        ESX.ShowNotification("~r~You already have a cab out, daddy-o!")
        return
    end

    local modelHash = GetHashKey(jobData.vehicleModel)
    RequestModel(modelHash)

    while not HasModelLoaded(modelHash) do
        Citizen.Wait(100)
    end

    local spawn = jobData.vehicleSpawn
    taxiVehicle = CreateVehicle(modelHash, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    SetVehicleNumberPlateText(taxiVehicle, "TAXI 70")
    SetVehicleColours(taxiVehicle, 89, 89) -- Taxi yellow
    SetModelAsNoLongerNeeded(modelHash)
    TaskWarpPedIntoVehicle(PlayerPedId(), taxiVehicle, -1)

    ESX.ShowNotification("~y~Your cab is ready! Cruise around and pick up fares.")
    ESX.ShowNotification("~y~Check the map for fare locations marked in yellow.")

    -- Create fare pickup blips
    GenerateTaxiFare(jobData)
end

function GenerateTaxiFare(jobData)
    if taxiBlip and DoesBlipExist(taxiBlip) then
        RemoveBlip(taxiBlip)
    end

    local pickup = jobData.pickupLocations[math.random(#jobData.pickupLocations)]
    taxiBlip = AddBlipForCoord(pickup.coords.x, pickup.coords.y, pickup.coords.z)
    SetBlipSprite(taxiBlip, 198)
    SetBlipColour(taxiBlip, 5)
    SetBlipScale(taxiBlip, 0.9)
    SetBlipRoute(taxiBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Fare: " .. pickup.name)
    EndTextCommandSetBlipName(taxiBlip)

    currentFare = {pickup = pickup, jobData = jobData}

    -- Wait for player to reach pickup
    Citizen.CreateThread(function()
        while currentFare do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local dist = #(playerCoords - currentFare.pickup.coords)

            if dist < 10.0 then
                ESX.ShowNotification("~g~Passenger picked up! Take them to the dropoff.")

                if taxiBlip and DoesBlipExist(taxiBlip) then
                    RemoveBlip(taxiBlip)
                end

                -- Set dropoff
                local dropoff = jobData.dropoffLocations[math.random(#jobData.dropoffLocations)]
                taxiBlip = AddBlipForCoord(dropoff.coords.x, dropoff.coords.y, dropoff.coords.z)
                SetBlipSprite(taxiBlip, 198)
                SetBlipColour(taxiBlip, 2)
                SetBlipScale(taxiBlip, 0.9)
                SetBlipRoute(taxiBlip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Dropoff: " .. dropoff.name)
                EndTextCommandSetBlipName(taxiBlip)

                -- Wait for dropoff
                while currentFare do
                    local playerCoords2 = GetEntityCoords(PlayerPedId())
                    local dist2 = #(playerCoords2 - dropoff.coords)

                    if dist2 < 10.0 then
                        local fare = jobData.farePerMile * math.random(8, 25)
                        TriggerServerEvent('trickem:taxiFareComplete', fare)

                        if taxiBlip and DoesBlipExist(taxiBlip) then
                            RemoveBlip(taxiBlip)
                        end

                        Citizen.Wait(2000)
                        if currentFare then
                            GenerateTaxiFare(jobData)
                        end
                        return
                    end
                    Citizen.Wait(1000)
                end
                return
            end
            Citizen.Wait(1000)
        end
    end)
end

function EndTaxiShift()
    currentFare = nil

    if taxiBlip and DoesBlipExist(taxiBlip) then
        RemoveBlip(taxiBlip)
        taxiBlip = nil
    end

    if taxiVehicle and DoesEntityExist(taxiVehicle) then
        DeleteEntity(taxiVehicle)
        taxiVehicle = nil
    end

    ESX.ShowNotification("~o~Shift over! Good hustling out there.")
end

-- FISHING JOB
function StartFishing(jobData)
    local nearest = nil
    local nearestDist = 999999
    local playerCoords = GetEntityCoords(PlayerPedId())

    for _, spot in ipairs(jobData.fishingSpots) do
        local dist = #(playerCoords - spot.coords)
        if dist < nearestDist then
            nearestDist = dist
            nearest = spot
        end
    end

    if nearestDist > 50.0 then
        ESX.ShowNotification("~r~Head to a fishing spot first! Check the map, baby.")
        return
    end

    ESX.ShowNotification("~y~Casting your line... Hold tight!")

    -- Fishing animation
    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_FISHING", 0, true)

    local fishTime = math.random(8000, 15000)
    Citizen.Wait(fishTime)

    ClearPedTasks(playerPed)

    -- Random catch
    local roll = math.random(1, 100)
    local cumulativeChance = 0
    local caughtFish = nil

    -- 20% chance of catching nothing
    if roll <= 20 then
        ESX.ShowNotification("~r~Nothing biting... Try again!")
        return
    end

    -- Determine which fish
    local fishRoll = math.random(1, 100)
    for _, fish in ipairs(jobData.fishTypes) do
        cumulativeChance = cumulativeChance + fish.chance
        if fishRoll <= cumulativeChance then
            caughtFish = fish
            break
        end
    end

    if caughtFish then
        TriggerServerEvent('trickem:caughtFish', caughtFish.name, caughtFish.price)
        ESX.ShowNotification("~g~Far out! You caught a " .. caughtFish.name .. "! Worth ~y~$" .. caughtFish.price)
    end
end

-- LUMBERJACK JOB
function StartLumberjack(jobData)
    local nearest = nil
    local nearestDist = 999999
    local playerCoords = GetEntityCoords(PlayerPedId())

    for _, spot in ipairs(jobData.treeLocations) do
        local dist = #(playerCoords - spot)
        if dist < nearestDist then
            nearestDist = dist
            nearest = spot
        end
    end

    if nearestDist > 20.0 then
        ESX.ShowNotification("~r~Get closer to the trees, man!")
        return
    end

    ESX.ShowNotification("~y~Chopping wood... Put your back into it!")

    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_HAMMERING", 0, true)

    Citizen.Wait(math.random(8000, 12000))
    ClearPedTasks(playerPed)

    local amount = math.random(1, 3)
    TriggerServerEvent('trickem:harvestWood', amount)
    ESX.ShowNotification("~g~Solid work! Got " .. amount .. " wood.")
end

-- MINING JOB
function StartMining(jobData)
    local nearest = nil
    local nearestDist = 999999
    local playerCoords = GetEntityCoords(PlayerPedId())

    for _, spot in ipairs(jobData.miningSpots) do
        local dist = #(playerCoords - spot)
        if dist < nearestDist then
            nearestDist = dist
            nearest = spot
        end
    end

    if nearestDist > 20.0 then
        ESX.ShowNotification("~r~Get to a mining spot first, brother!")
        return
    end

    ESX.ShowNotification("~y~Swinging the pickaxe... Dig deep!")

    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_HAMMERING", 0, true)

    Citizen.Wait(math.random(10000, 15000))
    ClearPedTasks(playerPed)

    -- Random ore
    local roll = math.random(1, 100)
    local cumulativeChance = 0

    for _, ore in ipairs(jobData.oreTypes) do
        cumulativeChance = cumulativeChance + ore.chance
        if roll <= cumulativeChance then
            TriggerServerEvent('trickem:minedOre', ore.item, ore.name, ore.price)
            ESX.ShowNotification("~g~Right on! Found " .. ore.name .. "!")
            return
        end
    end
end

-- Server notifications
RegisterNetEvent('trickem:notification')
AddEventHandler('trickem:notification', function(msg)
    ESX.ShowNotification(msg)
end)

-- Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        EndTaxiShift()
    end
end)
