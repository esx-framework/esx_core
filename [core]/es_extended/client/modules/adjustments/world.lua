-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

-- Optional server-owned population override. Cache state-bag changes instead of
-- deserializing GlobalState on every frame or running a competing resource loop.
local populationDensity
local function updatePopulationDensity(value)
    if type(value) ~= "table" then
        populationDensity = nil
        return
    end

    local density = {}
    for _, key in ipairs({ "pedDensity", "vehicleDensity", "randomVehicleDensity" }) do
        local multiplier = value[key]
        if type(multiplier) == "number" and multiplier == multiplier and multiplier >= 0 and multiplier <= 1 then
            density[key] = multiplier
        end
    end
    populationDensity = density
end

AddStateBagChangeHandler("esx:populationDensity", "global", function(_, _, value)
    updatePopulationDensity(value)
end)
updatePopulationDensity(GlobalState["esx:populationDensity"])

function Adjustments:DisableNPCDrops()
    if Config.DisableNPCDrops then
        local weaponPickups = { `PICKUP_WEAPON_CARBINERIFLE`, `PICKUP_WEAPON_PISTOL`, `PICKUP_WEAPON_PUMPSHOTGUN` }
        for i = 1, #weaponPickups do
            ToggleUsePickupsForPlayer(ESX.playerId, weaponPickups[i], false)
        end
    end
end

function Adjustments:DispatchServices()
    if Config.DisableDispatchServices then
        for i = 1, 15 do
            EnableDispatchService(i, false)
        end
        SetAudioFlag("PoliceScannerDisabled", true)
    end
end

function Adjustments:NPCScenarios()
    if Config.DisableScenarios then
        local scenarios = {
            "WORLD_VEHICLE_ATTRACTOR",
            "WORLD_VEHICLE_AMBULANCE",
            "WORLD_VEHICLE_BICYCLE_BMX",
            "WORLD_VEHICLE_BICYCLE_BMX_BALLAS",
            "WORLD_VEHICLE_BICYCLE_BMX_FAMILY",
            "WORLD_VEHICLE_BICYCLE_BMX_HARMONY",
            "WORLD_VEHICLE_BICYCLE_BMX_VAGOS",
            "WORLD_VEHICLE_BICYCLE_MOUNTAIN",
            "WORLD_VEHICLE_BICYCLE_ROAD",
            "WORLD_VEHICLE_BIKE_OFF_ROAD_RACE",
            "WORLD_VEHICLE_BIKER",
            "WORLD_VEHICLE_BOAT_IDLE",
            "WORLD_VEHICLE_BOAT_IDLE_ALAMO",
            "WORLD_VEHICLE_BOAT_IDLE_MARQUIS",
            "WORLD_VEHICLE_BROKEN_DOWN",
            "WORLD_VEHICLE_BUSINESSMEN",
            "WORLD_VEHICLE_HELI_LIFEGUARD",
            "WORLD_VEHICLE_CLUCKIN_BELL_TRAILER",
            "WORLD_VEHICLE_CONSTRUCTION_SOLO",
            "WORLD_VEHICLE_CONSTRUCTION_PASSENGERS",
            "WORLD_VEHICLE_DRIVE_PASSENGERS",
            "WORLD_VEHICLE_DRIVE_PASSENGERS_LIMITED",
            "WORLD_VEHICLE_DRIVE_SOLO",
            "WORLD_VEHICLE_FIRE_TRUCK",
            "WORLD_VEHICLE_EMPTY",
            "WORLD_VEHICLE_MARIACHI",
            "WORLD_VEHICLE_MECHANIC",
            "WORLD_VEHICLE_MILITARY_PLANES_BIG",
            "WORLD_VEHICLE_MILITARY_PLANES_SMALL",
            "WORLD_VEHICLE_PARK_PARALLEL",
            "WORLD_VEHICLE_PARK_PERPENDICULAR_NOSE_IN",
            "WORLD_VEHICLE_PASSENGER_EXIT",
            "WORLD_VEHICLE_POLICE_BIKE",
            "WORLD_VEHICLE_POLICE_CAR",
            "WORLD_VEHICLE_POLICE",
            "WORLD_VEHICLE_POLICE_NEXT_TO_CAR",
            "WORLD_VEHICLE_QUARRY",
            "WORLD_VEHICLE_SALTON",
            "WORLD_VEHICLE_SALTON_DIRT_BIKE",
            "WORLD_VEHICLE_SECURITY_CAR",
            "WORLD_VEHICLE_STREETRACE",
            "WORLD_VEHICLE_TOURBUS",
            "WORLD_VEHICLE_TOURIST",
            "WORLD_VEHICLE_TANDL",
            "WORLD_VEHICLE_TRACTOR",
            "WORLD_VEHICLE_TRACTOR_BEACH",
            "WORLD_VEHICLE_TRUCK_LOGS",
            "WORLD_VEHICLE_TRUCKS_TRAILERS",
            "WORLD_VEHICLE_DISTANT_EMPTY_GROUND",
            "WORLD_HUMAN_PAPARAZZI",
        }

        for i = 1, #scenarios do
            SetScenarioTypeEnabled(scenarios[i], false)
        end
    end
end

function Adjustments:LicensePlates()
    SetDefaultVehicleNumberPlateTextPattern(-1, Config.CustomAIPlates)
end

function Adjustments:Multipliers()
    CreateThread(function()
        while ESX.PlayerLoaded do
            local density = populationDensity
            local pedDensity = density and density.pedDensity
            local vehicleDensity = density and density.vehicleDensity
            local randomVehicleDensity = density and density.randomVehicleDensity
            SetPedDensityMultiplierThisFrame(pedDensity or Config.Multipliers.pedDensity)
            SetScenarioPedDensityMultiplierThisFrame(pedDensity or Config.Multipliers.scenarioPedDensityInterior, pedDensity or Config.Multipliers.scenarioPedDensityExterior)
            SetAmbientVehicleRangeMultiplierThisFrame(Config.Multipliers.ambientVehicleRange)
            SetParkedVehicleDensityMultiplierThisFrame(vehicleDensity or Config.Multipliers.parkedVehicleDensity)
            SetRandomVehicleDensityMultiplierThisFrame(randomVehicleDensity or Config.Multipliers.randomVehicleDensity)
            SetVehicleDensityMultiplierThisFrame(vehicleDensity or Config.Multipliers.vehicleDensity)
            Wait(0)
        end
    end)
end
