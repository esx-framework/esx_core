fx_version 'cerulean'

game 'gta5'

description 'ESX banking'
lua54 'yes'
version '1.8.6'

shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

client_scripts {
	'client/main.lua'
}

ui_page 'html/ui.html'

files {
	'html/**',
}

dependency 'es_extended'
