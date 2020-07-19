fx_version 'adamant'

game 'gta5'

description 'ESX Boat'

version '1.0.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'locales/pl.lua',
  'locales/es.lua',
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
	'config.lua',
	'client/main.lua',
	'client/marker.lua'
}

dependencies {
	'es_extended',
	'esx_vehicleshop'
}