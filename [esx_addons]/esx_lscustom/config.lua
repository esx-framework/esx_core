Config                   = {}
Config.DrawDistance      = 10.0
Config.Locale = GetConvar('esx:locale', 'en')
Config.IsMechanicJobOnly = false

Config.Zones = {

	ls1 = {
		Pos   = { x = -337.38, y = -136.92, z = 38.57},
		Size  = {x = 3.0, y = 3.0, z = 0.2},
		Color = {r = 204, g = 204, b = 0},
		Marker= 1,
		Name  = TranslateCap('blip_name'),
		Hint  = TranslateCap('press_custom')
	},

	ls2 = {
		Pos   = { x = -1155.53, y = -2007.18, z = 12.74},
		Size  = {x = 3.0, y = 3.0, z = 0.2},
		Color = {r = 204, g = 204, b = 0},
		Marker= 1,
		Name  = TranslateCap('blip_name'),
		Hint  = TranslateCap('press_custom')
	},

	ls3 = {
		Pos   = { x = 731.81, y = -1088.82, z = 21.73},
		Size  = {x = 3.0, y = 3.0, z = 0.2},
		Color = {r = 204, g = 204, b = 0},
		Marker= 1,
		Name  = TranslateCap('blip_name'),
		Hint  = TranslateCap('press_custom')
	},

	ls4 = {
		Pos   = { x = 1175.04, y = 2640.21, z = 37.32},
		Size  = {x = 3.0, y = 3.0, z = 0.2},
		Color = {r = 204, g = 204, b = 0},
		Marker= 1,
		Name  = TranslateCap('blip_name'),
		Hint  = TranslateCap('press_custom')
	},

	ls5 = {
		Pos   = { x = 110.99, y = 6626.39, z = 30.89},
		Size  = {x = 3.0, y = 3.0, z = 0.2},
		Color = {r = 204, g = 204, b = 0},
		Marker= 1,
		Name  = TranslateCap('blip_name'),
		Hint  = TranslateCap('press_custom')
	}

}

Config.Colors = {
	{label = TranslateCap('black'), value = 'black'},
	{label = TranslateCap('white'), value = 'white'},
	{label = TranslateCap('grey'), value = 'grey'},
	{label = TranslateCap('red'), value = 'red'},
	{label = TranslateCap('pink'), value = 'pink'},
	{label = TranslateCap('blue'), value = 'blue'},
	{label = TranslateCap('yellow'), value = 'yellow'},
	{label = TranslateCap('green'), value = 'green'},
	{label = TranslateCap('orange'), value = 'orange'},
	{label = TranslateCap('brown'), value = 'brown'},
	{label = TranslateCap('purple'), value = 'purple'},
	{label = TranslateCap('chrome'), value = 'chrome'},
	{label = TranslateCap('gold'), value = 'gold'}
}

