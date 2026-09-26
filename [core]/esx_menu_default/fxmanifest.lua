-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

fx_version 'cerulean'

game 'gta5'
author 'ESX-Framework'
description 'A basic menu system for ESX Legacy.'
lua54 'yes'
version '1.16.0'

shared_script '@esx_lib/imports.lua'
client_scripts { '@es_extended/imports.lua', 'client/main.lua' }

ui_page 'web/build/index.html'

files { 'web/build/index.html', 'web/build/**/*' }

dependencies { 'es_extended' }
