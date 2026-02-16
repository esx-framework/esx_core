local ESX = exports["es_extended"]:getSharedObject()
local isHudVisible = true

-- Toggle default GTA HUD elements we want to hide
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Hide default health/armor bars (we use custom ones)
        HideHudComponentThisFrame(3)  -- CASH
        HideHudComponentThisFrame(4)  -- MP CASH
        HideHudComponentThisFrame(6)  -- VEHICLE_NAME
        HideHudComponentThisFrame(7)  -- AREA_NAME
        HideHudComponentThisFrame(8)  -- VEHICLE_CLASS
        HideHudComponentThisFrame(9)  -- STREET_NAME
    end
end)

-- Update HUD data
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        if isHudVisible then
            local playerPed = PlayerPedId()
            local health = GetEntityHealth(playerPed) - 100 -- Health starts at 100 (dead) to 200
            local armor = GetPedArmour(playerPed)
            local xPlayer = ESX.GetPlayerData()
            local cash = 0
            local bank = 0
            local job = "Unemployed"
            local jobGrade = ""

            if xPlayer and xPlayer.accounts then
                for _, account in ipairs(xPlayer.accounts) do
                    if account.name == 'money' then
                        cash = account.money
                    elseif account.name == 'bank' then
                        bank = account.money
                    end
                end
            end

            if xPlayer and xPlayer.job then
                job = xPlayer.job.label or "Unemployed"
                jobGrade = xPlayer.job.grade_label or ""
            end

            -- Get current street name
            local streetHash, crossingHash = GetStreetNameAtCoord(
                GetEntityCoords(playerPed).x,
                GetEntityCoords(playerPed).y,
                GetEntityCoords(playerPed).z
            )
            local streetName = GetStreetNameFromHashKey(streetHash)

            -- Get time
            local hour = GetClockHours()
            local minute = GetClockMinutes()

            -- Check if in vehicle
            local inVehicle = IsPedInAnyVehicle(playerPed, false)
            local speed = 0
            local fuel = 0

            if inVehicle then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                speed = math.floor(GetEntitySpeed(vehicle) * 2.236936) -- Convert to MPH
                fuel = GetVehicleFuelLevel(vehicle)
            end

            SendNUIMessage({
                type = "updateHud",
                health = math.max(0, health),
                armor = armor,
                cash = cash,
                bank = bank,
                job = job,
                jobGrade = jobGrade,
                street = streetName,
                hour = hour,
                minute = minute,
                inVehicle = inVehicle,
                speed = speed,
                fuel = math.floor(fuel)
            })
        end
    end
end)

-- Toggle HUD visibility
RegisterCommand('togglehud', function()
    isHudVisible = not isHudVisible
    SendNUIMessage({
        type = "toggleHud",
        visible = isHudVisible
    })
end, false)

RegisterKeyMapping('togglehud', 'Toggle 70s HUD', 'keyboard', 'F7')
