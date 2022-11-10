fx_version 'bodacious'

games {"gta5"}
author 'ESX-Framework & Toño#0001'
description 'ESX Blips Creations In Game'
lua54 'yes'
version '1.0.0'

server_script {
    "Config/*.lua",
    "Server/*.lua"
}

client_script {
    "Locale/*.lua",
    "Config/*.lua",
    "Cliente/*.lua"
}

shared_script '@es_extended/imports.lua'

dependencies {
    'es_extended',
    'esx_context'
}
