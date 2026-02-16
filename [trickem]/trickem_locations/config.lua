Config = {}

-- 70s Themed Blips and Locations for TrickEm City
-- All coordinates are in-game GTA V map positions

Config.Blips = {
    -- Disco Clubs
    {
        name = "Disco Inferno",
        coords = vector3(-1388.0, -586.0, 30.0), -- Del Perro area
        sprite = 614, -- Nightclub icon
        color = 27, -- Pink
        scale = 0.9,
        category = "entertainment"
    },
    {
        name = "Studio 54",
        coords = vector3(134.0, -1280.0, 29.0), -- Downtown
        sprite = 614,
        color = 5, -- Yellow
        scale = 0.9,
        category = "entertainment"
    },
    {
        name = "The Boogie Room",
        coords = vector3(-565.0, 277.0, 83.0), -- Vinewood area
        sprite = 614,
        color = 27,
        scale = 0.8,
        category = "entertainment"
    },

    -- Police Stations (renamed to 70s style)
    {
        name = "LSPD Precinct - The Fuzz",
        coords = vector3(425.1, -979.5, 30.7), -- Mission Row PD
        sprite = 60,
        color = 3, -- Blue
        scale = 0.9,
        category = "emergency"
    },
    {
        name = "Sheriff's Office",
        coords = vector3(-448.2, 6008.7, 31.7), -- Paleto Bay
        sprite = 60,
        color = 3,
        scale = 0.8,
        category = "emergency"
    },

    -- Hospitals
    {
        name = "County General Hospital",
        coords = vector3(295.8, -1447.3, 29.9), -- Pillbox Hill
        sprite = 61,
        color = 1, -- Red
        scale = 0.9,
        category = "emergency"
    },
    {
        name = "Sandy Shores Medical",
        coords = vector3(1839.6, 3672.9, 34.3), -- Sandy Shores
        sprite = 61,
        color = 1,
        scale = 0.8,
        category = "emergency"
    },

    -- Gas Stations (70s style)
    {
        name = "Moe's Gas & Go",
        coords = vector3(-724.6, -935.9, 19.2),
        sprite = 361,
        color = 1,
        scale = 0.7,
        category = "services"
    },
    {
        name = "Richie's Fill-Up",
        coords = vector3(265.6, -1261.3, 29.1),
        sprite = 361,
        color = 1,
        scale = 0.7,
        category = "services"
    },
    {
        name = "Highway Service Station",
        coords = vector3(2581.5, 362.0, 108.5),
        sprite = 361,
        color = 1,
        scale = 0.7,
        category = "services"
    },

    -- Mechanic Shops
    {
        name = "Slick's Auto Body",
        coords = vector3(-337.0, -133.0, 39.0), -- Burton area
        sprite = 72,
        color = 17, -- Orange
        scale = 0.9,
        category = "services"
    },
    {
        name = "Tony's Garage",
        coords = vector3(538.0, -183.0, 54.0), -- Downtown Vinewood
        sprite = 72,
        color = 17,
        scale = 0.8,
        category = "services"
    },

    -- Car Dealership
    {
        name = "Groovy Rides Auto Sales",
        coords = vector3(-57.0, -1098.0, 26.0), -- Premium Deluxe area
        sprite = 326,
        color = 5, -- Yellow
        scale = 0.9,
        category = "shopping"
    },

    -- Banks
    {
        name = "Bank of TrickEm City",
        coords = vector3(150.3, -1040.2, 29.4), -- Legion Square
        sprite = 108,
        color = 2, -- Green
        scale = 0.9,
        category = "services"
    },
    {
        name = "Pacific Standard Savings",
        coords = vector3(253.2, 228.4, 101.7), -- Pacific Standard
        sprite = 108,
        color = 2,
        scale = 0.8,
        category = "services"
    },

    -- Clothing / Tailor
    {
        name = "Far Out Threads",
        coords = vector3(72.3, -1399.1, 29.4), -- Strawberry
        sprite = 73,
        color = 4, -- White
        scale = 0.8,
        category = "shopping"
    },
    {
        name = "Dynomite Fashion",
        coords = vector3(-703.8, -152.3, 37.4), -- Burton
        sprite = 73,
        color = 4,
        scale = 0.8,
        category = "shopping"
    },
    {
        name = "Jive Turkey Outfitters",
        coords = vector3(-167.9, -299.0, 39.7), -- Hawick
        sprite = 73,
        color = 4,
        scale = 0.8,
        category = "shopping"
    },

    -- Barber
    {
        name = "Foxy Cuts Barbershop",
        coords = vector3(-814.3, -183.8, 37.6), -- Rockford Hills
        sprite = 71,
        color = 4,
        scale = 0.8,
        category = "shopping"
    },

    -- Taxi HQ
    {
        name = "Downtown Cab Co.",
        coords = vector3(895.0, -179.0, 74.0),
        sprite = 198,
        color = 5, -- Yellow
        scale = 0.8,
        category = "jobs"
    },

    -- 24/7 Stores (Renamed)
    {
        name = "Corner Store",
        coords = vector3(25.7, -1347.3, 29.5),
        sprite = 59,
        color = 2,
        scale = 0.7,
        category = "shopping"
    },
    {
        name = "Bodega",
        coords = vector3(-3040.7, 585.9, 7.9),
        sprite = 59,
        color = 2,
        scale = 0.7,
        category = "shopping"
    },

    -- Fishing Spot
    {
        name = "Del Perro Pier Fishing",
        coords = vector3(-1850.0, -1231.0, 13.0),
        sprite = 68,
        color = 3,
        scale = 0.7,
        category = "jobs"
    },

    -- Lumber / Mining
    {
        name = "Paleto Lumber Yard",
        coords = vector3(-538.0, 5400.0, 70.0),
        sprite = 77,
        color = 17,
        scale = 0.7,
        category = "jobs"
    },

    -- Gun Shop (Back-alley style for 70s)
    {
        name = "Big Al's Pawn & Arms",
        coords = vector3(252.6, -50.0, 69.9), -- Vinewood
        sprite = 110,
        color = 1,
        scale = 0.8,
        category = "shopping"
    },

    -- Parking Garages
    {
        name = "Municipal Parking",
        coords = vector3(215.8, -810.0, 30.7),
        sprite = 357,
        color = 4,
        scale = 0.7,
        category = "services"
    },
    {
        name = "Vinewood Parking",
        coords = vector3(-290.0, -988.0, 31.1),
        sprite = 357,
        color = 4,
        scale = 0.7,
        category = "services"
    },
}

-- NPC Locations for ambient 70s atmosphere
Config.NPCLocations = {
    {
        name = "Street Musician",
        model = "a_m_m_eastsa_02",
        coords = vector4(-425.0, 1111.0, 325.9, 180.0),
        scenario = "WORLD_HUMAN_MUSICIAN"
    },
    {
        name = "Hot Dog Vendor",
        model = "s_m_m_strvend_01",
        coords = vector4(161.0, -1039.0, 29.4, 50.0),
        scenario = "WORLD_HUMAN_STAND_IMPATIENT"
    },
}
