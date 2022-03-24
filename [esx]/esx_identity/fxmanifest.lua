--[[ FX Information ]]--
fx_version   'cerulean'
use_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'

--[[ Resource Information ]]--
name         'es_extended'
version      '1.6.5'
description  'ESX Identity'
author       'esx-legacy'
repository   'https://github.com/esx-framework/esx-legacy/tree/main/%5Besx%5D/esx_identity'

--[[ Manifest ]]--
dependency 'esx_identity'

shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
    'config.lua',
}

client_scripts {
	'client/main.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/js/script.js',
	'html/css/style.css',
	'html/img/esx_identity.png'
}