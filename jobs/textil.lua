Config.Jobs.textil = {
	BlipInfos = {
		Sprite = 366,
		Color = 4
	},
	Vehicles = {
		Truck = {
			Spawner = 1,
			Hash = "youga2",
			Trailer = "none",
			HasCaution = true
		}
	},
	Zones = {
		CloakRoom = {
			Pos   = {x = 706.735412597656, y = -960.902893066406, z = 29.3953247070313},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = true,
			Name  = "Vestiaire",
			Type  = "cloakroom",
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour vous changer.",
			GPS = {x = 740.808776855469, y = -970.066650390625, z = 23.4693908691406}
		},

		Whool = {
			Pos   = {x = 1978.92407226563, y = 5171.70166015625, z = 46.6391181945801},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = true,
			Name  = "Laine",
			Type  = "work",
			Item  = {
				{
					name   = "Laine",
					db_name= "whool",
					time   = 3000,
					max    = 40,
					add    = 1,
					remove = 1,
					requires = "nothing",
					requires_name = "Nothing",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour récupérer de la laine.",
			GPS = {x = 715.954650878906, y = -959.639587402344, z = 29.3953247070313}
		},

		Fabric = {
			Pos   = {x = 715.954650878906, y = -959.639587402344, z = 29.3953247070313},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = false,
			Name  = "Tissu",
			Type  = "work",
			Item  = {
				{
					name   = "Tissu",
					db_name= "fabric",
					time   = 5000,
					max    = 80,
					add    = 2,
					remove = 1,
					requires = "whool",
					requires_name = "Laine",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour fabriquer du tissu.",
			GPS = {x = 712.928283691406, y = -970.5869140625, z = 29.3953247070313}
		},

		Clothe = {
			Pos   = {x = 712.928283691406, y = -970.5869140625, z = 29.3953247070313},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = false,
			Name  = "Vêtement",
			Type  = "work",
			Item  = {
				{
					name   = "Vêtement",
					db_name= "clothe",
					time   = 4000,
					max    = 40,
					add    = 1,
					remove = 2,
					requires = "fabric",
					requires_name = "Tissu",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour récupérer des vêtements.",
			GPS = {x = 429.595855712891, y = -807.341613769531, z = 28.4911441802979}
		},

		VehicleSpawner = {
			Pos   = {x = 740.808776855469, y = -970.066650390625, z = 23.4693908691406},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 204, g = 204, b = 0},
			Marker= 1,
			Blip  = false,
			Name  = "Spawner véhicule de fonction",
			Type  = "vehspawner",
			Spawner = 1,
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour appeler le véhicule de livraison.",
			Caution = 2000,
			GPS = {x = 1978.92407226563, y = 5171.70166015625, z = 46.6391181945801}
		},

		VehicleSpawnPoint = {
			Pos   = {x = 747.31396484375, y = -966.235778808594, z = 23.705005645752},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Marker= -1,
			Blip  = false,
			Name  = "Véhicule de fonction",
			Type  = "vehspawnpt",
			Spawner = 1,
			Heading = 270.1,
			GPS = 0
		},
		
		VehicleDeletePoint = {
			Pos   = {x = 693.796325683594, y = -963.010498046875, z = 22.8247337341309},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
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
			Pos   = {x = 429.595855712891, y = -807.341613769531, z = 28.4911441802979},
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
					price  = 40,
					requires = "clothe",
					requires_name = "Vêtement",
					drop   = 100
				}
			},
			Hint  = "Appuyez sur ~INPUT_PICKUP~ pour livrer les vêtements.",
			GPS = {x = 1978.92407226563, y = 5171.70166015625, z = 46.6391181945801}
		}
	}
}