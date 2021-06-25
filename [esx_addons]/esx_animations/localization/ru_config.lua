Config = {}

Config.Animations = {

	{
		name  = 'festives',
		label = 'Действия',
		items = {
			{label = "Курнуть", type = "scenario", data = {anim = "WORLD_HUMAN_SMOKING"}},
			--{label = "Jouer de la musique", type = "scenario", data = {anim = "WORLD_HUMAN_MUSICIAN"}},
			{label = "Dj", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@dj", anim = "dj"}},
			{label = "Пить", type = "scenario", data = {anim = "WORLD_HUMAN_DRINKING"}},
			{label = "Веселиться с пивасом", type = "scenario", data = {anim = "WORLD_HUMAN_PARTYING"}},
			{label = "Воздушная гитара", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@air_guitar", anim = "air_guitar"}},
			{label = "Воздушный перепихон", type = "anim", data = {lib = "anim@mp_player_intcelebrationfemale@air_shagging", anim = "air_shagging"}},
			{label = "Rock'n'roll", type = "anim", data = {lib = "mp_player_int_upperrock", anim = "mp_player_int_rock"}},
			{label = "Курить как профи", type = "scenario", data = {anim = "WORLD_HUMAN_SMOKING_POT"}},
			{label = "Изоброжать пьянь", type = "anim", data = {lib = "amb@world_human_bum_standing@drunk@idle_a", anim = "idle_a"}},
			--{label = "Vomir en voiture", type = "anim", data = {lib = "oddjobs@taxi@tie", anim = "vomit_outside"}},
		}
	},

	{
		name  = 'greetings',
		label = 'Приветствия',
		items = {
			{label = "Салют", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_hello"}},
			{label = "Рукопожатие", type = "anim", data = {lib = "mp_common", anim = "givetake1_a"}},
			{label = "Крутое Рукопожатие", type = "anim", data = {lib = "mp_ped_interaction", anim = "handshake_guy_a"}},
			{label = "Рука-обнимашка", type = "anim", data = {lib = "mp_ped_interaction", anim = "hugs_guy_a"}},
			{label = "Отдать честь", type = "anim", data = {lib = "mp_player_int_uppersalute", anim = "mp_player_int_salute"}},
		}
	},

	{
		name  = 'work',
		label = 'Работа',
		items = {
			{label = "На колени, руки за голову", type = "anim", data = {lib = "random@arrests@busted", anim = "idle_c"}},
			{label = "Рыбачить", type = "scenario", data = {anim = "world_human_stand_fishing"}},
			{label = "Police : Осматривать", type = "anim", data = {lib = "amb@code_human_police_investigate@idle_b", anim = "idle_f"}},
			{label = "Police : Проверять рацию", type = "anim", data = {lib = "random@arrests", anim = "generic_radio_chatter"}},
			{label = "Police : Махать палкой", type = "scenario", data = {anim = "WORLD_HUMAN_CAR_PARK_ATTENDANT"}},
			{label = "Police : Глядеть вдаль биноклем", type = "scenario", data = {anim = "WORLD_HUMAN_BINOCULARS"}},
			{label = "Капать лопаткой", type = "scenario", data = {anim = "world_human_gardener_plant"}},
			{label = "Ремонтировать что-то", type = "anim", data = {lib = "mini@repair", anim = "fixing_a_ped"}},
			{label = "Медик : Осморт лежачего", type = "scenario", data = {anim = "CODE_HUMAN_MEDIC_KNEEL"}},
			--{label = "Taxi : parler au client", type = "anim", data = {lib = "oddjobs@taxi@driver", anim = "leanover_idle"}},
			--{label = "Taxi : donner la facture", type = "anim", data = {lib = "oddjobs@taxi@cyi", anim = "std_hand_off_ps_passenger"}},
			{label = "Достать, положитьб перед собой", type = "anim", data = {lib = "mp_am_hold_up", anim = "purchase_beerbox_shopkeeper"}},
			{label = "Бармен : Налить рюмку", type = "anim", data = {lib = "mini@drinking", anim = "shots_barman_b"}},
			{label = "Фотографировать", type = "scenario", data = {anim = "WORLD_HUMAN_PAPARAZZI"}},
			{label = "Работать с блокнотом", type = "scenario", data = {anim = "WORLD_HUMAN_CLIPBOARD"}},
			{label = "Молотить", type = "scenario", data = {anim = "WORLD_HUMAN_HAMMERING"}},
			{label = "Попрошайничать", type = "scenario", data = {anim = "WORLD_HUMAN_BUM_FREEWAY"}},
			{label = "Изображать статую", type = "scenario", data = {anim = "WORLD_HUMAN_HUMAN_STATUE"}},
		}
	},

	{
		name  = 'humors',
		label = 'Эмоции',
		items = {
			{label = "Ура! Заебись", type = "scenario", data = {anim = "WORLD_HUMAN_CHEERING"}},
			{label = "Супер", type = "anim", data = {lib = "mp_action", anim = "thanks_male_06"}},
			{label = "Показать пальцем", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_point"}},
			{label = "Сюда иди", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_come_here_soft"}}, 
			{label = "Че нах ?", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_bring_it_on"}},
			{label = "А я?", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_me"}},
			--{label = "Je le savais, putain", type = "anim", data = {lib = "anim@am_hold_up@male", anim = "shoplift_high"}},
			--{label = "Etre épuisé", type = "scenario", data = {lib = "amb@world_human_jog_standing@male@idle_b", anim = "idle_d"}},
			--{label = "Je suis dans la merde", type = "scenario", data = {lib = "amb@world_human_bum_standing@depressed@idle_a", anim = "idle_a"}},
			{label = "Facepalm", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@face_palm", anim = "face_palm"}},
			{label = "Тихо - тихо", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_easy_now"}},
			{label = "Шо там ебать?", type = "anim", data = {lib = "oddjobs@assassinate@multi@", anim = "react_big_variations_a"}},
			{label = "Страшно", type = "anim", data = {lib = "amb@code_human_cower_stand@male@react_cowering", anim = "base_right"}},
			{label = "Разминаться", type = "anim", data = {lib = "anim@deathmatch_intros@unarmed", anim = "intro_male_unarmed_e"}},
			{label = "Черт!", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_damn"}},
			{label = "Обьятия с поцелуем", type = "anim", data = {lib = "mp_ped_interaction", anim = "kisses_guy_a"}},
			{label = "Два фака", type = "anim", data = {lib = "mp_player_int_upperfinger", anim = "mp_player_int_finger_01_enter"}},
			{label = "Мастурбация", type = "anim", data = {lib = "mp_player_int_upperwank", anim = "mp_player_int_wank_01"}},
			{label = "Застрелиться", type = "anim", data = {lib = "mp_suicide", anim = "pistol"}},
		}
	},

	{
		name  = 'sports',
		label = 'Спорт',
		items = {
			{label = "Выебываться мускулами", type = "anim", data = {lib = "amb@world_human_muscle_flex@arms_at_side@base", anim = "base"}},
			{label = "Поднимать штангу", type = "anim", data = {lib = "amb@world_human_muscle_free_weights@male@barbell@base", anim = "base"}},
			{label = "Отжимание", type = "anim", data = {lib = "amb@world_human_push_ups@male@base", anim = "base"}},
			{label = "Пресс", type = "anim", data = {lib = "amb@world_human_sit_ups@male@base", anim = "base"}},
			{label = "Йога", type = "anim", data = {lib = "amb@world_human_yoga@male@base", anim = "base_a"}},
		}
	},

	{
		name  = 'misc',
		label = 'Разное',
		items = {
			--{label = "Boire un café", type = "anim", data = {lib = "amb@world_human_aa_coffee@idle_a", anim = "idle_a"}},
			--{label = "S'asseoir", type = "anim", data = {lib = "anim@heists@prison_heistunfinished_biztarget_idle", anim = "target_idle"}},
			{label = "Курить у стенки", type = "scenario", data = {anim = "world_human_leaning"}},
			{label = "Лежать", type = "scenario", data = {anim = "WORLD_HUMAN_SUNBATHE_BACK"}},
			{label = "Лежать на животе", type = "scenario", data = {anim = "WORLD_HUMAN_SUNBATHE"}},
			{label = "Протирать", type = "scenario", data = {anim = "world_human_maid_clean"}},
			{label = "Жарить на грилле", type = "scenario", data = {anim = "PROP_HUMAN_BBQ"}},
			--{label = "Position de Fouille", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_bj_to_prop_female"}},
			{label = "Селфи", type = "scenario", data = {anim = "world_human_tourist_mobile"}},
			{label = "Подслушивать", type = "anim", data = {lib = "mini@safe_cracking", anim = "idle_base"}}, 
		}
	},

	{
		name  = 'attitudem',
		label = 'Походка',
		items = {
			{label = "Normal M", type = "attitude", data = {lib = "move_m@confident", anim = "move_m@confident"}},
			{label = "Normal F", type = "attitude", data = {lib = "move_f@heels@c", anim = "move_f@heels@c"}},
			{label = "Depressif", type = "attitude", data = {lib = "move_m@depressed@a", anim = "move_m@depressed@a"}},
			{label = "Depressif F", type = "attitude", data = {lib = "move_f@depressed@a", anim = "move_f@depressed@a"}},
			{label = "Business", type = "attitude", data = {lib = "move_m@business@a", anim = "move_m@business@a"}},
			{label = "Determine", type = "attitude", data = {lib = "move_m@brave@a", anim = "move_m@brave@a"}},
			{label = "Casual", type = "attitude", data = {lib = "move_m@casual@a", anim = "move_m@casual@a"}},
			{label = "Trop mange", type = "attitude", data = {lib = "move_m@fat@a", anim = "move_m@fat@a"}},
			{label = "Hipster", type = "attitude", data = {lib = "move_m@hipster@a", anim = "move_m@hipster@a"}},
			{label = "Blesse", type = "attitude", data = {lib = "move_m@injured", anim = "move_m@injured"}},
			{label = "Intimide", type = "attitude", data = {lib = "move_m@hurry@a", anim = "move_m@hurry@a"}},
			{label = "Hobo", type = "attitude", data = {lib = "move_m@hobo@a", anim = "move_m@hobo@a"}},
			{label = "Malheureux", type = "attitude", data = {lib = "move_m@sad@a", anim = "move_m@sad@a"}},
			{label = "Muscle", type = "attitude", data = {lib = "move_m@muscle@a", anim = "move_m@muscle@a"}},
			{label = "Choc", type = "attitude", data = {lib = "move_m@shocked@a", anim = "move_m@shocked@a"}},
			{label = "Sombre", type = "attitude", data = {lib = "move_m@shadyped@a", anim = "move_m@shadyped@a"}},
			{label = "Fatigue", type = "attitude", data = {lib = "move_m@buzzed", anim = "move_m@buzzed"}},
			{label = "Pressee", type = "attitude", data = {lib = "move_m@hurry_butch@a", anim = "move_m@hurry_butch@a"}},
			{label = "Fier", type = "attitude", data = {lib = "move_m@money", anim = "move_m@money"}},
			{label = "Petite course", type = "attitude", data = {lib = "move_m@quick", anim = "move_m@quick"}},
			{label = "Mangeuse d'homme", type = "attitude", data = {lib = "move_f@maneater", anim = "move_f@maneater"}},
			{label = "Impertinent", type = "attitude", data = {lib = "move_f@sassy", anim = "move_f@sassy"}},	
			{label = "Arrogante", type = "attitude", data = {lib = "move_f@arrogant@a", anim = "move_f@arrogant@a"}},
		}
	},
	{
		name  = 'porn',
		label = '18+ БЛЯТЬ',
		items = {
			{label = "Тебе сосут (сидя) в машине", type = "anim", data = {lib = "oddjobs@towing", anim = "m_blow_job_loop"}},
			{label = "Ты сосешь (сидя) в машине", type = "anim", data = {lib = "oddjobs@towing", anim = "f_blow_job_loop"}},
			{label = "Тебе сосут в машине, оч приятно", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_sex_loop_player"}},
			{label = "Трах в машине", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_sex_loop_female"}},
			{label = "Зачесались яйца", type = "anim", data = {lib = "mp_player_int_uppergrab_crotch", anim = "mp_player_int_grab_crotch"}},
			{label = "Аура шлюхи", type = "anim", data = {lib = "mini@strip_club@idles@stripper", anim = "stripper_idle_02"}},
			{label = "Поза шлюхи", type = "scenario", data = {anim = "WORLD_HUMAN_PROSTITUTE_HIGH_CLASS"}},
			{label = "Титькотрясение", type = "anim", data = {lib = "mini@strip_club@backroom@", anim = "stripper_b_backroom_idle_b"}},
			{label = "Стрип 1", type = "anim", data = {lib = "mini@strip_club@lap_dance@ld_girl_a_song_a_p1", anim = "ld_girl_a_song_a_p1_f"}},
			{label = "Стрип 2", type = "anim", data = {lib = "mini@strip_club@private_dance@part2", anim = "priv_dance_p2"}},
			{label = "Стрип 3", type = "anim", data = {lib = "mini@strip_club@private_dance@part3", anim = "priv_dance_p3"}},
		}
	}
}