function GetColors(color)
	local colors = {}
	if color == 'black' then
		colors = {
			{ index = 0, label = TranslateCap('black')},
			{ index = 1, label = TranslateCap('graphite')},
			{ index = 2, label = TranslateCap('black_metallic')},
			{ index = 3, label = TranslateCap('caststeel')},
			{ index = 11, label = TranslateCap('black_anth')},
			{ index = 12, label = TranslateCap('matteblack')},
			{ index = 15, label = TranslateCap('darknight')},
			{ index = 16, label = TranslateCap('deepblack')},
			{ index = 21, label = TranslateCap('oil')},
			{ index = 147, label = TranslateCap('carbon')}
		}
	elseif color == 'white' then
		colors = {
			{ index = 106, label = TranslateCap('vanilla')},
			{ index = 107, label = TranslateCap('creme')},
			{ index = 111, label = TranslateCap('white')},
			{ index = 112, label = TranslateCap('polarwhite')},
			{ index = 113, label = TranslateCap('beige')},
			{ index = 121, label = TranslateCap('mattewhite')},
			{ index = 122, label = TranslateCap('snow')},
			{ index = 131, label = TranslateCap('cotton')},
			{ index = 132, label = TranslateCap('alabaster')},
			{ index = 134, label = TranslateCap('purewhite')}
		}
	elseif color == 'grey' then
		colors = {
			{ index = 4, label = TranslateCap('silver')},
			{ index = 5, label = TranslateCap('metallicgrey')},
			{ index = 6, label = TranslateCap('laminatedsteel')},
			{ index = 7, label = TranslateCap('darkgray')},
			{ index = 8, label = TranslateCap('rockygray')},
			{ index = 9, label = TranslateCap('graynight')},
			{ index = 10, label = TranslateCap('aluminum')},
			{ index = 13, label = TranslateCap('graymat')},
			{ index = 14, label = TranslateCap('lightgrey')},
			{ index = 17, label = TranslateCap('asphaltgray')},
			{ index = 18, label = TranslateCap('grayconcrete')},
			{ index = 19, label = TranslateCap('darksilver')},
			{ index = 20, label = TranslateCap('magnesite')},
			{ index = 22, label = TranslateCap('nickel')},
			{ index = 23, label = TranslateCap('zinc')},
			{ index = 24, label = TranslateCap('dolomite')},
			{ index = 25, label = TranslateCap('bluesilver')},
			{ index = 26, label = TranslateCap('titanium')},
			{ index = 66, label = TranslateCap('steelblue')},
			{ index = 93, label = TranslateCap('champagne')},
			{ index = 144, label = TranslateCap('grayhunter')},
			{ index = 156, label = TranslateCap('grey')}
		}
	elseif color == 'red' then
		colors = {
			{ index = 27, label = TranslateCap('red')},
			{ index = 28, label = TranslateCap('torino_red')},
			{ index = 29, label = TranslateCap('poppy')},
			{ index = 30, label = TranslateCap('copper_red')},
			{ index = 31, label = TranslateCap('cardinal')},
			{ index = 32, label = TranslateCap('brick')},
			{ index = 33, label = TranslateCap('garnet')},
			{ index = 34, label = TranslateCap('cabernet')},
			{ index = 35, label = TranslateCap('candy')},
			{ index = 39, label = TranslateCap('matte_red')},
			{ index = 40, label = TranslateCap('dark_red')},
			{ index = 43, label = TranslateCap('red_pulp')},
			{ index = 44, label = TranslateCap('bril_red')},
			{ index = 46, label = TranslateCap('pale_red')},
			{ index = 143, label = TranslateCap('wine_red')},
			{ index = 150, label = TranslateCap('volcano')}
		}
	elseif color == 'pink' then
		colors = {
			{ index = 135, label = TranslateCap('electricpink')},
			{ index = 136, label = TranslateCap('salmon')},
			{ index = 137, label = TranslateCap('sugarplum')}
		}
	elseif color == 'blue' then
		colors = {
			{ index = 54, label = TranslateCap('topaz')},
			{ index = 60, label = TranslateCap('light_blue')},
			{ index = 61, label = TranslateCap('galaxy_blue')},
			{ index = 62, label = TranslateCap('dark_blue')},
			{ index = 63, label = TranslateCap('azure')},
			{ index = 64, label = TranslateCap('navy_blue')},
			{ index = 65, label = TranslateCap('lapis')},
			{ index = 67, label = TranslateCap('blue_diamond')},
			{ index = 68, label = TranslateCap('surfer')},
			{ index = 69, label = TranslateCap('pastel_blue')},
			{ index = 70, label = TranslateCap('celeste_blue')},
			{ index = 73, label = TranslateCap('rally_blue')},
			{ index = 74, label = TranslateCap('blue_paradise')},
			{ index = 75, label = TranslateCap('blue_night')},
			{ index = 77, label = TranslateCap('cyan_blue')},
			{ index = 78, label = TranslateCap('cobalt')},
			{ index = 79, label = TranslateCap('electric_blue')},
			{ index = 80, label = TranslateCap('horizon_blue')},
			{ index = 82, label = TranslateCap('metallic_blue')},
			{ index = 83, label = TranslateCap('aquamarine')},
			{ index = 84, label = TranslateCap('blue_agathe')},
			{ index = 85, label = TranslateCap('zirconium')},
			{ index = 86, label = TranslateCap('spinel')},
			{ index = 87, label = TranslateCap('tourmaline')},
			{ index = 127, label = TranslateCap('paradise')},
			{ index = 140, label = TranslateCap('bubble_gum')},
			{ index = 141, label = TranslateCap('midnight_blue')},
			{ index = 146, label = TranslateCap('forbidden_blue')},
			{ index = 157, label = TranslateCap('glacier_blue')}
		}
	elseif color == 'yellow' then
		colors = {
			{ index = 42, label = TranslateCap('yellow')},
			{ index = 88, label = TranslateCap('wheat')},
			{ index = 89, label = TranslateCap('raceyellow')},
			{ index = 91, label = TranslateCap('paleyellow')},
			{ index = 126, label = TranslateCap('lightyellow')}
		}
	elseif color == 'green' then
		colors = {
			{ index = 49, label = TranslateCap('met_dark_green')},
			{ index = 50, label = TranslateCap('rally_green')},
			{ index = 51, label = TranslateCap('pine_green')},
			{ index = 52, label = TranslateCap('olive_green')},
			{ index = 53, label = TranslateCap('light_green')},
			{ index = 55, label = TranslateCap('lime_green')},
			{ index = 56, label = TranslateCap('forest_green')},
			{ index = 57, label = TranslateCap('lawn_green')},
			{ index = 58, label = TranslateCap('imperial_green')},
			{ index = 59, label = TranslateCap('green_bottle')},
			{ index = 92, label = TranslateCap('citrus_green')},
			{ index = 125, label = TranslateCap('green_anis')},
			{ index = 128, label = TranslateCap('khaki')},
			{ index = 133, label = TranslateCap('army_green')},
			{ index = 151, label = TranslateCap('dark_green')},
			{ index = 152, label = TranslateCap('hunter_green')},
			{ index = 155, label = TranslateCap('matte_foilage_green')}
		}
	elseif color == 'orange' then
		colors = {
			{ index = 36, label = TranslateCap('tangerine')},
			{ index = 38, label = TranslateCap('orange')},
			{ index = 41, label = TranslateCap('matteorange')},
			{ index = 123, label = TranslateCap('lightorange')},
			{ index = 124, label = TranslateCap('peach')},
			{ index = 130, label = TranslateCap('pumpkin')},
			{ index = 138, label = TranslateCap('orangelambo')}
		}
	elseif color == 'brown' then
		colors = {
			{ index = 45, label = TranslateCap('copper')},
			{ index = 47, label = TranslateCap('lightbrown')},
			{ index = 48, label = TranslateCap('darkbrown')},
			{ index = 90, label = TranslateCap('bronze')},
			{ index = 94, label = TranslateCap('brownmetallic')},
			{ index = 95, label = TranslateCap('expresso')},
			{ index = 96, label = TranslateCap('chocolate')},
			{ index = 97, label = TranslateCap('terracotta')},
			{ index = 98, label = TranslateCap('marble')},
			{ index = 99, label = TranslateCap('sand')},
			{ index = 100, label = TranslateCap('sepia')},
			{ index = 101, label = TranslateCap('bison')},
			{ index = 102, label = TranslateCap('palm')},
			{ index = 103, label = TranslateCap('caramel')},
			{ index = 104, label = TranslateCap('rust')},
			{ index = 105, label = TranslateCap('chestnut')},
			{ index = 108, label = TranslateCap('brown')},
			{ index = 109, label = TranslateCap('hazelnut')},
			{ index = 110, label = TranslateCap('shell')},
			{ index = 114, label = TranslateCap('mahogany')},
			{ index = 115, label = TranslateCap('cauldron')},
			{ index = 116, label = TranslateCap('blond')},
			{ index = 129, label = TranslateCap('gravel')},
			{ index = 153, label = TranslateCap('darkearth')},
			{ index = 154, label = TranslateCap('desert')}
		}
	elseif color == 'purple' then
		colors = {
			{ index = 71, label = TranslateCap('indigo')},
			{ index = 72, label = TranslateCap('deeppurple')},
			{ index = 76, label = TranslateCap('darkviolet')},
			{ index = 81, label = TranslateCap('amethyst')},
			{ index = 142, label = TranslateCap('mysticalviolet')},
			{ index = 145, label = TranslateCap('purplemetallic')},
			{ index = 148, label = TranslateCap('matteviolet')},
			{ index = 149, label = TranslateCap('mattedeeppurple')}
		}
	elseif color == 'chrome' then
		colors = {
			{ index = 117, label = TranslateCap('brushedchrome')},
			{ index = 118, label = TranslateCap('blackchrome')},
			{ index = 119, label = TranslateCap('brushedaluminum')},
			{ index = 120, label = TranslateCap('chrome')}
		}
	elseif color == 'gold' then
		colors = {
			{ index = 37, label = TranslateCap('gold')},
			{ index = 158, label = TranslateCap('puregold')},
			{ index = 159, label = TranslateCap('brushedgold')},
			{ index = 160, label = TranslateCap('lightgold')}
		}
	end
	return colors
