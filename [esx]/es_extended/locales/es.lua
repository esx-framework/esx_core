Locales['es'] = {
  -- Inventory
  ['inventory'] = 'Inventario %s / %s',
  ['use'] = 'Usar',
  ['give'] = 'Dar',
  ['remove'] = 'Tirar',
  ['return'] = 'Volver',
  ['give_to'] = 'Dar a',
  ['amount'] = 'Cantidad',
  ['giveammo'] = 'Dar munición',
  ['amountammo'] = 'Cantidad de munición',
  ['noammo'] = 'No tienes suficiente munición!',
  ['gave_item'] = 'Has dado %sx %s a %s',
  ['received_item'] = 'Has recibido %sx %s de %s',
  ['gave_weapon'] = 'Has dado %s a %s',
  ['gave_weapon_ammo'] = 'Has dado ~o~%sx %s para %s a %s',
  ['gave_weapon_withammo'] = 'Has dado %s con ~o~%sx %s a %s',
  ['gave_weapon_hasalready'] = '%s ya tiene un/a %s',
  ['gave_weapon_noweapon'] = '%s no tiene ese arma',
  ['received_weapon'] = 'Has recibido %s de %s',
  ['received_weapon_ammo'] = 'Has recibido ~o~%sx %s para su %s de %s',
  ['received_weapon_withammo'] = 'Has recibido %s con ~o~%sx %s de %s',
  ['received_weapon_hasalready'] = '%s intentó darle un/a %s, pero ya tienes uno',
  ['received_weapon_noweapon'] = '%s intentó darles munición para un %s, pero no tiene uno',
  ['gave_account_money'] = 'Has dado $%s (%s) a %s',
  ['received_account_money'] = 'Has recibido $%s (%s) de %s',
  ['amount_invalid'] = 'Cantidad inválida',
  ['players_nearby'] = 'No hay jugadores cerca',
  ['ex_inv_lim'] = 'Acción no posible, excediendo el límite de inventario para %s',
  ['imp_invalid_quantity'] = 'Acción imposible, cantidad inválida',
  ['imp_invalid_amount'] = 'Acción imposible, cantidad inválida',
  ['threw_standard'] = 'Has tirado %sx %s',
  ['threw_account'] = 'Has tirado $%s %s',
  ['threw_weapon'] = 'Has tirado %s',
  ['threw_weapon_ammo'] = 'Has tirado %s con ~o~%sx %s',
  ['threw_weapon_already'] = 'Ya llevas el mismo arma',
  ['threw_cannot_pickup'] = 'No puedes recogerlo porque tu inventario está lleno!',
  ['threw_pickup_prompt'] = 'Pulsa E para recoger',

  -- Key mapping
  ['keymap_showinventory'] = 'Ver Inventario',

  -- Salary related
  ['received_salary'] = 'Has recibido tu sueldo: $%s',
  ['received_help'] = 'Has recibido su cheque de bienestar: $%s',
  ['company_nomoney'] = 'La empresa en la que trabajas no tiene dinero para pagar tu sueldo',
  ['received_paycheck'] = 'Recibió su paga',
  ['bank'] = 'Banco',
  ['account_bank'] = 'Banco',
  ['account_black_money'] = 'Dinero Negro',
  ['account_money'] = 'Efectivo',

  ['act_imp'] = 'Acción imposible',
  ['in_vehicle'] = 'No se puede dar nada a alguien en un vehículo',

  -- Commands
  ['command_bring'] = 'Traer un jugador hacia ti',
  ['command_car'] = 'Generar un vehiculo',
  ['command_car_car'] = 'Nombre o hash del vehículo',
  ['command_cardel'] = 'Eliminar vehículos cercanos',
  ['command_cardel_radius'] = 'Opcional, eliminar todos los vehículos en el radio especificado',
  ['command_clear'] = 'Limpiar chat',
  ['command_clearall'] = 'Limpiar chat para todos los jugadores',
  ['command_clearinventory'] = 'Limpiar el inventario del jugador',
  ['command_clearloadout'] = 'Limpiar inventario de un jugador',
  ['command_freeze'] = 'Congelar un jugador',
  ['command_unfreeze'] = 'Descongelar un jugador',
  ['command_giveaccountmoney'] = 'Dar dinero',
  ['command_giveaccountmoney_account'] = 'Nombre de cuenta válido',
  ['command_giveaccountmoney_amount'] = 'Cantidad a añadir',
  ['command_giveaccountmoney_invalid'] = 'Nombre de cuenta inválido',
  ['command_giveitem'] = 'Dar un objeto a un jugador',
  ['command_giveitem_item'] = 'Nombre del artículo',
  ['command_giveitem_count'] = 'Cantidad de articulos',
  ['command_giveweapon'] = 'Dar un arma a un jugador',
  ['command_giveweapon_weapon'] = 'Nombre del arma',
  ['command_giveweapon_ammo'] = 'Cantidad de municion',
  ['command_giveweapon_hasalready'] = 'El jugador ya tiene esa arma',
  ['command_giveweaponcomponent'] = 'Dar el componente del arma',
  ['command_giveweaponcomponent_component'] = 'Nombre del componente',
  ['command_giveweaponcomponent_invalid'] = 'Componente del arma no válido',
  ['command_giveweaponcomponent_hasalready'] = 'El jugador ya tiene ese componente del arma',
  ['command_giveweaponcomponent_missingweapon'] = 'El jugador no tiene esa arma',
  ['command_goto'] = 'Teletransporte hacia un jugador',
  ['command_kill'] = 'Matar un jugador',
  ['command_save'] = 'Guardar un jugador en la base de datos',
  ['command_saveall'] = 'Guardar todos los jugadores en la base de datos',
  ['command_setaccountmoney'] = 'Establecer el dinero de la cuenta para un jugador',
  ['command_setaccountmoney_amount'] = 'Cantidad de dinero para fijar',
  ['command_setcoords'] = 'Teletransporte a coordenadas',
  ['command_setcoords_x'] = 'Eje X',
  ['command_setcoords_y'] = 'Eje Y',
  ['command_setcoords_z'] = 'Eje Z',
  ['command_setjob'] = 'Dar un trabajo a un jugador',
  ['command_setjob_job'] = 'Nombre del trabajo',
  ['command_setjob_grade'] = 'Rango del trabajo',
  ['command_setjob_invalid'] = 'El trabajo, el rango o ambos no son válidos',
  ['command_setgroup'] = 'Establecer el grupo de un jugador',
  ['command_setgroup_group'] = 'Nombre del grupo',
  ['commanderror_argumentmismatch'] = 'error en el recuento de argumentos (pasado %s, deseado %s)',
  ['commanderror_argumentmismatch_number'] = 'argumento #%s tipo no coincide (cadena pasada, número deseado)',
  ['commanderror_invaliditem'] = 'Nombre del artículo no válido',
  ['commanderror_invalidweapon'] = 'Arma inválida',
  ['commanderror_console'] = 'Ese comando no se puede ejecutar desde la consola',
  ['commanderror_invalidcommand'] = '/%s ¡No es un comando válido!',
  ['commanderror_invalidplayerid'] = 'No hay ningún jugador en línea que coincida con la ID del servidor',
  ['commandgeneric_playerid'] = 'ID del jugador',
  ['command_giveammo_noweapon_found'] = '%s does not have that weapon',
  ['command_giveammo_weapon'] = 'Weapon name',
  ['command_giveammo_ammo'] = 'Ammo Quantity',
  ['tpm_nowaypoint'] = 'No has marcado el destino',
  ['tpm_success'] = 'Teletransporte completado',
  ['noclip_message'] = 'Noclip ha sido %s',
  ['enabled'] = '~g~activado~s~',
  ['disabled'] = '~r~desactivado~s~', 

  -- Locale settings
  ['locale_digit_grouping_symbol'] = ',',
  ['locale_currency'] = '$%s',

  -- Weapons

  -- Melee
  ['weapon_dagger'] = 'Daga',
  ['weapon_bat'] = 'Bate',
  ['weapon_battleaxe'] = 'Hacha de combate',
  ['weapon_bottle'] = 'Botella',
  ['weapon_crowbar'] = 'Palanca',
  ['weapon_flashlight'] = 'Linterna',
  ['weapon_golfclub'] = 'Palos de Golf',
  ['weapon_hammer'] = 'Martillo',
  ['weapon_hatchet'] = 'Hacha',
  ['weapon_knife'] = 'Cuchillo',
  ['weapon_knuckle'] = 'Puños Americanos',
  ['weapon_machete'] = 'Machete',
  ['weapon_nightstick'] = 'Porra',
  ['weapon_wrench'] = 'Llave Inglesa',
  ['weapon_poolcue'] = 'Taco de Billar',
  ['weapon_stone_hatchet'] = 'Hacha de Piedra',
  ['weapon_switchblade'] = 'Navaja',

  -- Handguns
  ['weapon_appistol'] = 'Pistola AP ',
  ['weapon_ceramicpistol'] = 'Pistola Corta',
  ['weapon_combatpistol'] = 'Pistola Combate',
  ['weapon_doubleaction'] = 'Revólver de Doble Acción',
  ['weapon_navyrevolver'] = 'Revólver de la Armada',
  ['weapon_flaregun'] = 'Pistola de Bengalas',
  ['weapon_gadgetpistol'] = 'Pistola de Perico',
  ['weapon_heavypistol'] = 'Pistola Pesada',
  ['weapon_revolver'] = 'Revólver Pesado',
  ['weapon_revolver_mk2'] = 'Revólver Pesado MK2',
  ['weapon_marksmanpistol'] = 'Pistola Marksman',
  ['weapon_pistol'] = 'Pistola',
  ['weapon_pistol_mk2'] = 'Pistola MK2',
  ['weapon_pistol50'] = 'Pistola .50',
  ['weapon_snspistol'] = 'Pistola SNS',
  ['weapon_snspistol_mk2'] = 'Pistola SNS MK2',
  ['weapon_stungun'] = 'Tazer',
  ['weapon_raypistol'] = 'Up-N-Atomizer',
  ['weapon_vintagepistol'] = 'Pistola Vintage',

  -- Shotguns
  ['weapon_assaultshotgun'] = 'Escopeta de Asalto',
  ['weapon_autoshotgun'] = 'Escopeta Automática',
  ['weapon_bullpupshotgun'] = 'Escopeta Bullpup',
  ['weapon_combatshotgun'] = 'Escopeta Combate',
  ['weapon_dbshotgun'] = 'Escopeta de Doble Barril',
  ['weapon_heavyshotgun'] = 'Escopeta Pesada',
  ['weapon_musket'] = 'Mosquete',
  ['weapon_pumpshotgun'] = 'Escopeta de Bombeo',
  ['weapon_pumpshotgun_mk2'] = 'Escopeta de Bombeo MK2',
  ['weapon_sawnoffshotgun'] = 'Escopeta Recortada',

  -- SMG & LMG
  ['weapon_assaultsmg'] = 'Subfusil de Asalto',
  ['weapon_combatmg'] = 'Ametralladora de Combate',
  ['weapon_combatmg_mk2'] = 'Ametralladora MK2',
  ['weapon_combatpdw'] = 'Subfusil PDW',
  ['weapon_gusenberg'] = 'Subfusil de Barril',
  ['weapon_machinepistol'] = 'Pistola Ametralladora',
  ['weapon_mg'] = 'Ametralladora',
  ['weapon_microsmg'] = 'Micro Subfusil',
  ['weapon_minismg'] = 'Mini Subfusil',
  ['weapon_smg'] = 'Subfusil',
  ['weapon_smg_mk2'] = 'Subfusil MK2',
  ['weapon_raycarbine'] = 'Ametralladora de Rayos',

  -- Rifles
  ['weapon_advancedrifle'] = 'Rifle Avanzado',
  ['weapon_assaultrifle'] = 'Rifle de Asalto',
  ['weapon_assaultrifle_mk2'] = 'Rifle de Asalto MK2',
  ['weapon_bullpuprifle'] = 'Rifle Bullpup',
  ['weapon_bullpuprifle_mk2'] = 'Rifle Bullpup MK2',
  ['weapon_carbinerifle'] = 'Carabina',
  ['weapon_carbinerifle_mk2'] = 'Carabina MK2',
  ['weapon_compactrifle'] = 'Rifle Compacto',
  ['weapon_militaryrifle'] = 'Rifle Militar',
  ['weapon_specialcarbine'] = 'Carabina Especial',
  ['weapon_specialcarbine_mk2'] = 'Carabina Especial MK2',

  -- Sniper
  ['weapon_heavysniper'] = 'Francotirador Pesado',
  ['weapon_heavysniper_mk2'] = 'Francotirador Pesado MK2',
  ['weapon_marksmanrifle'] = 'Rifle Marksman',
  ['weapon_marksmanrifle_mk2'] = 'Rifle Marksman MK2',
  ['weapon_sniperrifle'] = 'Rifle de Francotirador',

  -- Heavy / Launchers
  ['weapon_compactlauncher'] = 'Lanzador Compacto',
  ['weapon_firework'] = 'Lanzador de Fuegos Artificiales',
  ['weapon_grenadelauncher'] = 'Lanzagranadas',
  ['weapon_hominglauncher'] = 'Lanzacohetes Guiado',
  ['weapon_minigun'] = 'Minigun',
  ['weapon_railgun'] = 'Cañón de riel',
  ['weapon_rpg'] = 'Lanzador de cohetes',
  ['weapon_rayminigun'] = 'Minigun de Rayos',
	
	  -- Criminal Enterprises DLC
  ['weapon_metaldetector'] = 'Detector de Metales',
  ['weapon_precisionrifle'] = 'Rifle de Precision',
  ['weapon_tactilerifle'] = 'Carabina Tactica', 

  -- Thrown
  ['weapon_ball'] = 'Pelota de Beisbol',
  ['weapon_bzgas'] = 'Gas Pimienta',
  ['weapon_flare'] = 'Bengala',
  ['weapon_grenade'] = 'Granada',
  ['weapon_petrolcan'] = 'Bidon de Gasolina',
  ['weapon_hazardcan'] = 'Bidón de Gasolina Peligroso',
  ['weapon_molotov'] = 'Molotov',
  ['weapon_proxmine'] = 'Mina de Proximidad ',
  ['weapon_pipebomb'] = 'Bomba de Tubo',
  ['weapon_snowball'] = 'Bola de nieve',
  ['weapon_stickybomb'] = 'Bomba Pegajosa',
  ['weapon_smokegrenade'] = 'Granada de Humo',

  -- Special
  ['weapon_fireextinguisher'] = 'Extintor',
  ['weapon_digiscanner'] = 'Escaner Digital',
  ['weapon_garbagebag'] = 'Bolsa de Basura',
  ['weapon_handcuffs'] = 'Grilletes',
  ['gadget_nightvision'] = 'Vision Nocturna',
  ['gadget_parachute'] = 'Paracaidas',

  -- Weapon Components
  ['component_knuckle_base'] = 'Modelo Basico',
  ['component_knuckle_pimp'] = 'el Proxeneta',
  ['component_knuckle_ballas'] = 'los Ballas',
  ['component_knuckle_dollar'] = 'el Buscavidas',
  ['component_knuckle_diamond'] = 'la Roca',
  ['component_knuckle_hate'] = 'el Hater',
  ['component_knuckle_love'] = 'el Amante',
  ['component_knuckle_player'] = 'el Jugador',
  ['component_knuckle_king'] = 'el Rey',
  ['component_knuckle_vagos'] = 'los Vagos',

  ['component_luxary_finish'] = 'Acabado de Armas de Lujo',

  ['component_handle_default'] = 'Mango Default',
  ['component_handle_vip'] = 'Mango VIP',
  ['component_handle_bodyguard'] = 'Mango de Guardaespaldas',

  ['component_vip_finish'] = 'Acabado VIP',
  ['component_bodyguard_finish'] = 'Acabado Guardaespaldas',

  ['component_camo_finish'] = 'Camuflaje Digital',
  ['component_camo_finish2'] = 'Camuflaje Pincelada',
  ['component_camo_finish3'] = 'Camuflaje Bosque',
  ['component_camo_finish4'] = 'Camuflaje Calavera',
  ['component_camo_finish5'] = 'Camuflaje Sessanta Nove',
  ['component_camo_finish6'] = 'Camuflaje Perseo',
  ['component_camo_finish7'] = 'Camuflaje Leopardo',
  ['component_camo_finish8'] = 'Camuflaje Zebra',
  ['component_camo_finish9'] = 'Camuflaje Geométrico',
  ['component_camo_finish10'] = 'Camuflaje Boom',
  ['component_camo_finish11'] = 'Camuflaje Patriotico',

  ['component_camo_slide_finish'] = 'Camuflaje Digital Deslizante',
  ['component_camo_slide_finish2'] = 'Camuflaje Pincelada Deslizante',
  ['component_camo_slide_finish3'] = 'Camuflaje Bosque Deslizante',
  ['component_camo_slide_finish4'] = 'Camuflaje Calavera Deslizante',
  ['component_camo_slide_finish5'] = 'Camuflaje Sessanta Nove Deslizante',
  ['component_camo_slide_finish6'] = 'Camuflaje Perseo Deslizante',
  ['component_camo_slide_finish7'] = 'Camuflaje Leopardo Deslizante',
  ['component_camo_slide_finish8'] = 'Camuflaje Zebra Deslizante',
  ['component_camo_slide_finish9'] = 'Camuflaje Geométrico Deslizante',
  ['component_camo_slide_finish10'] = 'Camuflaje Boom Deslizante',
  ['component_camo_slide_finish11'] = 'Camuflaje Patriotico Deslizante',

  ['component_clip_default'] = 'Cargador Default',
  ['component_clip_extended'] = 'Cargador Extendido',
  ['component_clip_drum'] = 'Cargador Barril',
  ['component_clip_box'] = 'Caja de Cargador',

  ['component_scope_holo'] = 'Mira Holográfico',
  ['component_scope_small'] = 'Mira Pequeña',
  ['component_scope_medium'] = 'Mira Mediana',
  ['component_scope_large'] = 'Mira Larga',
  ['component_scope'] = 'Mira',
  ['component_scope_advanced'] = 'Mira Avanzada',
  ['component_ironsights'] = 'Mira de Hierro',

  ['component_suppressor'] = 'Supresor',
  ['component_compensator'] = 'Compensador',

  ['component_muzzle_flat'] = 'Boquilla de Freno Plana',
  ['component_muzzle_tactical'] = 'Boquilla de Freno Tactica',
  ['component_muzzle_fat'] = 'Boquilla de Freno Punta Gorda',
  ['component_muzzle_precision'] = 'Boquilla de Freno de Precision',
  ['component_muzzle_heavy'] = 'Boquilla de Freno Pesada',
  ['component_muzzle_slanted'] = 'Boquilla de Freno inclinada',
  ['component_muzzle_split'] = 'Boquilla de Freno de Puntas Abiertas',
  ['component_muzzle_squared'] = 'Boquilla de Freno Cuadrada',

  ['component_flashlight'] = 'Linterna',
  ['component_grip'] = 'Agarre',

  ['component_barrel_default'] = 'Barril Por Defecto',
  ['component_barrel_heavy'] = 'Barril Pesado',

  ['component_ammo_tracer'] = 'Munición de Rastreo',
  ['component_ammo_incendiary'] = 'Munición Incendiaria',
  ['component_ammo_hollowpoint'] = 'Munición de Punta Hueca',
  ['component_ammo_fmj'] = 'Munición fMJ',
  ['component_ammo_armor'] = 'Munición Perforante para Blindaje',
  ['component_ammo_explosive'] = 'Munición Incendiaria Perforadora de Blindajes',

  ['component_shells_default'] = 'Casquillos Por Defecto',
  ['component_shells_incendiary'] = 'Casquillos Aliento de Dragón',
  ['component_shells_armor'] = 'Casquillos Perdigones de Acero',
  ['component_shells_hollowpoint'] = 'Casquillos Punta Hueca',
  ['component_shells_explosive'] = 'Casquillos Posta Explosiva',

  -- Weapon Ammo
  ['ammo_rounds'] = 'Redonda/s',
  ['ammo_shells'] = 'Casquillo/s',
  ['ammo_charge'] = 'Carga',
  ['ammo_petrol'] = 'Galones de Combustible',
  ['ammo_firework'] = 'Fuegos Artificiale/s',
  ['ammo_rockets'] = 'Cohete/s',
  ['ammo_grenadelauncher'] = 'Granada/s',
  ['ammo_grenade'] = 'Granada/s',
  ['ammo_stickybomb'] = 'Bomba/s',
  ['ammo_pipebomb'] = 'Bomba/s',
  ['ammo_smokebomb'] = 'Bomba/s',
  ['ammo_molotov'] = 'Molotov/s',
  ['ammo_proxmine'] = 'Mina(s)',
  ['ammo_bzgas'] = 'Lata(s)',
  ['ammo_ball'] = 'Bola(s)',
  ['ammo_snowball'] = 'Bola(s)',
  ['ammo_flare'] = 'Bengala(s)',
  ['ammo_flaregun'] = 'Bengala(s)',

  -- Weapon Tints
  ['tint_default'] = 'Skin Por Defecto',
  ['tint_green'] = 'Skin Verde',
  ['tint_gold'] = 'Skin Oro',
  ['tint_pink'] = 'Skin Rosa',
  ['tint_army'] = 'Skin Militar',
  ['tint_lspd'] = 'Skin Azul',
  ['tint_orange'] = 'Skin Naranja',
  ['tint_platinum'] = 'Skin Plata',
  
  -- Duty related
  ['stopped_duty'] = 'Has salido de servicio.',
  ['started_duty'] = 'Has entrado de servicio.',
}
