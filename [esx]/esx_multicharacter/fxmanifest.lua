fx_version 'cerulean'
game 'gta5'
description 'Official Multicharacter System For ESX Legacy'
version '1.7.5'
lua54 'yes'

dependencies {
	'es_extended',
	'esx_menu_default',
	'esx_identity',
	'esx_skin'
}

shared_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua'
}

server_scripts {
	'@es_extended/imports.lua',
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua',
}

client_scripts {
	'client/*.lua'
}

ui_page {
	'html/ui.html',
}

files {
	'html/ui.html',
	'html/css/main.css',
	'html/js/app.js',
	'html/locales/*.js',
}
