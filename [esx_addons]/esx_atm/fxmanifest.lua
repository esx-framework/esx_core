fx_version 'adamant'

game 'gta5'

description 'ESX Atm'

version '1.7.0'

shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua'
}

server_scripts {
	'server/main.lua'
}

client_scripts {
	'client/main.lua'
}

ui_page 'html/ui.html'

files {
	'html/ui.html',
	'html/roboto.ttf',
	'html/img/fleeca.png',
	'html/css/app.css',
	'html/scripts/app.js'
}

dependency 'es_extended'
