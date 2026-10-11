-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

fx_version 'cerulean'

lua54 'yes'
game 'gta5'
author 'ESX-Framework'
description 'A beautiful and simple NUI notification system for ESX'
version '1.16.0'

shared_script '@es_extended/imports.lua'

client_scripts { 'Config.lua', 'Notify.lua'}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/js/*.js',
    'nui/css/*.css',
}
