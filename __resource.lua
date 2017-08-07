description 'ESX ATM'

server_script 'server/esx_atm_sv.lua'

client_script {
	'config.lua',
	'client/esx_atm_cl.lua'
}

ui_page 'html/ui.html'

files {
	'html/ui.html',
	'html/pdown.ttf',
	'html/img/cursor.png',
	'html/css/app.css',
	'html/scripts/app.js'
}