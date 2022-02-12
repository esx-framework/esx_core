fx_version 'adamant'

game 'gta5'

description 'ESX Whitelist'

version 'legacy'

server_scripts {
	'@es_extended/imports.lua',
	'@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'config.lua',
	'locales/*.lua',
	'server/main.lua',
	'server/commands.lua'
}
