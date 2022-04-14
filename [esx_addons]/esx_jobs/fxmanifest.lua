fx_version 'adamant'

game 'gta5'

description 'ESX Jobs'

version '1.6.5'

shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua'
}
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
	'jobs/*.lua'
}

client_scripts {
	'client/main.lua',
	'jobs/*.lua'
}

dependency 'es_extended'