end

function GetWindowName(index)
	if (index == 1) then
		return "Pure Black"
	elseif (index == 2) then
		return "Darksmoke"
	elseif (index == 3) then
		return "Lightsmoke"
	elseif (index == 4) then
		return "Limo"
	elseif (index == 5) then
		return "Green"
	else
		return "Unknown"
	end
end

function GetHornName(index)
	if (index == 0) then
		return "Truck Horn"
	elseif (index == 1) then
		return "Cop Horn"
	elseif (index == 2) then
		return "Clown Horn"
	elseif (index == 3) then
		return "Musical Horn 1"
	elseif (index == 4) then
		return "Musical Horn 2"
	elseif (index == 5) then
		return "Musical Horn 3"
	elseif (index == 6) then
		return "Musical Horn 4"
	elseif (index == 7) then
		return "Musical Horn 5"
	elseif (index == 8) then
		return "Sad Trombone"
	elseif (index == 9) then
		return "Classical Horn 1"
	elseif (index == 10) then
		return "Classical Horn 2"
	elseif (index == 11) then
		return "Classical Horn 3"
	elseif (index == 12) then
		return "Classical Horn 4"
	elseif (index == 13) then
		return "Classical Horn 5"
	elseif (index == 14) then
		return "Classical Horn 6"
	elseif (index == 15) then
		return "Classical Horn 7"
	elseif (index == 16) then
		return "Scale - Do"
	elseif (index == 17) then
		return "Scale - Re"
	elseif (index == 18) then
		return "Scale - Mi"
	elseif (index == 19) then
		return "Scale - Fa"
	elseif (index == 20) then
		return "Scale - Sol"
	elseif (index == 21) then
		return "Scale - La"
	elseif (index == 22) then
		return "Scale - Ti"
	elseif (index == 23) then
		return "Scale - Do"
	elseif (index == 24) then
		return "Jazz Horn 1"
	elseif (index == 25) then
		return "Jazz Horn 2"
	elseif (index == 26) then
		return "Jazz Horn 3"
	elseif (index == 27) then
		return "Jazz Horn Loop"
	elseif (index == 28) then
		return "Star Spangled Banner 1"
	elseif (index == 29) then
		return "Star Spangled Banner 2"
	elseif (index == 30) then
		return "Star Spangled Banner 3"
	elseif (index == 31) then
		return "Star Spangled Banner 4"
	elseif (index == 32) then
		return "Classical Horn 8 Loop"
	elseif (index == 33) then
		return "Classical Horn 9 Loop"
	elseif (index == 34) then
		return "Classical Horn 10 Loop"
	elseif (index == 35) then
		return "Classical Horn 8"
	elseif (index == 36) then
		return "Classical Horn 9"
	elseif (index == 37) then
		return "Classical Horn 10"
	elseif (index == 38) then
		return "Funeral Loop"
	elseif (index == 39) then
		return "Funeral"
	elseif (index == 40) then
		return "Spooky Loop"
	elseif (index == 41) then
		return "Spooky"
	elseif (index == 42) then
		return "San Andreas Loop"
	elseif (index == 43) then
		return "San Andreas"
	elseif (index == 44) then
		return "Liberty City Loop"
	elseif (index == 45) then
		return "Liberty City"
	elseif (index == 46) then
		return "Festive 1 Loop"
	elseif (index == 47) then
		return "Festive 1"
	elseif (index == 48) then
		return "Festive 2 Loop"
	elseif (index == 49) then
		return "Festive 2"
	elseif (index == 50) then
		return "Festive 3 Loop"
	elseif (index == 51) then
		return "Festive 3"
	else
		return "Unknown Horn"
	end
