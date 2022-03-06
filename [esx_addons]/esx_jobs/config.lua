Config              = {}
Config.DrawDistance = 10.0
Config.Locale       = 'en'
Config.Jobs         = {}

Config.MaxCaution = 10000 -- the max caution allowed

Config.PublicZones = {

	EnterBuilding = {
		Pos   = vector3(-118.21, -607.14, 35.28),
		Size  = {x = 3.0, y = 3.0, z = 0.2},
		Color = {r = 204, g = 204, b = 0},
		Marker= 1,
		Blip  = false,
		Name  = _U('reporter_name'),
		Type  = "teleport",
		Hint  = _U('public_enter'),
		Teleport = vector3(-139.09,-620.74, 167.82)
	},

	ExitBuilding = {
		Pos   = vector3( -139.45, -617.32, 167.82),
		Size  = {x = 3.0, y = 3.0, z = 0.2},
		Color = {r = 204, g = 204, b = 0},
		Marker= 1,
		Blip  = false,
		Name  = _U('reporter_name'),
		Type  = "teleport",
		Hint  = _U('public_leave'),
		Teleport = vector3(-113.07, -604.93, 35.28 ),
	}

}
