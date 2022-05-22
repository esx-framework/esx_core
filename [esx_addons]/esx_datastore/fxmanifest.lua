fx_version 'adamant'

game 'gta5'

description 'ESX Data Store'

version '1.7.5'

server_scripts {
	'@es_extended/imports.lua',
	'@oxmysql/lib/MySQL.lua',
	'server/classes/datastore.lua',
	'server/main.lua'
}
