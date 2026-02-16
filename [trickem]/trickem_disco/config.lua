Config = {}

Config.Clubs = {
    {
        name = "Disco Inferno",
        coords = vector3(-1388.0, -586.0, 30.0),
        entrance = vector4(-1388.0, -586.0, 30.0, 120.0),
        barLocation = vector3(-1385.0, -583.0, 30.0),
        danceFloor = vector3(-1390.0, -590.0, 30.0),
        danceRadius = 8.0,
        djBooth = vector3(-1393.0, -588.0, 31.0),
    },
    {
        name = "Studio 54",
        coords = vector3(134.0, -1280.0, 29.0),
        entrance = vector4(134.0, -1280.0, 29.0, 260.0),
        barLocation = vector3(137.0, -1277.0, 29.0),
        danceFloor = vector3(130.0, -1284.0, 29.0),
        danceRadius = 8.0,
        djBooth = vector3(127.0, -1282.0, 30.0),
    },
}

-- Drinks menu (70s cocktails)
Config.Drinks = {
    {name = "Harvey Wallbanger", price = 8, health = 5},
    {name = "Tequila Sunrise", price = 10, health = 8},
    {name = "Pina Colada", price = 12, health = 10},
    {name = "Grasshopper", price = 9, health = 6},
    {name = "Singapore Sling", price = 11, health = 7},
    {name = "Tom Collins", price = 7, health = 4},
    {name = "Brandy Alexander", price = 13, health = 12},
    {name = "Whiskey Sour", price = 8, health = 5},
    {name = "Cold Beer", price = 3, health = 3},
    {name = "Coca-Cola", price = 1, health = 2},
}

-- Dance animations
Config.DanceAnims = {
    {dict = "anim@amb@nightclub@dancers@crowd@", anim = "hi_dance_crowd_09_v1_male^1"},
    {dict = "anim@amb@nightclub@dancers@crowd@", anim = "hi_dance_crowd_09_v2_male^1"},
    {dict = "anim@amb@nightclub@dancers@crowd@", anim = "hi_dance_crowd_11_v1_male^1"},
    {dict = "anim@amb@nightclub@dancers@crowd@", anim = "hi_dance_crowd_13_v2_male^1"},
    {dict = "anim@amb@nightclub@dancers@crowd@", anim = "hi_dance_crowd_15_v2_male^1"},
    {dict = "anim@amb@nightclub@dancers@crowd@", anim = "hi_dance_crowd_17_v1_male^1"},
    {dict = "mini@strip_club@idles@bouncer@", anim = "idle_a"},
}

-- DJ job - earnings per "set"
Config.DJPayPerSet = 75
Config.DJSetDuration = 60000 -- 60 seconds per set
