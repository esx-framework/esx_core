fx_version 'adamant'

game 'gta5'
author 'ESX-Framework'
description 'A beautiful and simple NUI progress bar for ESX'
version '1.11.4'
lua54 'yes'

client_scripts { 'Progress.lua' }
shared_script '@es_extended/imports.lua'
ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/js/*.js',
    'nui/css/*.css',
}
