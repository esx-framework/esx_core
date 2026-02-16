Config = {}

-- Groovy Rides Auto Sales - 70s Era Vehicle Dealership
Config.DealershipLocation = vector3(-57.0, -1098.0, 26.0)
Config.DealershipRadius = 30.0

-- Vehicle spawn point at dealership
Config.SpawnPoint = vector4(-56.2, -1116.2, 26.0, 70.0)

-- Vehicle categories matching the 70s era
Config.Categories = {
    {name = "muscle", label = "Muscle Cars"},
    {name = "classics", label = "Classic Cruisers"},
    {name = "luxury", label = "Luxury Rides"},
    {name = "economy", label = "Economy Cars"},
    {name = "trucks", label = "Trucks & Vans"},
    {name = "motorcycles", label = "Choppers & Bikes"},
}

-- 70s Era Vehicles (using GTA V models that fit the era)
-- Prices adjusted for 1970s economy feel
Config.Vehicles = {
    -- Muscle Cars (the heart of the 70s)
    {name = "Sabre Turbo", model = "sabregt", price = 4500, category = "muscle"},
    {name = "Sabre GT Custom", model = "sabregt2", price = 5200, category = "muscle"},
    {name = "Dukes", model = "dukes", price = 3800, category = "muscle"},
    {name = "Gauntlet", model = "gauntlet", price = 4200, category = "muscle"},
    {name = "Dominator", model = "dominator", price = 4800, category = "muscle"},
    {name = "Phoenix", model = "phoenix", price = 3200, category = "muscle"},
    {name = "Vigero", model = "vigero", price = 2800, category = "muscle"},
    {name = "Blade", model = "blade", price = 2500, category = "muscle"},
    {name = "Buccaneer", model = "buccaneer", price = 2200, category = "muscle"},
    {name = "Buccaneer Custom", model = "buccaneer2", price = 3500, category = "muscle"},
    {name = "Chino", model = "chino", price = 2000, category = "muscle"},
    {name = "Chino Custom", model = "chino2", price = 3000, category = "muscle"},
    {name = "Tampa", model = "tampa", price = 2800, category = "muscle"},
    {name = "Faction", model = "faction", price = 2600, category = "muscle"},
    {name = "Faction Custom", model = "faction2", price = 3800, category = "muscle"},
    {name = "Nightshade", model = "nightshade", price = 5500, category = "muscle"},
    {name = "Voodoo", model = "voodoo", price = 1800, category = "muscle"},
    {name = "Picador", model = "picador", price = 2400, category = "muscle"},
    {name = "Slam Van", model = "slamvan3", price = 2000, category = "muscle"},
    {name = "Hustler", model = "hustler", price = 6500, category = "muscle"},
    {name = "Hermes", model = "hermes", price = 5800, category = "muscle"},
    {name = "Yosemite", model = "yosemite", price = 4200, category = "muscle"},
    {name = "Hotknife", model = "hotknife", price = 7500, category = "muscle"},
    {name = "Coquette BlackFin", model = "coquette3", price = 6000, category = "muscle"},
    {name = "Ruiner", model = "ruiner", price = 3500, category = "muscle"},
    {name = "Impaler", model = "impaler", price = 3200, category = "muscle"},
    {name = "Tulip", model = "tulip", price = 4000, category = "muscle"},
    {name = "Vamos", model = "vamos", price = 3800, category = "muscle"},
    {name = "Clique", model = "clique", price = 4500, category = "muscle"},
    {name = "Deviant", model = "deviant", price = 5000, category = "muscle"},
    {name = "Ellie", model = "ellie", price = 5200, category = "muscle"},

    -- Classic Cruisers (sports classics)
    {name = "Stinger", model = "stinger", price = 8500, category = "classics"},
    {name = "Stinger GT", model = "stingergt", price = 8000, category = "classics"},
    {name = "Monroe", model = "monroe", price = 6000, category = "classics"},
    {name = "Coquette Classic", model = "coquette2", price = 5500, category = "classics"},
    {name = "Manana", model = "manana", price = 1600, category = "classics"},
    {name = "Pigalle", model = "pigalle", price = 2800, category = "classics"},
    {name = "Casco", model = "casco", price = 4000, category = "classics"},
    {name = "JB 700", model = "jb700", price = 7500, category = "classics"},
    {name = "GT 500", model = "gt500", price = 9000, category = "classics"},
    {name = "Retinue", model = "retinue", price = 6500, category = "classics"},
    {name = "Savestra", model = "savestra", price = 8000, category = "classics"},
    {name = "Rapid GT Classic", model = "rapidgt3", price = 7200, category = "classics"},
    {name = "Z-Type", model = "ztype", price = 15000, category = "classics"},
    {name = "Roosevelt", model = "btype", price = 6500, category = "classics"},
    {name = "Deluxo", model = "deluxo", price = 12000, category = "classics"},
    {name = "Tornado", model = "tornado", price = 1800, category = "classics"},
    {name = "Tornado Custom", model = "tornado5", price = 3200, category = "classics"},
    {name = "Viseris", model = "viseris", price = 8500, category = "classics"},
    {name = "Ardent", model = "ardent", price = 10000, category = "classics"},
    {name = "Stirling GT", model = "feltzer3", price = 7000, category = "classics"},

    -- Luxury Rides
    {name = "Washington", model = "washington", price = 2500, category = "luxury"},
    {name = "Emperor", model = "emperor", price = 2200, category = "luxury"},
    {name = "Glendale", model = "glendale", price = 1800, category = "luxury"},
    {name = "Cognoscenti", model = "cognoscenti", price = 6000, category = "luxury"},
    {name = "Super Diamond", model = "superd", price = 8000, category = "luxury"},
    {name = "Stretch Limo", model = "stretch", price = 9500, category = "luxury"},
    {name = "Windsor", model = "windsor", price = 7500, category = "luxury"},
    {name = "Stafford", model = "stafford", price = 7000, category = "luxury"},

    -- Economy Cars
    {name = "Regina", model = "regina", price = 800, category = "economy"},
    {name = "Warrener", model = "warrener", price = 650, category = "economy"},
    {name = "Asea", model = "asea", price = 900, category = "economy"},
    {name = "Intruder", model = "intruder", price = 1100, category = "economy"},
    {name = "Premier", model = "premier", price = 1200, category = "economy"},
    {name = "Fugitive", model = "fugitive", price = 1500, category = "economy"},
    {name = "Blista", model = "blista", price = 1000, category = "economy"},
    {name = "Issi", model = "issi2", price = 1200, category = "economy"},
    {name = "Panto", model = "panto", price = 900, category = "economy"},
    {name = "Brioso", model = "brioso", price = 1400, category = "economy"},

    -- Trucks & Vans
    {name = "Surfer Van", model = "surfer", price = 1600, category = "trucks"},
    {name = "Youga Van", model = "youga", price = 1800, category = "trucks"},
    {name = "Moonbeam", model = "moonbeam", price = 2200, category = "trucks"},
    {name = "Moonbeam Custom", model = "moonbeam2", price = 3500, category = "trucks"},
    {name = "Minivan", model = "minivan", price = 1500, category = "trucks"},
    {name = "Burrito", model = "burrito3", price = 2000, category = "trucks"},
    {name = "Bobcat XL", model = "bobcatxl", price = 2800, category = "trucks"},
    {name = "Bison", model = "bison", price = 3200, category = "trucks"},
    {name = "Sandking", model = "sandking", price = 3800, category = "trucks"},
    {name = "Journey", model = "journey", price = 1200, category = "trucks"},
    {name = "Paradise Van", model = "paradise", price = 2400, category = "trucks"},
    {name = "Camper", model = "camper", price = 3000, category = "trucks"},
    {name = "Rumpo Van", model = "rumpo", price = 1800, category = "trucks"},

    -- Choppers & Bikes (motorcycles)
    {name = "Western Daemon", model = "daemon", price = 1500, category = "motorcycles"},
    {name = "Western Daemon High", model = "daemon2", price = 1800, category = "motorcycles"},
    {name = "Hexer", model = "hexer", price = 1600, category = "motorcycles"},
    {name = "Innovation", model = "innovation", price = 2200, category = "motorcycles"},
    {name = "Wolfsbane", model = "wolfsbane", price = 1200, category = "motorcycles"},
    {name = "Nightblade", model = "nightblade", price = 2800, category = "motorcycles"},
    {name = "Sovereign", model = "sovereign", price = 2000, category = "motorcycles"},
    {name = "Zombie Chopper", model = "zombiea", price = 1400, category = "motorcycles"},
    {name = "Avarus", model = "avarus", price = 1600, category = "motorcycles"},
    {name = "Chimera Trike", model = "chimera", price = 3000, category = "motorcycles"},
    {name = "Bagger", model = "bagger", price = 1800, category = "motorcycles"},
    {name = "PCJ-600", model = "pcj", price = 900, category = "motorcycles"},
    {name = "Sanchez", model = "sanchez", price = 700, category = "motorcycles"},
    {name = "Faggio", model = "faggio", price = 300, category = "motorcycles"},
    {name = "Vespa", model = "faggio2", price = 450, category = "motorcycles"},
}
