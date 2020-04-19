Config = {}
Config.Locale = 'en'

Config.Accounts = {
	bank = _U('account_bank'),
	black_money = _U('account_black_money'),
	money = _U('account_money')
}

Config.StartingAccountMoney = {bank = 50000}

Config.EnableSocietyPayouts = false -- pay from the society account that the player is employed at? Requirement: esx_society
Config.EnableHud            = true -- enable the default hud? Display current job and accounts (black, bank & cash)
Config.MaxWeight            = 24   -- the max inventory weight without backpack
Config.PaycheckInterval     = 7 * 60000 -- how often to recieve pay checks in milliseconds
Config.EnableDebug          = false

Config.IncompatibleResourcesToStop = {
	['essentialmode'] = 'ES for short, the performance heavy RP framework no one uses - and source for the random unwanted ZAP ads you\'re seeing',
	['es_admin2'] = 'Adminstration tool for the ancient ES framework that wont work with ESX',
	['esplugin_mysql'] = 'MySQL "plugin" for the ancient ES framework that has a SQL injection vulnerability',
	['es_ui'] = 'Money HUD for ES',
	['spawnmanager'] = 'Default resource that takes care of spawning players, ESX does this already',
	['mapmanager'] = 'Default resource that was required by spawnmanager, but neither are used',
	['basic-gamemode'] = 'Resource that is solely for choosing the default game type',
	['fivem'] = 'Resource that is solely for choosing the default game type',
	['fivem-map-hipster'] = 'Default spawn locations for mapmanager',
	['fivem-map-skater'] = 'Default spawn locations for mapmanager',
	['baseevents'] = 'Default resource for handling death events, ESX does this already'
}
