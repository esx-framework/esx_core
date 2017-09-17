Config              = {}
Config.DrawDistance = 1000.0
Config.Locale       = 'de'

Config.Plates = {
  taxi = "TAXI",
  fisherman = "FISH",
  cop = "LSPD",
  ambulance = "EMS",
  depanneur = "MECA",
  fuel = "FUEL",
  lumberjack = "BUCH",
  miner = "MINE",
  reporter = "JOUR",
  slaughterer = "ABAT",
  textil = "COUT"
}

Config.Jobs = {}

Config.PublicZones = {
  EnterBuilding = {
    Pos   = { x = -118.21381378174, y = -607.14227294922, z = 35.280723571777 },
    Size  = {x = 3.0, y = 3.0, z = 0.2},
    Color = {r = 204, g = 204, b = 0},
    Marker= 1,
    Blip  = false,
    Name  = "Arbeitsamt",
    Type  = "teleport",
    Hint  = "Drücke ~INPUT_PICKUP~ um das Gebäude zu betreten.",
    Teleport = { x = -139.09838867188, y = -620.74865722656, z = 167.82052612305 }
  },

  ExitBuilding = {
    Pos   = { x = -139.45831298828, y = -617.32312011719, z = 167.82052612305 },
    Size  = {x = 3.0, y = 3.0, z = 0.2},
    Color = {r = 204, g = 204, b = 0},
    Marker= 1,
    Blip  = false,
    Name  = "Arbeitsamt",
    Type  = "teleport",
    Hint  = "Drücke ~INPUT_PICKUP~ um das Gebäude zu verlassen.",
    Teleport = { x = -113.07, y = -604.93, z = 35.28 },
  },
}
