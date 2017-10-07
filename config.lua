Config = {}

Config.Price = 100

Config.DrawDistance = 100.0
Config.MarkerSize   = {x = 1.5, y = 1.5, z = 1.0}
Config.MarkerColor  = {r = 102, g = 102, b = 204}
Config.MarkerType   = 1
Config.Locale = 'fr'

Config.Zones = {}

Config.Shops = {
  {x = -814.308,  y = -183.823,  z = 36.568},
  {x = 136.826,   y = -1708.373, z = 28.291},
  {x = -1282.604, y = -1116.757, z = 5.990},
  {x = 1931.513,  y = 3729.671,  z = 31.844},
  {x = 1212.840,  y = -472.921,  z = 65.208},
  {x = -32.885,   y = -152.319,  z = 56.076},
  {x = -278.077,  y = 6228.463,  z = 30.695},
}

for i=1, #Config.Shops, 1 do

	Config.Zones['Shop_' .. i] = {
	 	Pos   = Config.Shops[i],
	 	Size  = Config.MarkerSize,
	 	Color = Config.MarkerColor,
	 	Type  = Config.MarkerType
  }

end
