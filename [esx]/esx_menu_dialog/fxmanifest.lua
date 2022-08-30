fx_version 'adamant'

game 'gta5'

description 'ESX Menu Dialog'
lua54 'yes'
version '1.7.5'

client_scripts {
	'@es_extended/imports.lua',
	'@es_extended/client/wrapper.lua',
	'client/main.lua'
}

ui_page 'html/ui.html'

files {
	'html/ui.html',

	'html/css/app.css',

	'html/js/mustache.min.js',
	'html/js/app.js',

	'html/fonts/pdown.ttf',
	'html/fonts/bankgothic.ttf'
}

dependency 'es_extended'
