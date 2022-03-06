Config              = {}
Config.DrawDistance = 10.0
Config.MarkerColor  = { r = 120, g = 120, b = 240 }
Config.Locale       = 'en'

Config.Zones = {
	OfficeEnter = {
		Pos   = vector3( -199.151, -575.000,  39.489 ),
		Size  = { x = 1.5, y = 1.5, z = 1.0 },
		Type  = 1
	},

	OfficeExit = {
		Pos   = vector3( -141.226, -614.166,  167.820 ),
		Size  = { x = 1.5, y = 1.5, z = 1.0 },
		Type  = 1
	},

	OfficeInside = {
		Pos   = vector3( -140.969, -616.785,  167.820 ),
		Size  = { x = 1.5, y = 1.5, z = 1.0 },
		Type  = -1
	},

	OfficeOutside = {
		Pos   = vector3( -202.238, -578.193,  39.500 ),
		Size  = { x = 1.5, y = 1.5, z = 1.0 },
		Type  = -1
	},

	OfficeActions = {
		Pos   = vector3( -124.786, -641.486,  167.820 ),
		Size  = { x = 1.5, y = 1.5, z = 1.0 },
		Type  = -1
	}
}
