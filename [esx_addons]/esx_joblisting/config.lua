Config = {}

Config.DrawDistance = 15.0
Config.ZoneSize = {x = 2.7, y = 2.7, z = 0.5}
Config.MarkerColor = {r = 100, g = 200, b = 104}
Config.MarkerType = 27
Config.Debug = ESX.GetConfig().EnableDebug

Config.Locale = GetConvar('esx:locale', 'en')

Config.Zones = {
  vector3(-265.08, -964.1, 30.3)
}

Config.Blip = {
  Enabled = true, 
  Sprite = 407, 
  Display = 4, 
  Scale = 0.8, 
  Colour = 27, 
  ShortRange = true
}