end

function GetNeons()
	local neons = {
		{label = TranslateCap('white'),		r = 255, 	g = 255, 	b = 255},
		{label = "Slate Gray",		r = 112, 	g = 128, 	b = 144},
		{label = "Blue",			r = 0, 		g = 0, 		b = 255},
		{label = "Light Blue",		r = 0, 		g = 150, 	b = 255},
		{label = "Navy Blue", 		r = 0, 		g = 0, 		b = 128},
		{label = "Sky Blue", 		r = 135, 	g = 206, 	b = 235},
		{label = "Turquoise", 		r = 0, 		g = 245, 	b = 255},
		{label = "Mint Green", 	r = 50, 	g = 255, 	b = 155},
		{label = "Lime Green", 	r = 0, 		g = 255, 	b = 0},
		{label = "Olive", 			r = 128, 	g = 128, 	b = 0},
		{label = TranslateCap('yellow'), 	r = 255, 	g = 255, 	b = 0},
		{label = TranslateCap('gold'), 		r = 255, 	g = 215, 	b = 0},
		{label = TranslateCap('orange'), 	r = 255, 	g = 165, 	b = 0},
		{label = TranslateCap('wheat'), 		r = 245, 	g = 222, 	b = 179},
		{label = TranslateCap('red'), 		r = 255, 	g = 0, 		b = 0},
		{label = TranslateCap('pink'), 		r = 255, 	g = 161, 	b = 211},
		{label = TranslateCap('brightpink'),	r = 255, 	g = 0, 		b = 255},
		{label = TranslateCap('purple'), 	r = 153, 	g = 0, 		b = 153},
		{label = "Ivory", 			r = 41, 	g = 36, 	b = 33}
	}

	return neons
