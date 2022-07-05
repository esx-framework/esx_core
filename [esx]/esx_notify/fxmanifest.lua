fx_version 'adamant'
lua54 'yes'
game 'gta5'

author 'ESX-Framework'
description 'ESX Notification system for esx_legacy'

shared_script '@es_extended/imports.lua'

client_scripts { 'Notify.lua' }

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/js/*.js',
    'nui/css/*.css',
    'nui/img/*.png',
}
