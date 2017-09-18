Config                            = {}
Config.DrawDistance               = 100.0
Config.MarkerType                 = 1
Config.MarkerSize                 = {x = 1.5, y = 1.5, z = 1.0}
Config.MarkerColor                = {r = 50, g = 50, b = 204}
Config.EnablePlayerManagement     = false
Config.EnableArmoryManagement     = false
Config.EnableESXIdentity          = false -- only turn this on if you are using esx_identity
Config.EnableNonFreemodePeds      = false -- turn this on if you want custom peds
Config.EnableSocietyOwnedVehicles = false
Config.MaxInService               = -1
Config.Locale                     = 'de'


Config.PoliceStations = {

  LSPD = {

    Blip = {
      Pos     = { x = 425.130, y = -979.558, z = 30.711 },
      Sprite  = 60,
      Display = 4,
      Scale   = 1.2,
      Colour  = 29,
    },

    AuthorizedWeapons = {
      {name = 'WEAPON_NIGHTSTICK',       price = 200},
      {name = 'WEAPON_COMBATPISTOL',     price = 300},
      {name = 'WEAPON_ASSAULTSMG',       price = 1250},
      {name = 'WEAPON_ASSAULTRIFLE',     price = 1500},
      {name = 'WEAPON_PUMPSHOTGUN',      price = 600},
      {name = 'WEAPON_STUNGUN',          price = 500},
      {name = 'WEAPON_FLASHLIGHT',       price = 80},
      {name = 'WEAPON_FIREEXTINGUISHER', price = 120},
      {name = 'WEAPON_FLAREGUN',         price = 60},
      {name = 'WEAPON_STICKYBOMB',       price = 250},
      {name = 'GADGET_PARACHUTE',        price = 300},
    },

    AuthorizedVehicles = {
      {name = 'police' , label = 'Streifenfahrzeug 1'},
      {name = 'police2', label = 'Streifenfahrzeug 2'},
      {name = 'police3', label = 'Streifenfahrzeug 3'},
      {name = 'police4', label = 'Zivilfahrzeug'},
      {name = 'policeb', label = 'Motorrad'},
      {name = 'policet', label = 'Transporter'},
    },

    Cloakrooms = {
      {x = 452.600, y = -993.306, z = 29.750}
    },

    Armories = {
      {x = 451.699, y = -980.356, z = 29.689}
    },

    Vehicles = {
      {
        Spawner    = {x = 454.69, y = -1017.4, z = 27.430},
        SpawnPoint = {x = 438.42, y = -1018.3, z = 27.757},
        Heading    = 90.0
      }
    },

    Helicopters = {
      {
        Spawner    = {x = 466.477, y = -982.819, z = 42.691},
        SpawnPoint = {x = 450.04, y = -981.14, z = 42.691},
        Heading    = 0.0
      }
    },

    VehicleDeleters = {
      {x = 462.74, y = -1014.4, z = 27.065},
      {x = 462.40, y = -1019.7, z = 27.104}
    },

    BossActions = {
      {x = 448.417, y = -973.208, z = 29.689}
    }

  }

}
