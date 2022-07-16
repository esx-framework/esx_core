Config = {}

Config.Locale = 'en'

Config.Price = 100

Config.EnableControls = true

Config.DrawDistance = 10
Config.Size   = {x = 1.5, y = 1.5, z = 1.0}
Config.Color  = {r = 50, g = 200, b = 50}
Config.Type   = 1

-- Fill this if you want to see the blips,
-- If you have esx_clothesshop you should not fill this
-- more than it's already filled.
Config.ShopsBlips = {
	-- Ears = {
	-- 	Pos = nil,
	-- 	Blip = nil
	-- },
	Mask = {
		Pos = { 
			vector3(-1338.1, -1278.2, 3.8),
		},
		Blip = {sprite = 362, color = 2}
	},
	-- Helmet = {
	-- 	Pos = nil,
	-- 	Blip = nil
	-- },
	-- Glasses = {
	-- 	Pos = nil,
	-- 	Blip = nil
	-- }
}

Config.Zones = {
	Ears = {
		Pos = {
			vector3(80.3, -1389.4, 28.4),
			vector3(-163.0, -302.0, 38.8),
			vector3(-163.0,-302.0, 38.8),
			vector3(420.7, -809.6, 28.6),
			vector3(-817.0, -1075.9, 10.4),
			vector3(-1451.3, -238.2, 48.9),
			vector3(-0.7, 6513.6, 30.9),
			vector3(123.4, -208.0, 53.6),
			vector3(1687.3, 4827.6, 41.1),
			vector3(622.8, 2749.2, 41.2),
			vector3(1200.0, 2705.4,	37.3),
			vector3(-1199.9, -782.5, 16.4),
			vector3(-3171.8, 1059.6, 19.9),
			vector3(-1095.6, 2709.2, 18.2),
		}},
	
	Mask = {
		Pos = {
			vector3(-1338.1, -1278.2, 3.8),
		}},
	
	Helmet = {
		Pos = {
			vector3(81.5, -1400.6, 28.4),
			vector3(-705.8, -159.0,	36.5),
			vector3(-161.3, -295.7,	38.8),
			vector3(419.3, -800.6, 28.6),
			vector3(-824.3, -1081.7, 10.4),
			vector3(-1454.8, -242.9, 48.9),
			vector3(4.7, 6520.9, 30.9),
			vector3(121.0, -223.2, 53.3),
			vector3(1689.6, 4818.8,	41.1),
			vector3(613.9, 2749.9, 41.2),
			vector3(1189.5, 2703.9,	37.3),
			vector3(-1204.0, -774.4, 16.4),
			vector3(-3164.2, 1054.7, 19.9),
			vector3(-1103.1, 2700.5, 18.2),
		}},
	
	Glasses = {
		Pos = {
			vector3(75.2, -1391.1, 28.4),
			vector3(-713.1, -160.1, 36.5),
			vector3(-156.1, -300.5,	38.8),
			vector3(425.4, -807.8, 28.6),
			vector3(-820.8, -1072.9, 10.4),
			vector3(-1458.0, -236.7, 48.9),
			vector3(3.5, 6511.5, 30.9),
			vector3(131.3, -212.3, 53.6),
			vector3(1694.9, 4820.8,	41.1),
			vector3(613.9, 2768.8, 41.2),
			vector3(1198.6, 2711.0, 37.3),
			vector3(-1188.2, -764.5, 16.4),
			vector3(-3173.1,  1038.2, 19.9),
			vector3(-1100.4, 2712.4, 18.2),
		}}
}
