Config = {}

Config.Animations = {
	
	{
		name  = 'festives',
		label = 'Festivas',
		items = {
	    	{label = "Fumar", type = "scenario", data = {anim = "WORLD_HUMAN_SMOKING"}},
	    	{label = "Musico", type = "scenario", data = {anim = "WORLD_HUMAN_MUSICIAN"}},
	    	{label = "Dj", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@dj", anim = "dj"}},
	    	{label = "Cafe", type = "scenario", data = {anim = "WORLD_HUMAN_DRINKING"}},
	    	{label = "Cerveza", type = "scenario", data = {anim = "WORLD_HUMAN_PARTYING"}},
	    	{label = "Guitarra en el aire", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@air_guitar", anim = "air_guitar"}},
	    	{label = "Air Shagging", type = "anim", data = {lib = "anim@mp_player_intcelebrationfemale@air_shagging", anim = "air_shagging"}},
	    	{label = "Rock'n'roll", type = "anim", data = {lib = "mp_player_int_upperrock", anim = "mp_player_int_rock"}},
	    	-- {label = "Fumer un joint", type = "scenario", data = {anim = "WORLD_HUMAN_SMOKING_POT"}},
	    	{label = "Borracho de pie", type = "anim", data = {lib = "amb@world_human_bum_standing@drunk@idle_a", anim = "idle_a"}},
	    	{label = "Vomitando", type = "anim", data = {lib = "oddjobs@taxi@tie", anim = "vomit_outside"}},
		}
	},

	{
		name  = 'greetings',
		label = 'Saludos',
		items = {
	    	{label = "Hola", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_hello"}},
	    	{label = "Ola", type = "anim", data = {lib = "mp_common", anim = "givetake1_a"}},
	    	{label = "Apreton de manos", type = "anim", data = {lib = "mp_ped_interaction", anim = "handshake_guy_a"}},
	    	{label = "Abrazo", type = "anim", data = {lib = "mp_ped_interaction", anim = "hugs_guy_a"}},
	    	{label = "Saludo Militar", type = "anim", data = {lib = "mp_player_int_uppersalute", anim = "mp_player_int_salute"}},
		}
	},

	{
		name  = 'work',
		label = 'Trabajo',
		items = {
	    	{label = "Suspechoso : Rendirse", type = "anim", data = {lib = "random@arrests@busted", anim = "idle_c"}},
	    	{label = "Pescando", type = "scenario", data = {anim = "world_human_stand_fishing"}},
	    	{label = "Policia : Investigando", type = "anim", data = {lib = "amb@code_human_police_investigate@idle_b", anim = "idle_f"}},
	    	{label = "Policia : Usa Radio", type = "anim", data = {lib = "random@arrests", anim = "generic_radio_chatter"}},
	    	{label = "Policia : Trafico", type = "scenario", data = {anim = "WORLD_HUMAN_CAR_PARK_ATTENDANT"}},
	    	{label = "Policia : Prismaticos", type = "scenario", data = {anim = "WORLD_HUMAN_BINOCULARS"}},
	    	{label = "Agricultor : Plantando", type = "scenario", data = {anim = "world_human_gardener_plant"}},
	    	{label = "Mecanico : Arreglando Motor", type = "anim", data = {lib = "mini@repair", anim = "fixing_a_ped"}},
	    	{label = "Medico : Arrodillado", type = "scenario", data = {anim = "CODE_HUMAN_MEDIC_KNEEL"}},
	    	{label = "Taxista : Hablando con el pasajero", type = "anim", data = {lib = "oddjobs@taxi@driver", anim = "leanover_idle"}},
	    	{label = "Taxista : Dando el recibo", type = "anim", data = {lib = "oddjobs@taxi@cyi", anim = "std_hand_off_ps_passenger"}},
	    	{label = "Dependiente : Deja la caja", type = "anim", data = {lib = "mp_am_hold_up", anim = "purchase_beerbox_shopkeeper"}},
	    	{label = "Barman : Sirviendo", type = "anim", data = {lib = "mini@drinking", anim = "shots_barman_b"}},
	    	{label = "Periodista : Tomando Fotos", type = "scenario", data = {anim = "WORLD_HUMAN_PAPARAZZI"}},
	    	{label = "Todos los trabajos : Portapapeles", type = "scenario", data = {anim = "WORLD_HUMAN_CLIPBOARD"}},
	    	{label = "Todos los trabajos : Martilleo", type = "scenario", data = {anim = "WORLD_HUMAN_HAMMERING"}},
	    	{label = "Bum : Sujetando Cartel", type = "scenario", data = {anim = "WORLD_HUMAN_BUM_FREEWAY"}},
	    	{label = "Bum : Estatua Humana", type = "scenario", data = {anim = "WORLD_HUMAN_HUMAN_STATUE"}},
		}
	},

	{
		name  = 'humors',
		label = 'Divertidos',
		items = {
	    	{label = "Animando", type = "scenario", data = {anim = "WORLD_HUMAN_CHEERING"}},
	    	{label = "Super", type = "anim", data = {lib = "mp_action", anim = "thanks_male_06"}},
	    	{label = "Señalando", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_point"}},
	    	{label = "Ven aqui", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_come_here_soft"}}, 
	    	{label = "Dale", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_bring_it_on"}},
	    	{label = "Yo", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_me"}},
	    	{label = "lo sabia", type = "anim", data = {lib = "anim@am_hold_up@male", anim = "shoplift_high"}},
	    	{label = "Exhausto", type = "scenario", data = {lib = "amb@world_human_jog_standing@male@idle_b", anim = "idle_d"}},
	    	{label = "Soy un mierdas", type = "scenario", data = {lib = "amb@world_human_bum_standing@depressed@idle_a", anim = "idle_a"}},
	    	{label = "Decepcionado", type = "anim", data = {lib = "anim@mp_player_intcelebrationmale@face_palm", anim = "face_palm"}},
	    	{label = "Relajate ", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_easy_now"}},
	    	{label = "Que he hecho yo?", type = "anim", data = {lib = "oddjobs@assassinate@multi@", anim = "react_big_variations_a"}},
	    	{label = "Miedo", type = "anim", data = {lib = "amb@code_human_cower_stand@male@react_cowering", anim = "base_right"}},
	    	{label = "Pelea ?", type = "anim", data = {lib = "anim@deathmatch_intros@unarmed", anim = "intro_male_unarmed_e"}},
	    	{label = "No es posible !", type = "anim", data = {lib = "gestures@m@standing@casual", anim = "gesture_damn"}},
	    	{label = "Besarse", type = "anim", data = {lib = "mp_ped_interaction", anim = "kisses_guy_a"}},
	    	{label = "Dedo de honor", type = "anim", data = {lib = "mp_player_int_upperfinger", anim = "mp_player_int_finger_01_enter"}},
	    	{label = "Tu pajero", type = "anim", data = {lib = "mp_player_int_upperwank", anim = "mp_player_int_wank_01"}},
	    	{label = "Una bala en tu cabeza", type = "anim", data = {lib = "mp_suicide", anim = "pistol"}},
		}
	},

	{
		name  = 'sports',
		label = 'Deporte',
		items = {
	    	{label = "Marcando biceps", type = "anim", data = {lib = "amb@world_human_muscle_flex@arms_at_side@base", anim = "base"}},
	    	{label = "Levantar pesas", type = "anim", data = {lib = "amb@world_human_muscle_free_weights@male@barbell@base", anim = "base"}},
	    	{label = "Flexiones", type = "anim", data = {lib = "amb@world_human_push_ups@male@base", anim = "base"}},
	    	{label = "Sentadillas", type = "anim", data = {lib = "amb@world_human_sit_ups@male@base", anim = "base"}},
	    	{label = "Yoga", type = "anim", data = {lib = "amb@world_human_yoga@male@base", anim = "base_a"}},
		}
	},

	{
		name  = 'misc',
		label = 'Diversos',
		items = {
	    	{label = "Drink coffee", type = "anim", data = {lib = "amb@world_human_aa_coffee@idle_a", anim = "idle_a"}},
	    	{label = "Sentarse", type = "anim", data = {lib = "anim@heists@prison_heistunfinished_biztarget_idle", anim = "target_idle"}},
	    	{label = "Apoyarse contra la pared", type = "scenario", data = {anim = "world_human_leaning"}},
	    	{label = "Tomando el sol de espaldas", type = "scenario", data = {anim = "WORLD_HUMAN_SUNBATHE_BACK"}},
	    	{label = "Tomando el sol", type = "scenario", data = {anim = "WORLD_HUMAN_SUNBATHE"}},
	    	{label = "Limpiando", type = "scenario", data = {anim = "world_human_maid_clean"}},
	    	{label = "BBQ", type = "scenario", data = {anim = "PROP_HUMAN_BBQ"}},
	    	{label = "Buscando", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_bj_to_prop_female"}},
	    	{label = "Tomando un selfie", type = "scenario", data = {anim = "world_human_tourist_mobile"}},
	    	{label = "Escuchando a traves de la pared/puerta", type = "anim", data = {lib = "mini@safe_cracking", anim = "idle_base"}}, 
		}
	},

	{
		name  = 'attitudem',
		label = 'Estilos de caminar',
		items = {
	    	{label = "Normal M", type = "attitude", data = {lib = "move_m@confident", anim = "move_m@confident"}},
	    	{label = "Normal F", type = "attitude", data = {lib = "move_f@heels@c", anim = "move_f@heels@c"}},
	    	{label = "Hombre deprimido", type = "attitude", data = {lib = "move_m@depressed@a", anim = "move_m@depressed@a"}},
	    	{label = "Mujer deprimida", type = "attitude", data = {lib = "move_f@depressed@a", anim = "move_f@depressed@a"}},
	    	{label = "Hombre de negocios", type = "attitude", data = {lib = "move_m@business@a", anim = "move_m@business@a"}},
	    	{label = "Determinado", type = "attitude", data = {lib = "move_m@brave@a", anim = "move_m@brave@a"}},
	    	{label = "Casual", type = "attitude", data = {lib = "move_m@casual@a", anim = "move_m@casual@a"}},
	    	{label = "Con el estomago lleno", type = "attitude", data = {lib = "move_m@fat@a", anim = "move_m@fat@a"}},
	    	{label = "Hipster", type = "attitude", data = {lib = "move_m@hipster@a", anim = "move_m@hipster@a"}},
	    	{label = "Herido", type = "attitude", data = {lib = "move_m@injured", anim = "move_m@injured"}},
	    	{label = "Con prisas", type = "attitude", data = {lib = "move_m@hurry@a", anim = "move_m@hurry@a"}},
	    	{label = "Vagabundo", type = "attitude", data = {lib = "move_m@hobo@a", anim = "move_m@hobo@a"}},
	    	{label = "Triste", type = "attitude", data = {lib = "move_m@sad@a", anim = "move_m@sad@a"}},
	    	{label = "Musculoso", type = "attitude", data = {lib = "move_m@muscle@a", anim = "move_m@muscle@a"}},
	    	{label = "Traumatizado", type = "attitude", data = {lib = "move_m@shocked@a", anim = "move_m@shocked@a"}},
	    	{label = "Sospechoso", type = "attitude", data = {lib = "move_m@shadyped@a", anim = "move_m@shadyped@a"}},
	    	{label = "Zumbado", type = "attitude", data = {lib = "move_m@buzzed", anim = "move_m@buzzed"}},
	    	{label = "Con prisas 2", type = "attitude", data = {lib = "move_m@hurry_butch@a", anim = "move_m@hurry_butch@a"}},
	    	{label = "Orgulloso", type = "attitude", data = {lib = "move_m@money", anim = "move_m@money"}},
	    	{label = "Sprintando", type = "attitude", data = {lib = "move_m@quick", anim = "move_m@quick"}},
	    	{label = "Come-hombres", type = "attitude", data = {lib = "move_f@maneater", anim = "move_f@maneater"}},
	    	{label = "Atrevido", type = "attitude", data = {lib = "move_f@sassy", anim = "move_f@sassy"}},	
	    	{label = "Arrogante", type = "attitude", data = {lib = "move_f@arrogant@a", anim = "move_f@arrogant@a"}},
		}
	},
	{
		name  = 'porn',
		label = '+18',
		items = {
	    	{label = "Hombre recibiendo en el coche", type = "anim", data = {lib = "oddjobs@towing", anim = "m_blow_job_loop"}},
	    	{label = "Mujer dando en el coche", type = "anim", data = {lib = "oddjobs@towing", anim = "f_blow_job_loop"}},
	    	{label = "Hombre abajo en el coche", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_sex_loop_player"}},
	    	{label = "Mujer arriba en el coche", type = "anim", data = {lib = "mini@prostitutes@sexlow_veh", anim = "low_car_sex_loop_female"}},
	    	{label = "Rascandosela", type = "anim", data = {lib = "mp_player_int_uppergrab_crotch", anim = "mp_player_int_grab_crotch"}},
	    	{label = "Prostituta 1", type = "anim", data = {lib = "mini@strip_club@idles@stripper", anim = "stripper_idle_02"}},
	    	{label = "Prostituta 2", type = "scenario", data = {anim = "WORLD_HUMAN_PROSTITUTE_HIGH_CLASS"}},
	    	{label = "Prostituta 3", type = "anim", data = {lib = "mini@strip_club@backroom@", anim = "stripper_b_backroom_idle_b"}},
	    	{label = "Strip Tease 1", type = "anim", data = {lib = "mini@strip_club@lap_dance@ld_girl_a_song_a_p1", anim = "ld_girl_a_song_a_p1_f"}},
	    	{label = "Strip Tease 2", type = "anim", data = {lib = "mini@strip_club@private_dance@part2", anim = "priv_dance_p2"}},
	    	{label = "Stip Tease de rodillas", type = "anim", data = {lib = "mini@strip_club@private_dance@part3", anim = "priv_dance_p3"}},
			}
	},

}
