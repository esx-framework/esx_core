Config = {}

Config.Animations = {

	{
		name  = 'festives',
		label = 'Slavnostní',
		items = {
			{label = "Kouření cigarety", type = "scenario", data = {anim = "WORLD_HUMAN_SMOKING"}},
			{label = "Hraní na hudební nástroj", type = "scenario", data = {anim = "WORLD_HUMAN_MUSICIAN"}},
			{label = "DJ", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@dj", anim = "dj"}},
			{label = "Pití", type = "scenario", data = {anim = "WORLD_HUMAN_DRINKING"}},
			{label = "Párty", type = "scenario", data = {anim = "WORLD_HUMAN_PARTYING"}},
			{label = "Hraní na imaginární kytaru", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@air_guitar", anim = "air_guitar"}},
			{label = "Oslavování", type = "anim", data = {lib = "anim@mp_player_intcelebrationfemale@air_shagging", anim = "air_shagging"}},
			{label = "Rock'n'roll", type = "anim", data = {lib = "mp_player_int_upperrock", anim = "mp_player_int_rock"}},
			-- {label = "Kouření jointu", type = "scenario", data = {anim = "WORLD_HUMAN_SMOKING_POT"}},
			{label = "Ožralecké balancování", type = "anim", data = {lib = "amb@world_human_bum_standing@drunk@idle_a", anim = "idle_a"}},
			{label = "Zvracení v autě", type = "anim", data = {lib = "oddjobs@taxi@tie", anim = "vomit_outside"}},
		}
	},

	{
		name  = 'greetings',
		label = 'Pozdravy',
		items = {
			{label = "Pozdrav", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_hello"}},
			{label = "Podání ruky", type = "anim", data = {lib = "mp_common", anim = "givetake1_a"}},
			{label = "Podání ruky 2", type = "anim", data = {lib = "mp_ped_interaction", anim = "handshake_guy_a"}},
			{label = "Gangsterské objetí", type = "anim", data = {lib = "mp_ped_interaction", anim = "hugs_guy_a"}},
			{label = "Salutování", type = "anim", data = {lib = "mp_player_int_uppersalute", anim = "mp_player_int_salute"}},
		}
	},

	{
		name  = 'work',
		label = 'Práce',
		items = {
			{label = "Podezřelý: vzdání se policii", type = "anim", data = {lib = "random@arrests@busted", anim = "idle_c"}},
			{label = "Rybaření", type = "scenario", data = {anim = "world_human_stand_fishing"}},
			{label = "Policie: vyšetřování", type = "anim", data = {lib = "amb@code_human_police_investigate@idle_b", anim = "idle_f"}},
			{label = "Policie: mluvení do vysílačky", type = "anim", data = {lib = "random@arrests", anim = "generic_radio_chatter"}},
			{label = "Policie: řízení dopravy", type = "scenario", data = {anim = "WORLD_HUMAN_CAR_PARK_ATTENDANT"}},
			{label = "Policie: dalekohled", type = "scenario", data = {anim = "WORLD_HUMAN_BINOCULARS"}},
			{label = "Zemědělství: sbírání", type = "scenario", data = {anim = "world_human_gardener_plant"}},
			{label = "Mechanik: oprava motoru", type = "anim", data = {lib = "mini@repair", anim = "fixing_a_ped"}},
			{label = "Lékař: prohlídka", type = "scenario", data = {anim = "CODE_HUMAN_MEDIC_KNEEL"}},
			{label = "Taxi: mluvení k zákazníkovi", type = "anim", data = {lib = "oddjobs@taxi@driver", anim = "leanover_idle"}},
			{label = "Taxi: dávání faktury", type = "anim", data = {lib = "oddjobs@taxi@cyi", anim = "std_hand_off_ps_passenger"}},
			{label = "Prodavač: podávání zboží", type = "anim", data = {lib = "mp_am_hold_up", anim = "purchase_beerbox_shopkeeper"}},
			{label = "Barman: nalití panáka", type = "anim", data = {lib = "mini@drinking", anim = "shots_barman_b"}},
			{label = "Novinář: focení", type = "scenario", data = {anim = "WORLD_HUMAN_PAPARAZZI"}},
			{label = "Jiná práce: zapisování poznámek", type = "scenario", data = {anim = "WORLD_HUMAN_CLIPBOARD"}},
			{label = "Jiná práce: ťukání kladivem", type = "scenario", data = {anim = "WORLD_HUMAN_HAMMERING"}},
			{label = "Tulák: držení cedule", type = "scenario", data = {anim = "WORLD_HUMAN_BUM_FREEWAY"}},
			{label = "Tulák: imitace sochy", type = "scenario", data = {anim = "WORLD_HUMAN_HUMAN_STATUE"}},
		}
	},

	{
		name  = 'humors',
		label = 'Nálady',
		items = {
			{label = "Potlesk", type = "scenario", data = {anim = "WORLD_HUMAN_CHEERING"}},
			{label = "Super", type = "anim", data = {lib = "mp_action", anim = "thanks_male_06"}},
			{label = "Ukázání prstem", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_point"}},
			{label = "Pojď sem", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_come_here_soft"}}, 
			{label = "Tak co je?", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_bring_it_on"}},
			{label = "Já?", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_me"}},
			{label = "Já to věděl sakra", type = "anim", data = {lib = "anim@am_hold_up@male", anim = "shoplift_high"}},
			{label = "Postávání", type = "scenario", data = {lib = "amb@world_human_jog_standing@male@idle_b", anim = "idle_d"}},
			{label = "Je to v háji", type = "scenario", data = {lib = "amb@world_human_bum_standing@depressed@idle_a", anim = "idle_a"}},
			{label = "Facepalm", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@face_palm", anim = "face_palm"}},
			{label = "Klídek", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_easy_now"}},
			{label = "Co jsem to udělal?", type = "anim", data = {lib = "oddjobs@assassinate@multi@", anim = "react_big_variations_a"}},
			{label = "Oh ne", type = "anim", data = {lib = "amb@code_human_cower_stand@male@react_cowering", anim = "base_right"}},
			{label = "Bitka?", type = "anim", data = {lib = "anim@deathmatch_intros@unarmed", anim = "intro_male_unarmed_e"}},
			{label = "To snad není možné!", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_damn"}},
			{label = "Polibek", type = "anim", data = {lib = "mp_ped_interaction", anim = "kisses_guy_a"}},
			{label = "Fakování", type = "anim", data = {lib = "mp_player_int_upperfinger", anim = "mp_player_int_finger_01_enter"}},
			{label = "Onanování", type = "anim", data = {lib = "mp_player_int_upperwank", anim = "mp_player_int_wank_01"}},
			{label = "Kulka do hlavy", type = "anim", data = {lib = "mp_suicide", anim = "pistol"}},
		}
	},

	{
		name  = 'sports',
		label = 'Sporty',
		items = {
			{label = "Ukázání svalů", type = "anim", data = {lib = "amb@world_human_muscle_flex@arms_at_side@base", anim = "base"}},
			{label = "Posilování", type = "anim", data = {lib = "amb@world_human_muscle_free_weights@male@barbell@base", anim = "base"}},
			{label = "Klikování", type = "anim", data = {lib = "amb@world_human_push_ups@male@base", anim = "base"}},
			{label = "Sedy lehy", type = "anim", data = {lib = "amb@world_human_sit_ups@male@base", anim = "base"}},
			{label = "Jóga", type = "anim", data = {lib = "amb@world_human_yoga@male@base", anim = "base_a"}},
		}
	},

	{
		name  = 'misc',
		label = 'Ostatní',
		items = {
			{label = "Pití kávy", type = "anim", data = {lib = "amb@world_human_aa_coffee@idle_a", anim = "idle_a"}},
			{label = "Sedění", type = "anim", data = {lib = "anim@heists@prison_heistunfinished_biztarget_idle", anim = "target_idle"}},
			{label = "Opření o zeď", type = "scenario", data = {anim = "world_human_leaning"}},
			{label = "Ležení na zádech", type = "scenario", data = {anim = "WORLD_HUMAN_SUNBATHE_BACK"}},
			{label = "Ležení na břiše", type = "scenario", data = {anim = "WORLD_HUMAN_SUNBATHE"}},
			{label = "Uklízení", type = "scenario", data = {anim = "world_human_maid_clean"}},
			{label = "Grilování", type = "scenario", data = {anim = "PROP_HUMAN_BBQ"}},
			{label = "Osobní prohlídka", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_bj_to_prop_female"}},
			{label = "Focení selfie", type = "scenario", data = {anim = "world_human_tourist_mobile"}},
			{label = "Poslouchání u dveří", type = "anim", data = {lib = "mini@safe_cracking", anim = "idle_base"}}, 
		}
	},

	{
		name  = 'attitudem',
		label = 'Postoje',
		items = {
			{label = "Normální muž", type = "attitude", data = {lib = "move_m@confident", anim = "move_m@confident"}},
			{label = "Normální žena", type = "attitude", data = {lib = "move_f@heels@c", anim = "move_f@heels@c"}},
			{label = "Deprese muž", type = "attitude", data = {lib = "move_m@depressed@a", anim = "move_m@depressed@a"}},
			{label = "Deprese žena", type = "attitude", data = {lib = "move_f@depressed@a", anim = "move_f@depressed@a"}},
			{label = "Business", type = "attitude", data = {lib = "move_m@business@a", anim = "move_m@business@a"}},
			{label = "Odhodlaný", type = "attitude", data = {lib = "move_m@brave@a", anim = "move_m@brave@a"}},
			{label = "Běžný", type = "attitude", data = {lib = "move_m@casual@a", anim = "move_m@casual@a"}},
			{label = "Přejezení", type = "attitude", data = {lib = "move_m@fat@a", anim = "move_m@fat@a"}},
			{label = "Hipster", type = "attitude", data = {lib = "move_m@hipster@a", anim = "move_m@hipster@a"}},
			{label = "Zranění", type = "attitude", data = {lib = "move_m@injured", anim = "move_m@injured"}},
			{label = "Pospíchání", type = "attitude", data = {lib = "move_m@hurry@a", anim = "move_m@hurry@a"}},
			{label = "Bezdomovec", type = "attitude", data = {lib = "move_m@hobo@a", anim = "move_m@hobo@a"}},
			{label = "Smutný", type = "attitude", data = {lib = "move_m@sad@a", anim = "move_m@sad@a"}},
			{label = "Svalnatost", type = "attitude", data = {lib = "move_m@muscle@a", anim = "move_m@muscle@a"}},
			{label = "Šokovaný", type = "attitude", data = {lib = "move_m@shocked@a", anim = "move_m@shocked@a"}},
			{label = "Podezřelý", type = "attitude", data = {lib = "move_m@shadyped@a", anim = "move_m@shadyped@a"}},
			{label = "Únava", type = "attitude", data = {lib = "move_m@buzzed", anim = "move_m@buzzed"}},
			{label = "Uspěchanost", type = "attitude", data = {lib = "move_m@hurry_butch@a", anim = "move_m@hurry_butch@a"}},
			{label = "Pyšný", type = "attitude", data = {lib = "move_m@money", anim = "move_m@money"}},
			{label = "Sprint", type = "attitude", data = {lib = "move_m@quick", anim = "move_m@quick"}},
			{label = "Gay", type = "attitude", data = {lib = "move_f@maneater", anim = "move_f@maneater"}},
			{label = "Drzost", type = "attitude", data = {lib = "move_f@sassy", anim = "move_f@sassy"}},	
			{label = "Arogance", type = "attitude", data = {lib = "move_f@arrogant@a", anim = "move_f@arrogant@a"}},
		}
	},
	{
		name  = 'porn',
		label = 'Sex',
		items = {
			{label = "Kouření v autě - muž", type = "anim", data = {lib = "oddjobs@towing", anim = "m_blow_job_loop"}},
			{label = "Kouření v autě - žena", type = "anim", data = {lib = "oddjobs@towing", anim = "f_blow_job_loop"}},
			{label = "Sex v autě - muž", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_sex_loop_player"}},
			{label = "Sex v autě - žena", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_sex_loop_female"}},
			{label = "Škrabání v rozkroku", type = "anim", data = {lib = "mp_player_int_uppergrab_crotch", anim = "mp_player_int_grab_crotch"}},
			{label = "Stání prostitutky", type = "anim", data = {lib = "mini@strip_club@idles@stripper", anim = "stripper_idle_02"}},
			{label = "Póza prostitutky", type = "scenario", data = {anim = "WORLD_HUMAN_PROSTITUTE_HIGH_CLASS"}},
			{label = "Ukázání prsou", type = "anim", data = {lib = "mini@strip_club@backroom@", anim = "stripper_b_backroom_idle_b"}},
			{label = "Striptýz", type = "anim", data = {lib = "mini@strip_club@lap_dance@ld_girl_a_song_a_p1", anim = "ld_girl_a_song_a_p1_f"}},
			{label = "Striptýz 2", type = "anim", data = {lib = "mini@strip_club@private_dance@part2", anim = "priv_dance_p2"}},
			{label = "Striptýz 3", type = "anim", data = {lib = "mini@strip_club@private_dance@part3", anim = "priv_dance_p3"}},
		}
	}
}