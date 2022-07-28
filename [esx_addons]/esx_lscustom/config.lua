Config                   = {}
Config.DrawDistance      = 10.0
Config.Locale            = 'en'
Config.IsMechanicJobOnly = false

Config.Zones = {

	ls1 = {
		Pos   = { x = -337.38, y = -136.92, z = 38.57},
		Size  = {x = 3.0, y = 3.0, z = 0.2},
		Color = {r = 204, g = 204, b = 0},
		Marker= 1,
		Name  = _U('blip_name'),
		Hint  = _U('press_custom')
	},

	ls2 = {
		Pos   = { x = -1155.53, y = -2007.18, z = 12.74},
		Size  = {x = 3.0, y = 3.0, z = 0.2},
		Color = {r = 204, g = 204, b = 0},
		Marker= 1,
		Name  = _U('blip_name'),
		Hint  = _U('press_custom')
	},

	ls3 = {
		Pos   = { x = 731.81, y = -1088.82, z = 21.73},
		Size  = {x = 3.0, y = 3.0, z = 0.2},
		Color = {r = 204, g = 204, b = 0},
		Marker= 1,
		Name  = _U('blip_name'),
		Hint  = _U('press_custom')
	},

	ls4 = {
		Pos   = { x = 1175.04, y = 2640.21, z = 37.32},
		Size  = {x = 3.0, y = 3.0, z = 0.2},
		Color = {r = 204, g = 204, b = 0},
		Marker= 1,
		Name  = _U('blip_name'),
		Hint  = _U('press_custom')
	},

	ls5 = {
		Pos   = { x = 110.99, y = 6626.39, z = 30.89},
		Size  = {x = 3.0, y = 3.0, z = 0.2},
		Color = {r = 204, g = 204, b = 0},
		Marker= 1,
		Name  = _U('blip_name'),
		Hint  = _U('press_custom')
	}

}

Config.Colors = {
	{label = _U('black'), value = 'black'},
	{label = _U('white'), value = 'white'},
	{label = _U('grey'), value = 'grey'},
	{label = _U('red'), value = 'red'},
	{label = _U('pink'), value = 'pink'},
	{label = _U('blue'), value = 'blue'},
	{label = _U('yellow'), value = 'yellow'},
	{label = _U('green'), value = 'green'},
	{label = _U('orange'), value = 'orange'},
	{label = _U('brown'), value = 'brown'},
	{label = _U('purple'), value = 'purple'},
	{label = _U('chrome'), value = 'chrome'},
	{label = _U('gold'), value = 'gold'}
}

