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
      Name  = _U('s_slaughter_locker'),
      Type  = "cloakroom",
      Hint  = _U('cloak_change'),
    },

    AliveChicken = {
      Pos   = {x = -62.9018, y = 6241.46, z = 30.0901},
      Size  = {x = 3.0, y = 3.0, z = 1.0},
      Color = {r = 204, g = 204, b = 0},
      Marker= 1,
      Blip  = true,
      Name  = _U('s_hen'),
      Type  = "work",
      Item  = {
        {
          name   = _U('s_alive_chicken'),
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
      Hint  = _U('s_catch_hen')
    },

    SlaughterHouse = {
      Pos   = {x = -77.991, y = 6229.063, z = 30.091},
      Size  = {x = 3.0, y = 3.0, z = 1.0},
      Color = {r = 204, g = 204, b = 0},
      Marker= 1,
      Blip  = false,
      Name  = _U('s_slaughtered'),
      Type  = "work",
      Item  = {
        {
          name   = _U('s_slaughtered_chicken'),
          db_name= "slaughtered_chicken",
          time   = 5000,
          max    = 20,
          add    = 1,
          remove = 1,
          requires = "alive_chicken",
          requires_name = _U('s_alive_chicken'),
          drop   = 100
        }
      },
      Hint  = _U('s_chop_animal')
    },

    Packaging = {
      Pos   = {x = -101.978, y = 6208.799, z = 30.025},
      Size  = {x = 3.0, y = 3.0, z = 1.0},
      Color = {r = 204, g = 204, b = 0},
      Marker= 1,
      Blip  = false,
      Name  = _U('s_package'),
      Type  = "work",
      Item  = {
        {
          name   = _U('s_packagechicken'),
          db_name= "packaged_chicken",
          time   = 4000,
          max    = 100,
          add    = 5,
          remove = 1,
          requires = "slaughtered_chicken",
          requires_name = _U('s_unpackaged'),
          drop   = 100
        }
      },
      Hint  = _U('s_unpackaged_button')
    },

    VehicleSpawner = {
      Pos   = {x = -1042.9444580078, y = -2023.2551269531, z = 12.161581993103},
      Size  = {x = 3.0, y = 3.0, z = 1.0},
      Color = {r = 204, g = 204, b = 0},
      Marker= 1,
      Blip  = false,
      Name  = _U('spawn_veh'),
      Type  = "vehspawner",
      Spawner = 1,
      Hint  = _U('spawn_veh_button'),
      Caution = 2000
    },

    VehicleSpawnPoint = {
      Pos   = {x = -1048.8568115234, y = -2025.322265625, z = 12.161581993103},
      Size  = {x = 3.0, y = 3.0, z = 1.0},
      Marker= -1,
      Blip  = false,
      Name  = _U('service_vh'),
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
      Name  = _U('return_vh'),
      Type  = "vehdelete",
      Hint  = _U('return_vh_button'),
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
      Name  = _U('delivery_point'),
      Type  = "delivery",
      Spawner = 1,
      Item  = {
        {
          name   = _U('delivery'),
          time   = 500,
          remove = 1,
          max    = 100, -- if not present, probably an error at itemQtty >= item.max in esx_jobs_sv.lua
          price  = 11,
          requires = "packaged_chicken",
          requires_name = _U('s_packagechicken'),
          drop   = 100
        }
      },
      Hint  = _U('s_deliver')
    }
  }
}
