fx_version 'cerulean'

game 'gta5'
description 'A basic menu system for ESX Legacy.'
lua54 'yes'
version '1.15.0'

shared_script '@esx_lib/imports.lua'
client_scripts { '@es_extended/imports.lua', 'client/main.lua' }

ui_page 'web/build/index.html'

files { 'web/build/index.html', 'web/build/**/*' }

dependencies { 'es_extended' }
