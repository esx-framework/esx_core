fx_version 'adamant'

game 'gta5'
author 'ESX-Framework'
version '1.10.4'
description 'A beautiful and simple Persistent Notification system for ESX.'
lua54 'yes'

client_scripts { 'TextUI.lua' }
shared_script '@es_extended/imports.lua'
ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/js/*.js',
    'nui/css/*.css'
}
