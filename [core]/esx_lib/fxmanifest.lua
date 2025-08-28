fx_version 'cerulean'
game 'gta5'

use_experimental_fxv2_oal 'yes'
lua54 'yes'

author 'ESX Team'
version '0.01'
description 'Official ESX library'

files {
    'imports.lua',
    'imports/**/client.lua',
    'imports/**/shared.lua',
}

shared_scripts {
    'resource/**/shared.lua',
}

client_scripts {
    'resource/**/client.lua',
}

server_scripts {
    'resource/**/server.lua',
}



