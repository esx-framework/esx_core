fx_version 'adamant'
game 'gta5'
description 'ESX Identity'
version '1.6.0'
lua54 'yes'


shared_script '@es_extended/imports.lua'

server_scripts {
	'@es_extended/locale.lua',
	'@oxmysql/lib/MySQL.lua',
	'locales/*.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
	'client/main.lua'
}

ui_page 'html/index.html'

files {
	'html/**/*.*',
}

dependency 'es_extended'

