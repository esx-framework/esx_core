game 'common'

version '1.10.3'
fx_version 'cerulean'
author 'ESX-Framework'
lua54 'yes'
loadscreen 'index.html'

shared_script 'config.lua'

loadscreen_manual_shutdown "yes"

client_script 'client/client.lua'

files { 'index.html', './vid/*.mp4', './vid/*.webm', './js/index.js', './css/index.css' }
