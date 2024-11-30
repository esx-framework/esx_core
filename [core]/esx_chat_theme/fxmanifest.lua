version '1.11.4'
author 'ESX-Framework'
description 'A ESX Stylised theme for the chat resource.'

file 'style.css'
file 'shadow.js'

chat_theme 'esx' {
    styleSheet = 'style.css',
    script = 'shadow.js',
    msgTemplates = {
        default = '<b>{0}</b><span>{1}</span>'
    }
}

game 'common'
fx_version 'adamant'
