fx_version 'adamant'

game 'gta5'

description 'ESX Job Listing'

version '1.6.5'

shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'config.lua'
}
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'locales/*.lua',
	'server/main.lua'
}

client_scripts {
	'locales/*.lua',
	'client/main.lua'
}

dependency 'es_extended'
