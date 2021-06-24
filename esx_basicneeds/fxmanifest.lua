fx_version 'adamant'

game 'gta5'

<<<<<<< HEAD
description 'ESX Status'

version '1.0.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'config.lua',
	'client/classes/status.lua',
	'client/main.lua'
}

ui_page 'html/ui.html'

files {
	'html/ui.html',
	'html/css/app.css',
	'html/scripts/app.js'
=======
description 'ESX Basic Needs'

version '1.0.1'

server_scripts {
    '@es_extended/locale.lua',
    'locales/de.lua',
    'locales/br.lua',
    'locales/en.lua',
    'locales/es.lua',
    'locales/fi.lua',
    'locales/fr.lua',
    'locales/sv.lua',
    'locales/pl.lua',
    'locales/tr.lua',
    'config.lua',
    'server/main.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/de.lua',
    'locales/br.lua',
    'locales/en.lua',
    'locales/es.lua',
    'locales/fi.lua',
    'locales/fr.lua',
    'locales/sv.lua',
    'locales/pl.lua',
    'locales/tr.lua',
    'config.lua',
    'client/main.lua'
}

dependencies {
    'es_extended',
    'esx_status'
>>>>>>> esx_basicneeds/master
}
