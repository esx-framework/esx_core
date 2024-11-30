fx_version 'bodacious'

game 'gta5'
author 'ESX-Framework & Brayden'
description 'A simplistic context menu for ESX.'
lua54 'yes'
version '1.11.4'

ui_page 'index.html'

shared_script '@es_extended/imports.lua'

client_scripts {
    'config.lua',
    'main.lua',
}

files {
    'index.html'
}

dependencies {
    'es_extended'
}
