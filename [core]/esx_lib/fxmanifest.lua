fx_version 'cerulean'
game 'gta5'

use_experimental_fxv2_oal 'yes'
lua54 'yes'

author 'ESX Team'
version '0.01'
description 'Official ESX library'

ui_page 'html/medal.html'

files {
    'imports.lua',
    'imports/**/client.lua',
    'imports/**/shared.lua',
    'html/medal.html',
    'html/medal.js',
}

shared_scripts {
    'config.lua',
    'resource/init.lua',
    'resource/**/shared.lua',
}

client_scripts {
    'resource/**/client.lua',
}

server_scripts {
    'resource/**/server.lua',
}



