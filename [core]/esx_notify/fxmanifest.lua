fx_version 'adamant'

lua54 'yes'
game 'gta5'
version '1.12.2'
author 'ESX-Framework'
description 'A beautiful and simple NUI notification system for ESX'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'
}

client_scripts { 'Notify.lua' }

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/js/*.js',
    'nui/css/*.css',
}
