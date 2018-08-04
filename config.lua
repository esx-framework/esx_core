Config = {}

Config.Locale = 'en'

Config.MarkerType   = 1
Config.DrawDistance = 100.0

Config.Marker = {
	r = 100, g = 204, b = 100, -- blue-ish color, standard size circle
	x = 1.5, y = 1.5, z = 1.0
}

Config.StoreMarker = {
	r = 255, g = 0, b = 0,
	x = 5.0, y = 5.0, z = 1.0 -- big circle for storing boat
}


Config.Zones = {
	
	Garages = {
		{
			GaragePos  = { x = -772.42, y = -1430.90, z = 0.55 },
			SpawnPoint = { x = -785.39, y = -1426.30, z = -0.47 },
			StorePos   = { x = -798.45, y = -1456.03, z = 0.00 },
			Heading    = 150.0
		}

	},

	BoatShops = {

		{ -- shank st
			Outside = { x = -773.76, y = -1495.25, z = 1.6 },
			Inside  = { x = -798.59, y = -1503.12, z = -0.47 },
			Heading = 120.0
		}

	}

}

Config.Vehicles = {

	{
		model = 'seashark',
		label = 'Seashark',
		hash  = -1030275036,
		price = 15000
	},

	{
		model = 'speeder',
		label = 'Speeder',
		hash  = 231083307,
		price = 10000
	}

}