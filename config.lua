Config               = {}

Config.Locale        = 'en'

Config.EnableLicense = true -- enable boat license?
Config.LicensePrice  = 50000

Config.MarkerType    = 1
Config.DrawDistance  = 100.0

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
			SpawnPoint = { x = -785.39, y = -1426.30, z = 0.00 },
			StorePos   = { x = -798.45, y = -1456.03, z = 0.00 },
			Heading    = 146.0
		},

		{
			GaragePos  = { x = 3864.93, y = 4463.98, z = 1.65 },
			SpawnPoint = { x = 3854.40, y = 4477.28, z = 0.00 },
			StorePos   = { x = 3857.04, y = 4446.94, z = 0.00 },
			Heading    = 273.0
		},

		{
			GaragePos  = { x = -1614.03, y = 5260.10, z = 2.80 },
			SpawnPoint = { x = -1622.52, y = 5247.12, z = 0.00 },
			StorePos   = { x = -1600.37, y = 5261.91, z = 0.00 },
			Heading    = 21.0
		},

		{
			GaragePos  = { x = 712.67, y = 4093.31, z = 33.70 },
			SpawnPoint = { x = 712.89, y = 4080.20, z = 29.35 },
			StorePos   = { x = 705.16, y = 4110.16, z = 30.20 },
			Heading    = 181.0
		},

		{
			GaragePos  = { x = 23.87, y = -2806.82, z = 4.80 },
			SpawnPoint = { x = 23.35, y = -2828.69, z = 0.81 },
			StorePos   = { x = -1.03, y = -2799.20, z = 0.50 },
			Heading    = 181.0
		},

		{
			GaragePos  = { x = -3427.36, y = 956.94, z = 7.35 },
			SpawnPoint = { x = -3448.97, y = 953.80, z = 0.00 },
			StorePos   = { x = -3436.55, y = 946.67, z = 0.30 },
			Heading    = 75.0
		},

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
		label = 'Seashark (Random Color)',
		price = 7500
	},

	{
		model = 'seashark3',
		label = 'Seashark (Dark Blue)',
		price = 7500
	},

	{
		model = 'suntrap',
		label = 'Suntrap',
		price = 10000
	},

	{
		model = 'jetmax',
		label = 'Jetmax',
		price = 45000
	},

	{
		model = 'tropic2',
		label = 'Tropic',
		price = 65000
	},

	{
		model = 'dinghy2',
		label = 'Dinghy (Black)',
		price = 32500
	},

	{
		model = 'dinghy',
		label = 'Dinghy 2 (Random Color)',
		price = 40000
	},

	{
		model = 'speeder',
		label = 'Speeder',
		price = 85000
	},

	{
		model = 'squalo',
		label = 'Squalo (Random Color)',
		price = 61000
	},

	{
		model = 'toro',
		label = 'Toro',
		price = 200000
	},

	{
		model = 'submersible',
		label = 'Submersible',
		price = 750000
	}

}