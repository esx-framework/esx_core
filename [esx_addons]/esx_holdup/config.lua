Config = {}
Config.Locale = GetConvar('esx:locale', 'en')

Config.Marker = {
	r = 250, g = 0, b = 0, a = 100,  -- red color
	x = 1.0, y = 1.0, z = 1.5,       -- tiny, cylinder formed circle
	DrawDistance = 15.0, Type = 1    -- default circle type, low draw distance due to indoors area
}

Config.PoliceNumberRequired = 2
Config.TimerBeforeNewRob    = 1800 -- The cooldown timer on a store after robbery was completed / canceled, in seconds

Config.MaxDistance    = 20   -- max distance from the robbary, going any longer away from it will to cancel the robbary
Config.GiveBlackMoney = true -- give black money? If disabled it will give cash instead

Stores = {
	['paleto_twentyfourseven'] = {
		position = vector3(1736.32, 6419.47, 34.03),
		reward = math.random(5000, 35000),
		nameOfStore = '24/7. (Paleto Bay)',
		secondsRemaining = 350, -- seconds
		lastRobbed = 0
	},
	['sandyshores_twentyfoursever'] = {
		position = vector3(1961.24, 3749.46, 31.34),
		reward = math.random(3000, 20000),
		nameOfStore = '24/7. (Sandy Shores)',
		secondsRemaining = 200, -- seconds
		lastRobbed = 0
	},
	['littleseoul_twentyfourseven'] = {
		position = vector3(-709.17, -904.21, 18.21),
		reward = math.random(3000, 20000),
		nameOfStore = '24/7. (Little Seoul)',
		secondsRemaining = 200, -- seconds
		lastRobbed = 0
	},
	['bar_one'] = {
		position = vector3(1990.57, 3044.95, 46.21),
		reward = math.random(5000, 35000),
		nameOfStore = 'Yellow Jack. (Sandy Shores)',
		secondsRemaining = 300, -- seconds
		lastRobbed = 0
	},
	['ocean_liquor'] = {
		position = vector3(-2959.33, 388.21, 13.00),
		reward = math.random(3000, 30000),
		nameOfStore = 'Robs Liquor. (Great Ocean Highway)',
		secondsRemaining = 200, -- seconds
		lastRobbed = 0
	},
	['rancho_liquor'] = {
		position = vector3(1126.80, -980.40, 44.41),
		reward = math.random(3000, 50000),
		nameOfStore = 'Robs Liquor. (El Rancho Blvd)',
		secondsRemaining = 200, -- seconds
		lastRobbed = 0
	},
	['sanandreas_liquor'] = {
		position = vector3(-1219.85, -916.27, 10.32),
		reward = math.random(3000, 30000),
		nameOfStore = 'Robs Liquor. (San Andreas Avenue)',
		secondsRemaining = 200, -- seconds
		lastRobbed = 0
	},
	['grove_ltd'] = {
		position = vector3(-43.40, -1749.20, 28.42),
		reward = math.random(3000, 15000),
		nameOfStore = 'LTD Gasoline. (Grove Street)',
		secondsRemaining = 200, -- seconds
		lastRobbed = 0
	},
	['mirror_ltd'] = {
		position = vector3(1160.67, -314.40, 68.20),
		reward = math.random(3000, 15000),
		nameOfStore = 'LTD Gasoline. (Mirror Park Boulevard)',
		secondsRemaining = 200, -- seconds
		lastRobbed = 0
	}
}
