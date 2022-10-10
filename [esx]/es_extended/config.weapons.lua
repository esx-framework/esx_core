Config.DefaultWeaponTints = {
	[0] = TranslateCap('tint_default'),
	[1] = TranslateCap('tint_green'),
	[2] = TranslateCap('tint_gold'),
	[3] = TranslateCap('tint_pink'),
	[4] = TranslateCap('tint_army'),
	[5] = TranslateCap('tint_lspd'),
	[6] = TranslateCap('tint_orange'),
	[7] = TranslateCap('tint_platinum')
}

Config.Weapons = {
	-- Melee
	{name = 'WEAPON_DAGGER', label = TranslateCap('weapon_dagger'), components = {}},
	{name = 'WEAPON_BAT', label = TranslateCap('weapon_bat'), components = {}},
	{name = 'WEAPON_BATTLEAXE', label = TranslateCap('weapon_battleaxe'), components = {}},
	{
		name = 'WEAPON_KNUCKLE',
		label = TranslateCap('weapon_knuckle'),
		components = {
			{name = 'knuckle_base', label = TranslateCap('component_knuckle_base'), hash = `COMPONENT_KNUCKLE_VARMOD_BASE`},
			{name = 'knuckle_pimp', label = TranslateCap('component_knuckle_pimp'), hash = `COMPONENT_KNUCKLE_VARMOD_PIMP`},
			{name = 'knuckle_ballas', label = TranslateCap('component_knuckle_ballas'), hash = `COMPONENT_KNUCKLE_VARMOD_BALLAS`},
			{name = 'knuckle_dollar', label = TranslateCap('component_knuckle_dollar'), hash = `COMPONENT_KNUCKLE_VARMOD_DOLLAR`},
			{name = 'knuckle_diamond', label = TranslateCap('component_knuckle_diamond'), hash = `COMPONENT_KNUCKLE_VARMOD_DIAMOND`},
			{name = 'knuckle_hate', label = TranslateCap('component_knuckle_hate'), hash = `COMPONENT_KNUCKLE_VARMOD_HATE`},
			{name = 'knuckle_love', label = TranslateCap('component_knuckle_love'), hash = `COMPONENT_KNUCKLE_VARMOD_LOVE`},
			{name = 'knuckle_player', label = TranslateCap('component_knuckle_player'), hash = `COMPONENT_KNUCKLE_VARMOD_PLAYER`},
			{name = 'knuckle_king', label = TranslateCap('component_knuckle_king'), hash = `COMPONENT_KNUCKLE_VARMOD_KING`},
			{name = 'knuckle_vagos', label = TranslateCap('component_knuckle_vagos'), hash = `COMPONENT_KNUCKLE_VARMOD_VAGOS`}
		}
	},
	{name = 'WEAPON_BOTTLE', label = TranslateCap('weapon_bottle'), components = {}},
	{name = 'WEAPON_CROWBAR', label = TranslateCap('weapon_crowbar'), components = {}},
	{name = 'WEAPON_FLASHLIGHT', label = TranslateCap('weapon_flashlight'), components = {}},
	{name = 'WEAPON_GOLFCLUB', label = TranslateCap('weapon_golfclub'), components = {}},
	{name = 'WEAPON_HAMMER', label = TranslateCap('weapon_hammer'), components = {}},
	{name = 'WEAPON_HATCHET', label = TranslateCap('weapon_hatchet'), components = {}},
	{name = 'WEAPON_KNIFE', label = TranslateCap('weapon_knife'), components = {}},
	{name = 'WEAPON_MACHETE', label = TranslateCap('weapon_machete'), components = {}},
	{name = 'WEAPON_NIGHTSTICK', label = TranslateCap('weapon_nightstick'), components = {}},
	{name = 'WEAPON_WRENCH', label = TranslateCap('weapon_wrench'), components = {}},
	{name = 'WEAPON_POOLCUE', label = TranslateCap('weapon_poolcue'), components = {}},
	{name = 'WEAPON_STONE_HATCHET', label = TranslateCap('weapon_stone_hatchet'), components = {}},
	{
		name = 'WEAPON_SWITCHBLADE',
		label = TranslateCap('weapon_switchblade'),
		components = {
			{name = 'handle_default', label = TranslateCap('component_handle_default'), hash = `COMPONENT_SWITCHBLADE_VARMOD_BASE`},
			{name = 'handle_vip', label = TranslateCap('component_handle_vip'), hash = `COMPONENT_SWITCHBLADE_VARMOD_VAR1`},
			{name = 'handle_bodyguard', label = TranslateCap('component_handle_bodyguard'), hash = `COMPONENT_SWITCHBLADE_VARMOD_VAR2`}
		}
	},
	-- Handguns
	{
		name = 'WEAPON_APPISTOL',
		label = TranslateCap('weapon_appistol'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_PISTOL`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_APPISTOL_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_APPISTOL_CLIP_02`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_PI_FLSH`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_PI_SUPP`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_APPISTOL_VARMOD_LUXE`}
		}
	},
	{name = 'WEAPON_CERAMICPISTOL', label = TranslateCap('weapon_ceramicpistol'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_PISTOL`}},
	{
		name = 'WEAPON_COMBATPISTOL',
		label = TranslateCap('weapon_combatpistol'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_PISTOL`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_COMBATPISTOL_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_COMBATPISTOL_CLIP_02`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_PI_FLSH`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_PI_SUPP`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_COMBATPISTOL_VARMOD_LOWRIDER`}
		}
	},
	{name = 'WEAPON_DOUBLEACTION', label = TranslateCap('weapon_doubleaction'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_PISTOL`}},
	{name = 'WEAPON_NAVYREVOLVER', label = TranslateCap('weapon_navyrevolver'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_PISTOL`}},
	{name = 'WEAPON_FLAREGUN', label = TranslateCap('weapon_flaregun'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = TranslateCap('ammo_flaregun'), hash = `AMMO_FLAREGUN`}},
	{name = 'WEAPON_GADGETPISTOL', label = TranslateCap('weapon_gadgetpistol'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_PISTOL`}},
	{
		name = 'WEAPON_HEAVYPISTOL',
		label = TranslateCap('weapon_heavypistol'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_PISTOL`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_HEAVYPISTOL_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_HEAVYPISTOL_CLIP_02`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_PI_FLSH`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_PI_SUPP`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_HEAVYPISTOL_VARMOD_LUXE`}
		}
	},
	{
		name = 'WEAPON_REVOLVER',
		label = TranslateCap('weapon_revolver'),
		ammo = {label = TranslateCap('ammo_rounds'),hash = `AMMO_PISTOL`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_REVOLVER_CLIP_01`},
			{name = 'vip_finish', label = TranslateCap('component_vip_finish'), hash = `COMPONENT_REVOLVER_VARMOD_BOSS`},
			{name = 'bodyguard_finish', label = TranslateCap('component_bodyguard_finish'), hash = `COMPONENT_REVOLVER_VARMOD_GOON`}
		}
	},
	{
		name = 'WEAPON_REVOLVER_MK2',
		label = TranslateCap('weapon_revolver_mk2'),
		ammo = {label = TranslateCap('ammo_rounds'),hash = `AMMO_PISTOL`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_REVOLVER_MK2_CLIP_01`},
			{name = 'ammo_tracer', label = TranslateCap('component_ammo_tracer'), hash = `COMPONENT_REVOLVER_MK2_CLIP_TRACER`},
			{name = 'ammo_incendiary', label = TranslateCap('component_ammo_incendiary'), hash = `COMPONENT_REVOLVER_MK2_CLIP_INCENDIARY`},
			{name = 'ammo_hollowpoint', label = TranslateCap('component_ammo_hollowpoint'), hash = `COMPONENT_REVOLVER_MK2_CLIP_HOLLOWPOINT`},
			{name = 'ammo_fmj', label = TranslateCap('component_ammo_fmj'), hash = `COMPONENT_REVOLVER_MK2_CLIP_FMJ`},
			{name = 'scope_holo', label = TranslateCap('component_scope_holo'), hash = `COMPONENT_AT_SIGHTS`},
			{name = 'scope_small', label = TranslateCap('component_ammo_fmj'), hash = `COMPONENT_AT_SCOPE_MACRO_MK2`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_PI_FLSH`},
			{name = 'compensator', label = TranslateCap('component_compensator'), hash = `COMPONENT_AT_PI_COMP_03`},
			{name = 'camo_finish', label = TranslateCap('component_camo_finish'), hash = `COMPONENT_REVOLVER_MK2_CAMO`},
			{name = 'camo_finish2', label = TranslateCap('component_camo_finish2'), hash = `COMPONENT_REVOLVER_MK2_CAMO_02`},
			{name = 'camo_finish3', label = TranslateCap('component_camo_finish3'), hash = `COMPONENT_REVOLVER_MK2_CAMO_03`},
			{name = 'camo_finish4', label = TranslateCap('component_camo_finish4'), hash = `COMPONENT_REVOLVER_MK2_CAMO_04`},
			{name = 'camo_finish5', label = TranslateCap('component_camo_finish5'), hash = `COMPONENT_REVOLVER_MK2_CAMO_05`},
			{name = 'camo_finish6', label = TranslateCap('component_camo_finish6'), hash = `COMPONENT_REVOLVER_MK2_CAMO_06`},
			{name = 'camo_finish7', label = TranslateCap('component_camo_finish7'), hash = `COMPONENT_REVOLVER_MK2_CAMO_07`},
			{name = 'camo_finish8', label = TranslateCap('component_camo_finish8'), hash = `COMPONENT_REVOLVER_MK2_CAMO_08`},
			{name = 'camo_finish9', label = TranslateCap('component_camo_finish9'), hash = `COMPONENT_REVOLVER_MK2_CAMO_09`},
			{name = 'camo_finish10', label = TranslateCap('component_camo_finish10'), hash = `COMPONENT_REVOLVER_MK2_CAMO_10`},
			{name = 'camo_finish11', label = TranslateCap('component_camo_finish11'), hash = `COMPONENT_REVOLVER_MK2_CAMO_IND_01`}
		}
	},
	{name = 'WEAPON_MARKSMANPISTOL', label = TranslateCap('weapon_marksmanpistol'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_PISTOL`}},
	{
		name = 'WEAPON_PISTOL',
		label = TranslateCap('weapon_pistol'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_PISTOL`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_PISTOL_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_PISTOL_CLIP_02`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_PI_FLSH`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_PI_SUPP_02`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_PISTOL_VARMOD_LUXE`}
		}
	},
	{
		name = 'WEAPON_PISTOL_MK2',
		label = TranslateCap('weapon_pistol_mk2'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_PISTOL`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_PISTOL_MK2_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_PISTOL_MK2_CLIP_02`},
			{name = 'ammo_tracer', label = TranslateCap('component_ammo_tracer'), hash = `COMPONENT_PISTOL_MK2_CLIP_TRACER`},
			{name = 'ammo_incendiary', label = TranslateCap('component_ammo_incendiary'), hash = `COMPONENT_PISTOL_MK2_CLIP_INCENDIARY`},
			{name = 'ammo_hollowpoint', label = TranslateCap('component_ammo_hollowpoint'), hash = `COMPONENT_PISTOL_MK2_CLIP_HOLLOWPOINT`},
			{name = 'ammo_fmj', label = TranslateCap('component_ammo_fmj'), hash = `COMPONENT_PISTOL_MK2_CLIP_FMJ`},
			{name = 'scope', label = TranslateCap('component_scope'), hash = `COMPONENT_AT_PI_RAIL`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_PI_FLSH_02`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_PI_SUPP_02`},
			{name = 'compensator', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_PI_COMP`},
			{name = 'camo_finish', label = TranslateCap('component_camo_finish'), hash = `COMPONENT_PISTOL_MK2_CAMO`},
			{name = 'camo_finish2', label = TranslateCap('component_camo_finish2'), hash = `COMPONENT_PISTOL_MK2_CAMO_02`},
			{name = 'camo_finish3', label = TranslateCap('component_camo_finish3'), hash = `COMPONENT_PISTOL_MK2_CAMO_03`},
			{name = 'camo_finish4', label = TranslateCap('component_camo_finish4'), hash = `COMPONENT_PISTOL_MK2_CAMO_04`},
			{name = 'camo_finish5', label = TranslateCap('component_camo_finish5'), hash = `COMPONENT_PISTOL_MK2_CAMO_05`},
			{name = 'camo_finish6', label = TranslateCap('component_camo_finish6'), hash = `COMPONENT_PISTOL_MK2_CAMO_06`},
			{name = 'camo_finish7', label = TranslateCap('component_camo_finish7'), hash = `COMPONENT_PISTOL_MK2_CAMO_07`},
			{name = 'camo_finish8', label = TranslateCap('component_camo_finish8'), hash = `COMPONENT_PISTOL_MK2_CAMO_08`},
			{name = 'camo_finish9', label = TranslateCap('component_camo_finish9'), hash = `COMPONENT_PISTOL_MK2_CAMO_09`},
			{name = 'camo_finish10', label = TranslateCap('component_camo_finish10'), hash = `COMPONENT_PISTOL_MK2_CAMO_10`},
			{name = 'camo_finish11', label = TranslateCap('component_camo_finish11'), hash = `COMPONENT_PISTOL_MK2_CAMO_IND_01`},
			{name = 'camo_slide_finish', label = TranslateCap('component_camo_slide_finish'), hash = `COMPONENT_PISTOL_MK2_CAMO_SLIDE`},
			{name = 'camo_slide_finish2', label = TranslateCap('component_camo_slide_finish2'), hash = `COMPONENT_PISTOL_MK2_CAMO_02_SLIDE`},
			{name = 'camo_slide_finish3', label = TranslateCap('component_camo_slide_finish3'), hash = `COMPONENT_PISTOL_MK2_CAMO_03_SLIDE`},
			{name = 'camo_slide_finish4', label = TranslateCap('component_camo_slide_finish4'), hash = `COMPONENT_PISTOL_MK2_CAMO_04_SLIDE`},
			{name = 'camo_slide_finish5', label = TranslateCap('component_camo_slide_finish5'), hash = `COMPONENT_PISTOL_MK2_CAMO_05_SLIDE`},
			{name = 'camo_slide_finish6', label = TranslateCap('component_camo_slide_finish6'), hash = `COMPONENT_PISTOL_MK2_CAMO_06_SLIDE`},
			{name = 'camo_slide_finish7', label = TranslateCap('component_camo_slide_finish7'), hash = `COMPONENT_PISTOL_MK2_CAMO_07_SLIDE`},
			{name = 'camo_slide_finish8', label = TranslateCap('component_camo_slide_finish8'), hash = `COMPONENT_PISTOL_MK2_CAMO_08_SLIDE`},
			{name = 'camo_slide_finish9', label = TranslateCap('component_camo_slide_finish9'), hash = `COMPONENT_PISTOL_MK2_CAMO_09_SLIDE`},
			{name = 'camo_slide_finish10', label = TranslateCap('component_camo_slide_finish10'), hash = `COMPONENT_PISTOL_MK2_CAMO_10_SLIDE`},
			{name = 'camo_slide_finish11', label = TranslateCap('component_camo_slide_finish11'), hash = `COMPONENT_PISTOL_MK2_CAMO_IND_01_SLIDE`}
		}
	},
	{
		name = 'WEAPON_PISTOL50',
		label = TranslateCap('weapon_pistol50'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_PISTOL`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_PISTOL50_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_PISTOL50_CLIP_02`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_PI_FLSH`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP_02`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_PISTOL50_VARMOD_LUXE`}
		}
	},
	{
		name = 'WEAPON_SNSPISTOL',
		label = TranslateCap('weapon_snspistol'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_PISTOL`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_SNSPISTOL_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_SNSPISTOL_CLIP_02`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_SNSPISTOL_VARMOD_LOWRIDER`}
		}
	},
	{
		name = 'WEAPON_SNSPISTOL_MK2',
		label = TranslateCap('weapon_snspistol_mk2'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_PISTOL`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_SNSPISTOL_MK2_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_SNSPISTOL_MK2_CLIP_02`},
			{name = 'ammo_tracer', label = TranslateCap('component_ammo_tracer'), hash = `COMPONENT_SNSPISTOL_MK2_CLIP_TRACER`},
			{name = 'ammo_incendiary', label = TranslateCap('component_ammo_incendiary'), hash = `COMPONENT_SNSPISTOL_MK2_CLIP_INCENDIARY`},
			{name = 'ammo_hollowpoint', label = TranslateCap('component_ammo_hollowpoint'), hash = `COMPONENT_SNSPISTOL_MK2_CLIP_HOLLOWPOINT`},
			{name = 'ammo_fmj', label = TranslateCap('component_ammo_fmj'), hash = `COMPONENT_SNSPISTOL_MK2_CLIP_FMJ`},
			{name = 'scope', label = TranslateCap('component_scope'), hash = `COMPONENT_AT_PI_RAIL_02`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_PI_FLSH_03`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_PI_SUPP_02`},
			{name = 'compensator', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_PI_COMP_02`},
			{name = 'camo_finish', label = TranslateCap('component_camo_finish'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO`},
			{name = 'camo_finish2', label = TranslateCap('component_camo_finish2'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_02`},
			{name = 'camo_finish3', label = TranslateCap('component_camo_finish3'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_03`},
			{name = 'camo_finish4', label = TranslateCap('component_camo_finish4'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_04`},
			{name = 'camo_finish5', label = TranslateCap('component_camo_finish5'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_05`},
			{name = 'camo_finish6', label = TranslateCap('component_camo_finish6'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_06`},
			{name = 'camo_finish7', label = TranslateCap('component_camo_finish7'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_07`},
			{name = 'camo_finish8', label = TranslateCap('component_camo_finish8'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_08`},
			{name = 'camo_finish9', label = TranslateCap('component_camo_finish9'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_09`},
			{name = 'camo_finish10', label = TranslateCap('component_camo_finish10'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_10`},
			{name = 'camo_finish11', label = TranslateCap('component_camo_finish11'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_IND_01`},
			{name = 'camo_slide_finish', label = TranslateCap('component_camo_slide_finish'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_SLIDE`},
			{name = 'camo_slide_finish2', label = TranslateCap('component_camo_slide_finish2'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_02_SLIDE`},
			{name = 'camo_slide_finish3', label = TranslateCap('component_camo_slide_finish3'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_03_SLIDE`},
			{name = 'camo_slide_finish4', label = TranslateCap('component_camo_slide_finish4'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_04_SLIDE`},
			{name = 'camo_slide_finish5', label = TranslateCap('component_camo_slide_finish5'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_05_SLIDE`},
			{name = 'camo_slide_finish6', label = TranslateCap('component_camo_slide_finish6'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_06_SLIDE`},
			{name = 'camo_slide_finish7', label = TranslateCap('component_camo_slide_finish7'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_07_SLIDE`},
			{name = 'camo_slide_finish8', label = TranslateCap('component_camo_slide_finish8'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_08_SLIDE`},
			{name = 'camo_slide_finish9', label = TranslateCap('component_camo_slide_finish9'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_09_SLIDE`},
			{name = 'camo_slide_finish10', label = TranslateCap('component_camo_slide_finish10'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_10_SLIDE`},
			{name = 'camo_slide_finish11', label = TranslateCap('component_camo_slide_finish11'), hash = `COMPONENT_SNSPISTOL_MK2_CAMO_IND_01_SLIDE`}
		}
	},
	{name = 'WEAPON_STUNGUN', label = TranslateCap('weapon_stungun'), tints = Config.DefaultWeaponTints, components = {}},
	{name = 'WEAPON_RAYPISTOL', label = TranslateCap('weapon_raypistol'), tints = Config.DefaultWeaponTints, components = {}},
	{
		name = 'WEAPON_VINTAGEPISTOL',
		label = TranslateCap('weapon_vintagepistol'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_PISTOL`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_VINTAGEPISTOL_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_VINTAGEPISTOL_CLIP_02`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_PI_SUPP`}
		}
	},
	-- Shotguns
	{
		name = 'WEAPON_ASSAULTSHOTGUN',
		label = TranslateCap('weapon_assaultshotgun'),
		ammo = {label = TranslateCap('ammo_shells'), hash = `AMMO_SHOTGUN`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_ASSAULTSHOTGUN_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_ASSAULTSHOTGUN_CLIP_02`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP`},
			{name = 'grip', label = TranslateCap('component_grip'), hash = `COMPONENT_AT_AR_AFGRIP`}
		}
	},
	{name = 'WEAPON_AUTOSHOTGUN', label = TranslateCap('weapon_autoshotgun'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = TranslateCap('ammo_shells'), hash = `AMMO_SHOTGUN`}},
	{
		name = 'WEAPON_BULLPUPSHOTGUN',
		label = TranslateCap('weapon_bullpupshotgun'),
		ammo = {label = TranslateCap('ammo_shells'), hash = `AMMO_SHOTGUN`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP_02`},
			{name = 'grip', label = TranslateCap('component_grip'), hash = `COMPONENT_AT_AR_AFGRIP`}
		}
	},
	{
		name = 'WEAPON_COMBATSHOTGUN',
		label = TranslateCap('weapon_combatshotgun'),
		ammo = {label = TranslateCap('ammo_shells'), hash = `AMMO_SHOTGUN`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP`}
		}
	},
	{name = 'WEAPON_DBSHOTGUN', label = TranslateCap('weapon_dbshotgun'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = TranslateCap('ammo_shells'), hash = `AMMO_SHOTGUN`}},
	{
		name = 'WEAPON_HEAVYSHOTGUN',
		label = TranslateCap('weapon_heavyshotgun'),
		ammo = {label = TranslateCap('ammo_shells'), hash = `AMMO_SHOTGUN`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_HEAVYSHOTGUN_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_HEAVYSHOTGUN_CLIP_02`},
			{name = 'clip_drum', label = TranslateCap('component_clip_drum'), hash = `COMPONENT_HEAVYSHOTGUN_CLIP_03`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP_02`},
			{name = 'grip', label = TranslateCap('component_grip'), hash = `COMPONENT_AT_AR_AFGRIP`}
		}
	},
	{name = 'WEAPON_MUSKET', label = TranslateCap('weapon_musket'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_SHOTGUN`}},
	{
		name = 'WEAPON_PUMPSHOTGUN',
		label = TranslateCap('weapon_pumpshotgun'),
		ammo = {label = TranslateCap('ammo_shells'), hash = `AMMO_SHOTGUN`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_SR_SUPP`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_PUMPSHOTGUN_VARMOD_LOWRIDER`}
		}
	},
	{
		name = 'WEAPON_PUMPSHOTGUN_MK2',
		label = TranslateCap('weapon_pumpshotgun_mk2'),
		ammo = {label = TranslateCap('ammo_shells'), hash = `AMMO_SHOTGUN`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'shells_default', label = TranslateCap('component_shells_default'), hash = `COMPONENT_PUMPSHOTGUN_MK2_CLIP_01`},
			{name = 'shells_incendiary', label = TranslateCap('component_shells_incendiary'), hash = `COMPONENT_PUMPSHOTGUN_MK2_CLIP_INCENDIARY`},
			{name = 'shells_armor', label = TranslateCap('component_shells_armor'), hash = `COMPONENT_PUMPSHOTGUN_MK2_CLIP_ARMORPIERCING`},
			{name = 'shells_hollowpoint', label = TranslateCap('component_shells_hollowpoint'), hash = `COMPONENT_PUMPSHOTGUN_MK2_CLIP_HOLLOWPOINT`},
			{name = 'shells_explosive', label = TranslateCap('component_shells_explosive'), hash = `COMPONENT_PUMPSHOTGUN_MK2_CLIP_EXPLOSIVE`},
			{name = 'scope_holo', label = TranslateCap('component_scope_holo'), hash = `COMPONENT_AT_SIGHTS`},
			{name = 'scope_small', label = TranslateCap('component_scope_small'), hash = `COMPONENT_AT_SCOPE_MACRO_MK2`},
			{name = 'scope_medium', label = TranslateCap('component_scope_medium'), hash = `COMPONENT_AT_SCOPE_SMALL_MK2`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_SR_SUPP_03`},
			{name = 'muzzle_squared', label = TranslateCap('component_muzzle_squared'), hash = `COMPONENT_AT_MUZZLE_08`},
			{name = 'camo_finish', label = TranslateCap('component_camo_finish'), hash = `COMPONENT_PUMPSHOTGUN_MK2_CAMO`},
			{name = 'camo_finish2', label = TranslateCap('component_camo_finish2'), hash = `COMPONENT_PUMPSHOTGUN_MK2_CAMO_02`},
			{name = 'camo_finish3', label = TranslateCap('component_camo_finish3'), hash = `COMPONENT_PUMPSHOTGUN_MK2_CAMO_03`},
			{name = 'camo_finish4', label = TranslateCap('component_camo_finish4'), hash = `COMPONENT_PUMPSHOTGUN_MK2_CAMO_04`},
			{name = 'camo_finish5', label = TranslateCap('component_camo_finish5'), hash = `COMPONENT_PUMPSHOTGUN_MK2_CAMO_05`},
			{name = 'camo_finish6', label = TranslateCap('component_camo_finish6'), hash = `COMPONENT_PUMPSHOTGUN_MK2_CAMO_06`},
			{name = 'camo_finish7', label = TranslateCap('component_camo_finish7'), hash = `COMPONENT_PUMPSHOTGUN_MK2_CAMO_07`},
			{name = 'camo_finish8', label = TranslateCap('component_camo_finish8'), hash = `COMPONENT_PUMPSHOTGUN_MK2_CAMO_08`},
			{name = 'camo_finish9', label = TranslateCap('component_camo_finish9'), hash = `COMPONENT_PUMPSHOTGUN_MK2_CAMO_09`},
			{name = 'camo_finish10', label = TranslateCap('component_camo_finish10'), hash = `COMPONENT_PUMPSHOTGUN_MK2_CAMO_10`},
			{name = 'camo_finish11', label = TranslateCap('component_camo_finish11'), hash = `COMPONENT_PUMPSHOTGUN_MK2_CAMO_IND_01`}
		}
	},
	{
		name = 'WEAPON_SAWNOFFSHOTGUN',
		label = TranslateCap('weapon_sawnoffshotgun'),
		ammo = {label = TranslateCap('ammo_shells'), hash = `AMMO_SHOTGUN`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_SAWNOFFSHOTGUN_VARMOD_LUXE`}
		}
	},
	-- SMG & LMG
	{
		name = 'WEAPON_ASSAULTSMG',
		label = TranslateCap('weapon_assaultsmg'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_SMG`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_ASSAULTSMG_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_ASSAULTSMG_CLIP_02`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'scope', label = TranslateCap('component_scope'), hash = `COMPONENT_AT_SCOPE_MACRO`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP_02`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_ASSAULTSMG_VARMOD_LOWRIDER`}
		}
	},
	{
		name = 'WEAPON_COMBATMG',
		label = TranslateCap('weapon_combatmg'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_MG`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_COMBATMG_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_COMBATMG_CLIP_02`},
			{name = 'scope', label = TranslateCap('component_scope'), hash = `COMPONENT_AT_SCOPE_MEDIUM`},
			{name = 'grip', label = TranslateCap('component_grip'), hash = `COMPONENT_AT_AR_AFGRIP`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_COMBATMG_VARMOD_LOWRIDER`}
		}
	},
	{
		name = 'WEAPON_COMBATMG_MK2',
		label = TranslateCap('weapon_combatmg_mk2'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_MG`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_COMBATMG_MK2_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_COMBATMG_MK2_CLIP_02`},
			{name = 'ammo_tracer', label = TranslateCap('component_ammo_tracer'), hash = `COMPONENT_COMBATMG_MK2_CLIP_TRACER`},
			{name = 'ammo_incendiary', label = TranslateCap('component_ammo_incendiary'), hash = `COMPONENT_COMBATMG_MK2_CLIP_INCENDIARY`},
			{name = 'ammo_hollowpoint', label = TranslateCap('component_ammo_hollowpoint'), hash = `COMPONENT_COMBATMG_MK2_CLIP_ARMORPIERCING`},
			{name = 'ammo_fmj', label = TranslateCap('component_ammo_fmj'), hash = `COMPONENT_COMBATMG_MK2_CLIP_FMJ`},
			{name = 'grip', label = TranslateCap('component_grip'), hash = `COMPONENT_AT_AR_AFGRIP_02`},
			{name = 'scope_holo', label = TranslateCap('component_scope_holo'), hash = `COMPONENT_AT_SIGHTS`},
			{name = 'scope_medium', label = TranslateCap('component_scope_medium'), hash = `COMPONENT_AT_SCOPE_SMALL_MK2`},
			{name = 'scope_large', label = TranslateCap('component_scope_large'), hash = `COMPONENT_AT_SCOPE_MEDIUM_MK2`},
			{name = 'muzzle_flat', label = TranslateCap('component_muzzle_flat'), hash = `COMPONENT_AT_MUZZLE_01`},
			{name = 'muzzle_tactical', label = TranslateCap('component_muzzle_tactical'), hash = `COMPONENT_AT_MUZZLE_02`},
			{name = 'muzzle_fat', label = TranslateCap('component_muzzle_fat'), hash = `COMPONENT_AT_MUZZLE_03`},
			{name = 'muzzle_precision', label = TranslateCap('component_muzzle_precision'), hash = `COMPONENT_AT_MUZZLE_04`},
			{name = 'muzzle_heavy', label = TranslateCap('component_muzzle_heavy'), hash = `COMPONENT_AT_MUZZLE_05`},
			{name = 'muzzle_slanted', label = TranslateCap('component_muzzle_slanted'), hash = `COMPONENT_AT_MUZZLE_06`},
			{name = 'muzzle_split', label = TranslateCap('component_muzzle_split'), hash = `COMPONENT_AT_MUZZLE_07`},
			{name = 'barrel_default', label = TranslateCap('component_barrel_default'), hash = `COMPONENT_AT_MG_BARREL_01`},
			{name = 'barrel_heavy', label = TranslateCap('component_barrel_heavy'), hash = `COMPONENT_AT_MG_BARREL_02`},
			{name = 'camo_finish', label = TranslateCap('component_camo_finish'), hash = `COMPONENT_COMBATMG_MK2_CAMO`},
			{name = 'camo_finish2', label = TranslateCap('component_camo_finish2'), hash = `COMPONENT_COMBATMG_MK2_CAMO_02`},
			{name = 'camo_finish3', label = TranslateCap('component_camo_finish3'), hash = `COMPONENT_COMBATMG_MK2_CAMO_03`},
			{name = 'camo_finish4', label = TranslateCap('component_camo_finish4'), hash = `COMPONENT_COMBATMG_MK2_CAMO_04`},
			{name = 'camo_finish5', label = TranslateCap('component_camo_finish5'), hash = `COMPONENT_COMBATMG_MK2_CAMO_05`},
			{name = 'camo_finish6', label = TranslateCap('component_camo_finish6'), hash = `COMPONENT_COMBATMG_MK2_CAMO_06`},
			{name = 'camo_finish7', label = TranslateCap('component_camo_finish7'), hash = `COMPONENT_COMBATMG_MK2_CAMO_07`},
			{name = 'camo_finish8', label = TranslateCap('component_camo_finish8'), hash = `COMPONENT_COMBATMG_MK2_CAMO_08`},
			{name = 'camo_finish9', label = TranslateCap('component_camo_finish9'), hash = `COMPONENT_COMBATMG_MK2_CAMO_09`},
			{name = 'camo_finish10', label = TranslateCap('component_camo_finish10'), hash = `COMPONENT_COMBATMG_MK2_CAMO_10`},
			{name = 'camo_finish11', label = TranslateCap('component_camo_finish11'), hash = `COMPONENT_COMBATMG_MK2_CAMO_IND_01`}
		}
	},
	{
		name = 'WEAPON_COMBATPDW',
		label = TranslateCap('weapon_combatpdw'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_SMG`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_COMBATPDW_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_COMBATPDW_CLIP_02`},
			{name = 'clip_drum', label = TranslateCap('component_clip_drum'), hash = `COMPONENT_COMBATPDW_CLIP_03`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'grip', label = TranslateCap('component_grip'), hash = `COMPONENT_AT_AR_AFGRIP`},
			{name = 'scope', label = TranslateCap('component_scope'), hash = `COMPONENT_AT_SCOPE_SMALL`}
		}
	},
	{
		name = 'WEAPON_GUSENBERG',
		label = TranslateCap('weapon_gusenberg'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_MG`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_GUSENBERG_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_GUSENBERG_CLIP_02`}
		}
	},
	{
		name = 'WEAPON_MACHINEPISTOL',
		label = TranslateCap('weapon_machinepistol'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_PISTOL`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_MACHINEPISTOL_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_MACHINEPISTOL_CLIP_02`},
			{name = 'clip_drum', label = TranslateCap('component_clip_drum'), hash = `COMPONENT_MACHINEPISTOL_CLIP_03`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_PI_SUPP`}
		}
	},
	{
		name = 'WEAPON_MG',
		label = TranslateCap('weapon_mg'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_MG`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_MG_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_MG_CLIP_02`},
			{name = 'scope', label = TranslateCap('component_scope'), hash = `COMPONENT_AT_SCOPE_SMALL_02`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_MG_VARMOD_LOWRIDER`}
		}
	},
	{
		name = 'WEAPON_MICROSMG',
		label = TranslateCap('weapon_microsmg'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_SMG`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_MICROSMG_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_MICROSMG_CLIP_02`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_PI_FLSH`},
			{name = 'scope', label = TranslateCap('component_scope'), hash = `COMPONENT_AT_SCOPE_MACRO`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP_02`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_MICROSMG_VARMOD_LUXE`}
		}
	},
	{
		name = 'WEAPON_MINISMG',
		label = TranslateCap('weapon_minismg'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_SMG`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_MINISMG_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_MINISMG_CLIP_02`}
		}
	},
	{
		name = 'WEAPON_SMG',
		label = TranslateCap('weapon_smg'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_SMG`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_SMG_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_SMG_CLIP_02`},
			{name = 'clip_drum', label = TranslateCap('component_clip_drum'), hash = `COMPONENT_SMG_CLIP_03`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'scope', label = TranslateCap('component_scope'), hash = `COMPONENT_AT_SCOPE_MACRO_02`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_PI_SUPP`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_SMG_VARMOD_LUXE`}
		}
	},
	{
		name = 'WEAPON_SMG_MK2',
		label = TranslateCap('weapon_smg_mk2'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_SMG`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_SMG_MK2_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_SMG_MK2_CLIP_02`},
			{name = 'ammo_tracer', label = TranslateCap('component_ammo_tracer'), hash = `COMPONENT_SMG_MK2_CLIP_TRACER`},
			{name = 'ammo_incendiary', label = TranslateCap('component_ammo_incendiary'), hash = `COMPONENT_SMG_MK2_CLIP_INCENDIARY`},
			{name = 'ammo_hollowpoint', label = TranslateCap('component_ammo_hollowpoint'), hash = `COMPONENT_SMG_MK2_CLIP_HOLLOWPOINT`},
			{name = 'ammo_fmj', label = TranslateCap('component_ammo_fmj'), hash = `COMPONENT_SMG_MK2_CLIP_FMJ`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'scope_holo', label = TranslateCap('component_scope_holo'), hash = `COMPONENT_AT_SIGHTS_SMG`},
			{name = 'scope_small', label = TranslateCap('component_scope_small'), hash = `COMPONENT_AT_SCOPE_MACRO_02_SMG_MK2`},
			{name = 'scope_medium', label = TranslateCap('component_scope_medium'), hash = `COMPONENT_AT_SCOPE_SMALL_SMG_MK2`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_PI_SUPP`},
			{name = 'muzzle_flat', label = TranslateCap('component_muzzle_flat'), hash = `COMPONENT_AT_MUZZLE_01`},
			{name = 'muzzle_tactical', label = TranslateCap('component_muzzle_tactical'), hash = `COMPONENT_AT_MUZZLE_02`},
			{name = 'muzzle_fat', label = TranslateCap('component_muzzle_fat'), hash = `COMPONENT_AT_MUZZLE_03`},
			{name = 'muzzle_precision', label = TranslateCap('component_muzzle_precision'), hash = `COMPONENT_AT_MUZZLE_04`},
			{name = 'muzzle_heavy', label = TranslateCap('component_muzzle_heavy'), hash = `COMPONENT_AT_MUZZLE_05`},
			{name = 'muzzle_slanted', label = TranslateCap('component_muzzle_slanted'), hash = `COMPONENT_AT_MUZZLE_06`},
			{name = 'muzzle_split', label = TranslateCap('component_muzzle_split'), hash = `COMPONENT_AT_MUZZLE_07`},
			{name = 'barrel_default', label = TranslateCap('component_barrel_default'), hash = `COMPONENT_AT_SB_BARREL_01`},
			{name = 'barrel_heavy', label = TranslateCap('component_barrel_heavy'), hash = `COMPONENT_AT_SB_BARREL_02`},
			{name = 'camo_finish', label = TranslateCap('component_camo_finish'), hash = `COMPONENT_SMG_MK2_CAMO`},
			{name = 'camo_finish2', label = TranslateCap('component_camo_finish2'), hash = `COMPONENT_SMG_MK2_CAMO_02`},
			{name = 'camo_finish3', label = TranslateCap('component_camo_finish3'), hash = `COMPONENT_SMG_MK2_CAMO_03`},
			{name = 'camo_finish4', label = TranslateCap('component_camo_finish4'), hash = `COMPONENT_SMG_MK2_CAMO_04`},
			{name = 'camo_finish5', label = TranslateCap('component_camo_finish5'), hash = `COMPONENT_SMG_MK2_CAMO_05`},
			{name = 'camo_finish6', label = TranslateCap('component_camo_finish6'), hash = `COMPONENT_SMG_MK2_CAMO_06`},
			{name = 'camo_finish7', label = TranslateCap('component_camo_finish7'), hash = `COMPONENT_SMG_MK2_CAMO_07`},
			{name = 'camo_finish8', label = TranslateCap('component_camo_finish8'), hash = `COMPONENT_SMG_MK2_CAMO_08`},
			{name = 'camo_finish9', label = TranslateCap('component_camo_finish9'), hash = `COMPONENT_SMG_MK2_CAMO_09`},
			{name = 'camo_finish10', label = TranslateCap('component_camo_finish10'), hash = `COMPONENT_SMG_MK2_CAMO_10`},
			{name = 'camo_finish11', label = TranslateCap('component_camo_finish11'), hash = `COMPONENT_SMG_MK2_CAMO_IND_01`}
		}
	},
	{name = 'WEAPON_RAYCARBINE', label = TranslateCap('weapon_raycarbine'), ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_SMG`}, tints = Config.DefaultWeaponTints, components = {}},
	-- Rifles
	{
		name = 'WEAPON_ADVANCEDRIFLE',
		label = TranslateCap('weapon_advancedrifle'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_RIFLE`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_ADVANCEDRIFLE_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_ADVANCEDRIFLE_CLIP_02`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'scope', label = TranslateCap('component_scope'), hash = `COMPONENT_AT_SCOPE_SMALL`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_ADVANCEDRIFLE_VARMOD_LUXE`}
		}
	},
	{
		name = 'WEAPON_ASSAULTRIFLE',
		label = TranslateCap('weapon_assaultrifle'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_RIFLE`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_ASSAULTRIFLE_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_ASSAULTRIFLE_CLIP_02`},
			{name = 'clip_drum', label = TranslateCap('component_clip_drum'), hash = `COMPONENT_ASSAULTRIFLE_CLIP_03`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'scope', label = TranslateCap('component_scope'), hash = `COMPONENT_AT_SCOPE_MACRO`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP_02`},
			{name = 'grip', label = TranslateCap('component_grip'), hash = `COMPONENT_AT_AR_AFGRIP`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_ASSAULTRIFLE_VARMOD_LUXE`}
		}
	},
	{
		name = 'WEAPON_ASSAULTRIFLE_MK2',
		label = TranslateCap('weapon_assaultrifle_mk2'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_RIFLE`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_ASSAULTRIFLE_MK2_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_ASSAULTRIFLE_MK2_CLIP_02`},
			{name = 'ammo_tracer', label = TranslateCap('component_ammo_tracer'), hash = `COMPONENT_ASSAULTRIFLE_MK2_CLIP_TRACER`},
			{name = 'ammo_incendiary', label = TranslateCap('component_ammo_incendiary'), hash = `COMPONENT_ASSAULTRIFLE_MK2_CLIP_INCENDIARY`},
			{name = 'ammo_armor', label = TranslateCap('component_ammo_armor'), hash = `COMPONENT_ASSAULTRIFLE_MK2_CLIP_ARMORPIERCING`},
			{name = 'ammo_fmj', label = TranslateCap('component_ammo_fmj'), hash = `COMPONENT_ASSAULTRIFLE_MK2_CLIP_FMJ`},
			{name = 'grip', label = TranslateCap('component_grip'), hash = `COMPONENT_AT_AR_AFGRIP_02`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'scope_holo', label = TranslateCap('component_scope_holo'), hash = `COMPONENT_AT_SIGHTS`},
			{name = 'scope_small', label = TranslateCap('component_scope_small'), hash = `COMPONENT_AT_SCOPE_MACRO_MK2`},
			{name = 'scope_large', label = TranslateCap('component_scope_large'), hash = `COMPONENT_AT_SCOPE_MEDIUM_MK2`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP_02`},
			{name = 'muzzle_flat', label = TranslateCap('component_muzzle_flat'), hash = `COMPONENT_AT_MUZZLE_01`},
			{name = 'muzzle_tactical', label = TranslateCap('component_muzzle_tactical'), hash = `COMPONENT_AT_MUZZLE_02`},
			{name = 'muzzle_fat', label = TranslateCap('component_muzzle_fat'), hash = `COMPONENT_AT_MUZZLE_03`},
			{name = 'muzzle_precision', label = TranslateCap('component_muzzle_precision'), hash = `COMPONENT_AT_MUZZLE_04`},
			{name = 'muzzle_heavy', label = TranslateCap('component_muzzle_heavy'), hash = `COMPONENT_AT_MUZZLE_05`},
			{name = 'muzzle_slanted', label = TranslateCap('component_muzzle_slanted'), hash = `COMPONENT_AT_MUZZLE_06`},
			{name = 'muzzle_split', label = TranslateCap('component_muzzle_split'), hash = `COMPONENT_AT_MUZZLE_07`},
			{name = 'barrel_default', label = TranslateCap('component_barrel_default'), hash = `COMPONENT_AT_AR_BARREL_01`},
			{name = 'barrel_heavy', label = TranslateCap('component_barrel_heavy'), hash = `COMPONENT_AT_AR_BARREL_02`},
			{name = 'camo_finish', label = TranslateCap('component_camo_finish'), hash = `COMPONENT_ASSAULTRIFLE_MK2_CAMO`},
			{name = 'camo_finish2', label = TranslateCap('component_camo_finish2'), hash = `COMPONENT_ASSAULTRIFLE_MK2_CAMO_02`},
			{name = 'camo_finish3', label = TranslateCap('component_camo_finish3'), hash = `COMPONENT_ASSAULTRIFLE_MK2_CAMO_03`},
			{name = 'camo_finish4', label = TranslateCap('component_camo_finish4'), hash = `COMPONENT_ASSAULTRIFLE_MK2_CAMO_04`},
			{name = 'camo_finish5', label = TranslateCap('component_camo_finish5'), hash = `COMPONENT_ASSAULTRIFLE_MK2_CAMO_05`},
			{name = 'camo_finish6', label = TranslateCap('component_camo_finish6'), hash = `COMPONENT_ASSAULTRIFLE_MK2_CAMO_06`},
			{name = 'camo_finish7', label = TranslateCap('component_camo_finish7'), hash = `COMPONENT_ASSAULTRIFLE_MK2_CAMO_07`},
			{name = 'camo_finish8', label = TranslateCap('component_camo_finish8'), hash = `COMPONENT_ASSAULTRIFLE_MK2_CAMO_08`},
			{name = 'camo_finish9', label = TranslateCap('component_camo_finish9'), hash = `COMPONENT_ASSAULTRIFLE_MK2_CAMO_09`},
			{name = 'camo_finish10', label = TranslateCap('component_camo_finish10'), hash = `COMPONENT_ASSAULTRIFLE_MK2_CAMO_10`},
			{name = 'camo_finish11', label = TranslateCap('component_camo_finish11'), hash = `COMPONENT_ASSAULTRIFLE_MK2_CAMO_IND_01`}
		}
	},
	{
		name = 'WEAPON_BULLPUPRIFLE',
		label = TranslateCap('weapon_bullpuprifle'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_RIFLE`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_BULLPUPRIFLE_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_BULLPUPRIFLE_CLIP_02`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'scope', label = TranslateCap('component_scope'), hash = `COMPONENT_AT_SCOPE_SMALL`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP`},
			{name = 'grip', label = TranslateCap('component_grip'), hash = `COMPONENT_AT_AR_AFGRIP`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_BULLPUPRIFLE_VARMOD_LOW`}
		}
	},
	{
		name = 'WEAPON_BULLPUPRIFLE_MK2',
		label = TranslateCap('weapon_bullpuprifle_mk2'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_RIFLE`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_BULLPUPRIFLE_MK2_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_BULLPUPRIFLE_MK2_CLIP_02`},
			{name = 'ammo_tracer', label = TranslateCap('component_ammo_tracer'), hash = `COMPONENT_BULLPUPRIFLE_MK2_CLIP_TRACER`},
			{name = 'ammo_incendiary', label = TranslateCap('component_ammo_incendiary'), hash = `COMPONENT_BULLPUPRIFLE_MK2_CLIP_INCENDIARY`},
			{name = 'ammo_armor', label = TranslateCap('component_ammo_armor'), hash = `COMPONENT_BULLPUPRIFLE_MK2_CLIP_ARMORPIERCING`},
			{name = 'ammo_fmj', label = TranslateCap('component_ammo_fmj'), hash = `COMPONENT_BULLPUPRIFLE_MK2_CLIP_FMJ`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'scope_holo', label = TranslateCap('component_scope_holo'), hash = `COMPONENT_AT_SIGHTS`},
			{name = 'scope_small', label = TranslateCap('component_scope_small'), hash = `COMPONENT_AT_SCOPE_MACRO_02_MK2`},
			{name = 'scope_medium', label = TranslateCap('component_scope_medium'), hash = `COMPONENT_AT_SCOPE_SMALL_MK2`},
			{name = 'barrel_default', label = TranslateCap('component_barrel_default'), hash = `COMPONENT_AT_BP_BARREL_01`},
			{name = 'barrel_heavy', label = TranslateCap('component_barrel_heavy'), hash = `COMPONENT_AT_BP_BARREL_02`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP`},
			{name = 'muzzle_flat', label = TranslateCap('component_muzzle_flat'), hash = `COMPONENT_AT_MUZZLE_01`},
			{name = 'muzzle_tactical', label = TranslateCap('component_muzzle_tactical'), hash = `COMPONENT_AT_MUZZLE_02`},
			{name = 'muzzle_fat', label = TranslateCap('component_muzzle_fat'), hash = `COMPONENT_AT_MUZZLE_03`},
			{name = 'muzzle_precision', label = TranslateCap('component_muzzle_precision'), hash = `COMPONENT_AT_MUZZLE_04`},
			{name = 'muzzle_heavy', label = TranslateCap('component_muzzle_heavy'), hash = `COMPONENT_AT_MUZZLE_05`},
			{name = 'muzzle_slanted', label = TranslateCap('component_muzzle_slanted'), hash = `COMPONENT_AT_MUZZLE_06`},
			{name = 'muzzle_split', label = TranslateCap('component_muzzle_split'), hash = `COMPONENT_AT_MUZZLE_07`},
			{name = 'grip', label = TranslateCap('component_grip'), hash = `COMPONENT_AT_AR_AFGRIP_02`},
			{name = 'camo_finish', label = TranslateCap('component_camo_finish'), hash = `COMPONENT_BULLPUPRIFLE_MK2_CAMO`},
			{name = 'camo_finish2', label = TranslateCap('component_camo_finish2'), hash = `COMPONENT_BULLPUPRIFLE_MK2_CAMO_02`},
			{name = 'camo_finish3', label = TranslateCap('component_camo_finish3'), hash = `COMPONENT_BULLPUPRIFLE_MK2_CAMO_03`},
			{name = 'camo_finish4', label = TranslateCap('component_camo_finish4'), hash = `COMPONENT_BULLPUPRIFLE_MK2_CAMO_04`},
			{name = 'camo_finish5', label = TranslateCap('component_camo_finish5'), hash = `COMPONENT_BULLPUPRIFLE_MK2_CAMO_05`},
			{name = 'camo_finish6', label = TranslateCap('component_camo_finish6'), hash = `COMPONENT_BULLPUPRIFLE_MK2_CAMO_06`},
			{name = 'camo_finish7', label = TranslateCap('component_camo_finish7'), hash = `COMPONENT_BULLPUPRIFLE_MK2_CAMO_07`},
			{name = 'camo_finish8', label = TranslateCap('component_camo_finish8'), hash = `COMPONENT_BULLPUPRIFLE_MK2_CAMO_08`},
			{name = 'camo_finish9', label = TranslateCap('component_camo_finish9'), hash = `COMPONENT_BULLPUPRIFLE_MK2_CAMO_09`},
			{name = 'camo_finish10', label = TranslateCap('component_camo_finish10'), hash = `COMPONENT_BULLPUPRIFLE_MK2_CAMO_10`},
			{name = 'camo_finish11', label = TranslateCap('component_camo_finish11'), hash = `COMPONENT_BULLPUPRIFLE_MK2_CAMO_IND_01`}
		}
	},
	{
		name = 'WEAPON_CARBINERIFLE',
		label = TranslateCap('weapon_carbinerifle'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_RIFLE`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_CARBINERIFLE_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_CARBINERIFLE_CLIP_02`},
			{name = 'clip_box', label = TranslateCap('component_clip_box'), hash = `COMPONENT_CARBINERIFLE_CLIP_03`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'scope', label = TranslateCap('component_scope'), hash = `COMPONENT_AT_SCOPE_MEDIUM`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP`},
			{name = 'grip', label = TranslateCap('component_grip'), hash = `COMPONENT_AT_AR_AFGRIP`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_CARBINERIFLE_VARMOD_LUXE`}
		}
	},
	{
		name = 'WEAPON_CARBINERIFLE_MK2',
		label = TranslateCap('weapon_carbinerifle_mk2'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_RIFLE`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_CARBINERIFLE_MK2_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_CARBINERIFLE_MK2_CLIP_02`},
			{name = 'ammo_tracer', label = TranslateCap('component_ammo_tracer'), hash = `COMPONENT_CARBINERIFLE_MK2_CLIP_TRACER`},
			{name = 'ammo_incendiary', label = TranslateCap('component_ammo_incendiary'), hash = `COMPONENT_CARBINERIFLE_MK2_CLIP_INCENDIARY`},
			{name = 'ammo_armor', label = TranslateCap('component_ammo_armor'), hash = `COMPONENT_CARBINERIFLE_MK2_CLIP_ARMORPIERCING`},
			{name = 'ammo_fmj', label = TranslateCap('component_ammo_fmj'), hash = `COMPONENT_CARBINERIFLE_MK2_CLIP_FMJ`},
			{name = 'grip', label = TranslateCap('component_grip'), hash = `COMPONENT_AT_AR_AFGRIP_02`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'scope_holo', label = TranslateCap('component_scope_holo'), hash = `COMPONENT_AT_SIGHTS`},
			{name = 'scope_medium', label = TranslateCap('component_scope_medium'), hash = `COMPONENT_AT_SCOPE_MACRO_MK2`},
			{name = 'scope_large', label = TranslateCap('component_scope_large'), hash = `COMPONENT_AT_SCOPE_MEDIUM_MK2`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP`},
			{name = 'muzzle_flat', label = TranslateCap('component_muzzle_flat'), hash = `COMPONENT_AT_MUZZLE_01`},
			{name = 'muzzle_tactical', label = TranslateCap('component_muzzle_tactical'), hash = `COMPONENT_AT_MUZZLE_02`},
			{name = 'muzzle_fat', label = TranslateCap('component_muzzle_fat'), hash = `COMPONENT_AT_MUZZLE_03`},
			{name = 'muzzle_precision', label = TranslateCap('component_muzzle_precision'), hash = `COMPONENT_AT_MUZZLE_04`},
			{name = 'muzzle_heavy', label = TranslateCap('component_muzzle_heavy'), hash = `COMPONENT_AT_MUZZLE_05`},
			{name = 'muzzle_slanted', label = TranslateCap('component_muzzle_slanted'), hash = `COMPONENT_AT_MUZZLE_06`},
			{name = 'muzzle_split', label = TranslateCap('component_muzzle_split'), hash = `COMPONENT_AT_MUZZLE_07`},
			{name = 'barrel_default', label = TranslateCap('component_barrel_default'), hash = `COMPONENT_AT_CR_BARREL_01`},
			{name = 'barrel_heavy', label = TranslateCap('component_barrel_heavy'), hash = `COMPONENT_AT_CR_BARREL_02`},
			{name = 'camo_finish', label = TranslateCap('component_camo_finish'), hash = `COMPONENT_CARBINERIFLE_MK2_CAMO`},
			{name = 'camo_finish2', label = TranslateCap('component_camo_finish2'), hash = `COMPONENT_CARBINERIFLE_MK2_CAMO_02`},
			{name = 'camo_finish3', label = TranslateCap('component_camo_finish3'), hash = `COMPONENT_CARBINERIFLE_MK2_CAMO_03`},
			{name = 'camo_finish4', label = TranslateCap('component_camo_finish4'), hash = `COMPONENT_CARBINERIFLE_MK2_CAMO_04`},
			{name = 'camo_finish5', label = TranslateCap('component_camo_finish5'), hash = `COMPONENT_CARBINERIFLE_MK2_CAMO_05`},
			{name = 'camo_finish6', label = TranslateCap('component_camo_finish6'), hash = `COMPONENT_CARBINERIFLE_MK2_CAMO_06`},
			{name = 'camo_finish7', label = TranslateCap('component_camo_finish7'), hash = `COMPONENT_CARBINERIFLE_MK2_CAMO_07`},
			{name = 'camo_finish8', label = TranslateCap('component_camo_finish8'), hash = `COMPONENT_CARBINERIFLE_MK2_CAMO_08`},
			{name = 'camo_finish9', label = TranslateCap('component_camo_finish9'), hash = `COMPONENT_CARBINERIFLE_MK2_CAMO_09`},
			{name = 'camo_finish10', label = TranslateCap('component_camo_finish10'), hash = `COMPONENT_CARBINERIFLE_MK2_CAMO_10`},
			{name = 'camo_finish11', label = TranslateCap('component_camo_finish11'), hash = `COMPONENT_CARBINERIFLE_MK2_CAMO_IND_01`}
		}
	},
	{
		name = 'WEAPON_COMPACTRIFLE',
		label = TranslateCap('weapon_compactrifle'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_RIFLE`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_COMPACTRIFLE_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_COMPACTRIFLE_CLIP_02`},
			{name = 'clip_drum', label = TranslateCap('component_clip_drum'), hash = `COMPONENT_COMPACTRIFLE_CLIP_03`}
		}
	},
	{
		name = 'WEAPON_MILITARYRIFLE',
		label = TranslateCap('weapon_militaryrifle'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_RIFLE`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_MILITARYRIFLE_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_MILITARYRIFLE_CLIP_02`},
			{name = 'ironsights', label = TranslateCap('component_ironsights'), hash = `COMPONENT_MILITARYRIFLE_SIGHT_01`},
			{name = 'scope', label = TranslateCap('component_scope'), hash = `COMPONENT_AT_SCOPE_SMALL`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP`}
		}
	},
	{
		name = 'WEAPON_SPECIALCARBINE',
		label = TranslateCap('weapon_specialcarbine'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_RIFLE`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_SPECIALCARBINE_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_SPECIALCARBINE_CLIP_02`},
			{name = 'clip_drum', label = TranslateCap('component_clip_drum'), hash = `COMPONENT_SPECIALCARBINE_CLIP_03`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'scope', label = TranslateCap('component_scope'), hash = `COMPONENT_AT_SCOPE_MEDIUM`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP_02`},
			{name = 'grip', label = TranslateCap('component_grip'), hash = `COMPONENT_AT_AR_AFGRIP`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_SPECIALCARBINE_VARMOD_LOWRIDER`}
		}
	},
	{
		name = 'WEAPON_SPECIALCARBINE_MK2',
		label = TranslateCap('weapon_specialcarbine_mk2'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_RIFLE`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_SPECIALCARBINE_MK2_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_SPECIALCARBINE_MK2_CLIP_02`},
			{name = 'ammo_tracer', label = TranslateCap('component_ammo_tracer'), hash = `COMPONENT_SPECIALCARBINE_MK2_CLIP_TRACER`},
			{name = 'ammo_incendiary', label = TranslateCap('component_ammo_incendiary'), hash = `COMPONENT_SPECIALCARBINE_MK2_CLIP_INCENDIARY`},
			{name = 'ammo_armor', label = TranslateCap('component_ammo_armor'), hash = `COMPONENT_SPECIALCARBINE_MK2_CLIP_ARMORPIERCING`},
			{name = 'ammo_fmj', label = TranslateCap('component_ammo_fmj'), hash = `COMPONENT_SPECIALCARBINE_MK2_CLIP_FMJ`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'scope_holo', label = TranslateCap('component_scope_holo'), hash = `COMPONENT_AT_SIGHTS`},
			{name = 'scope_small', label = TranslateCap('component_scope_small'), hash = `COMPONENT_AT_SCOPE_MACRO_MK2`},
			{name = 'scope_large', label = TranslateCap('component_scope_large'), hash = `COMPONENT_AT_SCOPE_MEDIUM_MK2`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP_02`},
			{name = 'muzzle_flat', label = TranslateCap('component_muzzle_flat'), hash = `COMPONENT_AT_MUZZLE_01`},
			{name = 'muzzle_tactical', label = TranslateCap('component_muzzle_tactical'), hash = `COMPONENT_AT_MUZZLE_02`},
			{name = 'muzzle_fat', label = TranslateCap('component_muzzle_fat'), hash = `COMPONENT_AT_MUZZLE_03`},
			{name = 'muzzle_precision', label = TranslateCap('component_muzzle_precision'), hash = `COMPONENT_AT_MUZZLE_04`},
			{name = 'muzzle_heavy', label = TranslateCap('component_muzzle_heavy'), hash = `COMPONENT_AT_MUZZLE_05`},
			{name = 'muzzle_slanted', label = TranslateCap('component_muzzle_slanted'), hash = `COMPONENT_AT_MUZZLE_06`},
			{name = 'muzzle_split', label = TranslateCap('component_muzzle_split'), hash = `COMPONENT_AT_MUZZLE_07`},
			{name = 'grip', label = TranslateCap('component_grip'), hash = `COMPONENT_AT_AR_AFGRIP_02`},
			{name = 'barrel_default', label = TranslateCap('component_barrel_default'), hash = `COMPONENT_AT_SC_BARREL_01`},
			{name = 'barrel_heavy', label = TranslateCap('component_barrel_heavy'), hash = `COMPONENT_AT_SC_BARREL_02`},
			{name = 'camo_finish', label = TranslateCap('component_camo_finish'), hash = `COMPONENT_SPECIALCARBINE_MK2_CAMO`},
			{name = 'camo_finish2', label = TranslateCap('component_camo_finish2'), hash = `COMPONENT_SPECIALCARBINE_MK2_CAMO_02`},
			{name = 'camo_finish3', label = TranslateCap('component_camo_finish3'), hash = `COMPONENT_SPECIALCARBINE_MK2_CAMO_03`},
			{name = 'camo_finish4', label = TranslateCap('component_camo_finish4'), hash = `COMPONENT_SPECIALCARBINE_MK2_CAMO_04`},
			{name = 'camo_finish5', label = TranslateCap('component_camo_finish5'), hash = `COMPONENT_SPECIALCARBINE_MK2_CAMO_05`},
			{name = 'camo_finish6', label = TranslateCap('component_camo_finish6'), hash = `COMPONENT_SPECIALCARBINE_MK2_CAMO_06`},
			{name = 'camo_finish7', label = TranslateCap('component_camo_finish7'), hash = `COMPONENT_SPECIALCARBINE_MK2_CAMO_07`},
			{name = 'camo_finish8', label = TranslateCap('component_camo_finish8'), hash = `COMPONENT_SPECIALCARBINE_MK2_CAMO_08`},
			{name = 'camo_finish9', label = TranslateCap('component_camo_finish9'), hash = `COMPONENT_SPECIALCARBINE_MK2_CAMO_09`},
			{name = 'camo_finish10', label = TranslateCap('component_camo_finish10'), hash = `COMPONENT_SPECIALCARBINE_MK2_CAMO_10`},
			{name = 'camo_finish11', label = TranslateCap('component_camo_finish11'), hash = `COMPONENT_SPECIALCARBINE_MK2_CAMO_IND_01`}
		}
	},
	-- Sniper
	{
		name = 'WEAPON_HEAVYSNIPER',
		label = TranslateCap('weapon_heavysniper'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_SNIPER`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'scope', label = TranslateCap('component_scope'), hash = `COMPONENT_AT_SCOPE_LARGE`},
			{name = 'scope_advanced', label = TranslateCap('component_scope_advanced'), hash = `COMPONENT_AT_SCOPE_MAX`}
		}
	},
	{
		name = 'WEAPON_HEAVYSNIPER_MK2',
		label = TranslateCap('weapon_heavysniper_mk2'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_SNIPER`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_HEAVYSNIPER_MK2_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_HEAVYSNIPER_MK2_CLIP_02`},
			{name = 'ammo_incendiary', label = TranslateCap('component_ammo_incendiary'), hash = `COMPONENT_HEAVYSNIPER_MK2_CLIP_INCENDIARY`},
			{name = 'ammo_armor', label = TranslateCap('component_ammo_armor'), hash = `COMPONENT_HEAVYSNIPER_MK2_CLIP_ARMORPIERCING`},
			{name = 'ammo_fmj', label = TranslateCap('component_ammo_fmj'), hash = `COMPONENT_HEAVYSNIPER_MK2_CLIP_FMJ`},
			{name = 'ammo_explosive', label = TranslateCap('component_ammo_explosive'), hash = `COMPONENT_HEAVYSNIPER_MK2_CLIP_EXPLOSIVE`},
			{name = 'scope_zoom', label = TranslateCap('component_scope_zoom'), hash = `COMPONENT_AT_SCOPE_LARGE_MK2`},
			{name = 'scope_advanced', label = TranslateCap('component_scope_advanced'), hash = `COMPONENT_AT_SCOPE_MAX`},
			{name = 'scope_nightvision', label = TranslateCap('component_scope_nightvision'), hash = `COMPONENT_AT_SCOPE_NV`},
			{name = 'scope_thermal', label = TranslateCap('component_scope_thermal'), hash = `COMPONENT_AT_SCOPE_THERMAL`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_SR_SUPP_03`},
			{name = 'muzzle_squared', label = TranslateCap('component_muzzle_squared'), hash = `COMPONENT_AT_MUZZLE_08`},
			{name = 'muzzle_bell', label = TranslateCap('component_muzzle_bell'), hash = `COMPONENT_AT_MUZZLE_09`},
			{name = 'barrel_default', label = TranslateCap('component_barrel_default'), hash = `COMPONENT_AT_SR_BARREL_01`},
			{name = 'barrel_heavy', label = TranslateCap('component_barrel_heavy'), hash = `COMPONENT_AT_SR_BARREL_02`},
			{name = 'camo_finish', label = TranslateCap('component_camo_finish'), hash = `COMPONENT_HEAVYSNIPER_MK2_CAMO`},
			{name = 'camo_finish2', label = TranslateCap('component_camo_finish2'), hash = `COMPONENT_HEAVYSNIPER_MK2_CAMO_02`},
			{name = 'camo_finish3', label = TranslateCap('component_camo_finish3'), hash = `COMPONENT_HEAVYSNIPER_MK2_CAMO_03`},
			{name = 'camo_finish4', label = TranslateCap('component_camo_finish4'), hash = `COMPONENT_HEAVYSNIPER_MK2_CAMO_04`},
			{name = 'camo_finish5', label = TranslateCap('component_camo_finish5'), hash = `COMPONENT_HEAVYSNIPER_MK2_CAMO_05`},
			{name = 'camo_finish6', label = TranslateCap('component_camo_finish6'), hash = `COMPONENT_HEAVYSNIPER_MK2_CAMO_06`},
			{name = 'camo_finish7', label = TranslateCap('component_camo_finish7'), hash = `COMPONENT_HEAVYSNIPER_MK2_CAMO_07`},
			{name = 'camo_finish8', label = TranslateCap('component_camo_finish8'), hash = `COMPONENT_HEAVYSNIPER_MK2_CAMO_08`},
			{name = 'camo_finish9', label = TranslateCap('component_camo_finish9'), hash = `COMPONENT_HEAVYSNIPER_MK2_CAMO_09`},
			{name = 'camo_finish10', label = TranslateCap('component_camo_finish10'), hash = `COMPONENT_HEAVYSNIPER_MK2_CAMO_10`},
			{name = 'camo_finish11', label = TranslateCap('component_camo_finish11'), hash = `COMPONENT_HEAVYSNIPER_MK2_CAMO_IND_01`}
		}
	},
	{
		name = 'WEAPON_MARKSMANRIFLE',
		label = TranslateCap('weapon_marksmanrifle'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_SNIPER`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_MARKSMANRIFLE_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_MARKSMANRIFLE_CLIP_02`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'scope', label = TranslateCap('component_scope'), hash = `COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP`},
			{name = 'grip', label = TranslateCap('component_grip'), hash = `COMPONENT_AT_AR_AFGRIP`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_MARKSMANRIFLE_VARMOD_LUXE`}
		}
	},
	{
		name = 'WEAPON_MARKSMANRIFLE_MK2',
		label = TranslateCap('weapon_marksmanrifle_mk2'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_SNIPER`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_MARKSMANRIFLE_MK2_CLIP_01`},
			{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_MARKSMANRIFLE_MK2_CLIP_02`},
			{name = 'ammo_tracer', label = TranslateCap('component_ammo_tracer'), hash = `COMPONENT_MARKSMANRIFLE_MK2_CLIP_TRACER`},
			{name = 'ammo_incendiary', label = TranslateCap('component_ammo_incendiary'), hash = `COMPONENT_MARKSMANRIFLE_MK2_CLIP_INCENDIARY`},
			{name = 'ammo_armor', label = TranslateCap('component_ammo_armor'), hash = `COMPONENT_MARKSMANRIFLE_MK2_CLIP_ARMORPIERCING`},
			{name = 'ammo_fmj', label = TranslateCap('component_ammo_fmj'), hash = `COMPONENT_MARKSMANRIFLE_MK2_CLIP_FMJ`},
			{name = 'scope_holo', label = TranslateCap('component_scope_holo'), hash = `COMPONENT_AT_SIGHTS`},
			{name = 'scope_large', label = TranslateCap('component_scope_large'), hash = `COMPONENT_AT_SCOPE_MEDIUM_MK2`},
			{name = 'scope_zoom', label = TranslateCap('component_scope_zoom'), hash = `COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM_MK2`},
			{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP`},
			{name = 'muzzle_flat', label = TranslateCap('component_muzzle_flat'), hash = `COMPONENT_AT_MUZZLE_01`},
			{name = 'muzzle_tactical', label = TranslateCap('component_muzzle_tactical'), hash = `COMPONENT_AT_MUZZLE_02`},
			{name = 'muzzle_fat', label = TranslateCap('component_muzzle_fat'), hash = `COMPONENT_AT_MUZZLE_03`},
			{name = 'muzzle_precision', label = TranslateCap('component_muzzle_precision'), hash = `COMPONENT_AT_MUZZLE_04`},
			{name = 'muzzle_heavy', label = TranslateCap('component_muzzle_heavy'), hash = `COMPONENT_AT_MUZZLE_05`},
			{name = 'muzzle_slanted', label = TranslateCap('component_muzzle_slanted'), hash = `COMPONENT_AT_MUZZLE_06`},
			{name = 'muzzle_split', label = TranslateCap('component_muzzle_split'), hash = `COMPONENT_AT_MUZZLE_07`},
			{name = 'barrel_default', label = TranslateCap('component_barrel_default'), hash = `COMPONENT_AT_MRFL_BARREL_01`},
			{name = 'barrel_heavy', label = TranslateCap('component_barrel_heavy'), hash = `COMPONENT_AT_MRFL_BARREL_02`},
			{name = 'grip', label = TranslateCap('component_grip'), hash = `COMPONENT_AT_AR_AFGRIP_02`},
			{name = 'camo_finish', label = TranslateCap('component_camo_finish'), hash = `COMPONENT_MARKSMANRIFLE_MK2_CAMO`},
			{name = 'camo_finish2', label = TranslateCap('component_camo_finish2'), hash = `COMPONENT_MARKSMANRIFLE_MK2_CAMO_02`},
			{name = 'camo_finish3', label = TranslateCap('component_camo_finish3'), hash = `COMPONENT_MARKSMANRIFLE_MK2_CAMO_03`},
			{name = 'camo_finish4', label = TranslateCap('component_camo_finish4'), hash = `COMPONENT_MARKSMANRIFLE_MK2_CAMO_04`},
			{name = 'camo_finish5', label = TranslateCap('component_camo_finish5'), hash = `COMPONENT_MARKSMANRIFLE_MK2_CAMO_05`},
			{name = 'camo_finish6', label = TranslateCap('component_camo_finish6'), hash = `COMPONENT_MARKSMANRIFLE_MK2_CAMO_06`},
			{name = 'camo_finish7', label = TranslateCap('component_camo_finish7'), hash = `COMPONENT_MARKSMANRIFLE_MK2_CAMO_07`},
			{name = 'camo_finish8', label = TranslateCap('component_camo_finish8'), hash = `COMPONENT_MARKSMANRIFLE_MK2_CAMO_08`},
			{name = 'camo_finish9', label = TranslateCap('component_camo_finish9'), hash = `COMPONENT_MARKSMANRIFLE_MK2_CAMO_09`},
			{name = 'camo_finish10', label = TranslateCap('component_camo_finish10'), hash = `COMPONENT_MARKSMANRIFLE_MK2_CAMO_10`},
			{name = 'camo_finish11', label = TranslateCap('component_camo_finish11'), hash = `COMPONENT_MARKSMANRIFLE_MK2_CAMO_IND_01`}
		}
	},
	{
		name = 'WEAPON_SNIPERRIFLE',
		label = TranslateCap('weapon_sniperrifle'),
		ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_SNIPER`},
		tints = Config.DefaultWeaponTints,
		components = {
			{name = 'scope', label = TranslateCap('component_scope'), hash = `COMPONENT_AT_SCOPE_LARGE`},
			{name = 'scope_advanced', label = TranslateCap('component_scope_advanced'), hash = `COMPONENT_AT_SCOPE_MAX`},
			{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP_02`},
			{name = 'luxary_finish', label = TranslateCap('component_luxary_finish'), hash = `COMPONENT_SNIPERRIFLE_VARMOD_LUXE`}
		}
	},
	-- Heavy / Launchers
	{name = 'WEAPON_COMPACTLAUNCHER', label = TranslateCap('weapon_compactlauncher'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = TranslateCap('ammo_grenadelauncher'), hash = `AMMO_GRENADELAUNCHER`}},
	{name = 'WEAPON_FIREWORK', label = TranslateCap('weapon_firework'), components = {}, ammo = {label = TranslateCap('ammo_firework'), hash = `AMMO_FIREWORK`}},
	{name = 'WEAPON_GRENADELAUNCHER', label = TranslateCap('weapon_grenadelauncher'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = TranslateCap('ammo_grenadelauncher'), hash = `AMMO_GRENADELAUNCHER`}},
	{name = 'WEAPON_HOMINGLAUNCHER', label = TranslateCap('weapon_hominglauncher'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = TranslateCap('ammo_rockets'), hash = `AMMO_HOMINGLAUNCHER`}},
	{name = 'WEAPON_MINIGUN', label = TranslateCap('weapon_minigun'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_MINIGUN`}},
	{name = 'WEAPON_RAILGUN', label = TranslateCap('weapon_railgun'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_RAILGUN`}},
	{name = 'WEAPON_RPG', label = TranslateCap('weapon_rpg'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = TranslateCap('ammo_rockets'), hash = `AMMO_RPG`}},
	{name = 'WEAPON_RAYMINIGUN', label = TranslateCap('weapon_rayminigun'), tints = Config.DefaultWeaponTints, components = {}, ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_MINIGUN`}},
	-- Thrown
	{name = 'WEAPON_BALL', label = TranslateCap('weapon_ball'), components = {}, ammo = {label = TranslateCap('ammo_ball'), hash = `AMMO_BALL`}},
	{name = 'WEAPON_BZGAS', label = TranslateCap('weapon_bzgas'), components = {}, ammo = {label = TranslateCap('ammo_bzgas'), hash = `AMMO_BZGAS`}},
	{name = 'WEAPON_FLARE', label = TranslateCap('weapon_flare'), components = {}, ammo = {label = TranslateCap('ammo_flare'), hash = `AMMO_FLARE`}},
	{name = 'WEAPON_GRENADE', label = TranslateCap('weapon_grenade'), components = {}, ammo = {label = TranslateCap('ammo_grenade'), hash = `AMMO_GRENADE`}},
	{name = 'WEAPON_PETROLCAN', label = TranslateCap('weapon_petrolcan'), components = {}, ammo = {label = TranslateCap('ammo_petrol'), hash = `AMMO_PETROLCAN`}},
	{name = 'WEAPON_HAZARDCAN', label = TranslateCap('weapon_hazardcan'), components = {}, ammo = {label = TranslateCap('ammo_petrol'), hash = `AMMO_PETROLCAN`}},
	{name = 'WEAPON_MOLOTOV', label = TranslateCap('weapon_molotov'), components = {}, ammo = {label = TranslateCap('ammo_molotov'), hash = `AMMO_MOLOTOV`}},
	{name = 'WEAPON_PROXMINE', label = TranslateCap('weapon_proxmine'), components = {}, ammo = {label = TranslateCap('ammo_proxmine'), hash = `AMMO_PROXMINE`}},
	{name = 'WEAPON_PIPEBOMB', label = TranslateCap('weapon_pipebomb'), components = {}, ammo = {label = TranslateCap('ammo_pipebomb'), hash = `AMMO_PIPEBOMB`}},
	{name = 'WEAPON_SNOWBALL', label = TranslateCap('weapon_snowball'), components = {}, ammo = {label = TranslateCap('ammo_snowball'), hash = `AMMO_SNOWBALL`}},
	{name = 'WEAPON_STICKYBOMB', label = TranslateCap('weapon_stickybomb'), components = {}, ammo = {label = TranslateCap('ammo_stickybomb'), hash = `AMMO_STICKYBOMB`}},
	{name = 'WEAPON_SMOKEGRENADE', label = TranslateCap('weapon_smokegrenade'), components = {}, ammo = {label = TranslateCap('ammo_smokebomb'), hash = `AMMO_SMOKEGRENADE`}},
	-- Tools
	{name = 'WEAPON_FIREEXTINGUISHER', label = TranslateCap('weapon_fireextinguisher'), components = {}, ammo = {label = TranslateCap('ammo_charge'), hash = `AMMO_FIREEXTINGUISHER`}},
	{name = 'WEAPON_DIGISCANNER', label = TranslateCap('weapon_digiscanner'), components = {}},
	{name = 'GADGET_PARACHUTE', label = TranslateCap('gadget_parachute'), components = {}},
	{name = 'WEAPON_TACTICALRIFLE',label = TranslateCap('weapon_tactilerifle'),ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_RIFLE`},tints = Config.DefaultWeaponTints,
		components = {
						{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_TACTICALRIFLE_CLIP_01`},
						{name = 'clip_extended', label = TranslateCap('component_clip_extended'), hash = `COMPONENT_TACTICALRIFLE_CLIP_02`},
						{name = 'flashlight', label = TranslateCap('component_flashlight'), hash = `COMPONENT_AT_AR_FLSH_REH`},
						{name = 'grip', label = TranslateCap('component_grip'), hash = `COMPONENT_AT_AR_AFGRIP`},
						{name = 'suppressor', label = TranslateCap('component_suppressor'), hash = `COMPONENT_AT_AR_SUPP_02`}
				}
	},
	{name = 'WEAPON_PRECISIONRIFLE', label = TranslateCap('weapon_precisionrifle'), ammo = {label = TranslateCap('ammo_rounds'), hash = `AMMO_SNIPER`}, tints = Config.DefaultWeaponTints,
				components = {
						{name = 'clip_default', label = TranslateCap('component_clip_default'), hash = `COMPONENT_PRECISIONRIFLE_CLIP_01`},
				}
	},
	{name = 'WEAPON_METALDETECTOR', label = TranslateCap('weapon_metaldetector'), components = {}}
}
