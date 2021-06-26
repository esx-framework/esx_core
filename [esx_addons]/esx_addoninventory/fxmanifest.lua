fx_version 'adamant'

game 'gta5'

description 'ESX Addon Inventory'

version 'legacy'

server_scripts {
	'@es_extended/imports.lua',
	'@mysql-async/lib/MySQL.lua',
	'server/classes/addoninventory.lua',
	'server/main.lua'
}

dependency 'es_extended'
