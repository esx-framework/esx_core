Config.Jobs.tailor = {
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
      Name  = _U('dd_dress_locker'),
      Type  = "cloakroom",
      Hint  = _U('cloak_change'),
      GPS = {x = 740.808776855469, y = -970.066650390625, z = 23.4693908691406}
    },

    Whool = {
      Pos   = {x = 1978.92407226563, y = 5171.70166015625, z = 46.6391181945801},
      Size  = {x = 3.0, y = 3.0, z = 1.0},
      Color = {r = 204, g = 204, b = 0},
      Marker= 1,
      Blip  = true,
      Name  = _U('dd_wool'),
      Type  = "work",
      Item  = {
        {
          name   = _U('dd_wool'),
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
      Hint  = _U('dd_pickup'),
      GPS = {x = 715.954650878906, y = -959.639587402344, z = 29.3953247070313}
    },

    Fabric = {
      Pos   = {x = 715.954650878906, y = -959.639587402344, z = 29.3953247070313},
      Size  = {x = 3.0, y = 3.0, z = 1.0},
      Color = {r = 204, g = 204, b = 0},
      Marker= 1,
      Blip  = false,
      Name  = _U('dd_fabric'),
      Type  = "work",
      Item  = {
        {
          name   = _U('dd_fabric'),
          db_name= "fabric",
          time   = 5000,
          max    = 80,
          add    = 2,
          remove = 1,
          requires = "whool",
          requires_name = _U('dd_wool'),
          drop   = 100
        }
      },
      Hint  = _U('dd_makefabric'),
      GPS = {x = 712.928283691406, y = -970.5869140625, z = 29.3953247070313}
    },

    Clothe = {
      Pos   = {x = 712.928283691406, y = -970.5869140625, z = 29.3953247070313},
      Size  = {x = 3.0, y = 3.0, z = 1.0},
      Color = {r = 204, g = 204, b = 0},
      Marker= 1,
      Blip  = false,
      Name  = _U('dd_clothing'),
      Type  = "work",
      Item  = {
        {
          name   = _U('dd_clothing'),
          db_name= "clothe",
          time   = 4000,
          max    = 40,
          add    = 1,
          remove = 2,
          requires = "fabric",
          requires_name = _U('dd_fabric'),
          drop   = 100
        }
      },
      Hint  = _U('dd_makeclothing'),
      GPS = {x = 429.595855712891, y = -807.341613769531, z = 28.4911441802979}
    },

    VehicleSpawner = {
      Pos   = {x = 740.808776855469, y = -970.066650390625, z = 23.4693908691406},
      Size  = {x = 3.0, y = 3.0, z = 1.0},
      Color = {r = 204, g = 204, b = 0},
      Marker= 1,
      Blip  = false,
      Name  = _U('spawn_veh'),
      Type  = "vehspawner",
      Spawner = 1,
      Hint  = _U('spawn_veh_button'),
      Caution = 2000,
      GPS = {x = 1978.92407226563, y = 5171.70166015625, z = 46.6391181945801}
    },

    VehicleSpawnPoint = {
      Pos   = {x = 747.31396484375, y = -966.235778808594, z = 23.705005645752},
      Size  = {x = 3.0, y = 3.0, z = 1.0},
      Marker= -1,
      Blip  = false,
      Name  = _U('service_vh'),
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
      Name  = _U('return_vh'),
      Type  = "vehdelete",
      Hint  = _U('return_vh_button'),
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
      Name  = _U('delivery_point'),
      Type  = "delivery",
      Spawner = 1,
      Item  = {
        {
          name   = _U('delivery'),
          time   = 500,
          remove = 1,
          max    = 100, -- if not present, probably an error at itemQtty >= item.max in esx_jobs_sv.lua
          price  = 40,
          requires = "clothe",
          requires_name = _U('dd_clothing'),
          drop   = 100
        }
      },
      Hint  = _U('dd_deliver_clothes'),
      GPS = {x = 1978.92407226563, y = 5171.70166015625, z = 46.6391181945801}
    }
  }
}
