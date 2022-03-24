--[[ FX Information ]]--
fx_version   'cerulean'
use_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'

--[[ Resource Information ]]--
name         'esx_skin'
version      '1.6.5'
description  'ESX Skin'
author       'esx-legacy'
repository   'https://github.com/esx-framework/esx-legacy/tree/main/%5Besx%5D/esx_skin'

--[[ Manifest ]]--
dependencies {
	'es_extended',
	'skinchanger'
}

shared_scripts {
	'@es_extended/imports.lua',
    '@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua'
}

client_scripts {
	'client/main.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}