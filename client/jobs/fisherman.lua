Config.Jobs.fisherman = {
  BlipInfos = {
    Sprite = 68,
    Color = 38
  },
  Vehicles = {
    Truck = {
      Spawner = 1,
      Hash = "benson",
      Trailer = "none",
      HasCaution = true
    },
    Boat = {
      Spawner = 2,
      Hash = "tug",
      Trailer = "none",
      HasCaution = false
    }
  },
  Zones = {
    CloakRoom = {
      Pos   = {x = 868.39929199219, y = -1639.7556152344, z = 29.339252471924},
      Size  = {x = 3.0, y = 3.0, z = 1.0},
      Color = {r = 204, g = 204, b = 0},
      Marker= 1,
      Blip  = true,
      Name  = _U('fm_fish_locker'),
      Type  = "cloakroom",
      Hint  = _U('cloak_change'),
      GPS = {x = 880.74462890625, y = -1663.9635009766, z = 29.370491027832}
    },

    FishingSpot = {
      Pos   = {x = 4435.21, y = 4829.6, z = 0.3439},
      Color = {r = 204, g = 204, b = 0},
      Size  = {x = 110.0, y = 110.0, z = 10.0},
      Marker= 1,
      Blip  = true,
      Name  = _U('fm_fish_area'),
      Type  = "work",
      Item  = {
        {
          name   = _U('fm_fish'),
          db_name= "fish",
          time   = 2000,
          max    = 100,
          add    = 1,
          remove = 1,
          requires = "nothing",
          requires_name = "Nothing",
          drop   = 100
        }
      },
      Hint  = _U('fm_fish_button'),
      GPS = {x = 3859.43, y = 4448.83, z = 0.39994}
    },

    BoatSpawner = {
      Pos   = {x = 3867.44, y = 4463.62, z = 1.72386},
      Size  = {x = 3.0, y = 3.0, z = 1.0},
      Color = {r = 204, g = 204, b = 0},
      Marker= 1,
      Blip  = true,
      Name  = _U('fm_spawnboat_title'),
      Type  = "vehspawner",
      Spawner = 2,
      Hint  = _U('fm_spawnboat'),
      Caution = 0,
      GPS = {x = 4435.21, y = 4829.6, z = 0.3439}
    },

    BoatSpawnPoint = {
      Pos   = {x = 3888.3, y = 4468.09, z = 0.0},
      Size  = {x = 3.0, y = 3.0, z = 1.0},
      Marker= -1,
      Blip  = false,
      Name  = _U('fm_boat_title'),
      Type  = "vehspawnpt",
      Spawner = 2,
      GPS = 0,
      Heading = 270.1
    },

    BoatDeletePoint = {
      Pos   = {x = 3859.43, y = 4448.83, z = 0.39994},
      Size  = {x = 10.0, y = 10.0, z = 1.0},
      Color = {r = 255, g = 0, b = 0},
      Marker= 1,
      Blip  = false,
      Name  = _U('fm_boat_return_title'),
      Type  = "vehdelete",
      Hint  = _U('fm_boat_return_button'),
      Spawner = 2,
      Caution = 0,
      GPS = {x = -1012.64758300781, y = -1354.62634277344, z = 5.54292726516724},
      Teleport = {x = 3867.44, y = 4463.62, z = 1.72386}
    },


    VehicleSpawner = {
          Pos   = {x = 880.74462890625, y = -1663.9635009766, z = 29.370491027832},
          Size  = {x = 3.0, y = 3.0, z = 1.0},
          Color = {r = 204, g = 204, b = 0},
      Marker= 1,
      Blip  = false,
      Name  = _U('spawn_veh'),
      Type  = "vehspawner",
      Spawner = 1,
      Hint  = _U('spawn_veh_button'),
      Caution = 2000,
      GPS = {x = 3867.44, y = 4463.62, z = 1.72386}
    },

    VehicleSpawnPoint = {
          Pos   = {x = 859.354, y = -1656.21, z = 29.5697},
          Size  = {x = 3.0, y = 3.0, z = 1.0},
      Marker= -1,
      Blip  = false,
      Name  = _U('service_vh'),
      Type  = "vehspawnpt",
      Spawner = 1,
      GPS = 0,
      Heading = 70.1
    },

    VehicleDeletePoint = {
          Pos   = {x = 863.23254394531, y = -1718.2849121094, z = 28.631998062134},
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
      Pos   = {x = -1012.64758300781, y = -1354.62634277344, z = 5.54292726516724},
      Color = {r = 204, g = 204, b = 0},
      Size  = {x = 5.0, y = 5.0, z = 3.0},
      Color = {r = 204, g = 204, b = 0},
      Marker= 1,
      Blip  = true,
      Name  = _U('delivery_point'),
      Type  = "delivery",
      Spawner = 2,
      Item  = {
        {
          name   = _U('delivery'),
          time   = 500,
          remove = 1,
          max    = 100, -- if not present, probably an error at itemQtty >= item.max in esx_jobs_sv.lua
          price  = 11,
          requires = "fish",
          requires_name = _U('fm_fish'),
          drop   = 100
        }
      },
      Hint  = _U('fm_deliver_fish'),
      GPS = {x = 3867.44, y = 4463.62, z = 1.72386}
    }
  }
}
