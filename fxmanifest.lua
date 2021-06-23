fx_version 'adamant'
game 'gta5'
description 'https://github.com/thelindat/esx_multicharacter'
version '1.1.0'

dependencies {
	'es_extended',
	'esx_menu_default',
	'esx_identity',
	'esx_skin'
}

shared_script 'config.lua'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/main.lua',
}

client_scripts {
	'@es_extended/locale.lua',
	'client/main.lua',
	'locales/*.lua',
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
