Config.DefaultWeaponTints = {
	[0] = _U('tint_default'),
	[1] = _U('tint_green'),
	[2] = _U('tint_gold'),
	[3] = _U('tint_pink'),
	[4] = _U('tint_army'),
	[5] = _U('tint_lspd'),
	[6] = _U('tint_orange'),
	[7] = _U('tint_platinum')
}

Config.Weapons = {
	{
		name = 'WEAPON_PISTOL',
		label = _U('weapon_pistol'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_PISTOL')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_PISTOL_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_PISTOL_CLIP_02')},
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_PI_FLSH')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_PI_SUPP_02')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_PISTOL_VARMOD_LUXE')}
		}
	},

	{
		name = 'WEAPON_COMBATPISTOL',
		label = _U('weapon_combatpistol'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_PISTOL')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_COMBATPISTOL_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_COMBATPISTOL_CLIP_02')},
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_PI_FLSH')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_PI_SUPP')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_COMBATPISTOL_VARMOD_LOWRIDER')}
		}
	},

	{
		name = 'WEAPON_APPISTOL',
		label = _U('weapon_appistol'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_PISTOL')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_APPISTOL_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_APPISTOL_CLIP_02')},
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_PI_FLSH')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_PI_SUPP')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_APPISTOL_VARMOD_LUXE')}
		}
	},

	{
		name = 'WEAPON_PISTOL50',
		label = _U('weapon_pistol50'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_PISTOL')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_PISTOL50_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_PISTOL50_CLIP_02')},
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_PI_FLSH')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_AR_SUPP_02')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_PISTOL50_VARMOD_LUXE')}
		}
	},

	{
		name = 'WEAPON_SNSPISTOL',
		label = _U('weapon_snspistol'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_PISTOL')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_SNSPISTOL_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_SNSPISTOL_CLIP_02')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_SNSPISTOL_VARMOD_LOWRIDER')}
		}
	},

	{
		name = 'WEAPON_HEAVYPISTOL',
		label = _U('weapon_heavypistol'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_PISTOL')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_HEAVYPISTOL_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_HEAVYPISTOL_CLIP_02')},
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_PI_FLSH')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_PI_SUPP')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_HEAVYPISTOL_VARMOD_LUXE')}
		}
	},

	{
		name = 'WEAPON_VINTAGEPISTOL',
		label = _U('weapon_vintagepistol'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_PISTOL')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_VINTAGEPISTOL_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_VINTAGEPISTOL_CLIP_02')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_PI_SUPP')}
		}
	},

	{
		name = 'WEAPON_MACHINEPISTOL',
		label = _U('weapon_machinepistol'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_PISTOL')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_MACHINEPISTOL_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_MACHINEPISTOL_CLIP_02')},
			{name = 'clip_drum', label = _U('component_clip_drum'), hash = GetHashKey('COMPONENT_MACHINEPISTOL_CLIP_03')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_PI_SUPP')}
		}
	},

	{name = 'WEAPON_REVOLVER', label = _U('weapon_revolver'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_PISTOL')}},
	{name = 'WEAPON_MARKSMANPISTOL', label = _U('weapon_marksmanpistol'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_PISTOL')}},
	{name = 'WEAPON_DOUBLEACTION', label = _U('weapon_doubleaction'), components = {}, ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_PISTOL')}},

	{
		name = 'WEAPON_SMG',
		label = _U('weapon_smg'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_SMG')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_SMG_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_SMG_CLIP_02')},
			{name = 'clip_drum', label = _U('component_clip_drum'), hash = GetHashKey('COMPONENT_SMG_CLIP_03')},
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_AR_FLSH')},
			{name = 'scope', label = _U('component_scope'), hash = GetHashKey('COMPONENT_AT_SCOPE_MACRO_02')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_PI_SUPP')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_SMG_VARMOD_LUXE')}
		}
	},

	{
		name = 'WEAPON_ASSAULTSMG',
		label = _U('weapon_assaultsmg'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_SMG')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_ASSAULTSMG_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_ASSAULTSMG_CLIP_02')},
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_AR_FLSH')},
			{name = 'scope', label = _U('component_scope'), hash = GetHashKey('COMPONENT_AT_SCOPE_MACRO')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_AR_SUPP_02')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_ASSAULTSMG_VARMOD_LOWRIDER')}
		}
	},

	{
		name = 'WEAPON_MICROSMG',
		label = _U('weapon_microsmg'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_SMG')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_MICROSMG_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_MICROSMG_CLIP_02')},
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_PI_FLSH')},
			{name = 'scope', label = _U('component_scope'), hash = GetHashKey('COMPONENT_AT_SCOPE_MACRO')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_AR_SUPP_02')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_MICROSMG_VARMOD_LUXE')}
		}
	},

	{
		name = 'WEAPON_MINISMG',
		label = _U('weapon_minismg'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_SMG')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_MINISMG_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_MINISMG_CLIP_02')}
		}
	},

	{
		name = 'WEAPON_COMBATPDW',
		label = _U('weapon_combatpdw'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_SMG')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_COMBATPDW_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_COMBATPDW_CLIP_02')},
			{name = 'clip_drum', label = _U('component_clip_drum'), hash = GetHashKey('COMPONENT_COMBATPDW_CLIP_03')},
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_AR_FLSH')},
			{name = 'grip', label = _U('component_grip'), hash = GetHashKey('COMPONENT_AT_AR_AFGRIP')},
			{name = 'scope', label = _U('component_scope'), hash = GetHashKey('COMPONENT_AT_SCOPE_SMALL')}
		}
	},

	{
		name = 'WEAPON_PUMPSHOTGUN',
		label = _U('weapon_pumpshotgun'),
		ammo = {label = _U('ammo_shells'), hash = GetHashKey('AMMO_SHOTGUN')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_AR_FLSH')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_SR_SUPP')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_PUMPSHOTGUN_VARMOD_LOWRIDER')}
		}
	},

	{
		name = 'WEAPON_SAWNOFFSHOTGUN',
		label = _U('weapon_sawnoffshotgun'),
		ammo = {label = _U('ammo_shells'), hash = GetHashKey('AMMO_SHOTGUN')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_SAWNOFFSHOTGUN_VARMOD_LUXE')}
		}
	},

	{
		name = 'WEAPON_ASSAULTSHOTGUN',
		label = _U('weapon_assaultshotgun'),
		ammo = {label = _U('ammo_shells'), hash = GetHashKey('AMMO_SHOTGUN')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_ASSAULTSHOTGUN_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_ASSAULTSHOTGUN_CLIP_02')},
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_AR_FLSH')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_AR_SUPP')},
			{name = 'grip', label = _U('component_grip'), hash = GetHashKey('COMPONENT_AT_AR_AFGRIP')}
		}
	},

	{
		name = 'WEAPON_BULLPUPSHOTGUN',
		label = _U('weapon_bullpupshotgun'),
		ammo = {label = _U('ammo_shells'), hash = GetHashKey('AMMO_SHOTGUN')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_AR_FLSH')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_AR_SUPP_02')},
			{name = 'grip', label = _U('component_grip'), hash = GetHashKey('COMPONENT_AT_AR_AFGRIP')}
		}
	},

	{
		name = 'WEAPON_HEAVYSHOTGUN',
		label = _U('weapon_heavyshotgun'),
		ammo = {label = _U('ammo_shells'), hash = GetHashKey('AMMO_SHOTGUN')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_HEAVYSHOTGUN_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_HEAVYSHOTGUN_CLIP_02')},
			{name = 'clip_drum', label = _U('component_clip_drum'), hash = GetHashKey('COMPONENT_HEAVYSHOTGUN_CLIP_03')},
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_AR_FLSH')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_AR_SUPP_02')},
			{name = 'grip', label = _U('component_grip'), hash = GetHashKey('COMPONENT_AT_AR_AFGRIP')}
		}
	},

	{name = 'WEAPON_DBSHOTGUN', label = _U('weapon_dbshotgun'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = _U('ammo_shells'), hash = GetHashKey('AMMO_SHOTGUN')}},
	{name = 'WEAPON_AUTOSHOTGUN', label = _U('weapon_autoshotgun'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = _U('ammo_shells'), hash = GetHashKey('AMMO_SHOTGUN')}},
	{name = 'WEAPON_MUSKET', label = _U('weapon_musket'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_SHOTGUN')}},

	{
		name = 'WEAPON_ASSAULTRIFLE',
		label = _U('weapon_assaultrifle'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_RIFLE')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_ASSAULTRIFLE_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_ASSAULTRIFLE_CLIP_02')},
			{name = 'clip_drum', label = _U('component_clip_drum'), hash = GetHashKey('COMPONENT_ASSAULTRIFLE_CLIP_03')},
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_AR_FLSH')},
			{name = 'scope', label = _U('component_scope'), hash = GetHashKey('COMPONENT_AT_SCOPE_MACRO')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_AR_SUPP_02')},
			{name = 'grip', label = _U('component_grip'), hash = GetHashKey('COMPONENT_AT_AR_AFGRIP')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_ASSAULTRIFLE_VARMOD_LUXE')}
		}
	},

	{
		name = 'WEAPON_CARBINERIFLE',
		label = _U('weapon_carbinerifle'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_RIFLE')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_CARBINERIFLE_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_CARBINERIFLE_CLIP_02')},
			{name = 'clip_box', label = _U('component_clip_box'), hash = GetHashKey('COMPONENT_CARBINERIFLE_CLIP_03')},
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_AR_FLSH')},
			{name = 'scope', label = _U('component_scope'), hash = GetHashKey('COMPONENT_AT_SCOPE_MEDIUM')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_AR_SUPP')},
			{name = 'grip', label = _U('component_grip'), hash = GetHashKey('COMPONENT_AT_AR_AFGRIP')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_CARBINERIFLE_VARMOD_LUXE')}
		}
	},

	{
		name = 'WEAPON_ADVANCEDRIFLE',
		label = _U('weapon_advancedrifle'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_RIFLE')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_ADVANCEDRIFLE_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_ADVANCEDRIFLE_CLIP_02')},
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_AR_FLSH')},
			{name = 'scope', label = _U('component_scope'), hash = GetHashKey('COMPONENT_AT_SCOPE_SMALL')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_AR_SUPP')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_ADVANCEDRIFLE_VARMOD_LUXE')}
		}
	},

	{
		name = 'WEAPON_SPECIALCARBINE',
		label = _U('weapon_specialcarbine'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_RIFLE')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_SPECIALCARBINE_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_SPECIALCARBINE_CLIP_02')},
			{name = 'clip_drum', label = _U('component_clip_drum'), hash = GetHashKey('COMPONENT_SPECIALCARBINE_CLIP_03')},
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_AR_FLSH')},
			{name = 'scope', label = _U('component_scope'), hash = GetHashKey('COMPONENT_AT_SCOPE_MEDIUM')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_AR_SUPP_02')},
			{name = 'grip', label = _U('component_grip'), hash = GetHashKey('COMPONENT_AT_AR_AFGRIP')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_SPECIALCARBINE_VARMOD_LOWRIDER')}
		}
	},

	{
		name = 'WEAPON_BULLPUPRIFLE',
		label = _U('weapon_bullpuprifle'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_RIFLE')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_BULLPUPRIFLE_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_BULLPUPRIFLE_CLIP_02')},
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_AR_FLSH')},
			{name = 'scope', label = _U('component_scope'), hash = GetHashKey('COMPONENT_AT_SCOPE_SMALL')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_AR_SUPP')},
			{name = 'grip', label = _U('component_grip'), hash = GetHashKey('COMPONENT_AT_AR_AFGRIP')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_BULLPUPRIFLE_VARMOD_LOW')}
		}
	},

	{
		name = 'WEAPON_COMPACTRIFLE',
		label = _U('weapon_compactrifle'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_RIFLE')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_COMPACTRIFLE_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_COMPACTRIFLE_CLIP_02')},
			{name = 'clip_drum', label = _U('component_clip_drum'), hash = GetHashKey('COMPONENT_COMPACTRIFLE_CLIP_03')}
		}
	},

	{
		name = 'WEAPON_MG',
		label = _U('weapon_mg'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_MG')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_MG_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_MG_CLIP_02')},
			{name = 'scope', label = _U('component_scope'), hash = GetHashKey('COMPONENT_AT_SCOPE_SMALL_02')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_MG_VARMOD_LOWRIDER')}
		}
	},

	{
		name = 'WEAPON_COMBATMG',
		label = _U('weapon_combatmg'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_MG')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_COMBATMG_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_COMBATMG_CLIP_02')},
			{name = 'scope', label = _U('component_scope'), hash = GetHashKey('COMPONENT_AT_SCOPE_MEDIUM')},
			{name = 'grip', label = _U('component_grip'), hash = GetHashKey('COMPONENT_AT_AR_AFGRIP')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_COMBATMG_VARMOD_LOWRIDER')}
		}
	},

	{
		name = 'WEAPON_GUSENBERG',
		label = _U('weapon_gusenberg'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_MG')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_GUSENBERG_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_GUSENBERG_CLIP_02')},
		}
	},

	{
		name = 'WEAPON_SNIPERRIFLE',
		label = _U('weapon_sniperrifle'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_SNIPER')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'scope', label = _U('component_scope'), hash = GetHashKey('COMPONENT_AT_SCOPE_LARGE')},
			{name = 'scope_advanced', label = _U('component_scope_advanced'), hash = GetHashKey('COMPONENT_AT_SCOPE_MAX')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_AR_SUPP_02')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_SNIPERRIFLE_VARMOD_LUXE')}
		}
	},

	{
		name = 'WEAPON_HEAVYSNIPER',
		label = _U('weapon_heavysniper'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_SNIPER')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'scope', label = _U('component_scope'), hash = GetHashKey('COMPONENT_AT_SCOPE_LARGE')},
			{name = 'scope_advanced', label = _U('component_scope_advanced'), hash = GetHashKey('COMPONENT_AT_SCOPE_MAX')}
		}
	},

	{
		name = 'WEAPON_MARKSMANRIFLE',
		label = _U('weapon_marksmanrifle'),
		ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_SNIPER')},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = _U('component_clip_default'), hash = GetHashKey('COMPONENT_MARKSMANRIFLE_CLIP_01')},
			{name = 'clip_extended', label = _U('component_clip_extended'), hash = GetHashKey('COMPONENT_MARKSMANRIFLE_CLIP_02')},
			{name = 'flashlight', label = _U('component_flashlight'), hash = GetHashKey('COMPONENT_AT_AR_FLSH')},
			{name = 'scope', label = _U('component_scope'), hash = GetHashKey('COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM')},
			{name = 'suppressor', label = _U('component_suppressor'), hash = GetHashKey('COMPONENT_AT_AR_SUPP')},
			{name = 'grip', label = _U('component_grip'), hash = GetHashKey('COMPONENT_AT_AR_AFGRIP')},
			{name = 'luxary_finish', label = _U('component_luxary_finish'), hash = GetHashKey('COMPONENT_MARKSMANRIFLE_VARMOD_LUXE')}
		}
	},

	{name = 'WEAPON_MINIGUN', label = _U('weapon_minigun'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_MINIGUN')}},
	{name = 'WEAPON_RAILGUN', label = _U('weapon_railgun'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = _U('ammo_rounds'), hash = GetHashKey('AMMO_RAILGUN')}},
	{name = 'WEAPON_STUNGUN', label = _U('weapon_stungun'), tints = Config.DefaultWeaponTints, components = {}},
	{name = 'WEAPON_RPG', label = _U('weapon_rpg'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = _U('ammo_rockets'), hash = GetHashKey('AMMO_RPG')}},
	{name = 'WEAPON_HOMINGLAUNCHER', label = _U('weapon_hominglauncher'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = _U('ammo_rockets'), hash = GetHashKey('AMMO_HOMINGLAUNCHER')}},
	{name = 'WEAPON_GRENADELAUNCHER', label = _U('weapon_grenadelauncher'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = _U('ammo_grenadelauncher'), hash = GetHashKey('AMMO_GRENADELAUNCHER')}},
	{name = 'WEAPON_COMPACTLAUNCHER', label = _U('weapon_compactlauncher'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = _U('ammo_grenadelauncher'), hash = GetHashKey('AMMO_GRENADELAUNCHER')}},
	{name = 'WEAPON_FLAREGUN', label = _U('weapon_flaregun'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = _U('ammo_flaregun'), hash = GetHashKey('AMMO_FLAREGUN')}},
	{name = 'WEAPON_FIREEXTINGUISHER', label = _U('weapon_fireextinguisher'), components = {}, ammo = {label = _U('ammo_charge'), hash = GetHashKey('AMMO_FIREEXTINGUISHER')}},
	{name = 'WEAPON_PETROLCAN', label = _U('weapon_petrolcan'), components = {}, ammo = {label = _U('ammo_petrol'), hash = GetHashKey('AMMO_PETROLCAN')}},
	{name = 'WEAPON_FIREWORK', label = _U('weapon_firework'), components = {}, ammo = {label = _U('ammo_firework'), hash = GetHashKey('AMMO_FIREWORK')}},
	{name = 'WEAPON_FLASHLIGHT', label = _U('weapon_flashlight'), components = {}},
	{name = 'GADGET_PARACHUTE', label = _U('gadget_parachute'), components = {}},
	{name = 'WEAPON_KNUCKLE', label = _U('weapon_knuckle'), components = {}},
	{name = 'WEAPON_HATCHET', label = _U('weapon_hatchet'), components = {}},
	{name = 'WEAPON_MACHETE', label = _U('weapon_machete'), components = {}},
	{name = 'WEAPON_SWITCHBLADE', label = _U('weapon_switchblade'), components = {}},
	{name = 'WEAPON_BOTTLE', label = _U('weapon_bottle'), components = {}},
	{name = 'WEAPON_DAGGER', label = _U('weapon_dagger'), components = {}},
	{name = 'WEAPON_POOLCUE', label = _U('weapon_poolcue'), components = {}},
	{name = 'WEAPON_WRENCH', label = _U('weapon_wrench'), components = {}},
	{name = 'WEAPON_BATTLEAXE', label = _U('weapon_battleaxe'), components = {}},
	{name = 'WEAPON_KNIFE', label = _U('weapon_knife'), components = {}},
	{name = 'WEAPON_NIGHTSTICK', label = _U('weapon_nightstick'), components = {}},
	{name = 'WEAPON_HAMMER', label = _U('weapon_hammer'), components = {}},
	{name = 'WEAPON_BAT', label = _U('weapon_bat'), components = {}},
	{name = 'WEAPON_GOLFCLUB', label = _U('weapon_golfclub'), components = {}},
	{name = 'WEAPON_CROWBAR', label = _U('weapon_crowbar'), components = {}},

	{name = 'WEAPON_GRENADE', label = _U('weapon_grenade'), components = {}, ammo = {label = _U('ammo_grenade'), hash = GetHashKey('AMMO_GRENADE')}},
	{name = 'WEAPON_SMOKEGRENADE', label = _U('weapon_smokegrenade'), components = {}, ammo = {label = _U('ammo_smokebomb'), hash = GetHashKey('AMMO_SMOKEGRENADE')}},
	{name = 'WEAPON_STICKYBOMB', label = _U('weapon_stickybomb'), components = {}, ammo = {label = _U('ammo_stickybomb'), hash = GetHashKey('AMMO_STICKYBOMB')}},
	{name = 'WEAPON_PIPEBOMB', label = _U('weapon_pipebomb'), components = {}, ammo = {label = _U('ammo_pipebomb'), hash = GetHashKey('AMMO_PIPEBOMB')}},
	{name = 'WEAPON_BZGAS', label = _U('weapon_bzgas'), components = {}, ammo = {label = _U('ammo_bzgas'), hash = GetHashKey('AMMO_BZGAS')}},
	{name = 'WEAPON_MOLOTOV', label = _U('weapon_molotov'), components = {}, ammo = {label = _U('ammo_molotov'), hash = GetHashKey('AMMO_MOLOTOV')}},
	{name = 'WEAPON_PROXMINE', label = _U('weapon_proxmine'), components = {}, ammo = {label = _U('ammo_proxmine'), hash = GetHashKey('AMMO_PROXMINE')}},
	{name = 'WEAPON_SNOWBALL', label = _U('weapon_snowball'), components = {}, ammo = {label = _U('ammo_snowball'), hash = GetHashKey('AMMO_SNOWBALL')}},
	{name = 'WEAPON_BALL', label = _U('weapon_ball'), components = {}, ammo = {label = _U('ammo_ball'), hash = GetHashKey('AMMO_BALL')}},
	{name = 'WEAPON_FLARE', label = _U('weapon_flare'), components = {}, ammo = {label = _U('ammo_flare'), hash = GetHashKey('AMMO_FLARE')}}
}
