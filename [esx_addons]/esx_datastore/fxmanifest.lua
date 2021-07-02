fx_version 'adamant'

game 'gta5'

description 'ESX Data Store'

version 'legacy'

server_scripts {
	'@es_extended/imports.lua',
	'@mysql-async/lib/MySQL.lua',
	'server/classes/datastore.lua',
	'server/main.lua'
}
