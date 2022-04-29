fx_version 'adamant'

game 'gta5'

description 'ESX Jobs'

version '1.7.0'

shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'locales/en.lua',
	'config.lua',
	'jobs/*.lua',
}
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua',
}

client_scripts {
	'client/main.lua',
}

dependency 'es_extended'
