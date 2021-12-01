fx_version 'cerulean'
game 'gta5'
description 'https://github.com/thelindat/esx_multicharacter'
version '1.4.2'
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
	'@mysql-async/lib/MySQL.lua',
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
