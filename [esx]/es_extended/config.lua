Config = {}
Config.Locale = GetConvar('esx:locale', 'en')

Config.Accounts = {
	bank = {
		label = TranslateCap('account_bank'),
		round = true
	},
	black_money = {
		label = TranslateCap('account_black_money'),
		round = true
	},
	money = {
		label = TranslateCap('account_money'),
		round = true
	}
}

Config.StartingAccountMoney 	= {bank = 50000}

Config.EnableSocietyPayouts 	= false -- pay from the society account that the player is employed at? Requirement: esx_society
Config.EnableHud            	= true -- enable the default hud? Display current job and accounts (black, bank & cash)
Config.MaxWeight            	= 24   -- the max inventory weight without backpack
Config.PaycheckInterval         = 7 * 60000 -- how often to recieve pay checks in milliseconds
Config.EnableDebug              = false -- Use Debug options?
Config.EnableDefaultInventory   = true -- Display the default Inventory ( F2 )
Config.EnableWantedLevel    	= false -- Use Normal GTA wanted Level?
Config.EnablePVP                = true -- Allow Player to player combat

Config.Multichar                = true -- Enable support for esx_multicharacter
Config.Identity                 = true -- Select a characters identity data before they have loaded in (this happens by default with multichar)
Config.DistanceGive 			= 4.0 -- Max distance when giving items, weapons etc.
Config.DisableHealthRegeneration  = false -- Player will no longer regenerate health
Config.DisableVehicleRewards      = false -- Disables Player Recieving weapons from vehicles
Config.DisableNPCDrops            = false -- stops NPCs from dropping weapons on death
Config.DisableWeaponWheel         = false -- Disables default weapon wheel
Config.DisableAimAssist           = false -- disables AIM assist (mainly on controllers)
Config.RemoveHudCommonents = {
	[1] = false, --WANTED_STARS,
	[2] = false, --WEAPON_ICON
	[3] = false, --CASH
	[4] = false,  --MP_CASH
	[5] = false, --MP_MESSAGE
	[6] = false, --VEHICLE_NAME
	[7] = false,-- AREA_NAME
	[8] = false,-- VEHICLE_CLASS
	[9] = false, --STREET_NAME
	[10] = false, --HELP_TEXT
	[11] = false, --FLOATING_HELP_TEXT_1
	[12] = false, --FLOATING_HELP_TEXT_2
	[13] = false, --CASH_CHANGE
	[14] = false, --RETICLE
	[15] = false, --SUBTITLE_TEXT
	[16] = false, --RADIO_STATIONS
	[17] = false, --SAVING_GAME,
	[18] = false, --GAME_STREAM
	[19] = false, --WEAPON_WHEEL
	[20] = false, --WEAPON_WHEEL_STATS
	[21] = false, --HUD_COMPONENTS
	[22] = false, --HUD_WEAPONS
}

Config.MaxAdminVehicles = false -- admin vehicles spawn with max vehcle settings
Config.CustomAIPlates = 'ESX.A111' -- Custom plates for AI vehicles 
-- Pattern string format
--1 will lead to a random number from 0-9.
--A will lead to a random letter from A-Z.
-- . will lead to a random letter or number, with 50% probability of being either.
--^1 will lead to a literal 1 being emitted.
--^A will lead to a literal A being emitted.
--Any other character will lead to said character being emitted.
-- A string shorter than 8 characters will be padded on the right.
