fx_version 'adamant'

game 'gta5'

description 'ESX Whitelist'

version '1.7.0'

server_only 'yes'

server_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'config.lua',
	'locales/*.lua',
	'server/main.lua'
}
