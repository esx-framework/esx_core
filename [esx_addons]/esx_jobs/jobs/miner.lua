Config.Jobs.miner = {

	BlipInfos = {
		Sprite = 68,
		Color = 5
	},

	Vehicles = {

		Truck = {
			Spawner = 1,
			Hash = 'rubble',
			Trailer = 'none',
			HasCaution = true
		}

	},

	Zones = {

		CloakRoom = {
			Pos = {x = 892.35, y = -2172.77, z = 31.28},
			Size  = {x = 0.8, y = 0.5, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker= 20,
			Blip = true,
			Name = TranslateCap('m_miner_locker'),
			Type = 'cloakroom',
			Hint = TranslateCap('cloak_change'),
			GPS = {x = 884.86, y = -2176.51, z = 29.51}
		},

		Mine = {
			Pos = {x = 2962.40, y = 2746.20, z = 42.39},
			Size = {x = 5.0, y = 5.0, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker = 1,
			Blip = true,
			Name = TranslateCap('m_rock'),
			Type = 'work',
			Item = {
				{
					name = TranslateCap('m_rock'),
					db_name = 'stone',
					time = 3,
					max = 7,
					add = 1,
					remove = 0,
					requires = 'nothing',
					requires_name = 'Nothing',
					drop = 100
				}
			},
			Hint = TranslateCap('m_pickrocks'),
			GPS = {x = 289.24, y = 2862.90, z = 42.64}
		},

		StoneWash = {
			Pos = {x = 289.24, y = 2862.90, z = 42.64},
			Size = {x = 5.0, y = 5.0, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker = 1,
			Blip = true,
			Name = TranslateCap('m_washrock'),
			Type = 'work',
			Item = {
				{
					name = TranslateCap('m_washrock'),
					db_name = 'washed_stone',
					time = 5,
					max = 7,
					add = 1,
					remove = 1,
					requires = 'stone',
					requires_name = TranslateCap('m_rock'),
					drop = 100
				}
			},
			Hint = TranslateCap('m_rock_button'),
			GPS = {x = 1109.14, y = -2007.87, z = 30.01}
		},

		Foundry = {
			Pos = {x = 1109.14, y = -2007.87, z = 30.01},
			Size = {x = 5.0, y = 5.0, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker = 1,
			Blip = true,
			Name = TranslateCap('m_rock_smelting'),
			Type = 'work',
			Item = {  
				{
					name = TranslateCap('m_copper'),
					db_name = 'copper',
					time = 4,
					max = 56,
					add = 8,
					remove = 1,
					requires = 'washed_stone',
					requires_name = TranslateCap('m_washrock'),
					drop = 100
				},
				{
					name = TranslateCap('m_iron'),
					db_name = 'iron',
					max = 42,
					add = 6,
					drop = 100
				},
				{
					name = TranslateCap('m_gold'),
					db_name = 'gold',
					max = 21,
					add = 3,
					drop = 100
				},
				{
					name = TranslateCap('m_diamond'),
					db_name = 'diamond',
					max = 50,
					add = 1,
					drop = 5
				}
			},
			Hint = TranslateCap('m_melt_button'),
			GPS = {x = -169.48, y = -2659.16, z = 5.00}
		},

		VehicleSpawner = {
			Pos = {x = 884.86, y = -2176.51, z = 29.51},
			Size = {x = 5.0, y = 5.0, z = 1.0},
			Color = {r = 50, g = 200, b = 50},
			Marker = 1,
			Blip = false,
			Name = TranslateCap('spawn_veh'),
			Type = 'vehspawner',
			Spawner = 1,
			Hint = TranslateCap('spawn_veh_button'),
			Caution = 2000,
			GPS = {x = 2962.40, y = 2746.20, z = 42.39}
		},

		VehicleSpawnPoint = {
			Pos = {x = 879.55, y = -2189.79, z = 29.51},
			Size = {x = 5.0, y = 5.0, z = 1.0},
			Marker = -1,
			Blip = false,
			Name = TranslateCap('service_vh'),
			Type = 'vehspawnpt',
			Spawner = 1,
			Heading = 90.1,
			GPS = 0
		},

		VehicleDeletePoint = {
			Pos = {x = 881.93, y = -2198.01, z = 29.51},
			Size = {x = 5.0, y = 5.0, z = 1.0},
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

		CopperDelivery = {
			Pos = {x = -169.481, y = -2659.16, z = 5.00103},
			Color = {r = 50, g = 200, b = 50},
			Size = {x = 5.0, y = 5.0, z = 3.0},
			Marker = 1,
			Blip = true,
			Name = TranslateCap('m_sell_copper'),
			Type = 'delivery',
			Spawner = 1,
			Item = {
				{
					name = TranslateCap('delivery'),
					time = 0.5,
					remove = 1,
					max = 56, -- if not present, probably an error at itemQtty >= item.max in esx_jobs_sv.lua
					price = 5,
					requires = 'copper',
					requires_name = TranslateCap('m_copper'),
					drop = 100
				}
			},
			Hint = TranslateCap('m_deliver_copper'),
			GPS = {x = -148.78, y = -1040.38, z = 26.27}
		},

		IronDelivery = {
			Pos = {x = -148.78, y = -1040.38, z = 26.27},
			Color = {r = 50, g = 200, b = 50},
			Size = {x = 5.0, y = 5.0, z = 3.0},
			Marker = 1,
			Blip = true,
			Name = TranslateCap('m_sell_iron'),
			Type = 'delivery',
			Spawner = 1,
			Item = {
				{
					name = TranslateCap('delivery'),
					time = 0.5,
					remove = 1,
					max = 42, -- if not present, probably an error at itemQtty >= item.max in esx_jobs_sv.lua
					price = 9,
					requires = 'iron',
					requires_name = TranslateCap('m_iron'),
					drop = 100
				}
			},
			Hint = TranslateCap('m_deliver_iron'),
			GPS = {x = 261.48, y = 207.35, z = 109.28}
		},

		GoldDelivery = {
			Pos = {x = 261.48, y = 207.35, z = 109.28},
			Color = {r = 50, g = 200, b = 50},
			Size = {x = 5.0, y = 5.0, z = 3.0},
			Marker = 1,
			Blip = true,
			Name = TranslateCap('m_sell_gold'),
			Type = 'delivery',
			Spawner = 1,
			Item = {
				{
					name = TranslateCap('delivery'),
					time = 0.5,
					remove = 1,
					max = 21, -- if not present, probably an error at itemQtty >= item.max in esx_jobs_sv.lua
					price = 25,
					requires = 'gold',
					requires_name = TranslateCap('m_gold'),
					drop = 100
				}
			},
			Hint = TranslateCap('m_deliver_gold'),
			GPS = {x = -621.04, y = -228.53, z = 37.05}
		},

		DiamondDelivery = {
			Pos = {x = -621.04, y = -228.53, z = 37.05},
			Color = {r = 50, g = 200, b = 50},
			Size = {x = 5.0, y = 5.0, z = 3.0},
			Marker = 1,
			Blip = true,
			Name = TranslateCap('m_sell_diamond'),
			Type = 'delivery',
			Spawner = 1,
			Item = {
				{
					name = TranslateCap('delivery'),
					time = 0.5,
					remove = 1,
					max = 50, -- if not present, probably an error at itemQtty >= item.max in esx_jobs_sv.lua
					price = 250,
					requires = 'diamond',
					requires_name = TranslateCap('m_diamond'),
					drop = 100
				}
			},
			Hint = TranslateCap('m_deliver_diamond'),
			GPS = {x = 2962.40, y = 2746.20, z = 42.39}
		}

	}
}
