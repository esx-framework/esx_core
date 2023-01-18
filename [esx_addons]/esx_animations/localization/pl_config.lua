Config = {} 

Config.Animations = {
	
	{
		name = 'festives',
		label = 'Imprezowe',
		items = {
			{label = "Graj na gitarze", type = "scenario", data = {anim = "WORLD_HUMAN_MUSICIAN"}},
			{label = "Dj", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@dj", anim = "dj"}},
			{label = "Picie piwa 'LEGALNIE'", type = "scenario", data = {anim = "WORLD_HUMAN_DRINKING"}},
			{label = "Picie piwa", type = "scenario", data = {anim = "WORLD_HUMAN_PARTYING"}},
			{label = "Udawanie gry na gitarze", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@air_guitar", anim = "air_guitar"}},
			{label = "Dokowanie", type = "anim", data = {lib = "anim@mp_player_intcelebrationfemale@air_shagging", anim = "air_shagging"}},
			{label = "Rock'n'roll", type = "anim", data = {lib = "mp_player_int_upperrock", anim = "mp_player_int_rock"}},
			-- {label = "Fumer un jo	int", type = "scenario", data = {anim = "WORLD_HUMAN_SMOKING_POT"}},
			{label = "Pijany", type = "anim", data = {lib = "amb@world_human_bum_standing@drunk@idle_a", anim = "idle_a"}},
			{label = "Wymiotowanie z auta", type = "anim", data = {lib = "oddjobs@taxi@tie", anim = "vomit_outside"}},
		}
	},

	{
		name = 'greetings',
		label = 'Przywitania',
		items = {
			{label = "Witaj", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_hello"}},
			{label = "Cześć", type = "anim", data = {lib = "mp_common", anim = "givetake1_a"}},
			{label = "Podaj reke", type = "anim", data = {lib = "mp_ped_interaction", anim = "handshake_guy_a"}},
			{label = "Gangsterskie", type = "anim", data = {lib = "mp_ped_interaction", anim = "hugs_guy_a"}},
			{label = "Saluuut", type = "anim", data = {lib = "mp_player_int_uppersalute", anim = "mp_player_int_salute"}},
		}
	},

	{
		name = 'work',
		label = 'Prace',
		items = {
			{label = "Na kolana", type = "anim", data = {lib = "random@arrests@busted", anim = "idle_c"}},
			{label = "Łow ryby", type = "scenario", data = {anim = "world_human_stand_fishing"}},
			{label = "Policja: sprawdź dowody", type = "anim", data = {lib = "amb@code_human_police_investigate@idle_b", anim = "idle_f"}},
			{label = "Policja: rozmowaij przez radio", type = "anim", data = {lib = "random@arrests", anim = "generic_radio_chatter"}},
			{label = "Policja: kieruj ruchem", type = "scenario", data = {anim = "WORLD_HUMAN_CAR_PARK_ATTENDANT"}},
			{label = "Użyj lornetki", type = "scenario", data = {anim = "WORLD_HUMAN_BINOCULARS"}},
			{label = "Wykopki", type = "scenario", data = {anim = "world_human_gardener_plant"}},
			{label = "Mechanik: sprawdź/napraw silnik", type = "anim", data = {lib = "mini@repair", anim = "fixing_a_ped"}},
			{label = "Medyk: sprawdź stan", type = "scenario", data = {anim = "CODE_HUMAN_MEDIC_KNEEL"}},
			{label = "Taxi: rozmawiaj z klientem", type = "anim", data = {lib = "oddjobs@taxi@driver", anim = "leanover_idle"}},
			{label = "Taxi : wystaw rachunek", type = "anim", data = {lib = "oddjobs@taxi@cyi", anim = "std_hand_off_ps_passenger"}},
			{label = "Załaduj towar", type = "anim", data = {lib = "mp_am_hold_up", anim = "purchase_beerbox_shopkeeper"}},
			{label = "Barman: polej kolejke", type = "anim", data = {lib = "mini@drinking", anim = "shots_barman_b"}},
			{label = "Redaktor: rób zdjęcia", type = "scenario", data = {anim = "WORLD_HUMAN_PAPARAZZI"}},
			{label = "Patrz w notatki", type = "scenario", data = {anim = "WORLD_HUMAN_CLIPBOARD"}},
			{label = "Jebaj młotkiem", type = "scenario", data = {anim = "WORLD_HUMAN_HAMMERING"}},
			{label = "Trzymaj kartke", type = "scenario", data = {anim = "WORLD_HUMAN_BUM_FREEWAY"}},
			{label = "Pozuj", type = "scenario", data = {anim = "WORLD_HUMAN_HUMAN_STATUE"}},
		}
	},

	{
		name = 'humors',
		label = 'Humor',
		items = {
			{label = "Klaskaj", type = "scenario", data = {anim = "WORLD_HUMAN_CHEERING"}},
			{label = "OK", type = "anim", data = {lib = "mp_action", anim = "thanks_male_06"}},
			{label = "Ty", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_point"}},
			{label = "Zawolaj", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_come_here_soft"}},
			{label = "O co cho??", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_bring_it_on"}},
			{label = "A moi", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_me"}},
			{label = "Mam to", type = "anim", data = {lib = "anim@am_hold_up@male", anim = "shoplift_high"}},
			{label = "BRAK!!!!!", type = "scenario", data = {lib = "amb@world_human_jog_standing@male@idle_b", anim = "idle_d"}},
			{label = "BRAK!!!!!", type = "scenario", data = {lib = "amb@world_human_bum_standing@depressed@idle_a", anim = "idle_a"}},
			{label = "Facepalm", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@face_palm", anim = "face_palm"}},
			{label = "Spokojnie ", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_easy_now"}},
			{label = "Zdziwienie", type = "anim", data = {lib = "oddjobs@assassinate@multi@", anim = "react_big_variations_a"}},
			{label = "Poddaj się", type = "anim", data = {lib = "amb@code_human_cower_stand@male@react_cowering", anim = "base_right"}},
			{label = "Przygotuj się do walki", type = "anim", data = {lib = "anim@deathmatch_intros@unarmed", anim = "intro_male_unarmed_e"}},
			{label = "Nie m ch**a", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_damn"}},
			{label = "Przytul", type = "anim", data = {lib = "mp_ped_interaction", anim = "kisses_guy_a"}},
			{label = "Zajeb fakera", type = "anim", data = {lib = "mp_player_int_upperfinger", anim = "mp_player_int_finger_01_enter"}},
			{label = "Marszcz freda", type = "anim", data = {lib = "mp_player_int_upperwank", anim = "mp_player_int_wank_01"}},
			{label = "Strzel sobie w głowe", type = "anim", data = {lib = "mp_suicide", anim = "pistol"}},
		}
	},

	{
		name = 'sports',
		label = 'Sport',
		items = {
			{label = "Napinaj miesnie", type = "anim", data = {lib = "amb@world_human_muscle_flex@arms_at_side@base", anim = "base"}},
			{label = "Wyciskaj sztange", type = "anim", data = {lib = "amb@world_human_muscle_free_weights@male@barbell@base", anim = "base"}},
			{label = "Pompuj", type = "anim", data = {lib = "amb@world_human_push_ups@male@base", anim = "base"}},
			{label = "Rob Brzuszki", type = "anim", data = {lib = "amb@world_human_sit_ups@male@base", anim = "base"}},
			{label = "Yoga", type = "anim", data = {lib = "amb@world_human_yoga@male@base", anim = "base_a"}},
		}
	},

	{
		name = 'misc',
		label = 'Inne',
		items = {
			{label = "Pij kawe", type = "anim", data = {lib = "amb@world_human_aa_coffee@idle_a", anim = "idle_a"}},
			{label = "Usiadz na krzesle", type = "anim", data = {lib = "anim@heists@prison_heistunfinished_biztarget_idle", anim = "target_idle"}},
			{label = "Przegladaj smartfon", type = "scenario", data = {anim = "world_human_leaning"}},
			{label = "Polóż się na ziemi", type = "scenario", data = {anim = "WORLD_HUMAN_SUNBATHE_BACK"}},
			{label = "Polóż się na ziemi na brzuchu", type = "scenario", data = {anim = "WORLD_HUMAN_SUNBATHE"}},
			{label = "Umyj", type = "scenario", data = {anim = "world_human_maid_clean"}},
			{label = "Smaż na grillu", type = "scenario", data = {anim = "PROP_HUMAN_BBQ"}},
			{label = "Pozuj: samolot", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_bj_to_prop_female"}},
			{label = "Rób selfie", type = "scenario", data = {anim = "world_human_tourist_mobile"}},
			{label = "Otwieraj sejf", type = "anim", data = {lib = "mini@safe_cracking", anim = "idle_base"}},
		}
	},

	{
		name  = 'attitudem',
		label = 'Zachowania',
		items = {
			{label = "Pewniak M", type = "attitude", data = {lib = "move_m@confident", anim = "move_m@confident"}},
			{label = "Pewniak K", type = "attitude", data = {lib = "move_f@heels@c", anim = "move_f@heels@c"}},
			{label = "Smutas M", type = "attitude", data = {lib = "move_m@depressed@a", anim = "move_m@depressed@a"}},
			{label = "Smutas K", type = "attitude", data = {lib = "move_f@depressed@a", anim = "move_f@depressed@a"}},
			{label = "Biznesman", type = "attitude", data = {lib = "move_m@business@a", anim = "move_m@business@a"}},
			{label = "Odważny", type = "attitude", data = {lib = "move_m@brave@a", anim = "move_m@brave@a"}},
			{label = "Luzak", type = "attitude", data = {lib = "move_m@casual@a", anim = "move_m@casual@a"}},
			{label = "Gruby", type = "attitude", data = {lib = "move_m@fat@a", anim = "move_m@fat@a"}},
			{label = "Hipster", type = "attitude", data = {lib = "move_m@hipster@a", anim = "move_m@hipster@a"}},
			{label = "Poszkodowany", type = "attitude", data = {lib = "move_m@injured", anim = "move_m@injured"}},
			{label = "W pośpiechu", type = "attitude", data = {lib = "move_m@hurry@a", anim = "move_m@hurry@a"}},
			{label = "Bezdomny", type = "attitude", data = {lib = "move_m@hobo@a", anim = "move_m@hobo@a"}},
			{label = "Smutny", type = "attitude", data = {lib = "move_m@sad@a", anim = "move_m@sad@a"}},
			{label = "Siłacz", type = "attitude", data = {lib = "move_m@muscle@a", anim = "move_m@muscle@a"}},
			{label = "Zszokowany", type = "attitude", data = {lib = "move_m@shocked@a", anim = "move_m@shocked@a"}},
			{label = "Podejrzany", type = "attitude", data = {lib = "move_m@shadyped@a", anim = "move_m@shadyped@a"}},
			{label = "Nabuzowany", type = "attitude", data = {lib = "move_m@buzzed", anim = "move_m@buzzed"}},
			{label = "W pośpiechu 2", type = "attitude", data = {lib = "move_m@hurry_butch@a", anim = "move_m@hurry_butch@a"}},
			{label = "Pieniądze", type = "attitude", data = {lib = "move_m@money", anim = "move_m@money"}},
			{label = "Szybki", type = "attitude", data = {lib = "move_m@quick", anim = "move_m@quick"}},
			{label = "Zjadacz", type = "attitude", data = {lib = "move_f@maneater", anim = "move_f@maneater"}},
			{label = "Impertynencki", type = "attitude", data = {lib = "move_f@sassy", anim = "move_f@sassy"}},	
			{label = "Arogancki", type = "attitude", data = {lib = "move_f@arrogant@a", anim = "move_f@arrogant@a"}},
		}
	},
	
	{
		name = 'porn',
		label = 'Wulgarne',
		items = {
			{label = "Głebokie gardlo", type = "anim", data = {lib = "oddjobs@towing", anim = "m_blow_job_loop"}},
			{label = "Rób loda", type = "anim", data = {lib = "oddjobs@towing", anim = "f_blow_job_loop"}},
			{label = "Zimny lokiec", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_sex_loop_player"}},
			{label = "Siadaj na berło", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_sex_loop_female"}},
			{label = "Drap sie po jajach", type = "anim", data = {lib = "mp_player_int_uppergrab_crotch", anim = "mp_player_int_grab_crotch"}},
			{label = "Uwodź", type = "anim", data = {lib = "mini@strip_club@idles@stripper", anim = "stripper_idle_02"}},
			{label = "Dziwka pali szluga", type = "scenario", data = {anim = "WORLD_HUMAN_PROSTITUTE_HIGH_CLASS"}},
			{label = "Machaj cyckami", type = "anim", data = {lib = "mini@strip_club@backroom@", anim = "stripper_b_backroom_idle_b"}},
			{label = "Strptiz", type = "anim", data = {lib = "mini@strip_club@lap_dance@ld_girl_a_song_a_p1", anim = "ld_girl_a_song_a_p1_f"}},
			{label = "Strptiz 2", type = "anim", data = {lib = "mini@strip_club@private_dance@part2", anim = "priv_dance_p2"}},
			{label = "Taniec erotyczny", type = "anim", data = {lib = "mini@strip_club@private_dance@part3", anim = "priv_dance_p3"}},
		}
	},
}