function GetColors(color)
	local colors = {}
	if color == 'black' then
		colors = {
			{ index = 0, label = _U('black')},
			{ index = 1, label = _U('graphite')},
			{ index = 2, label = _U('black_metallic')},
			{ index = 3, label = _U('caststeel')},
			{ index = 11, label = _U('black_anth')},
			{ index = 12, label = _U('matteblack')},
			{ index = 15, label = _U('darknight')},
			{ index = 16, label = _U('deepblack')},
			{ index = 21, label = _U('oil')},
			{ index = 147, label = _U('carbon')}
		}
	elseif color == 'white' then
		colors = {
			{ index = 106, label = _U('vanilla')},
			{ index = 107, label = _U('creme')},
			{ index = 111, label = _U('white')},
			{ index = 112, label = _U('polarwhite')},
			{ index = 113, label = _U('beige')},
			{ index = 121, label = _U('mattewhite')},
			{ index = 122, label = _U('snow')},
			{ index = 131, label = _U('cotton')},
			{ index = 132, label = _U('alabaster')},
			{ index = 134, label = _U('purewhite')}
		}
	elseif color == 'grey' then
		colors = {
			{ index = 4, label = _U('silver')},
			{ index = 5, label = _U('metallicgrey')},
			{ index = 6, label = _U('laminatedsteel')},
			{ index = 7, label = _U('darkgray')},
			{ index = 8, label = _U('rockygray')},
			{ index = 9, label = _U('graynight')},
			{ index = 10, label = _U('aluminum')},
			{ index = 13, label = _U('graymat')},
			{ index = 14, label = _U('lightgrey')},
			{ index = 17, label = _U('asphaltgray')},
			{ index = 18, label = _U('grayconcrete')},
			{ index = 19, label = _U('darksilver')},
			{ index = 20, label = _U('magnesite')},
			{ index = 22, label = _U('nickel')},
			{ index = 23, label = _U('zinc')},
			{ index = 24, label = _U('dolomite')},
			{ index = 25, label = _U('bluesilver')},
			{ index = 26, label = _U('titanium')},
			{ index = 66, label = _U('steelblue')},
			{ index = 93, label = _U('champagne')},
			{ index = 144, label = _U('grayhunter')},
			{ index = 156, label = _U('grey')}
		}
	elseif color == 'red' then
		colors = {
			{ index = 27, label = _U('red')},
			{ index = 28, label = _U('torino_red')},
			{ index = 29, label = _U('poppy')},
			{ index = 30, label = _U('copper_red')},
			{ index = 31, label = _U('cardinal')},
			{ index = 32, label = _U('brick')},
			{ index = 33, label = _U('garnet')},
			{ index = 34, label = _U('cabernet')},
			{ index = 35, label = _U('candy')},
			{ index = 39, label = _U('matte_red')},
			{ index = 40, label = _U('dark_red')},
			{ index = 43, label = _U('red_pulp')},
			{ index = 44, label = _U('bril_red')},
			{ index = 46, label = _U('pale_red')},
			{ index = 143, label = _U('wine_red')},
			{ index = 150, label = _U('volcano')}
		}
	elseif color == 'pink' then
		colors = {
			{ index = 135, label = _U('electricpink')},
			{ index = 136, label = _U('salmon')},
			{ index = 137, label = _U('sugarplum')}
		}
	elseif color == 'blue' then
		colors = {
			{ index = 54, label = _U('topaz')},
			{ index = 60, label = _U('light_blue')},
			{ index = 61, label = _U('galaxy_blue')},
			{ index = 62, label = _U('dark_blue')},
			{ index = 63, label = _U('azure')},
			{ index = 64, label = _U('navy_blue')},
			{ index = 65, label = _U('lapis')},
			{ index = 67, label = _U('blue_diamond')},
			{ index = 68, label = _U('surfer')},
			{ index = 69, label = _U('pastel_blue')},
			{ index = 70, label = _U('celeste_blue')},
			{ index = 73, label = _U('rally_blue')},
			{ index = 74, label = _U('blue_paradise')},
			{ index = 75, label = _U('blue_night')},
			{ index = 77, label = _U('cyan_blue')},
			{ index = 78, label = _U('cobalt')},
			{ index = 79, label = _U('electric_blue')},
			{ index = 80, label = _U('horizon_blue')},
			{ index = 82, label = _U('metallic_blue')},
			{ index = 83, label = _U('aquamarine')},
			{ index = 84, label = _U('blue_agathe')},
			{ index = 85, label = _U('zirconium')},
			{ index = 86, label = _U('spinel')},
			{ index = 87, label = _U('tourmaline')},
			{ index = 127, label = _U('paradise')},
			{ index = 140, label = _U('bubble_gum')},
			{ index = 141, label = _U('midnight_blue')},
			{ index = 146, label = _U('forbidden_blue')},
			{ index = 157, label = _U('glacier_blue')}
		}
	elseif color == 'yellow' then
		colors = {
			{ index = 42, label = _U('yellow')},
			{ index = 88, label = _U('wheat')},
			{ index = 89, label = _U('raceyellow')},
			{ index = 91, label = _U('paleyellow')},
			{ index = 126, label = _U('lightyellow')}
		}
	elseif color == 'green' then
		colors = {
			{ index = 49, label = _U('met_dark_green')},
			{ index = 50, label = _U('rally_green')},
			{ index = 51, label = _U('pine_green')},
			{ index = 52, label = _U('olive_green')},
			{ index = 53, label = _U('light_green')},
			{ index = 55, label = _U('lime_green')},
			{ index = 56, label = _U('forest_green')},
			{ index = 57, label = _U('lawn_green')},
			{ index = 58, label = _U('imperial_green')},
			{ index = 59, label = _U('green_bottle')},
			{ index = 92, label = _U('citrus_green')},
			{ index = 125, label = _U('green_anis')},
			{ index = 128, label = _U('khaki')},
			{ index = 133, label = _U('army_green')},
			{ index = 151, label = _U('dark_green')},
			{ index = 152, label = _U('hunter_green')},
			{ index = 155, label = _U('matte_foilage_green')}
		}
	elseif color == 'orange' then
		colors = {
			{ index = 36, label = _U('tangerine')},
			{ index = 38, label = _U('orange')},
			{ index = 41, label = _U('matteorange')},
			{ index = 123, label = _U('lightorange')},
			{ index = 124, label = _U('peach')},
			{ index = 130, label = _U('pumpkin')},
			{ index = 138, label = _U('orangelambo')}
		}
	elseif color == 'brown' then
		colors = {
			{ index = 45, label = _U('copper')},
			{ index = 47, label = _U('lightbrown')},
			{ index = 48, label = _U('darkbrown')},
			{ index = 90, label = _U('bronze')},
			{ index = 94, label = _U('brownmetallic')},
			{ index = 95, label = _U('expresso')},
			{ index = 96, label = _U('chocolate')},
			{ index = 97, label = _U('terracotta')},
			{ index = 98, label = _U('marble')},
			{ index = 99, label = _U('sand')},
			{ index = 100, label = _U('sepia')},
			{ index = 101, label = _U('bison')},
			{ index = 102, label = _U('palm')},
			{ index = 103, label = _U('caramel')},
			{ index = 104, label = _U('rust')},
			{ index = 105, label = _U('chestnut')},
			{ index = 108, label = _U('brown')},
			{ index = 109, label = _U('hazelnut')},
			{ index = 110, label = _U('shell')},
			{ index = 114, label = _U('mahogany')},
			{ index = 115, label = _U('cauldron')},
			{ index = 116, label = _U('blond')},
			{ index = 129, label = _U('gravel')},
			{ index = 153, label = _U('darkearth')},
			{ index = 154, label = _U('desert')}
		}
	elseif color == 'purple' then
		colors = {
			{ index = 71, label = _U('indigo')},
			{ index = 72, label = _U('deeppurple')},
			{ index = 76, label = _U('darkviolet')},
			{ index = 81, label = _U('amethyst')},
			{ index = 142, label = _U('mysticalviolet')},
			{ index = 145, label = _U('purplemetallic')},
			{ index = 148, label = _U('matteviolet')},
			{ index = 149, label = _U('mattedeeppurple')}
		}
	elseif color == 'chrome' then
		colors = {
			{ index = 117, label = _U('brushedchrome')},
			{ index = 118, label = _U('blackchrome')},
			{ index = 119, label = _U('brushedaluminum')},
			{ index = 120, label = _U('chrome')}
		}
	elseif color == 'gold' then
		colors = {
			{ index = 37, label = _U('gold')},
			{ index = 158, label = _U('puregold')},
			{ index = 159, label = _U('brushedgold')},
			{ index = 160, label = _U('lightgold')}
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
		{label = _U('white'),		r = 255, 	g = 255, 	b = 255},
		{label = "Slate Gray",		r = 112, 	g = 128, 	b = 144},
		{label = "Blue",			r = 0, 		g = 0, 		b = 255},
		{label = "Light Blue",		r = 0, 		g = 150, 	b = 255},
		{label = "Navy Blue", 		r = 0, 		g = 0, 		b = 128},
		{label = "Sky Blue", 		r = 135, 	g = 206, 	b = 235},
		{label = "Turquoise", 		r = 0, 		g = 245, 	b = 255},
		{label = "Mint Green", 	r = 50, 	g = 255, 	b = 155},
		{label = "Lime Green", 	r = 0, 		g = 255, 	b = 0},
		{label = "Olive", 			r = 128, 	g = 128, 	b = 0},
		{label = _U('yellow'), 	r = 255, 	g = 255, 	b = 0},
		{label = _U('gold'), 		r = 255, 	g = 215, 	b = 0},
		{label = _U('orange'), 	r = 255, 	g = 165, 	b = 0},
		{label = _U('wheat'), 		r = 245, 	g = 222, 	b = 179},
		{label = _U('red'), 		r = 255, 	g = 0, 		b = 0},
		{label = _U('pink'), 		r = 255, 	g = 161, 	b = 211},
		{label = _U('brightpink'),	r = 255, 	g = 0, 		b = 255},
		{label = _U('purple'), 	r = 153, 	g = 0, 		b = 153},
		{label = "Ivory", 			r = 41, 	g = 36, 	b = 33}
	}

	return neons
