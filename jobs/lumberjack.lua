Config.Jobs.lumberjack = {
	BlipInfos = {
		Sprite = 237,
		Color = 4
	},
	Vehicles = {
		Truck = {
			Spawner = 1,
			Hash = "phantom",
			Trailer = "trailers",
			HasCaution = true
		}
	},
	Zones = {
		CloakRoom = {
			Pos   = {x = 1200.63, y = -1276.875, z = 34.38},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = true,
			Name  = "Vestiaire",
			Type  = "cloakroom",
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour vous changer."
		},

		Wood = {
			Pos   = {x = -534.323669433594, y = 5373.794921875, z = 69.503059387207},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = true,
			Name  = "Tas de bois",
			Type  = "work",
			Item  = {
				{
					name   = "Bois",
					db_name= "wood",
					time   = 3000,
					max    = 20,
					add    = 1,
					remove = 1,
					requires = "nothing",
					requires_name = "Nothing",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour récupérer du bois."
		},

		CuttedWood = {
			Pos   = {x = -552.214660644531, y = 5326.90966796875, z = 72.5996017456055},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = false,
			Name  = "Découpe du bois",
			Type  = "work",
			Item  = {
				{
					name   = "Bois coupé",
					db_name= "cutted_wood",
					time   = 5000,
					max    = 20,
					add    = 1,
					remove = 1,
					requires = "wood",
					requires_name = "Bois",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour couper du bois."
		},

		Planks = {
			Pos   = {x = -501.386596679688, y = 5280.53076171875, z = 79.6187744140625},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = false,
			Name  = "Planches",
			Type  = "work",
			Item  = {
				{
					name   = "Paquet de planche",
					db_name= "packaged_plank",
					time   = 4000,
					max    = 100,
					add    = 5,
					remove = 1,
					requires = "cutted_wood",
					requires_name = "Bois coupé",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour récupérer des planches."
		},

		VehicleSpawner = {
			Pos   = {x = 1191.9681396484, y = -1261.7775878906, z = 34.170627593994},
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
			Pos   = {x = 1194.6257324219, y = -1286.955078125, z = 34.121524810791},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Marker= -1,
			Blip  = false,
			Name  = "Véhicule de fonction",
			Type  = "vehspawnpt",
			Spawner = 1,
			Heading = 285.1
		},
		
		VehicleDeletePoint = {
			Pos   = {x = 1216.8983154297, y = -1229.2396240234, z = 34.403507232666},
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
			Pos   = {x = 1201.3558349609, y = -1327.5159912109, z = 34.226093292236},
			Color = {r = 204, g = 204, b = 0},
			Size  = {x = 5.0, y = 5.0, z = 3.0},
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
					price  = 13,
					requires = "packaged_plank",
					requires_name = "Paquet de planche",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour livrer les planches."
		}
	}
}