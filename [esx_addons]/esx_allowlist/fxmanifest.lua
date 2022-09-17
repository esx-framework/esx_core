fx_version 'adamant'

game 'gta5'

author 'ESX-Framework'
description 'Offical AllowList script for ESX'

version '1.8.5'
lua54 'yes'
server_only 'yes'

server_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'config.lua',
	'locales/*.lua',
	'server/main.lua'
}
