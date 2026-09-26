-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

fx_version 'cerulean'
game 'common'
author 'ESX-Framework'
description 'A ESX Stylised theme for the chat resource.'
version '1.16.0'

file 'style.css'
file 'shadow.js'

chat_theme 'esx' {
    styleSheet = 'style.css',
    script = 'shadow.js',
    msgTemplates = {
        default = '<b>{0}</b><span>{1}</span>'
    }
}
