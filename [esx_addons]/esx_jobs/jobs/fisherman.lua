Config.Jobs.fisherman = {

	BlipInfos = {
		Sprite = 68,
		Color = 38
	},

	Vehicles = {

		Truck = {
			Spawner = 1,
			Hash = 'benson',
			Trailer = 'none',
			HasCaution = true
		},

		Boat = {
			Spawner = 2,
			Hash = 'tug',
			Trailer = 'none',
			HasCaution = true
		}

	},

	Zones = {

		CloakRoom = {
			Pos   = {x = 868.39, y = -1639.75, z = 30.33},
			Size  = {x = 0.8, y = 0.5, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker= 20,
			Blip  = true,
			Name  = TranslateCap('fm_fish_locker'),
			Type  = 'cloakroom',
			Hint  = TranslateCap('cloak_change'),
			GPS = {x = 880.74, y = -1663.96, z = 29.37}
		},

		FishingSpot = {
			Pos   = {x = 4435.21, y = 4829.60, z = 0.34},
			Size  = {x = 100.0, y = 100.0, z = 50.0},
			Color = {r = 50, g = 200, b = 50},
			Marker= 1,
			Blip  = true,
			Name  = TranslateCap('fm_fish_area'),
			Type  = 'work',
			Hint  = TranslateCap('fm_fish_button'),
			GPS   = {x = 3859.43, y = 4448.83, z = 0.39},
			Item = {
				{
					name   = TranslateCap('fm_fish'),
					db_name= 'fish',
					time   = 10,
					max    = 100,
					add    = 1,
					remove = 0,
					requires = 'nothing',
					requires_name = 'Nothing',
					drop   = 100
				}
			},

		},

		BoatSpawner = {
			Pos   = {x = 3866.268, y = 4463.868, z = 2.72},
			Size  = {x = 0.8, y = 0.5, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker= 20,
			Blip  = true,
			Name  = TranslateCap('fm_spawnboat_title'),
			Type  = 'vehspawner',
			Spawner = 2,
			Hint  = TranslateCap('fm_spawnboat'),
			Caution = 0,
			GPS = {x = 4435.21, y = 4829.60, z = 0.34}
		},

		BoatSpawnPoint = {
			Pos   = {x = 3888.3, y = 4468.09, z = 0.0},
			Size  = {x = 0.8, y = 0.5, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker= -1,
			Blip  = false,
			Name  = TranslateCap('fm_boat_title'),
			Type  = 'vehspawnpt',
			Spawner = 2,
			GPS = 0,
			Heading = 270.1
		},

		BoatDeletePoint = {
			Pos   = {x = 3859.43, y = 4448.83, z = 0.39},
			Size  = {x = 0.8, y = 0.5, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker= 20,
			Blip  = false,
			Name  = TranslateCap('fm_boat_return_title'),
			Type  = 'vehdelete',
			Hint  = TranslateCap('fm_boat_return_button'),
			Spawner = 2,
			Caution = 0,
			GPS = {x = -1012.64, y = -1354.62, z = 5.54},
			Teleport = {x = 3867.44, y = 4463.62, z = 1.72}
		},

		VehicleSpawner = {
			Pos   = {x = 880.74, y = -1663.96, z = 29.37},
			Size  = {x = 0.8, y = 0.5, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker= 20,
			Blip  = false,
			Name  = TranslateCap('spawn_veh'),
			Type  = 'vehspawner',
			Spawner = 1,
			Hint  = TranslateCap('spawn_veh_button'),
			Caution = 2000,
			GPS = {x = 3867.44, y = 4463.62, z = 1.72}
		},

		VehicleSpawnPoint = {
			Pos   = {x = 859.35, y = -1656.21, z = 29.56},
			Size  = {x = 0.8, y = 0.5, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker= 20,
			Blip  = false,
			Name  = TranslateCap('service_vh'),
			Type  = 'vehspawnpt',
			Spawner = 1,
			GPS = 0,
			Heading = 70.1
		},

		VehicleDeletePoint = {
			Pos   = {x = 863.23, y = -1718.28, z = 28.63},
			Size  = {x = 0.8, y = 0.5, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker= 20,
			Blip  = false,
			Name  = TranslateCap('return_vh'),
			Type  = 'vehdelete',
			Hint  = TranslateCap('return_vh_button'),
			Spawner = 1,
			Caution = 2000,
			GPS = 0,
			Teleport = 0
		},

		Delivery = {
			Pos   = {x = -1037.96, y = -1397.09, z = 5.54},
			Size  = {x = 0.8, y = 0.5, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker= 20,
			Blip  = true,
			Name  = TranslateCap('delivery_point'),
			Type  = 'delivery',
			Spawner = 2,
			Hint  = TranslateCap('fm_deliver_fish'),
			GPS   = {x = 3867.44, y = 4463.62, z = 1.72},
			Item = {
				{
				name   = TranslateCap('delivery'),
				time   = 0.5,
				remove = 1,
				max    = 100, -- if not present, probably an error at itemQtty >= item.max in esx_jobs_sv.lua
				price  = 11,
				requires = 'fish',
				requires_name = TranslateCap('fm_fish'),
				drop   = 100
				}
			}
		}

	}
}
