Config = {}

Config.Animations = {

	{
		name  = 'festives',
		label = 'Juhlalliset',
		items = {
			--{label = "Polta tupakkia", type = "scenario", data = {anim = "WORLD_HUMAN_SMOKING"}},
			{label = "Soita musiikkia", type = "scenario", data = {anim = "WORLD_HUMAN_MUSICIAN"}},
			{label = "Tiskijukka", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@dj", anim = "dj"}},
			{label = "Juo olutta", type = "scenario", data = {anim = "WORLD_HUMAN_DRINKING"}},
			{label = "Biletä", type = "scenario", data = {anim = "WORLD_HUMAN_PARTYING"}},
			{label = "Ilmakitara", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@air_guitar", anim = "air_guitar"}},
			{label = "Humppaa ilmaa", type = "anim", data = {lib = "anim@mp_player_intcelebrationfemale@air_shagging", anim = "air_shagging"}},
			{label = "Rock'n'roll", type = "anim", data = {lib = "mp_player_int_upperrock", anim = "mp_player_int_rock"}},
			-- {label = "Polta pilveä", type = "scenario", data = {anim = "WORLD_HUMAN_SMOKING_POT"}},
			{label = "Humala idle", type = "anim", data = {lib = "amb@world_human_bum_standing@drunk@idle_a", anim = "idle_a"}},
			{label = "Oksenna ulos(auto,vänkäri)", type = "anim", data = {lib = "oddjobs@taxi@tie", anim = "vomit_outside"}},
			{label = "Herää darrasta ja oksenna", type = "anim", data = {lib = "missfam5_blackout", anim = "vomit"}},
			{label = "Oksenna seisoalteen(nojaten)", type = "anim", data = {lib = "missheistpaletoscore1leadinout", anim = "trv_puking_leadout"}},
		}
	},

	{
		name  = 'greetings',
		label = 'Tervehdykset',
		items = {
			{label = "Tervehdi", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_hello"}},
			{label = "Kättele", type = "anim", data = {lib = "mp_common", anim = "givetake1_a"}},
			{label = "Kättele 2", type = "anim", data = {lib = "mp_ped_interaction", anim = "handshake_guy_a"}},
			{label = "Gangi tervehdys", type = "anim", data = {lib = "mp_ped_interaction", anim = "hugs_guy_a"}},
			{label = "Käsi lipalle", type = "anim", data = {lib = "mp_player_int_uppersalute", anim = "mp_player_int_salute"}},
		}
	},

	{
		name  = 'work',
		label = 'Työ',
		items = {
			{label = "Epäilty : mene polville", type = "anim", data = {lib = "random@arrests@busted", anim = "idle_c"}},
			{label = "Kalasta", type = "scenario", data = {anim = "world_human_stand_fishing"}},
			{label = "Poliisi : tutki rikospaikkaa", type = "anim", data = {lib = "amb@code_human_police_investigate@idle_b", anim = "idle_f"}},
			{label = "Poliisi : puhu radioon", type = "anim", data = {lib = "random@arrests", anim = "generic_radio_chatter"}},
			{label = "Poliisi : ohjaa liikenettä", type = "scenario", data = {anim = "WORLD_HUMAN_CAR_PARK_ATTENDANT"}},
			{label = "Poliisi : kiikaroi", type = "scenario", data = {anim = "WORLD_HUMAN_BINOCULARS"}},
			{label = "Istuta", type = "scenario", data = {anim = "world_human_gardener_plant"}},
			{label = "Mekaanikko : Korjaa moottoria", type = "anim", data = {lib = "mini@repair", anim = "fixing_a_ped"}},
			{label = "Mekaanikko :  Hitsaa", type = "scenario", data = {anim = "WORLD_HUMAN_WELDING"}},
			{label = "EMS : tutki", type = "scenario", data = {anim = "CODE_HUMAN_MEDIC_KNEEL"}},
			{label = "Taxi : Puhu asiakkalle", type = "anim", data = {lib = "oddjobs@taxi@driver", anim = "leanover_idle"}},
			{label = "Taxi : Anna lasku", type = "anim", data = {lib = "oddjobs@taxi@cyi", anim = "std_hand_off_ps_passenger"}},
			{label = "Myyjä : Siirrä laatikoita", type = "anim", data = {lib = "mp_am_hold_up", anim = "purchase_beerbox_shopkeeper"}},
			{label = "Baarimikko : Kaada shotti", type = "anim", data = {lib = "mini@drinking", anim = "shots_barman_b"}},
			{label = "Journalisti : Ota valokuvia", type = "scenario", data = {anim = "WORLD_HUMAN_PAPARAZZI"}},
			{label = "Muut työt : Katsele muistiinpanoja", type = "scenario", data = {anim = "WORLD_HUMAN_CLIPBOARD"}},
			{label = "Muut Työt : Vasaroi", type = "scenario", data = {anim = "WORLD_HUMAN_HAMMERING"}},
			{label = "Pummi : Näytä kylttiä", type = "scenario", data = {anim = "WORLD_HUMAN_BUM_FREEWAY"}},
			{label = "Pummi : Ole patsas", type = "scenario", data = {anim = "WORLD_HUMAN_HUMAN_STATUE"}},
		}
	},

	{
		name  = 'humors',
		label = 'Humoristiset',
		items = {
			{label = "Taputa", type = "scenario", data = {anim = "WORLD_HUMAN_CHEERING"}},
			{label = "Peukut", type = "anim", data = {lib = "mp_action", anim = "thanks_male_06"}},
			{label = "Osota", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_point"}},
			{label = "Tuu tänne", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_come_here_soft"}}, 
			{label = "Haasta riitaa", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_bring_it_on"}},
			{label = "minä", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_me"}},
			{label = "varasta, ylähylly", type = "anim", data = {lib = "anim@am_hold_up@male", anim = "shoplift_high"}},
			{label = "Hengästynyt", type = "scenario", data = {lib = "amb@world_human_jog_standing@male@idle_b", anim = "idle_d"}},
			{label = "Facepalm", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@face_palm", anim = "face_palm"}},
			{label = "Rauhoittele", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_easy_now"}},
			{label = "Pelästy", type = "anim", data = {lib = "oddjobs@assassinate@multi@", anim = "react_big_variations_a"}},
			{label = "Pelkää", type = "anim", data = {lib = "amb@code_human_cower_stand@male@react_cowering", anim = "base_right"}},
			{label = "Valmistu tappelluun", type = "anim", data = {lib = "anim@deathmatch_intros@unarmed", anim = "intro_male_unarmed_e"}},
			{label = "Voi rähmä!", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_damn"}},
			{label = "Suutele", type = "anim", data = {lib = "mp_ped_interaction", anim = "kisses_guy_a"}},
			{label = "Keskisormet", type = "anim", data = {lib = "mp_player_int_upperfinger", anim = "mp_player_int_finger_01_enter"}},
			{label = "Runkkaa", type = "anim", data = {lib = "mp_player_int_upperwank", anim = "mp_player_int_wank_01"}},
			{label = "Ammu itseä päähän", type = "anim", data = {lib = "mp_suicide", anim = "pistol"}},
		}
	},

	{
		name  = 'sports',
		label = 'Sporttiset',
		items = {
			{label = "Esittele lihaksia", type = "anim", data = {lib = "amb@world_human_muscle_flex@arms_at_side@base", anim = "base"}},
			{label = "Nostele painoja", type = "anim", data = {lib = "amb@world_human_muscle_free_weights@male@barbell@base", anim = "base"}},
			{label = "Punnerra", type = "anim", data = {lib = "amb@world_human_push_ups@male@base", anim = "base"}},
			{label = "Tee vatsalihaksia", type = "anim", data = {lib = "amb@world_human_sit_ups@male@base", anim = "base"}},
			{label = "Yoogaa", type = "anim", data = {lib = "amb@world_human_yoga@male@base", anim = "base_a"}},
		}
	},

	{
		name  = 'misc',
		label = 'Muut',
		items = {
			{label = "Juo kahvia", type = "anim", data = {lib = "amb@world_human_aa_coffee@idle_a", anim = "idle_a"}},
			{label = "Istua", type = "anim", data = {lib = "anim@heists@prison_heistunfinished_biztarget_idle", anim = "target_idle"}},
			{label = "Nojaa taakse", type = "scenario", data = {anim = "world_human_leaning"}},
			{label = "Ota aurinkoa selällään", type = "scenario", data = {anim = "WORLD_HUMAN_SUNBATHE_BACK"}},
			{label = "Ota aurinkoa mahallaan", type = "scenario", data = {anim = "WORLD_HUMAN_SUNBATHE"}},
			{label = "Pese", type = "scenario", data = {anim = "world_human_maid_clean"}},
			{label = "Grillaa", type = "scenario", data = {anim = "PROP_HUMAN_BBQ"}},
			{label = "T-pose", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_bj_to_prop_female"}},
			{label = "Ota selfie", type = "scenario", data = {anim = "world_human_tourist_mobile"}},
			{label = "Kuuntele ovea", type = "anim", data = {lib = "mini@safe_cracking", anim = "idle_base"}}, 
		}
	},

	{
		name  = 'attitudem',
		label = 'Asenteet',
		items = {
			{label = "Normaali M", type = "attitude", data = {lib = "move_m@confident", anim = "move_m@confident"}},
			{label = "Normaali N", type = "attitude", data = {lib = "move_f@heels@c", anim = "move_f@heels@c"}},
			{label = "Masentunut M", type = "attitude", data = {lib = "move_m@depressed@a", anim = "move_m@depressed@a"}},
			{label = "Masentunut N", type = "attitude", data = {lib = "move_f@depressed@a", anim = "move_f@depressed@a"}},
			{label = "Varakas", type = "attitude", data = {lib = "move_m@business@a", anim = "move_m@business@a"}},
			{label = "Rohkea", type = "attitude", data = {lib = "move_m@brave@a", anim = "move_m@brave@a"}},
			{label = "Filthy Kasuaali", type = "attitude", data = {lib = "move_m@casual@a", anim = "move_m@casual@a"}},
			{label = "Vitun Läski", type = "attitude", data = {lib = "move_m@fat@a", anim = "move_m@fat@a"}},
			{label = "Hipsteri", type = "attitude", data = {lib = "move_m@hipster@a", anim = "move_m@hipster@a"}},
			{label = "Loukkaantunut", type = "attitude", data = {lib = "move_m@injured", anim = "move_m@injured"}},
			{label = "Kiireinen", type = "attitude", data = {lib = "move_m@hurry@a", anim = "move_m@hurry@a"}},
			{label = "Pummi", type = "attitude", data = {lib = "move_m@hobo@a", anim = "move_m@hobo@a"}},
			{label = "Surullinen", type = "attitude", data = {lib = "move_m@sad@a", anim = "move_m@sad@a"}},
			{label = "Lihaksikas", type = "attitude", data = {lib = "move_m@muscle@a", anim = "move_m@muscle@a"}},
			{label = "Järkyttynyt", type = "attitude", data = {lib = "move_m@shocked@a", anim = "move_m@shocked@a"}},
			{label = "Kovis", type = "attitude", data = {lib = "move_m@shadyped@a", anim = "move_m@shadyped@a"}},
			{label = "Väsynyt", type = "attitude", data = {lib = "move_m@buzzed", anim = "move_m@buzzed"}},
			{label = "Kiirreellisempi", type = "attitude", data = {lib = "move_m@hurry_butch@a", anim = "move_m@hurry_butch@a"}},
			{label = "Ylpeä", type = "attitude", data = {lib = "move_m@money", anim = "move_m@money"}},
			{label = "Lyhyen kilpailun juoksija", type = "attitude", data = {lib = "move_m@quick", anim = "move_m@quick"}},
			{label = "Miesten hurmaaja", type = "attitude", data = {lib = "move_f@maneater", anim = "move_f@maneater"}},
			{label = "Nenäkäs", type = "attitude", data = {lib = "move_f@sassy", anim = "move_f@sassy"}},	
			{label = "Ylimielinen", type = "attitude", data = {lib = "move_f@arrogant@a", anim = "move_f@arrogant@a"}},
		}
	},

	{
		name  = 'porn',
		label = 'Härski K-18',
		items = {
			{label = "Kuski (poskihoito)", type = "anim", data = {lib = "oddjobs@towing", anim = "m_blow_job_loop"}},
			{label = "Vänkäri (poskihoito)", type = "anim", data = {lib = "oddjobs@towing", anim = "f_blow_job_loop"}},
			{label = "Kuski (panee)", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_sex_loop_player"}},
			{label = "Vänkäri (panee)", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_sex_loop_female"}},
			{label = "Korjaa pallien sijaintia", type = "anim", data = {lib = "mp_player_int_uppergrab_crotch", anim = "mp_player_int_grab_crotch"}},
			{label = "Strippari idle", type = "anim", data = {lib = "mini@strip_club@idles@stripper", anim = "stripper_idle_02"}},
			{label = "Strippari rööki", type = "scenario", data = {anim = "WORLD_HUMAN_PROSTITUTE_HIGH_CLASS"}},
			{label = "Heruta tissejä", type = "anim", data = {lib = "mini@strip_club@backroom@", anim = "stripper_b_backroom_idle_b"}},
			{label = "Strippi tanssi 1", type = "anim", data = {lib = "mini@strip_club@lap_dance@ld_girl_a_song_a_p1", anim = "ld_girl_a_song_a_p1_f"}},
			{label = "Strippi tanssi 2", type = "anim", data = {lib = "mini@strip_club@private_dance@part2", anim = "priv_dance_p2"}},
			{label = "Twerkkaa", type = "anim", data = {lib = "mini@strip_club@private_dance@part3", anim = "priv_dance_p3"}},
		}
	}
}