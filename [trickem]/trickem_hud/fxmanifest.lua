fx_version 'cerulean'
game 'gta5'

author 'TrickEm City'
description '70s Themed HUD for TrickEm City'
version '1.0.0'
lua54 'yes'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js'
}

dependencies {
    'es_extended'
}
