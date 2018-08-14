Config = {}
Config.Locale = 'fr'

Config.PoliceNumberRequired = 2
Config.TimerBeforeNewRob = 1800 -- seconds

Config.MaxDistance    = 40 -- max distance from the robbary, going any longer away from it will to cancel the robbary
Config.GiveBlackMoney = true -- give black money? If disabled it will give cash instead.

Stores = {
	["paleto_twentyfourseven"] = {
		position = { x = 1736.32, y = 6419.47, z = 35.03 },
		reward = math.random(5000, 35000),
		nameofstore = "24/7. (Paleto Bay)",
		secondsRemaining = 350, -- seconds
		lastrobbed = 0
	},
	["sandyshores_twentyfoursever"] = {
		position = { x = 1961.24, y = 3749.46, z = 32.34 },
		reward = math.random(3000, 20000),
		nameofstore = "24/7. (Sandy Shores)",
		secondsRemaining = 200, -- seconds
		lastrobbed = 0
	},
	["littleseoul_twentyfourseven"] = {
		position = { x = -709.17, y = -904.21, z = 19.21 },
		reward = math.random(3000, 20000),
		nameofstore = "24/7. (Little Seoul)",
		secondsRemaining = 200, -- seconds
		lastrobbed = 0
	},
	["bar_one"] = {
		position = { x = 1990.57, y = 3044.95, z = 47.21 },
		reward = math.random(5000, 35000),
		nameofstore = "Yellow Jack. (Sandy Shores)",
		secondsRemaining = 300, -- seconds
		lastrobbed = 0
	},
	["ocean_liquor"] = {
		position = { x = -2959.33, y = 388.21, z = 14.00 },
		reward = math.random(3000, 30000),
		nameofstore = "Robs Liquor. (Great Ocean Highway)",
		secondsRemaining = 200, -- seconds
		lastrobbed = 0
	},
	["rancho_liquor"] = {
		position = { x = 1126.80, y = -980.40, z = 45.41 },
		reward = math.random(3000, 50000),
		nameofstore = "Robs Liquor. (El Rancho Blvd)",
		secondsRemaining = 200, -- seconds
		lastrobbed = 0
	},
	["sanandreas_liquor"] = {
		position = { x = -1219.85, y = -916.27, z = 11.32 },
		reward = math.random(3000, 30000),
		nameofstore = "Robs Liquor. (San Andreas Avenue)",
		secondsRemaining = 200, -- seconds
		lastrobbed = 0
	},
	["grove_ltd"] = {
		position = { x = -43.40, y = -1749.20, z = 29.42 },
		reward = math.random(3000, 15000),
		nameofstore = "LTD Gasoline. (Grove Street)",
		secondsRemaining = 200, -- seconds
		lastrobbed = 0
	},
	["mirror_ltd"] = {
		position = { x = 1160.67, y = -314.40, z = 69.20 },
		reward = math.random(3000, 15000),
		nameofstore = "LTD Gasoline. (Mirror Park Boulevard)",
		secondsRemaining = 200, -- seconds
		lastrobbed = 0
	}
}
