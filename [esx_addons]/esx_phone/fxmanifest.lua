fx_version 'adamant'

game 'gta5'

description 'ESX Phone'

version '1.7.5'

shared_script '@es_extended/imports.lua'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'locales/*.lua',
	'client/main.lua'
}

ui_page 'html/ui.html'

files {
	'html/ui.html',

	'html/css/app.css',

	'html/scripts/mustache.min.js',
	'html/scripts/app.js',

	'html/img/phone.png',

	'html/img/icons/signal.png',
	'html/img/icons/rep.png',
	'html/img/icons/msg.png',
	'html/img/icons/add.png',
	'html/img/icons/back.png',
	'html/img/icons/new-msg.png',
	'html/img/icons/reply.png',
	'html/img/icons/write.png',
	'html/img/icons/edit.png',
	'html/img/icons/location.png'
}

dependency 'es_extended'
