--[[ FX Information ]]--
fx_version   'cerulean'
use_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'

--[[ Resource Information ]]--
name         'esx_multicharacter'
version      '1.6.5'
description  'Official Multicharacter System For ESX Legacy'
author       'Linden'
repository   'https://github.com/esx-framework/esx-legacy/tree/main/%5Besx%5D/esx_multicharacter'

--[[ Manifest ]]--
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