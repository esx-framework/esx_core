Config.Jobs.tailor = {

	BlipInfos = {
		Sprite = 366,
		Color = 4
	},

	Vehicles = {

		Truck = {
			Spawner = 1,
			Hash = 'youga2',
			Trailer = 'none',
			HasCaution = true
		}

	},

	Zones = {

		CloakRoom = {
			Pos = {x = 706.73, y = -960.90, z = 30.39},
			Size  = {x = 0.8, y = 0.5, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker= 20,
			Blip = true,
			Name = TranslateCap('dd_dress_locker'),
			Type = 'cloakroom',
			Hint = TranslateCap('cloak_change'),
			GPS = {x = 740.80, y = -970.06, z = 23.46}
		},

		Wool = {
			Pos = {x = 1978.92, y = 5171.70, z = 46.63},
			Size = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker = 1,
			Blip = true,
			Name = TranslateCap('dd_wool'),
			Type = 'work',
			Item = {
				{
					name = TranslateCap('dd_wool'),
					db_name = 'wool',
					time = 3,
					max = 40,
					add = 1,
					remove = 0,
					requires = 'nothing',
					requires_name = 'Nothing',
					drop = 100
				}
			},
			Hint = TranslateCap('dd_pickup'),
			GPS = {x = 715.95, y = -959.63, z = 29.39}
		},

		Fabric = {
			Pos = {x = 715.95, y = -959.63, z = 29.39},
			Size = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker = 1,
			Blip = false,
			Name = TranslateCap('dd_fabric'),
			Type = 'work',
			Item = {
				{
					name = TranslateCap('dd_fabric'),
					db_name = 'fabric',
					time = 5,
					max = 80,
					add = 2,
					remove = 1,
					requires = 'wool',
					requires_name = TranslateCap('dd_wool'),
					drop = 100
				}
			},
			Hint = TranslateCap('dd_makefabric'),
			GPS = {x = 712.92, y = -970.58, z = 29.39}
		},

		Clothe = {
			Pos = {x = 712.92, y = -970.58, z = 29.39},
			Size = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker = 1,
			Blip = false,
			Name = TranslateCap('dd_clothing'),
			Type = 'work',
			Item = {
				{
					name = TranslateCap('dd_clothing'),
					db_name = 'clothe',
					time = 4,
					max = 40,
					add = 1,
					remove = 2,
					requires = 'fabric',
					requires_name = TranslateCap('dd_fabric'),
					drop = 100
				}
			},
			Hint = TranslateCap('dd_makeclothing'),
			GPS = {x = 429.59, y = -807.34, z = 28.49}
		},

		VehicleSpawner = {
			Pos = {x = 740.80, y = -970.06, z = 23.46},
			Size = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker = 1,
			Blip = false,
			Name = TranslateCap('spawn_veh'),
			Type = 'vehspawner',
			Spawner = 1,
			Hint = TranslateCap('spawn_veh_button'),
			Caution = 2000,
			GPS = {x = 1978.92, y = 5171.70, z = 46.63}
		},

		VehicleSpawnPoint = {
			Pos = {x = 747.31, y = -966.23, z = 23.70},
			Size = {x = 3.0, y = 3.0, z = 1.0},
			Marker = -1,
			Blip = false,
			Name = TranslateCap('service_vh'),
			Type = 'vehspawnpt',
			Spawner = 1,
			Heading = 270.1,
			GPS = 0
		},

		VehicleDeletePoint = {
			Pos = {x = 693.79, y = -963.01, z = 22.82},
			Size = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 255, g = 0, b = 0},
			Marker = 1,
			Blip = false,
			Name = TranslateCap('return_vh'),
			Type = 'vehdelete',
			Hint = TranslateCap('return_vh_button'),
			Spawner = 1,
			Caution = 2000,
			GPS = 0,
			Teleport = 0
		},

		Delivery = {
			Pos = {x = 429.59, y = -807.34, z = 28.49},
			Color = {r = 50, g = 200, b = 50},
			Size = {x = 5.0, y = 5.0, z = 3.0},
			Marker = 1,
			Blip = true,
			Name = TranslateCap('delivery_point'),
			Type = 'delivery',
			Spawner = 1,
			Item = {
				{
					name = TranslateCap('delivery'),
					time = 0.5,
					remove = 1,
					max = 100, -- if not present, probably an error at itemQtty >= item.max in esx_jobs_sv.lua
					price = 40,
					requires = 'clothe',
					requires_name = TranslateCap('dd_clothing'),
					drop = 100
				}
			},
			Hint = TranslateCap('dd_deliver_clothes'),
			GPS = {x = 1978.92, y = 5171.70, z = 46.63}
		}
	}
}