end

function GetPlatesName(index)
	if (index == 0) then
		return _U('blue_on_white_1')
	elseif (index == 1) then
		return _U('yellow_on_black')
	elseif (index == 2) then
		return _U('yellow_blue')
	elseif (index == 3) then
		return _U('blue_on_white_2')
	elseif (index == 4) then
		return _U('blue_on_white_3')
	end
end

Config.Menus = {
	main = {
		label		= 'LS CUSTOMS',
		parent		= nil,
		upgrades	= _U('upgrades'),
		cosmetics	= _U('cosmetics')
	},
	upgrades = {
		label			= _U('upgrades'),
		parent			= 'main',
		modEngine		= _U('engine'),
		modBrakes		= _U('brakes'),
		modTransmission	= _U('transmission'),
		modSuspension	= _U('suspension'),
		modArmor		= _U('armor'),
		modTurbo		= _U('turbo')
	},
	modEngine = {
		label = _U('engine'),
		parent = 'upgrades',
		modType = 11,
		price = {13.95, 32.56, 65.12, 139.53}
	},
	modBrakes = {
		label = _U('brakes'),
		parent = 'upgrades',
		modType = 12,
		price = {4.65, 9.3, 18.6, 13.95}
	},
	modTransmission = {
		label = _U('transmission'),
		parent = 'upgrades',
		modType = 13,
		price = {13.95, 20.93, 46.51}
	},
	modSuspension = {
		label = _U('suspension'),
		parent = 'upgrades',
		modType = 15,
		price = {3.72, 7.44, 14.88, 29.77, 40.2}
	},
	modArmor = {
		label = _U('armor'),
		parent = 'upgrades',
		modType = 16,
		price = {69.77, 116.28, 130.00, 150.00, 180.00, 190.00}
	},
	modTurbo = {
		label = _U('turbo'),
		parent = 'upgrades',
		modType = 17,
		price = {55.81}
	},
	cosmetics = {
		label				= _U('cosmetics'),
		parent				= 'main',
		bodyparts			= _U('bodyparts'),
		windowTint			= _U('windowtint'),
		modHorns			= _U('horns'),
		neonColor			= _U('neons'),
		resprays			= _U('respray'),
		modXenon			= _U('headlights'),
		plateIndex			= _U('licenseplates'),
		wheels				= _U('wheels'),
		modPlateHolder		= _U('modplateholder'),
		modVanityPlate		= _U('modvanityplate'),
		modTrimA			= _U('interior'),
		modOrnaments		= _U('trim'),
		modDashboard		= _U('dashboard'),
		modDial				= _U('speedometer'),
		modDoorSpeaker		= _U('door_speakers'),
		modSeats			= _U('seats'),
		modSteeringWheel	= _U('steering_wheel'),
		modShifterLeavers	= _U('gear_lever'),
		modAPlate			= _U('quarter_deck'),
		modSpeakers			= _U('speakers'),
		modTrunk			= _U('trunk'),
		modHydrolic			= _U('hydraulic'),
		modEngineBlock		= _U('engine_block'),
		modAirFilter		= _U('air_filter'),
		modStruts			= _U('struts'),
		modArchCover		= _U('arch_cover'),
		modAerials			= _U('aerials'),
		modTrimB			= _U('wings'),
		modTank				= _U('fuel_tank'),
		modWindows			= _U('windows'),
		modLivery			= _U('stickers')
	},

	modPlateHolder = {
		label = _U('modplateholder'),
		parent = 'cosmetics',
		modType = 25,
		price = 3.49
	},
	modVanityPlate = {
		label = _U('modvanityplate'),
		parent = 'cosmetics',
		modType = 26,
		price = 1.1
	},
	modTrimA = {
		label = _U('interior'),
		parent = 'cosmetics',
		modType = 27,
		price = 6.98
	},
	modOrnaments = {
		label = _U('trim'),
		parent = 'cosmetics',
		modType = 28,
		price = 0.9
	},
	modDashboard = {
		label = _U('dashboard'),
		parent = 'cosmetics',
		modType = 29,
		price = 4.65
	},
	modDial = {
		label = _U('speedometer'),
		parent = 'cosmetics',
		modType = 30,
		price = 4.19
	},
	modDoorSpeaker = {
		label = _U('door_speakers'),
		parent = 'cosmetics',
		modType = 31,
		price = 5.58
	},
	modSeats = {
		label = _U('seats'),
		parent = 'cosmetics',
		modType = 32,
		price = 4.65
	},
	modSteeringWheel = {
		label = _U('steering_wheel'),
		parent = 'cosmetics',
		modType = 33,
		price = 4.19
	},
	modShifterLeavers = {
		label = _U('gear_lever'),
		parent = 'cosmetics',
		modType = 34,
		price = 3.26
	},
	modAPlate = {
		label = _U('quarter_deck'),
		parent = 'cosmetics',
		modType = 35,
		price = 4.19
	},
	modSpeakers = {
		label = _U('speakers'),
		parent = 'cosmetics',
		modType = 36,
		price = 6.98
	},
	modTrunk = {
		label = _U('trunk'),
		parent = 'cosmetics',
		modType = 37,
		price = 5.58
	},
	modHydrolic = {
		label = _U('hydraulic'),
		parent = 'cosmetics',
		modType = 38,
		price = 5.12
	},
	modEngineBlock = {
		label = _U('engine_block'),
		parent = 'cosmetics',
		modType = 39,
		price = 5.12
	},
	modAirFilter = {
		label = _U('air_filter'),
		parent = 'cosmetics',
		modType = 40,
		price = 3.72
	},
	modStruts = {
		label = _U('struts'),
		parent = 'cosmetics',
		modType = 41,
		price = 6.51
	},
	modArchCover = {
		label = _U('arch_cover'),
		parent = 'cosmetics',
		modType = 42,
		price = 4.19
	},
	modAerials = {
		label = _U('aerials'),
		parent = 'cosmetics',
		modType = 43,
		price = 1.12
	},
	modTrimB = {
		label = _U('wings'),
		parent = 'cosmetics',
		modType = 44,
		price = 6.05
	},
	modTank = {
		label = _U('fuel_tank'),
		parent = 'cosmetics',
		modType = 45,
		price = 4.19
	},
	modWindows = {
		label = _U('windows'),
		parent = 'cosmetics',
		modType = 46,
		price = 4.19
	},
	modLivery = {
		label = _U('stickers'),
		parent = 'cosmetics',
		modType = 48,
		price = 9.3
	},

	wheels = {
		label = _U('wheels'),
		parent = 'cosmetics',
		modFrontWheelsTypes = _U('wheel_type'),
		modFrontWheelsColor = _U('wheel_color'),
		tyreSmokeColor = _U('tiresmoke')
	},
	modFrontWheelsTypes = {
		label				= _U('wheel_type'),
		parent				= 'wheels',
		modFrontWheelsType0	= _U('sport'),
		modFrontWheelsType1	= _U('muscle'),
		modFrontWheelsType2	= _U('lowrider'),
		modFrontWheelsType3	= _U('suv'),
		modFrontWheelsType4	= _U('allterrain'),
		modFrontWheelsType5	= _U('tuning'),
		modFrontWheelsType6	= _U('motorcycle'),
		modFrontWheelsType7	= _U('highend')
	},
	modFrontWheelsType0 = {
		label = _U('sport'),
		parent = 'modFrontWheelsTypes',
		modType = 23,
		wheelType = 0,
		price = 4.65
	},
	modFrontWheelsType1 = {
		label = _U('muscle'),
		parent = 'modFrontWheelsTypes',
		modType = 23,
		wheelType = 1,
		price = 4.19
	},
	modFrontWheelsType2 = {
		label = _U('lowrider'),
		parent = 'modFrontWheelsTypes',
		modType = 23,
		wheelType = 2,
		price = 4.65
	},
	modFrontWheelsType3 = {
		label = _U('suv'),
		parent = 'modFrontWheelsTypes',
		modType = 23,
		wheelType = 3,
		price = 4.19
	},
	modFrontWheelsType4 = {
		label = _U('allterrain'),
		parent = 'modFrontWheelsTypes',
		modType = 23,
		wheelType = 4,
		price = 4.19
	},
	modFrontWheelsType5 = {
		label = _U('tuning'),
		parent = 'modFrontWheelsTypes',
		modType = 23,
		wheelType = 5,
		price = 5.12
	},
	modFrontWheelsType6 = {
		label = _U('motorcycle'),
		parent = 'modFrontWheelsTypes',
		modType = 23,
		wheelType = 6,
		price = 3.26
	},
	modFrontWheelsType7 = {
		label = _U('highend'),
		parent = 'modFrontWheelsTypes',
		modType = 23,
		wheelType = 7,
		price = 5.12
	},
	modFrontWheelsColor = {
		label = _U('wheel_color'),
		parent = 'wheels'
	},
	wheelColor = {
		label = _U('wheel_color'),
		parent = 'modFrontWheelsColor',
		modType = 'wheelColor',
		price = 0.66
	},
	plateIndex = {
		label = _U('licenseplates'),
		parent = 'cosmetics',
		modType = 'plateIndex',
		price = 1.1
	},
	resprays = {
		label = _U('respray'),
		parent = 'cosmetics',
		primaryRespray = _U('primary'),
		secondaryRespray = _U('secondary'),
		pearlescentRespray = _U('pearlescent'),
	},
	primaryRespray = {
		label = _U('primary'),
		parent = 'resprays',
	},
	secondaryRespray = {
		label = _U('secondary'),
		parent = 'resprays',
	},
	pearlescentRespray = {
		label = _U('pearlescent'),
		parent = 'resprays',
	},
	color1 = {
		label = _U('primary'),
		parent = 'primaryRespray',
		modType = 'color1',
		price = 1.12
	},
	color2 = {
		label = _U('secondary'),
		parent = 'secondaryRespray',
		modType = 'color2',
		price = 0.66
	},
	pearlescentColor = {
		label = _U('pearlescent'),
		parent = 'pearlescentRespray',
		modType = 'pearlescentColor',
		price = 0.88
	},
	modXenon = {
		label = _U('headlights'),
		parent = 'cosmetics',
		modType = 22,
		price = 3.72
	},
	bodyparts = {
		label = _U('bodyparts'),
		parent = 'cosmetics',
		modFender = _U('leftfender'),
		modRightFender = _U('rightfender'),
		modSpoilers = _U('spoilers'),
		modSideSkirt = _U('sideskirt'),
		modFrame = _U('cage'),
		modHood = _U('hood'),
		modGrille = _U('grille'),
		modRearBumper = _U('rearbumper'),
		modFrontBumper = _U('frontbumper'),
		modExhaust = _U('exhaust'),
		modRoof = _U('roof')
	},
	modSpoilers = {
		label = _U('spoilers'),
		parent = 'bodyparts',
		modType = 0,
		price = 4.65
	},
	modFrontBumper = {
		label = _U('frontbumper'),
		parent = 'bodyparts',
		modType = 1,
		price = 5.12
	},
	modRearBumper = {
		label = _U('rearbumper'),
		parent = 'bodyparts',
		modType = 2,
		price = 5.12
	},
	modSideSkirt = {
		label = _U('sideskirt'),
		parent = 'bodyparts',
		modType = 3,
		price = 4.65
	},
	modExhaust = {
		label = _U('exhaust'),
		parent = 'bodyparts',
		modType = 4,
		price = 5.12
	},
	modFrame = {
		label = _U('cage'),
		parent = 'bodyparts',
		modType = 5,
		price = 5.12
	},
	modGrille = {
		label = _U('grille'),
		parent = 'bodyparts',
		modType = 6,
		price = 3.72
	},
	modHood = {
		label = _U('hood'),
		parent = 'bodyparts',
		modType = 7,
		price = 4.88
	},
	modFender = {
		label = _U('leftfender'),
		parent = 'bodyparts',
		modType = 8,
		price = 5.12
	},
	modRightFender = {
		label = _U('rightfender'),
		parent = 'bodyparts',
		modType = 9,
		price = 5.12
	},
	modRoof = {
		label = _U('roof'),
		parent = 'bodyparts',
		modType = 10,
		price = 5.58
	},
	windowTint = {
		label = _U('windowtint'),
		parent = 'cosmetics',
		modType = 'windowTint',
		price = 1.12
	},
	modHorns = {
		label = _U('horns'),
		parent = 'cosmetics',
		modType = 14,
		price = 1.12
	},
	neonColor = {
		label = _U('neons'),
		parent = 'cosmetics',
		modType = 'neonColor',
		price = 1.12
	},
	tyreSmokeColor = {
		label = _U('tiresmoke'),
		parent = 'wheels',
		modType = 'tyreSmokeColor',
		price = 1.12
	}

}
