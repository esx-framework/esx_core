Config = {}

-- 70s Themed Job Locations
-- Each job has a sign-up location and work areas

Config.Jobs = {
    -- Taxi / Cab Driver
    taxi = {
        label = "Downtown Cab Co.",
        signupLocation = vector3(895.0, -179.0, 74.0),
        signupNPC = {
            model = "a_m_m_eastsa_01",
            coords = vector4(895.0, -179.0, 73.0, 240.0)
        },
        vehicleSpawn = vector4(903.0, -170.0, 74.0, 150.0),
        vehicleModel = "taxi",
        farePerMile = 12,
        pickupLocations = {
            {name = "Airport Terminal", coords = vector3(-1037.0, -2737.0, 13.8)},
            {name = "Vinewood Blvd", coords = vector3(307.0, 179.0, 104.0)},
            {name = "Del Perro Pier", coords = vector3(-1660.0, -1018.0, 13.1)},
            {name = "Legion Square", coords = vector3(197.0, -935.0, 30.7)},
            {name = "Vespucci Beach", coords = vector3(-1363.0, -1497.0, 4.4)},
            {name = "Rockford Hills", coords = vector3(-795.0, -230.0, 37.1)},
            {name = "Little Seoul", coords = vector3(-740.0, -740.0, 28.2)},
            {name = "East LS", coords = vector3(340.0, -1856.0, 27.5)},
            {name = "Mirror Park", coords = vector3(1042.0, -765.0, 58.0)},
            {name = "Sandy Shores", coords = vector3(1959.0, 3740.0, 32.3)},
        },
        dropoffLocations = {
            {name = "Downtown Vinewood", coords = vector3(353.0, 78.0, 68.4)},
            {name = "Pillbox Hill", coords = vector3(270.0, -1302.0, 29.3)},
            {name = "Strawberry", coords = vector3(74.0, -1395.0, 29.4)},
            {name = "Burton", coords = vector3(-632.0, -234.0, 38.1)},
            {name = "Hawick", coords = vector3(-140.0, -302.0, 40.1)},
            {name = "Alta", coords = vector3(-202.0, -819.0, 30.7)},
            {name = "Davis", coords = vector3(97.0, -1925.0, 20.8)},
            {name = "Rancho", coords = vector3(503.0, -1740.0, 28.9)},
            {name = "Morningwood", coords = vector3(-1270.0, -347.0, 36.7)},
            {name = "Pacific Bluffs", coords = vector3(-2152.0, -398.0, 13.3)},
        }
    },

    -- Mechanic
    mechanic = {
        label = "Slick's Auto Body",
        signupLocation = vector3(-337.0, -133.0, 39.0),
        signupNPC = {
            model = "s_m_m_autoshop_02",
            coords = vector4(-337.0, -133.0, 38.0, 120.0)
        },
        repairPrice = 250,
        towPrice = 150,
        locations = {
            {name = "Main Shop", coords = vector3(-337.0, -133.0, 39.0)},
            {name = "East LS Branch", coords = vector3(538.0, -183.0, 54.0)},
        }
    },

    -- Fisherman
    fisherman = {
        label = "Del Perro Fishing",
        signupLocation = vector3(-1850.0, -1231.0, 13.0),
        signupNPC = {
            model = "a_m_m_salton_04",
            coords = vector4(-1850.0, -1231.0, 12.0, 135.0)
        },
        fishingSpots = {
            {name = "Del Perro Pier", coords = vector3(-1858.0, -1244.0, 8.6)},
            {name = "Vespucci Canals", coords = vector3(-1129.0, -1586.0, 4.4)},
            {name = "Paleto Cove", coords = vector3(-1584.0, 5165.0, 4.0)},
        },
        fishTypes = {
            {name = "Bass", price = 15, weight = 1},
            {name = "Catfish", price = 20, weight = 2},
            {name = "Trout", price = 25, weight = 1},
            {name = "Salmon", price = 35, weight = 2},
            {name = "Tuna", price = 50, weight = 3},
        },
        sellLocation = vector3(-1827.0, -1196.0, 14.3)
    },

    -- Lumberjack
    lumberjack = {
        label = "Paleto Lumber Co.",
        signupLocation = vector3(-538.0, 5400.0, 70.0),
        signupNPC = {
            model = "s_m_m_gardener_01",
            coords = vector4(-538.0, 5400.0, 69.0, 0.0)
        },
        treeLocations = {
            vector3(-559.0, 5422.0, 70.0),
            vector3(-543.0, 5435.0, 70.0),
            vector3(-571.0, 5445.0, 70.0),
            vector3(-528.0, 5410.0, 68.0),
            vector3(-547.0, 5460.0, 65.0),
        },
        processLocation = vector3(-540.0, 5390.0, 70.0),
        sellLocation = vector3(-557.0, 5370.0, 70.0),
        woodPrice = 18,
        plankPrice = 35
    },

    -- Miner
    miner = {
        label = "Raton Canyon Mine",
        signupLocation = vector3(2960.0, 2758.0, 43.0),
        signupNPC = {
            model = "s_m_y_construct_02",
            coords = vector4(2960.0, 2758.0, 42.0, 180.0)
        },
        miningSpots = {
            vector3(2947.0, 2770.0, 43.0),
            vector3(2936.0, 2782.0, 43.0),
            vector3(2955.0, 2795.0, 43.0),
            vector3(2970.0, 2780.0, 43.0),
        },
        oreTypes = {
            {name = "Iron Ore", item = "iron", price = 12, chance = 50},
            {name = "Copper Ore", item = "copper", price = 18, chance = 30},
            {name = "Gold Nugget", item = "gold", price = 65, chance = 15},
            {name = "Diamond", item = "diamond", price = 150, chance = 5},
        },
        sellLocation = vector3(2945.0, 2750.0, 43.0)
    }
}

-- NPC interaction distance
Config.InteractionDistance = 2.5

-- Marker settings
Config.MarkerColor = {r = 255, g = 107, b = 53, a = 100} -- 70s orange
