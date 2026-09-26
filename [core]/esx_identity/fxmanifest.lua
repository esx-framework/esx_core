-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

fx_version 'cerulean'

game 'gta5'
author 'ESX-Framework'
description 'Allows the player to Pick their characters: Name, Gender, Height and Date-of-birth.'
lua54 'yes'
version '1.16.0'

shared_scripts {
	'@esx_lib/imports.lua',
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'locales/*.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'locales/*.lua',
	'config.lua',
	'client/main.lua'
}

files ({
	'web/dist/assets/**',
	'web/dist/**',
})

ui_page 'web/dist/index.html'

dependency 'es_extended'
