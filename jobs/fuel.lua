Config.Jobs.fuel = {
  BlipInfos = {
    Sprite = 436,
    Color = 5
  },
  Vehicles = {
    Truck = {
      Spawner = 1,
      Hash = "phantom",
      Trailer = "tanker",
      HasCaution = true
    }
  },
  Zones = {
    CloakRoom = { -- 1
      Pos   = {x = 557.933, y = -2327.9, z = 4.82896},
      Size  = {x = 3.0, y = 3.0, z = 2.0},
      Color = {r = 204, g = 204, b = 0},
      Marker= 1,
      Blip  = true,
      Name  = _U('f_oil_refiner'),
      Type  = "cloakroom",
      Hint  = _U('cloak_change'),
      GPS = {x = 554.597, y = -2314.43, z = 4.86293}
    },

    ChampPetrol = { -- 4 -- 8
      Pos   = {x = 609.589, y = 2856.74, z = 39.4958},
      Size  = {x = 20.0, y = 20.0, z = 1.0},
      Color = {r = 204, g = 204, b = 0},
      Marker= 1,
      Blip  = true,
      Name  = _U('f_drill_oil'),
      Type  = "work",
      Item  = {
        {
          name   = _U('f_fuel'),
          db_name= "petrol",
          time   = 5000,
          max    = 24,
          add    = 1,
          remove = 1,
          requires = "nothing",
          requires_name = "Nothing",
          drop   = 100
        }
      },
      Hint  = _U('f_drillbutton'),
      GPS = {x = 2736.94, y = 1417.99, z = 23.4888}
    },

    Raffinerie = { -- 5
      Pos   = {x = 2736.94, y = 1417.99, z = 23.4888},
      Size  = {x = 10.0, y = 10.0, z = 1.0},
      Color = {r = 204, g = 204, b = 0},
      Marker= 1,
      Blip  = true,
      Name  = _U('f_fuel_refine'),
      Type  = "work",
      Item  = {
        {
          name   = _U('f_fuel_refine'),
          db_name= "petrol_raffin",
          time   = 5000,
          max    = 20,
          add    = 1,
          remove = 2,
          requires = "petrol",
          requires_name = _U('f_fuel'),
          drop   = 100
        }
      },
      Hint  = _U('f_refine_fuel_button'),
      GPS = {x = 265.752, y = -3013.39, z = 4.73275}
    },

    Melange = { -- 6
      Pos   = {x = 265.752, y = -3013.39, z = 4.73275},
      Size  = {x = 10.0, y = 10.0, z = 1.0},
      Color = {r = 204, g = 204, b = 0},
      Marker= 1,
      Blip  = true,
      Name  = _U('f_fuel_mixture'),
      Type  = "work",
      Item  = {
        {
          name   = _U('f_gas'),
          db_name= "essence",
          time   = 5000,
          max    = 20,
          add    = 2,
          remove = 1,
          requires = "petrol_raffin",
          requires_name = _U('f_fuel_refine'),
          drop   = 100
        }
      },
      Hint  = _U('f_fuel_mixture_button'),
      GPS = {x = 491.406, y = -2163.37, z = 4.91827}
    },

    VehicleSpawner = { -- 2
      Pos   = {x = 554.597, y = -2314.43, z = 4.86293},
      Size  = {x = 3.0, y = 3.0, z = 2.0},
      Color = {r = 204, g = 204, b = 0},
      Marker= 1,
      Blip  = false,
      Name  = _U('spawn_veh'),
      Type  = "vehspawner",
      Spawner = 1,
      Hint  = _U('spawn_truck_button'),
      Caution = 2000,
      GPS = {x = 602.254, y = 2926.62, z = 39.6898}
    },

    VehicleSpawnPoint = {
      Pos   = {x = 580.541, y = -2309.7, z = 4.90915},
      Size  = {x = 3.0, y = 3.0, z = 1.0},
      Marker= -1,
      Blip  = false,
      Name  = _U('service_vh'),
      Type  = "vehspawnpt",
      Spawner = 1,
      GPS = 0,
      Heading = 0
    },

    VehicleDeletePoint = {
      Pos   = {x = 520.684, y = -2124.21, z = 4.98635},
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

    Delivery = { -- 7
      Pos   = {x = 491.406, y = -2163.37, z = 4.91827},
      Color = {r = 204, g = 204, b = 0},
      Size  = {x = 10.0, y = 10.0, z = 1.0},
      Marker= 1,
      Blip  = true,
      Name  = _U('f_deliver_gas'),
      Type  = "delivery",
      Spawner = 1,
      Item  = {
        {
          name   = _U('delivery'),
          time   = 500,
          remove = 1,
          max    = 100, -- if not present, probably an error at itemQtty >= item.max in esx_jobs_sv.lua
          price  = 61,
          requires = "essence",
          requires_name = _U('f_gas'),
          drop   = 100
        }
      },
      Hint  = _U('f_deliver_gas'),
      GPS = {x = 609.589, y = 2856.74, z = 39.4958}
    }
  }
}
