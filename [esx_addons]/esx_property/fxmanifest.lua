fx_version 'adamant'

game 'gta5'

description 'ESX Property'

version '1.7.0'

shared_script '@es_extended/imports.lua'

server_scripts {
	'@async/async.lua',
	'@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
	'client/main.lua'
}

dependencies {
	'async',
	'es_extended',
	'instance',
	'cron',
	'esx_addonaccount',
	'esx_addoninventory',
	'esx_datastore'
}
