fx_version 'cerulean'
game 'gta5'

author 'TrickEm City'
description '70s Themed Jobs System for TrickEm City'
version '1.0.0'
lua54 'yes'

shared_script 'config.lua'

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'es_extended',
    'oxmysql'
}
