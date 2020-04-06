fx_version 'adamant'

game 'gta5'

description 'ESX Identity'

version '1.3.0'

server_scripts {
	'@es_extended/locale.lua',
	'@mysql-async/lib/MySQL.lua',
	'locales/en.lua',
	'locales/cs.lua',
	'config.lua',
	'server/main.lua'
}

dependency 'es_extended'
