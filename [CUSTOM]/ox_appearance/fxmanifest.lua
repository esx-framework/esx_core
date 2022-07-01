--[[ FX Information ]]--
fx_version   'cerulean'
use_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'

--[[ Resource Information ]]--
name         'ox_appearance'
author       'Linden'
version      '1.0.0'
repository   'https://github.com/overextended/ox_appearance'
description  'Persistant appearance data and outfits for ox_appearance.'

--[[ Manifest ]]--
dependencies {
	'/server:5104',
    '/onesync',
    'oxmysql',
    'fivem-appearance',
}

shared_script '@ox_lib/init.lua'

client_scripts {
    'client/esx.lua',
    'client/main.lua',
    'client/outfits.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/esx.lua',
    'server/ox.lua',
}

files {
    'locales/*.json',
}

provides {
    'skinchanger',
    'esx_skin'
}
