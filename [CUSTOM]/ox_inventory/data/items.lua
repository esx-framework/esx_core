return {
	['bandage'] = {
		label = 'Bandage',
		weight = 115,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = true, car = true, combat = true },
			usetime = 2500,
		}
	},

	['black_money'] = {
		label = 'Dirty Money',
	},

	['burger'] = {
		label = 'Burger',
		weight = 220,
		client = {
			status = { hunger = 200000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
			prop = { model = `prop_cs_burger_01`, pos = vec3(0.02, 0.02, -0.02), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 2500,
		},
	},

	['testburger'] = {
		label = 'Test Burger',
		weight = 220,
		degrade = 60,
		limit = 3,
		client = {
			status = { hunger = 200000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
			prop = { model = `prop_cs_burger_01`, pos = vec3(0.02, 0.02, -0.02), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 2500,
		},
		server = {
			test = 'this is a test, yo'
		}
	},

	['cola'] = {
		label = 'eCola',
		weight = 350,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ecola_can`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
		}
	},

	['parachute'] = {
		label = 'Parachute',
		weight = 8000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 1500
		}
	},

	['garbage'] = {
		label = 'Garbage',
	},

	['paperbag'] = {
		label = 'Paper Bag',
		weight = 1,
		stack = false,
		close = false,
		consume = 0
	},

	['identification'] = {
		label = 'Identification',
	},

	['panties'] = {
		label = 'Knickers',
		weight = 10,
		consume = 0,
		client = {
			status = { thirst = -100000, stress = -25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
			usetime = 2500,
		}
	},

	['lockpick'] = {
		label = 'Lockpick',
		weight = 160,
		consume = 0,
		client = {
			anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechandplayer' },
			disable = { move = true, car = true, combat = true },
			usetime = 5000,
			cancel = true
		}
	},

	['phone'] = {
		label = 'Phone',
		weight = 190,
		stack = false,
		consume = 0,
		client = {
			usetime = 0,
			event = 'gcPhone:forceOpenPhone'
		}
	},

	['money'] = {
		label = 'Money',
	},

	['mustard'] = {
		label = 'Mustard',
		weight = 500,
		client = {
			status = { hunger = 25000, thirst = 25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
			usetime = 2500,
		}
	},

	['water'] = {
		label = 'Water',
		weight = 500,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			cancel = true
		}
	},

	['alive_chicken'] = {
		label = 'living chicken',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['bag'] = {
		label = 'bag',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['beer'] = {
		label = 'beer',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['blowpipe'] = {
		label = 'blowtorch',
		weight = 2,
		stack = true,
		close = true,
		description = ''
	},

	['bookmagic'] = {
		label = 'magic book',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['bookmagic2'] = {
		label = 'galactic book',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['bread'] = {
		label = 'bread',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['c4_bomb'] = {
		label = 'c4',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['cannabis'] = {
		label = 'cannabis',
		weight = 3,
		stack = true,
		close = true,
		description = ''
	},

	['car_keys'] = {
		label = 'vehicle key',
		weight = 0,
		stack = true,
		close = true,
		description = ''
	},

	['carokit'] = {
		label = 'body kit',
		weight = 3,
		stack = true,
		close = true,
		description = ''
	},

	['carotool'] = {
		label = 'tools',
		weight = 2,
		stack = true,
		close = true,
		description = ''
	},

	['cchip'] = {
		label = 'casino chips',
		weight = 0,
		stack = true,
		close = true,
		description = ''
	},

	['clothe'] = {
		label = 'cloth',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['coca'] = {
		label = 'coca raw',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['coca_seed'] = {
		label = 'coca seed',
		weight = 0,
		stack = true,
		close = true,
		description = ''
	},

	['cocaine'] = {
		label = 'cocaine',
		weight = 0,
		stack = true,
		close = true,
		description = ''
	},

	['cocaine_processing_table'] = {
		label = 'coke processing table',
		weight = 0,
		stack = true,
		close = true,
		description = ''
	},

	['coke_pooch'] = {
		label = 'coke pooch',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['contract'] = {
		label = 'contract',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['copper'] = {
		label = 'copper',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['cutted_wood'] = {
		label = 'cut wood',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['cutter'] = {
		label = 'cutter',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['diamond'] = {
		label = 'diamond',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['drill'] = {
		label = 'drill',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['essence'] = {
		label = 'gas',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['fabric'] = {
		label = 'fabric',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['fertilizer'] = {
		label = 'fertilizer',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['fish'] = {
		label = 'fish',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['fixkit'] = {
		label = 'repair kit',
		weight = 3,
		stack = true,
		close = true,
		description = ''
	},

	['fixtool'] = {
		label = 'repair tools',
		weight = 2,
		stack = true,
		close = true,
		description = ''
	},

	['gazbottle'] = {
		label = 'gas bottle',
		weight = 2,
		stack = true,
		close = true,
		description = ''
	},

	['gold'] = {
		label = 'gold',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['green_card'] = {
		label = 'green card',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['hack_usb'] = {
		label = 'hacking usb',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['iron'] = {
		label = 'iron',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['laptop'] = {
		label = 'laptop',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['marijuana'] = {
		label = 'marijuana',
		weight = 2,
		stack = true,
		close = true,
		description = ''
	},

	['medikit'] = {
		label = 'medikit',
		weight = 2,
		stack = true,
		close = true,
		description = ''
	},

	['ouija'] = {
		label = 'ouija',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['packaged_chicken'] = {
		label = 'chicken fillet',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['packaged_plank'] = {
		label = 'packaged wood',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['paintingf'] = {
		label = 'painting level 2',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['paintingg'] = {
		label = 'painting level 1',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['petrol'] = {
		label = 'oil',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['petrol_raffin'] = {
		label = 'processed oil',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['radio'] = {
		label = 'radio',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['slaughtered_chicken'] = {
		label = 'slaughtered chicken',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['stone'] = {
		label = 'stone',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['thermite_bomb'] = {
		label = 'thermite',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['uvlight'] = {
		label = 'uv flashlight',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['vanbottle'] = {
		label = 'antique bottle',
		weight = 0,
		stack = true,
		close = true,
		description = ''
	},

	['vandiamond'] = {
		label = 'diamond jewel',
		weight = 0,
		stack = true,
		close = true,
		description = ''
	},

	['vannecklace'] = {
		label = 'necklace',
		weight = 0,
		stack = true,
		close = true,
		description = ''
	},

	['vanpanther'] = {
		label = 'pink panther',
		weight = 0,
		stack = true,
		close = true,
		description = ''
	},

	['vanpogo'] = {
		label = 'gold statue',
		weight = 0,
		stack = true,
		close = true,
		description = ''
	},

	['washed_stone'] = {
		label = 'washed stone',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['weed_lemonhaze'] = {
		label = 'lemonhaze weed',
		weight = 0,
		stack = true,
		close = true,
		description = ''
	},

	['weed_lemonhaze_seed'] = {
		label = 'lemonhaze seed',
		weight = 0,
		stack = true,
		close = true,
		description = ''
	},

	['wood'] = {
		label = 'wood',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['wool'] = {
		label = 'wool',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['groupchat'] = {
		label = 'groupchat',
		weight = 0.2,
		stack = true,
		close = true,
		description = 'Group Chat UI'
	},

	['weed_pooch'] = {
		label = 'weed pooch',
		weight = 0,
		stack = true,
		close = true,
		description = ''
	},

	['weed_seed'] = {
		label = 'weed seed',
		weight = 0,
		stack = true,
		close = true,
		description = ''
	},
	['coca'] = {
		label = 'Cocaine',
		weight = 0,
		stack = true,
		close = true,
		description = ''
	},

	['coke_seed'] = {
		label = 'Coke seed',
		weight = 0,
		stack = true,
		close = true,
		description = ''
	},

	['water_bottle'] = {
		label = 'water bottle',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['weed_bananakush'] = {
		label = 'banana kush 2g',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['weed_bananakush_seed'] = {
		label = 'banana kush seed',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['weed_bluedream'] = {
		label = 'blue dream 2g',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['weed_bluedream_seed'] = {
		label = 'blue dream 2g',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['weed_og-kush'] = {
		label = 'ogkush 2g',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['weed_og-kush_seed'] = {
		label = 'ogkush seed',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['weed_purple-haze_seed'] = {
		label = 'purple haze 2g',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['weed_purplehaze'] = {
		label = 'purple haze 2g',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['id_card_f'] = {
		label = 'malicious access card',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['secure_card'] = {
		label = 'secure id card',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},
	['nitro'] = {
		label = 'NOS',
		weight = 1,
		stack = true,
		close = true,
		description = 'Vehicle Nitro'
	},

	['armor'] = {
		label = 'medium armor',
		weight = 1,
		stack = true,
		close = true,
		client = {
			disable = { move = true, car = true, combat = true },
			usetime = 2500,
		},
		description = ''
	},

	['heavyarmor'] = {
		label = 'heavy armor',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['lightarmor'] = {
		label = 'light armor',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},


	['dia_box'] = {
		label = 'diamond box',
		weight = 2,
		stack = true,
		close = true,
		description = ''
	},

	['gold_bar'] = {
		label = 'gold bar',
		weight = 2,
		stack = true,
		close = true,
		description = ''
	},

	['id_card'] = {
		label = 'id card',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['laptop_h'] = {
		label = 'hacker laptop',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['hacker_laptop'] = {
		label = 'hacker laptop',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['thermal_charge'] = {
		label = 'thermal charge',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['firework'] = {
		label = 'firework',
		weight = 5,
		stack = true,
		close = true,
		description = ''
	},

	['fireworks'] = {
		label = 'fireworks launcher',
		weight = 5,
		stack = true,
		close = true,
		description = ''
	},

	['blackphone'] = {
		label = 'blackphone',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['red_card'] = {
		label = 'Red Card',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},
	['trojan_usb'] = {
		label = 'Trojan USB',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},
	['hacking_device'] = {
		label = 'Hacking Device',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},
	['fake_plate'] = {
		label = 'Fake Plate',
		weight = 1,
		stack = true,
		close = true,
		description = ''
	},

	['golf'] = {
		label = 'golf ball',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['golf_green'] = {
		label = 'golf ball (green)',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['golf_pink'] = {
		label = 'golf ball (pink)',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['golf_yellow'] = {
		label = 'golf ball (yellow)',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['air_filter'] = {
		label = 'air filter',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['aluminum'] = {
		label = 'aluminium',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['awd'] = {
		label = 'awd',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['brake_caliper'] = {
		label = 'brake caliper',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['brake_discs'] = {
		label = 'brake discs',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['brake_pads'] = {
		label = 'brake pads',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['clutch'] = {
		label = 'clutch',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['fuel_filter'] = {
		label = 'fuel filter',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['fwd'] = {
		label = 'fwd',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['garett'] = {
		label = 'turbo',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['gear'] = {
		label = 'gear',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['nitrous'] = {
		label = 'nitro',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['oil'] = {
		label = 'oil',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['piston'] = {
		label = 'piston',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['race_brakes'] = {
		label = 'race brakes',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['rod'] = {
		label = 'rod',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['rwd'] = {
		label = 'rwd',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['semislick'] = {
		label = 'semi slick tires',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['serpentine_belt'] = {
		label = 'serpentine belt',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['shock_absorber'] = {
		label = 'shock absorber',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['slick'] = {
		label = 'slick tires',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['spark_plugs'] = {
		label = 'spark plugs',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['springs'] = {
		label = 'springs',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['susp'] = {
		label = 'very low suspension',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['susp1'] = {
		label = 'low suspension',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['susp2'] = {
		label = 'sport suspension',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['susp3'] = {
		label = 'comfort suspension',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['susp4'] = {
		label = 'high suspension',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['tires'] = {
		label = 'tires',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['transmission_oil'] = {
		label = 'transmission oil',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['2jzengine'] = {
		label = '2jz engine',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['mechanic_tools'] = {
		label = 'mechanic tools',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['michelin_tires'] = {
		label = 'michelin tires',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['race_suspension'] = {
		label = 'race suspension',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['race_transmition'] = {
		label = 'race transmition',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['toolbox'] = {
		label = 'tool box',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['turbo_lvl_1'] = {
		label = 'garet turbo',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['v8engine'] = {
		label = 'v8 engine',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['nos'] = {
		label = 'nitro',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['shell_oil'] = {
		label = 'shell oil',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['stock_brakes'] = {
		label = 'stock brakes',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['stock_engine'] = {
		label = 'stock engine',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['stock_oil'] = {
		label = 'stock oil',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['stock_suspension'] = {
		label = 'stock suspension',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['stock_tires'] = {
		label = 'stock tires',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},

	['stock_transmission'] = {
		label = 'stock transmission',
		weight = 1,
		stack = true,
		close = true,
		description = nil
	},
}