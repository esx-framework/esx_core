fx_version 'cerulean'
game 'gta5'
author 'ESX-Framework - Linden - KASH'
description 'Allows players to have multiple characters on the same account.'
version '1.13.4'
lua54 'yes'

dependencies { 'es_extended', 'esx_context', 'esx_identity', 'esx_skin' }

shared_scripts { '@es_extended/imports.lua', '@es_extended/locale.lua', 'locales/*.lua', 'config.lua' }

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
    'server/modules/*.lua'
}

client_scripts {
   "client/modules/*.lua",
   'client/*.lua'
}

ui_page 'web/build/index.html'

files { 'web/build/index.html', 'web/build/**/*.*'}
