fx_version 'adamant'
game 'gta5'
description 'https://github.com/thelindat/esx_multicharacter'
version '1.0.0'

dependency 'es_extended'

shared_script 'config.lua'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

--[[	Disabled for now
ui_page {
    'html/ui.html',
}

files {
    'html/ui.html',
    'html/css/main.css',
    'html/js/app.js',
    'html/locales/fr.js',
    'html/locales/en.js',
    'html/locales/pl.js',
}]]
