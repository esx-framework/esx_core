Config.Jobs.slaughterer = {
	BlipInfos = {
		Sprite = 256,
		Color = 5
	},
	Vehicles = {
		Truck = {
			Spawner = 1,
			Hash = "benson",
			Trailer = "none",
			HasCaution = true
		}
	},
	Zones = {
		CloakRoom = {
			Pos   = {x = -1071.1319580078, y = -2003.7891845703, z = 14.78551197052},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = true,
			Name  = "Vestiaire",
			Type  = "cloakroom",
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour vous changer."
		},

		AliveChicken = {
			Pos   = {x = -62.9018, y = 6241.46, z = 30.0901},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = true,
			Name  = "Poulailler",
			Type  = "work",
			Item  = {
				{
					name   = "Poulet vivant",
					db_name= "alive_chicken",
					time   = 3000,
					max    = 20,
					add    = 1,
					remove = 1,
					requires = "nothing",
					requires_name = "Nothing",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour attrapper des poulets vivants."
		},

		SlaughterHouse = {
			Pos   = {x = -77.991, y = 6229.063, z = 30.091},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = false,
			Name  = "Abattoir",
			Type  = "work",
			Item  = {
				{
					name   = "Poulet à conditionner",
					db_name= "slaughtered_chicken",
					time   = 5000,
					max    = 20,
					add    = 1,
					remove = 1,
					requires = "alive_chicken",
					requires_name = "Poulet vivant",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour dépecer les poulets."
		},

		Packaging = {
			Pos   = {x = -101.978, y = 6208.799, z = 30.025},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = false,
			Name  = "Emballage",
			Type  = "work",
			Item  = { 
				{
					name   = "Poulet en barquette",
					db_name= "packaged_chicken",
					time   = 4000,
					max    = 100,
					add    = 5,
					remove = 1,
					requires = "slaughtered_chicken",
					requires_name = "Poulet à conditionner",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour conditionner le poulet en barquette."
		},

		VehicleSpawner = {
			Pos   = {x = -1042.9444580078, y = -2023.2551269531, z = 12.161581993103},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = false,
			Name  = "Spawner véhicule de fonction",
			Type  = "vehspawner",
			Spawner = 1,
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour appeler le véhicule de livraison.",
			Caution = 2000
		},

		VehicleSpawnPoint = {
			Pos   = {x = -1048.8568115234, y = -2025.322265625, z = 12.161581993103},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Marker= -1,
			Blip  = false,
			Name  = "Véhicule de fonction",
			Type  = "vehspawnpt",
			Spawner = 1,
			Heading = 130.1
		},
		
		VehicleDeletePoint = {
			Pos   = {x = -1061.5164794922, y = -2008.3552246094, z = 12.161584854126},
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

		Delivery = {
			Pos   = {x = -596.158, y = -889.324, z = 24.5073},
			Color = {r = 204, g = 204, b = 0},
			Size  = {x = 5.0, y = 5.0, z = 1.0},
			Marker= 1,
			Blip  = true,
			Name  = "Point de livraison",
			Type  = "delivery",				
			Spawner = 1,
			Item  = {
				{
					name   = "Livraison",
					time   = 500,
					remove = 1,
					max    = 100, -- if not present, probably an error at itemQtty >= item.max in esx_jobs_sv.lua
					price  = 11,
					requires = "packaged_chicken",
					requires_name = "Poulet en barquette",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour livrer les barquettes de poulet."
		}
	}
}