Config = {}

Config.Animations = {
	
	{
		name  = 'festives',
		label = 'Prazniki',
		items = {
	    	{label = "Smoke", type = "scenario", data = {anim = "WORLD_HUMAN_SMOKING"}},
	    	{label = "Musician", type = "scenario", data = {anim = "WORLD_HUMAN_MUSICIAN"}},
	    	{label = "Dj", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@dj", anim = "dj"}},
	    	{label = "Coffee", type = "scenario", data = {anim = "WORLD_HUMAN_DRINKING"}},
	    	{label = "Beer", type = "scenario", data = {anim = "WORLD_HUMAN_PARTYING"}},
	    	{label = "Air Guitar", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@air_guitar", anim = "air_guitar"}},
	    	{label = "Air Shagging", type = "anim", data = {lib = "anim@mp_player_intcelebrationfemale@air_shagging", anim = "air_shagging"}},
	    	{label = "Rock'n'roll", type = "anim", data = {lib = "mp_player_int_upperrock", anim = "mp_player_int_rock"}},
	    	-- {label = "Fumer un joint", type = "scenario", data = {anim = "WORLD_HUMAN_SMOKING_POT"}},
	    	{label = "Drunk Standing", type = "anim", data = {lib = "amb@world_human_bum_standing@drunk@idle_a", anim = "idle_a"}},
	    	{label = "Vomiting", type = "anim", data = {lib = "oddjobs@taxi@tie", anim = "vomit_outside"}},
		}
	},

	{
		name  = 'greetings',
		label = 'Pozdravi',
		items = {
	    	{label = "Hello", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_hello"}},
	    	{label = "Wave", type = "anim", data = {lib = "mp_common", anim = "givetake1_a"}},
	    	{label = "Handshake", type = "anim", data = {lib = "mp_ped_interaction", anim = "handshake_guy_a"}},
	    	{label = "Hugging", type = "anim", data = {lib = "mp_ped_interaction", anim = "hugs_guy_a"}},
	    	{label = "Salute", type = "anim", data = {lib = "mp_player_int_uppersalute", anim = "mp_player_int_salute"}},
		}
	},

	{
		name  = 'work',
		label = 'Sluzba',
		items = {
	    	{label = "Suspect : Surrender", type = "anim", data = {lib = "random@arrests@busted", anim = "idle_c"}},
	    	{label = "Fishing", type = "scenario", data = {anim = "world_human_stand_fishing"}},
	    	{label = "Police : Investigate", type = "anim", data = {lib = "amb@code_human_police_investigate@idle_b", anim = "idle_f"}},
	    	{label = "Police : Use Radio", type = "anim", data = {lib = "random@arrests", anim = "generic_radio_chatter"}},
	    	{label = "Police : Traffic", type = "scenario", data = {anim = "WORLD_HUMAN_CAR_PARK_ATTENDANT"}},
	    	{label = "Police : Binoculars", type = "scenario", data = {anim = "WORLD_HUMAN_BINOCULARS"}},
	    	{label = "Agriculture : Planting", type = "scenario", data = {anim = "world_human_gardener_plant"}},
	    	{label = "Mechanic : Fixing Motor", type = "anim", data = {lib = "mini@repair", anim = "fixing_a_ped"}},
	    	{label = "Medic : Kneel", type = "scenario", data = {anim = "CODE_HUMAN_MEDIC_KNEEL"}},
	    	{label = "Taxi : Talk to customer", type = "anim", data = {lib = "oddjobs@taxi@driver", anim = "leanover_idle"}},
	    	{label = "Taxi : Give bill", type = "anim", data = {lib = "oddjobs@taxi@cyi", anim = "std_hand_off_ps_passenger"}},
	    	{label = "Grocer : Give", type = "anim", data = {lib = "mp_am_hold_up", anim = "purchase_beerbox_shopkeeper"}},
	    	{label = "Barman : Serve Shot", type = "anim", data = {lib = "mini@drinking", anim = "shots_barman_b"}},
	    	{label = "Journalist : Take Photos", type = "scenario", data = {anim = "WORLD_HUMAN_PAPARAZZI"}},
	    	{label = "All Jobs : Clipboard", type = "scenario", data = {anim = "WORLD_HUMAN_CLIPBOARD"}},
	    	{label = "All Jobs : Hammering", type = "scenario", data = {anim = "WORLD_HUMAN_HAMMERING"}},
	    	{label = "Bum : Holding Sign", type = "scenario", data = {anim = "WORLD_HUMAN_BUM_FREEWAY"}},
	    	{label = "Bum : Human Statue", type = "scenario", data = {anim = "WORLD_HUMAN_HUMAN_STATUE"}},
		}
	},

	{
		name  = 'humors',
		label = 'Zabava',
		items = {
	    	{label = "Cheering", type = "scenario", data = {anim = "WORLD_HUMAN_CHEERING"}},
	    	{label = "Super", type = "anim", data = {lib = "mp_action", anim = "thanks_male_06"}},
	    	{label = "Point", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_point"}},
	    	{label = "Come here", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_come_here_soft"}}, 
	    	{label = "Bring it on", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_bring_it_on"}},
	    	{label = "Me", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_me"}},
	    	{label = "I knew it", type = "anim", data = {lib = "anim@am_hold_up@male", anim = "shoplift_high"}},
	    	{label = "Exhausted", type = "scenario", data = {lib = "amb@world_human_jog_standing@male@idle_b", anim = "idle_d"}},
	    	{label = "I'm the shit", type = "scenario", data = {lib = "amb@world_human_bum_standing@depressed@idle_a", anim = "idle_a"}},
	    	{label = "Facepalm", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@face_palm", anim = "face_palm"}},
	    	{label = "Calm down ", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_easy_now"}},
	    	{label = "What did I do?", type = "anim", data = {lib = "oddjobs@assassinate@multi@", anim = "react_big_variations_a"}},
	    	{label = "Fear", type = "anim", data = {lib = "amb@code_human_cower_stand@male@react_cowering", anim = "base_right"}},
	    	{label = "Fight ?", type = "anim", data = {lib = "anim@deathmatch_intros@unarmed", anim = "intro_male_unarmed_e"}},
	    	{label = "It's not possible !", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_damn"}},
	    	{label = "Embrace", type = "anim", data = {lib = "mp_ped_interaction", anim = "kisses_guy_a"}},
	    	{label = "Finger of honor", type = "anim", data = {lib = "mp_player_int_upperfinger", anim = "mp_player_int_finger_01_enter"}},
	    	{label = "You wanker", type = "anim", data = {lib = "mp_player_int_upperwank", anim = "mp_player_int_wank_01"}},
	    	{label = "Bullet in the head", type = "anim", data = {lib = "mp_suicide", anim = "pistol"}},
		}
	},

	{
		name  = 'sports',
		label = 'Sporti',
		items = {
	    	{label = "Flex muscles", type = "anim", data = {lib = "amb@world_human_muscle_flex@arms_at_side@base", anim = "base"}},
	    	{label = "Lift weights", type = "anim", data = {lib = "amb@world_human_muscle_free_weights@male@barbell@base", anim = "base"}},
	    	{label = "Do push ups", type = "anim", data = {lib = "amb@world_human_push_ups@male@base", anim = "base"}},
	    	{label = "Do sit ups", type = "anim", data = {lib = "amb@world_human_sit_ups@male@base", anim = "base"}},
	    	{label = "Do yoga", type = "anim", data = {lib = "amb@world_human_yoga@male@base", anim = "base_a"}},
		}
	},

	{
		name  = 'misc',
		label = 'Razno',
		items = {
	    	{label = "Drink coffee", type = "anim", data = {lib = "amb@world_human_aa_coffee@idle_a", anim = "idle_a"}},
	    	{label = "Sit", type = "anim", data = {lib = "anim@heists@prison_heistunfinished_biztarget_idle", anim = "target_idle"}},
	    	{label = "Lean against wall", type = "scenario", data = {anim = "world_human_leaning"}},
	    	{label = "Sunbathe Back", type = "scenario", data = {anim = "WORLD_HUMAN_SUNBATHE_BACK"}},
	    	{label = "Sunbathe Front", type = "scenario", data = {anim = "WORLD_HUMAN_SUNBATHE"}},
	    	{label = "Clean", type = "scenario", data = {anim = "world_human_maid_clean"}},
	    	{label = "BBQ", type = "scenario", data = {anim = "PROP_HUMAN_BBQ"}},
	    	{label = "Search", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_bj_to_prop_female"}},
	    	{label = "Take selfie", type = "scenario", data = {anim = "world_human_tourist_mobile"}},
	    	{label = "Listen to wall/door", type = "anim", data = {lib = "mini@safe_cracking", anim = "idle_base"}}, 
		}
	},

	{
		name  = 'attitudem',
		label = 'Stili hoje',
		items = {
	    	{label = "Normal M", type = "attitude", data = {lib = "move_m@confident", anim = "move_m@confident"}},
	    	{label = "Normal F", type = "attitude", data = {lib = "move_f@heels@c", anim = "move_f@heels@c"}},
	    	{label = "Depressed male", type = "attitude", data = {lib = "move_m@depressed@a", anim = "move_m@depressed@a"}},
	    	{label = "Depressed female", type = "attitude", data = {lib = "move_f@depressed@a", anim = "move_f@depressed@a"}},
	    	{label = "Business", type = "attitude", data = {lib = "move_m@business@a", anim = "move_m@business@a"}},
	    	{label = "Determined", type = "attitude", data = {lib = "move_m@brave@a", anim = "move_m@brave@a"}},
	    	{label = "Casual", type = "attitude", data = {lib = "move_m@casual@a", anim = "move_m@casual@a"}},
	    	{label = "Ate too much", type = "attitude", data = {lib = "move_m@fat@a", anim = "move_m@fat@a"}},
	    	{label = "Hipster", type = "attitude", data = {lib = "move_m@hipster@a", anim = "move_m@hipster@a"}},
	    	{label = "Injured", type = "attitude", data = {lib = "move_m@injured", anim = "move_m@injured"}},
	    	{label = "In a hurry", type = "attitude", data = {lib = "move_m@hurry@a", anim = "move_m@hurry@a"}},
	    	{label = "Hobo", type = "attitude", data = {lib = "move_m@hobo@a", anim = "move_m@hobo@a"}},
	    	{label = "sad", type = "attitude", data = {lib = "move_m@sad@a", anim = "move_m@sad@a"}},
	    	{label = "Muscle", type = "attitude", data = {lib = "move_m@muscle@a", anim = "move_m@muscle@a"}},
	    	{label = "Shocked", type = "attitude", data = {lib = "move_m@shocked@a", anim = "move_m@shocked@a"}},
	    	{label = "Being shady", type = "attitude", data = {lib = "move_m@shadyped@a", anim = "move_m@shadyped@a"}},
	    	{label = "Buzzed", type = "attitude", data = {lib = "move_m@buzzed", anim = "move_m@buzzed"}},
	    	{label = "Hurry", type = "attitude", data = {lib = "move_m@hurry_butch@a", anim = "move_m@hurry_butch@a"}},
	    	{label = "Proud", type = "attitude", data = {lib = "move_m@money", anim = "move_m@money"}},
	    	{label = "Short race", type = "attitude", data = {lib = "move_m@quick", anim = "move_m@quick"}},
	    	{label = "Man eater", type = "attitude", data = {lib = "move_f@maneater", anim = "move_f@maneater"}},
	    	{label = "Sassy", type = "attitude", data = {lib = "move_f@sassy", anim = "move_f@sassy"}},	
	    	{label = "Arrogant", type = "attitude", data = {lib = "move_f@arrogant@a", anim = "move_f@arrogant@a"}},
		}
	},
	{
		name  = 'porn',
		label = 'NSFW',
		items = {
	    	{label = "Man receiving in car", type = "anim", data = {lib = "oddjobs@towing", anim = "m_blow_job_loop"}},
	    	{label = "Woman giving in car", type = "anim", data = {lib = "oddjobs@towing", anim = "f_blow_job_loop"}},
	    	{label = "Man on bottom in car", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_sex_loop_player"}},
	    	{label = "Woman on top in car", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_sex_loop_female"}},
	    	{label = "Scratch nuts", type = "anim", data = {lib = "mp_player_int_uppergrab_crotch", anim = "mp_player_int_grab_crotch"}},
	    	{label = "Hooker 1", type = "anim", data = {lib = "mini@strip_club@idles@stripper", anim = "stripper_idle_02"}},
	    	{label = "Hooker 2", type = "scenario", data = {anim = "WORLD_HUMAN_PROSTITUTE_HIGH_CLASS"}},
	    	{label = "Hooker 3", type = "anim", data = {lib = "mini@strip_club@backroom@", anim = "stripper_b_backroom_idle_b"}},
	    	{label = "Strip Tease 1", type = "anim", data = {lib = "mini@strip_club@lap_dance@ld_girl_a_song_a_p1", anim = "ld_girl_a_song_a_p1_f"}},
	    	{label = "Strip Tease 2", type = "anim", data = {lib = "mini@strip_club@private_dance@part2", anim = "priv_dance_p2"}},
	    	{label = "Stip Tease On Knees", type = "anim", data = {lib = "mini@strip_club@private_dance@part3", anim = "priv_dance_p3"}},
			}
	},

}