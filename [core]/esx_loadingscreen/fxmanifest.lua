game 'common'

fx_version 'cerulean'
author 'ESX-Framework'
description 'A simple but beautiful Loading Screen for your server!'

lua54 'yes'
loadscreen 'index.html'

shared_script 'config.lua'

loadscreen_manual_shutdown "yes"

client_script 'client/client.lua'

files { 'index.html', './vid/*.mp4', './vid/*.webm', './js/index.js', './css/index.css' }
