fx_version 'adamant'

game 'gta5'

description 'ESX Addon Account'

version 'legacy'

server_scripts {
	'@es_extended/imports.lua',
	'@mysql-async/lib/MySQL.lua',
	'server/classes/addonaccount.lua',
	'server/main.lua'
}

dependency 'es_extended'
