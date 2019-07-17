Config                            = {}

Config.DrawDistance               = 100.0

Config.Marker                     = { type = 21, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = true }

Config.ReviveReward               = 350  -- revive reward, set to 0 if you don't want it enabled
Config.AntiCombatLog              = true -- enable anti-combat logging?
Config.LoadIpl                    = true -- disable if you're using fivem-ipl or other IPL loaders

Config.Locale                     = 'en'

local second = 1000
local minute = 60 * second

Config.EarlyRespawnTimer          = 7 * minute  -- Time til respawn is available
Config.BleedoutTimer              = 10 * minute -- Time til the player bleeds out

Config.EnablePlayerManagement     = true

Config.RemoveWeaponsAfterRPDeath  = true
Config.RemoveCashAfterRPDeath     = true
Config.RemoveItemsAfterRPDeath    = true

-- Let the player pay for respawning early, only if he can afford it.
Config.EarlyRespawnFine           = false
Config.EarlyRespawnFineAmount     = 5000

Config.RespawnPoint = { coords = vector3(281.27, -581.24, 42.75), heading = 65.5 }

Config.Hospitals = {

	CentralLosSantos = {

		Blip = {
			coords = vector3(289.71, -585.82, 42.19),
			sprite = 61,
			scale  = 1.2,
			color  = 2
		},

		AmbulanceActions = {
			vector3(310.48, -599.23, 43.29)
		},

		Pharmacies = {
			vector3(270.5, -1363.22, 24.53)
		},

		Vehicles = {
			{
				Spawner = vector3(295.27, -600.8, 43.3),
				InsideShop = vector3(446.7, -1355.6, 43.5),
				Marker = { type = 36, x = 1.0, y = 1.0, z = 1.0, r = 100, g = 50, b = 200, a = 100, rotate = true },
				SpawnPoints = {
					{ coords = vector3(290.26, -599.41, 43.15), heading = 151.5, radius = 1.0 },
					{ coords = vector3(294.0, -1433.1, 29.8), heading = 227.6, radius = 4.0 },
					{ coords = vector3(309.4, -1442.5, 29.8), heading = 227.6, radius = 6.0 }
				}
			}
		},

		Helicopters = {
			{
				Spawner = vector3(345.46, -580.32, 74.16),
				InsideShop = vector3(305.6, -1419.7, 41.5),
				Marker = { type = 34, x = 1.5, y = 1.5, z = 1.5, r = 100, g = 150, b = 150, a = 100, rotate = true },
				SpawnPoints = {
					{ coords = vector3(352.06, -588.03, 74.16), heading = 330.5, radius = 10.0 },
					{ coords = vector3(299.5, -1453.2, 46.5), heading = 142.7, radius = 10.0 }
				}
			}
		},

		FastTravels = {
			{
				From = vector3(315.48, -583.04, 42.31),
				To = { coords = vector3(272.8, -1358.8, 23.5), heading = 0.0 },
				Marker = { type = 1, x = 2.0, y = 2.0, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false }
			},

			{
				From = vector3(275.3, -1361, 23.5),
				To = { coords = vector3(318.37, -584.1, 42.3), heading = 0.0 },
				Marker = { type = 1, x = 2.0, y = 2.0, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false }
			},

			{
				From = vector3(332.9, -591.3, 42.31),
				To = { coords = vector3(341.4, -584.99, 73.19), heading = 258.5 },
				Marker = { type = 1, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false }
			},

			{
				From = vector3(338.56, -583.64, 73.22),
				To = { coords = vector3(333.6, -589.61, 43.28), heading = 338.38 },
				Marker = { type = 1, x = 2.0, y = 2.0, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false }
			},

			{
				From = vector3(298.57, -584.43, 42.28),
				To = { coords = vector3(303.48, -586.12, 42.29), heading = 0.0 },
				Marker = { type = 1, x = 1.5, y = 1.5, z = 1.0, r = 102, g = 0, b = 102, a = 100, rotate = false }
			},

			{
				From = vector3(300.57, -585.11, 42.31),
				To = { coords = vector3(296.79, -584.34, 42.16), heading = 0.0 },
				Marker = { type = 1, x = 1.5, y = 1.5, z = 1.0, r = 102, g = 0, b = 102, a = 100, rotate = false }
			}
		},

		FastTravelsPrompt = {
			{
				From = vector3(237.4, -1373.8, 26.0),
				To = { coords = vector3(251.9, -1363.3, 38.5), heading = 0.0 },
				Marker = { type = 1, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false },
				Prompt = _U('fast_travel')
			},

			{
				From = vector3(256.5, -1357.7, 36.0),
				To = { coords = vector3(235.4, -1372.8, 26.3), heading = 0.0 },
				Marker = { type = 1, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false },
				Prompt = _U('fast_travel')
			}
		}

	}
}

Config.AuthorizedVehicles = {

	ambulance = {
		{ model = 'ambulance', label = 'Ambulance Van', price = 5000},
		{ model = 'dodgesamu', label = 'Dodge Samu', price = 5000}
	},

	doctor = {
		{ model = 'ambulance', label = 'Ambulance Van', price = 4500},
		{ model = 'dodgesamu', label = 'Dodge Samu', price = 5000}
	},

	chief_doctor = {
		{ model = 'ambulance', label = 'Ambulance Van', price = 3000},
		{ model = 'dodgeems', label = 'Dodge EMS', price = 5000}
	},

	boss = {
		{ model = 'ambulance', label = 'Ambulance Van', price = 2000},
		{ model = 'dodgeems', label = 'Dodge EMS', price = 5000}
	}

}

Config.AuthorizedHelicopters = {

	ambulance = {},

	doctor = {
		{ model = 'buzzard2', label = 'Nagasaki Buzzard', price = 20000 },
		{ model = 'polmav', label = 'EMS', livery = 1, price = 20000 }
	},

	chief_doctor = {
		{ model = 'buzzard2', label = 'Nagasaki Buzzard', price = 20000 },
		{ model = 'polmav', label = 'EMS', livery = 1, price = 20000 }
	},

	boss = {
		{ model = 'buzzard2', label = 'Nagasaki Buzzard', price = 20000 },
		{ model = 'polmav', label = 'EMS', livery = 1, price = 20000 }
	}

}
