fx_version 'cerulean'
game 'gta5'

author 'TrickEm City'
description 'Disco Inferno - 70s Disco Club Experience for TrickEm City'
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

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js'
}

dependencies {
    'es_extended',
    'oxmysql'
}
