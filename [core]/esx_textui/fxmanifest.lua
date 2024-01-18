fx_version 'adamant'

game 'gta5'
author 'ESX-Framework'
version '1.10.2'
description 'ESX TextUI'
lua54 'yes'

client_scripts { 'TextUI.lua' }
shared_script '@es_extended/imports.lua'
ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/js/*.js',
    'nui/css/*.css'
}
