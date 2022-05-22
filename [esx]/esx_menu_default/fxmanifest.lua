fx_version 'adamant'

game 'gta5'

description 'ESX Menu Default'

version '1.7.5'

client_scripts {
	'@es_extended/imports.lua',
	'client/main.lua'
}

ui_page {
	'html/ui.html'
}

files {
	'html/ui.html',
	'html/css/app.css',
	'html/js/mustache.min.js',
	'html/js/app.js'
}

dependencies {
	'es_extended'
}
