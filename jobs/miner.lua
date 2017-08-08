Config.Jobs.miner = {
	BlipInfos = {
		Sprite = 318,
		Color = 5
	},
	Vehicles = {
		Truck = {
			Spawner = 1,
			Hash = "rubble",
			Trailer = "none",
			HasCaution = true
		}
	},
	Zones = {
		CloakRoom = {
			Pos   = {x = 892.35333251953, y = -2172.7705078125, z = 31.286273956299},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = true,
			Name  = "Vestiaire",
			Type  = "cloakroom",
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour vous changer.",
			GPS = {x = 884.86889648438, y = -2176.5102539063, z = 29.519346237183}
		},

		Mine = {
			Pos   = {x = 2962.4, y = 2746.2, z = 42.398},
			Size  = {x = 5.0, y = 5.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = true,
			Name  = "Rocher",
			Type  = "work",
			Item  = {
				{
					name   = "Rocher",
					db_name= "stone",
					time   = 3000,
					max    = 7,
					add    = 1,
					remove = 1,
					requires = "nothing",
					requires_name = "Nothing",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour récupérer des rochers.",
			GPS = {x = 289.244, y = 2862.9, z = 42.6424}
		},

		StoneWash = {
			Pos   = {x = 289.244, y = 2862.9, z = 42.6424},
			Size  = {x = 5.0, y = 5.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = true,
			Name  = "Roche lavé",
			Type  = "work",
			Item  = { 
				{
					name   = "Roche lavé",
					db_name= "washed_stone",
					time   = 5000,
					max    = 7,
					add    = 1,
					remove = 1,
					requires = "stone",
					requires_name = "Rocher",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour laver les roches.",
			GPS = {x = 1109.14, y = -2007.87, z = 30.0188}
		},

		Foundry = {
			Pos   = {x = 1109.14, y = -2007.87, z = 30.0188},
			Size  = {x = 5.0, y = 5.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = true,
			Name  = "Fonderie",
			Type  = "work",
			Item  = {
				{
					name   = "Cuivre",
					db_name= "copper",
					time   = 4000,
					max    = 56,
					add    = 8,
					remove = 1,
					requires = "washed_stone",
					requires_name = "Roche lavé",
					drop   = 100
				},
				{
					name   = "Fer",
					db_name= "iron",
					max    = 42,
					add    = 6,
					drop   = 100
				},
				{
					name   = "Or",
					db_name= "gold",
					max    = 21,
					add    = 3,
					drop   = 100
				},
				{
					name   = "Diamant",
					db_name= "diamond",
					max    = 50,
					add    = 1,
					drop   = 5
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour fondre les roches.",
			GPS = {x = -169.481, y = -2659.16, z = 5.00103}
		},

		VehicleSpawner = {
			Pos   = {x = 884.86889648438, y = -2176.5102539063, z = 29.519346237183},
			Size  = {x = 5.0, y = 5.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = false,
			Name  = "Spawner véhicule de fonction",
			Type  = "vehspawner",
			Spawner = 1,
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour appeler le véhicule de livraison.",
			Caution = 2000,
			GPS = {x = 2962.4, y = 2746.2, z = 42.398}
		},

		VehicleSpawnPoint = {
			Pos   = {x = 879.55700683594, y = -2189.7995605469, z = 29.519348144531},
			Size  = {x = 5.0, y = 5.0, z = 1.0},
			Marker= -1,
			Blip  = false,
			Name  = "Véhicule de fonction",
			Type  = "vehspawnpt",	
			Spawner = 1,
			Heading = 90.1,
			GPS = 0
		},
		
		VehicleDeletePoint = {
			Pos   = {x = 881.93725585938, y = -2198.0151367188, z = 29.519351959229},
			Size  = {x = 5.0, y = 5.0, z = 1.0},
			Color = {r = 255, g = 0, b = 0},
			Marker= 1,
			Blip  = false,
			Name  = "Supression du véhicule",
			Type  = "vehdelete",
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour rendre le véhicule.",
			Spawner = 1,
			Caution = 2000,
			GPS = 0,
			Teleport = 0
		},

		CopperDelivery = {
			Pos   = {x = -169.481, y = -2659.16, z = 5.00103},
			Color = {r = 204, g = 204, b = 0},
			Size  = {x = 5.0, y = 5.0, z = 3.0},
			Marker= 1,
			Blip  = true,
			Name  = "Revente de cuivre",
			Type  = "delivery",				
			Spawner = 1,
			Item  = {
				{
					name   = "Livraison",
					time   = 500,
					remove = 1,
					max    = 56, -- if not present, probably an error at itemQtty >= item.max in esx_jobs_sv.lua
					price  = 5,
					requires = "copper",
					requires_name = "Cuivre",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour livrer le cuivre.",
			GPS = {x = -148.782, y = -1040.38, z = 26.2736}
		},

		IronDelivery = {
			Pos   = {x = -148.782, y = -1040.38, z = 26.2736},
			Color = {r = 204, g = 204, b = 0},
			Size  = {x = 5.0, y = 5.0, z = 3.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = true,
			Name  = "Revente de fer",
			Type  = "delivery",				
			Spawner = 1,
			Item  = {
				{
					name   = "Livraison",
					time   = 500,
					remove = 1,
					max    = 42, -- if not present, probably an error at itemQtty >= item.max in esx_jobs_sv.lua
					price  = 9,
					requires = "iron",
					requires_name = "Fer",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour livrer le fer.",
			GPS = {x = 261.487, y = 207.354, z = 109.287}
		},
		
		GoldDelivery = {
			Pos   = {x = 261.487, y = 207.354, z = 109.287},
			Color = {r = 204, g = 204, b = 0},
			Size  = {x = 5.0, y = 5.0, z = 3.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = true,
			Name  = "Revente d'or",
			Type  = "delivery",				
			Spawner = 1,
			Item  = {
				{
					name   = "Livraison",
					time   = 500,
					remove = 1,
					max    = 21, -- if not present, probably an error at itemQtty >= item.max in esx_jobs_sv.lua
					price  = 25,
					requires = "gold",
					requires_name = "Or",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour livrer l'or'.",
			GPS = {x = -621.046, y = -228.532, z = 37.0571}
		},
		
		DiamondDelivery = {
			Pos   = {x = -621.046, y = -228.532, z = 37.0571},
			Color = {r = 204, g = 204, b = 0},
			Size  = {x = 5.0, y = 5.0, z = 3.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = true,
			Name  = "Revente de diamants",
			Type  = "delivery",				
			Spawner = 1,
			Item  = {
				{
					name   = "Livraison",
					time   = 500,
					remove = 1,
					max    = 50, -- if not present, probably an error at itemQtty >= item.max in esx_jobs_sv.lua
					price  = 250,
					requires = "diamond",
					requires_name = "Diamant",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour livrer les diamants.",
			GPS = {x = 2962.4, y = 2746.2, z = 42.398}
		}
	}
}