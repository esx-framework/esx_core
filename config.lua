Config              = {}
Config.MarkerType   = 1
Config.DrawDistance = 100.0
Config.ZoneSize     = {x = 5.0, y = 5.0, z = 3.0}
Config.MarkerColor  = {r = 100, g = 204, b = 100}
Config.ShowBlips   = true  --markers visible on the map? (false to hide the markers on the map)

Config.RequiredCopsCoke  = 2
Config.RequiredCopsMeth  = 2
Config.RequiredCopsWeed  = 2
Config.RequiredCopsOpium = 2

Config.TimeToFarm    = 17 * 1000
Config.TimeToProcess = 46 * 1000
Config.TimeToSell    = 5  * 1000

Config.Locale = 'fr'

Config.Zones = {
	CokeField =			{x = 2448.92,	y = -1836.80,	z = 51.95,	name = _U('coke_field'),		sprite = 501,	color = 40},
	CokeProcessing =	{x = -458.13,	y = -2278.61,	z = 7.51,	name = _U('coke_processing'),	sprite = 478,	color = 40},
	CokeDealer =		{x = -1756.19,	y = 427.31,		z =126.68,	name = _U('coke_dealer'),		sprite = 500,	color = 75},
	MethField =			{x = 1525.29,	y = 1710.02,	z = 109.00,	name = _U('meth_field'),		sprite = 499,	color = 26},
	MethProcessing =	{x = -1001.41,	y = 4848.00,	z = 274.00,	name = _U('meth_processing'),	sprite = 499,	color = 26},
	MethDealer =		{x = -63.59,	y = -1224.07,	z = 27.76,	name = _U('meth_dealer'),		sprite = 500,	color = 75},
	WeedField =			{x = 1609.12,	y = 6663.59,	z = 20.96,	name = _U('weed_field'),		sprite = 496,	color = 52},
	WeedProcessing =	{x = 91.06,		y = 3750.03,	z = 39.77,	name = _U('weed_processing'),	sprite = 496,	color = 52},
	WeedDealer =		{x = -54.24,	y = -1443.36,	z = 31.06,	name = _U('weed_dealer'),		sprite = 500,	color = 75},
	OpiumField =		{x = 1972.78,	y = 3819.39,	z = 32.50,	name = _U('opium_field'),		sprite = 51,	color = 60},
	OpiumProcessing =	{x = 971.86,	y = -2157.00,	z = 28.47,	name = _U('opium_processing'),	sprite = 51,	color = 60},
	OpiumDealer =		{x = 2331.08,	y = 2570.22,	z = 45.30,	name = _U('opium_dealer'),		sprite = 500,	color = 75}
}
