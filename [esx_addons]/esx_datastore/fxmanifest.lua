fx_version 'adamant'

game 'gta5'

description 'ESX Data Store'
lua54 'yes'
version '1.9.0'

server_scripts {
	'@es_extended/imports.lua',
	'@oxmysql/lib/MySQL.lua',
	'server/classes/datastore.lua',
	'server/main.lua'
}
