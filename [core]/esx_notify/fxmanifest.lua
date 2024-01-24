fx_version 'adamant'

lua54 'yes'
game 'gta5'
version '1.10.3'
author 'ESX-Framework'
description 'Official NUI Notification system for ESX'

shared_script '@es_extended/imports.lua'

client_scripts { 'Notify.lua' }

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/js/*.js',
    'nui/css/*.css',
}
