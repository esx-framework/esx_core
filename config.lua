Config = {}

Config.Locale = 'en'

Config.MarkerType   = 1
Config.DrawDistance = 100.0
Config.ZoneSize     = {x = 5.0, y = 5.0, z = 3.0}
Config.MarkerColor  = {r = 100, g = 204, b = 100}
Config.MarkerSize   = { x = 1.5, y = 1.5, z = 1.0 }

Config.Zones = {
	
	Garages = {
		{
			GaragePos  = { x = -772.42, y = -1430.90, z = 1.59 },
			SpawnPoint = { x = -785.39, y = -1426.30, z = -0.47 },
			RemovePos  = { x = -798.45, y = -1456.03, z = -0.47 },
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
		price = 15000
	},

	{
		model = 'speeder',
		label = 'Speeder',
		price = 10000
	}

}