fx_version 'adamant'

game 'gta5'

description 'ESX Boat'

version '1.6.0'

shared_script '@es_extended/imports.lua'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'locales/pl.lua',
  	'locales/es.lua',
	'locales/hu.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'locales/pl.lua',
 	'locales/es.lua',
	'locales/hu.lua',
	'config.lua',
	'client/main.lua',
	'client/marker.lua'
}

dependencies {
	'es_extended',
	'esx_vehicleshop'
}
