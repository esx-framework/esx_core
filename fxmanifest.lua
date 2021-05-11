fx_version 'adamant'

game 'gta5'

shared_script '@es_extended/imports.lua'

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "config.lua",
    "server/main.lua",
}

client_scripts {
    "config.lua",
    "client/main.lua",
}

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
}

dependency 'es_extended'