end

function GetPlatesName(index)
	if (index == 0) then
		return TranslateCap('blue_on_white_1')
	elseif (index == 1) then
		return TranslateCap('yellow_on_black')
	elseif (index == 2) then
		return TranslateCap('yellow_blue')
	elseif (index == 3) then
		return TranslateCap('blue_on_white_2')
	elseif (index == 4) then
		return TranslateCap('blue_on_white_3')
	end
end

Config.Menus = {
	main = {
		label		= 'LS CUSTOMS',
		parent		= nil,
		upgrades	= TranslateCap('upgrades'),
		cosmetics	= TranslateCap('cosmetics')
	},
	upgrades = {
		label			= TranslateCap('upgrades'),
		parent			= 'main',
		modEngine		= TranslateCap('engine'),
		modBrakes		= TranslateCap('brakes'),
		modTransmission	= TranslateCap('transmission'),
		modSuspension	= TranslateCap('suspension'),
		modArmor		= TranslateCap('armor'),
		modTurbo		= TranslateCap('turbo')
	},
	modEngine = {
		label = TranslateCap('engine'),
		parent = 'upgrades',
		modType = 11,
		price = {13.95, 32.56, 65.12, 139.53}
	},
	modBrakes = {
		label = TranslateCap('brakes'),
		parent = 'upgrades',
		modType = 12,
		price = {4.65, 9.3, 18.6, 13.95}
	},
	modTransmission = {
		label = TranslateCap('transmission'),
		parent = 'upgrades',
		modType = 13,
		price = {13.95, 20.93, 46.51}
	},
	modSuspension = {
		label = TranslateCap('suspension'),
		parent = 'upgrades',
		modType = 15,
		price = {3.72, 7.44, 14.88, 29.77, 40.2}
	},
	modArmor = {
		label = TranslateCap('armor'),
		parent = 'upgrades',
		modType = 16,
		price = {69.77, 116.28, 130.00, 150.00, 180.00, 190.00}
	},
	modTurbo = {
		label = TranslateCap('turbo'),
		parent = 'upgrades',
		modType = 17,
		price = {55.81}
	},
	cosmetics = {
		label				= TranslateCap('cosmetics'),
		parent				= 'main',
		bodyparts			= TranslateCap('bodyparts'),
		windowTint			= TranslateCap('windowtint'),
		modHorns			= TranslateCap('horns'),
		neonColor			= TranslateCap('neons'),
		resprays			= TranslateCap('respray'),
		modXenon			= TranslateCap('headlights'),
		plateIndex			= TranslateCap('licenseplates'),
		wheels				= TranslateCap('wheels'),
		modPlateHolder		= TranslateCap('modplateholder'),
		modVanityPlate		= TranslateCap('modvanityplate'),
		modTrimA			= TranslateCap('interior'),
		modOrnaments		= TranslateCap('trim'),
		modDashboard		= TranslateCap('dashboard'),
		modDial				= TranslateCap('speedometer'),
		modDoorSpeaker		= TranslateCap('door_speakers'),
		modSeats			= TranslateCap('seats'),
		modSteeringWheel	= TranslateCap('steering_wheel'),
		modShifterLeavers	= TranslateCap('gear_lever'),
		modAPlate			= TranslateCap('quarter_deck'),
		modSpeakers			= TranslateCap('speakers'),
		modTrunk			= TranslateCap('trunk'),
		modHydrolic			= TranslateCap('hydraulic'),
		modEngineBlock		= TranslateCap('engine_block'),
		modAirFilter		= TranslateCap('air_filter'),
		modStruts			= TranslateCap('struts'),
		modArchCover		= TranslateCap('arch_cover'),
		modAerials			= TranslateCap('aerials'),
		modTrimB			= TranslateCap('wings'),
		modTank				= TranslateCap('fuel_tank'),
		modWindows			= TranslateCap('windows'),
		modLivery			= TranslateCap('stickers')
	},

	modPlateHolder = {
		label = TranslateCap('modplateholder'),
		parent = 'cosmetics',
		modType = 25,
		price = 3.49
	},
	modVanityPlate = {
		label = TranslateCap('modvanityplate'),
		parent = 'cosmetics',
		modType = 26,
		price = 1.1
	},
	modTrimA = {
		label = TranslateCap('interior'),
		parent = 'cosmetics',
		modType = 27,
		price = 6.98
	},
	modOrnaments = {
		label = TranslateCap('trim'),
		parent = 'cosmetics',
		modType = 28,
		price = 0.9
	},
	modDashboard = {
		label = TranslateCap('dashboard'),
		parent = 'cosmetics',
		modType = 29,
		price = 4.65
	},
	modDial = {
		label = TranslateCap('speedometer'),
		parent = 'cosmetics',
		modType = 30,
		price = 4.19
	},
	modDoorSpeaker = {
		label = TranslateCap('door_speakers'),
		parent = 'cosmetics',
		modType = 31,
		price = 5.58
	},
	modSeats = {
		label = TranslateCap('seats'),
		parent = 'cosmetics',
		modType = 32,
		price = 4.65
	},
	modSteeringWheel = {
		label = TranslateCap('steering_wheel'),
		parent = 'cosmetics',
		modType = 33,
		price = 4.19
	},
	modShifterLeavers = {
		label = TranslateCap('gear_lever'),
		parent = 'cosmetics',
		modType = 34,
		price = 3.26
	},
	modAPlate = {
		label = TranslateCap('quarter_deck'),
		parent = 'cosmetics',
		modType = 35,
		price = 4.19
	},
	modSpeakers = {
		label = TranslateCap('speakers'),
		parent = 'cosmetics',
		modType = 36,
		price = 6.98
	},
	modTrunk = {
		label = TranslateCap('trunk'),
		parent = 'cosmetics',
		modType = 37,
		price = 5.58
	},
	modHydrolic = {
		label = TranslateCap('hydraulic'),
		parent = 'cosmetics',
		modType = 38,
		price = 5.12
	},
	modEngineBlock = {
		label = TranslateCap('engine_block'),
		parent = 'cosmetics',
		modType = 39,
		price = 5.12
	},
	modAirFilter = {
		label = TranslateCap('air_filter'),
		parent = 'cosmetics',
		modType = 40,
		price = 3.72
	},
	modStruts = {
		label = TranslateCap('struts'),
		parent = 'cosmetics',
		modType = 41,
		price = 6.51
	},
	modArchCover = {
		label = TranslateCap('arch_cover'),
		parent = 'cosmetics',
		modType = 42,
		price = 4.19
	},
	modAerials = {
		label = TranslateCap('aerials'),
		parent = 'cosmetics',
		modType = 43,
		price = 1.12
	},
	modTrimB = {
		label = TranslateCap('wings'),
		parent = 'cosmetics',
		modType = 44,
		price = 6.05
	},
	modTank = {
		label = TranslateCap('fuel_tank'),
		parent = 'cosmetics',
		modType = 45,
		price = 4.19
	},
	modWindows = {
		label = TranslateCap('windows'),
		parent = 'cosmetics',
		modType = 46,
		price = 4.19
	},
	modLivery = {
		label = TranslateCap('stickers'),
		parent = 'cosmetics',
		modType = 48,
		price = 9.3
	},

	wheels = {
		label = TranslateCap('wheels'),
		parent = 'cosmetics',
		modFrontWheelsTypes = TranslateCap('wheel_type'),
		modFrontWheelsColor = TranslateCap('wheel_color'),
		tyreSmokeColor = TranslateCap('tiresmoke')
	},
	modFrontWheelsTypes = {
		label				= TranslateCap('wheel_type'),
		parent				= 'wheels',
		modFrontWheelsType0	= TranslateCap('sport'),
		modFrontWheelsType1	= TranslateCap('muscle'),
		modFrontWheelsType2	= TranslateCap('lowrider'),
		modFrontWheelsType3	= TranslateCap('suv'),
		modFrontWheelsType4	= TranslateCap('allterrain'),
		modFrontWheelsType5	= TranslateCap('tuning'),
		modFrontWheelsType6	= TranslateCap('motorcycle'),
		modFrontWheelsType7	= TranslateCap('highend')
	},
	modFrontWheelsType0 = {
		label = TranslateCap('sport'),
		parent = 'modFrontWheelsTypes',
		modType = 23,
		wheelType = 0,
		price = 4.65
	},
	modFrontWheelsType1 = {
		label = TranslateCap('muscle'),
		parent = 'modFrontWheelsTypes',
		modType = 23,
		wheelType = 1,
		price = 4.19
	},
	modFrontWheelsType2 = {
		label = TranslateCap('lowrider'),
		parent = 'modFrontWheelsTypes',
		modType = 23,
		wheelType = 2,
		price = 4.65
	},
	modFrontWheelsType3 = {
		label = TranslateCap('suv'),
		parent = 'modFrontWheelsTypes',
		modType = 23,
		wheelType = 3,
		price = 4.19
	},
	modFrontWheelsType4 = {
		label = TranslateCap('allterrain'),
		parent = 'modFrontWheelsTypes',
		modType = 23,
		wheelType = 4,
		price = 4.19
	},
	modFrontWheelsType5 = {
		label = TranslateCap('tuning'),
		parent = 'modFrontWheelsTypes',
		modType = 23,
		wheelType = 5,
		price = 5.12
	},
	modFrontWheelsType6 = {
		label = TranslateCap('motorcycle'),
		parent = 'modFrontWheelsTypes',
		modType = 23,
		wheelType = 6,
		price = 3.26
	},
	modFrontWheelsType7 = {
		label = TranslateCap('highend'),
		parent = 'modFrontWheelsTypes',
		modType = 23,
		wheelType = 7,
		price = 5.12
	},
	modFrontWheelsColor = {
		label = TranslateCap('wheel_color'),
		parent = 'wheels'
	},
	wheelColor = {
		label = TranslateCap('wheel_color'),
		parent = 'modFrontWheelsColor',
		modType = 'wheelColor',
		price = 0.66
	},
	plateIndex = {
		label = TranslateCap('licenseplates'),
		parent = 'cosmetics',
		modType = 'plateIndex',
		price = 1.1
	},
	resprays = {
		label = TranslateCap('respray'),
		parent = 'cosmetics',
		primaryRespray = TranslateCap('primary'),
		secondaryRespray = TranslateCap('secondary'),
		pearlescentRespray = TranslateCap('pearlescent'),
	},
	primaryRespray = {
		label = TranslateCap('primary'),
		parent = 'resprays',
	},
	secondaryRespray = {
		label = TranslateCap('secondary'),
		parent = 'resprays',
	},
	pearlescentRespray = {
		label = TranslateCap('pearlescent'),
		parent = 'resprays',
	},
	color1 = {
		label = TranslateCap('primary'),
		parent = 'primaryRespray',
		modType = 'color1',
		price = 1.12
	},
	color2 = {
		label = TranslateCap('secondary'),
		parent = 'secondaryRespray',
		modType = 'color2',
		price = 0.66
	},
	pearlescentColor = {
		label = TranslateCap('pearlescent'),
		parent = 'pearlescentRespray',
		modType = 'pearlescentColor',
		price = 0.88
	},
	modXenon = {
		label = TranslateCap('headlights'),
		parent = 'cosmetics',
		modType = 22,
		price = 3.72
	},
	bodyparts = {
		label = TranslateCap('bodyparts'),
		parent = 'cosmetics',
		modFender = TranslateCap('leftfender'),
		modRightFender = TranslateCap('rightfender'),
		modSpoilers = TranslateCap('spoilers'),
		modSideSkirt = TranslateCap('sideskirt'),
		modFrame = TranslateCap('cage'),
		modHood = TranslateCap('hood'),
		modGrille = TranslateCap('grille'),
		modRearBumper = TranslateCap('rearbumper'),
		modFrontBumper = TranslateCap('frontbumper'),
		modExhaust = TranslateCap('exhaust'),
		modRoof = TranslateCap('roof')
	},
	modSpoilers = {
		label = TranslateCap('spoilers'),
		parent = 'bodyparts',
		modType = 0,
		price = 4.65
	},
	modFrontBumper = {
		label = TranslateCap('frontbumper'),
		parent = 'bodyparts',
		modType = 1,
		price = 5.12
	},
	modRearBumper = {
		label = TranslateCap('rearbumper'),
		parent = 'bodyparts',
		modType = 2,
		price = 5.12
	},
	modSideSkirt = {
		label = TranslateCap('sideskirt'),
		parent = 'bodyparts',
		modType = 3,
		price = 4.65
	},
	modExhaust = {
		label = TranslateCap('exhaust'),
		parent = 'bodyparts',
		modType = 4,
		price = 5.12
	},
	modFrame = {
		label = TranslateCap('cage'),
		parent = 'bodyparts',
		modType = 5,
		price = 5.12
	},
	modGrille = {
		label = TranslateCap('grille'),
		parent = 'bodyparts',
		modType = 6,
		price = 3.72
	},
	modHood = {
		label = TranslateCap('hood'),
		parent = 'bodyparts',
		modType = 7,
		price = 4.88
	},
	modFender = {
		label = TranslateCap('leftfender'),
		parent = 'bodyparts',
		modType = 8,
		price = 5.12
	},
	modRightFender = {
		label = TranslateCap('rightfender'),
		parent = 'bodyparts',
		modType = 9,
		price = 5.12
	},
	modRoof = {
		label = TranslateCap('roof'),
		parent = 'bodyparts',
		modType = 10,
		price = 5.58
	},
	windowTint = {
		label = TranslateCap('windowtint'),
		parent = 'cosmetics',
		modType = 'windowTint',
		price = 1.12
	},
	modHorns = {
		label = TranslateCap('horns'),
		parent = 'cosmetics',
		modType = 14,
		price = 1.12
	},
	neonColor = {
		label = TranslateCap('neons'),
		parent = 'cosmetics',
		modType = 'neonColor',
		price = 1.12
	},
	tyreSmokeColor = {
		label = TranslateCap('tiresmoke'),
		parent = 'wheels',
		modType = 'tyreSmokeColor',
		price = 1.12
	}

}
