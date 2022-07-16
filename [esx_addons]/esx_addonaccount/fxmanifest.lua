fx_version 'adamant'

game 'gta5'

author 'ESX-Framework'
description 'ESX Addon Account'

version '1.7.5'

server_scripts {
	'@es_extended/imports.lua',
	'@oxmysql/lib/MySQL.lua',
	'server/classes/addonaccount.lua',
	'server/main.lua'
}

dependency 'es_extended'
