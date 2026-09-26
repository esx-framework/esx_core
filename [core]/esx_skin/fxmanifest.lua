-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

fx_version 'cerulean'

game 'gta5'
author 'ESX-Framework'
description 'Allows players to customise their character\'s appearance'
version '1.16.0'
lua54 'yes'

shared_scripts {
	'@esx_lib/imports.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'@es_extended/imports.lua',
	'config.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

client_scripts {
	'client/main.lua',
	'client/modules/*.lua'
}

ui_page 'web/dist/index.html'

files {
	'web/dist/**/*'
}

dependencies {
	'es_extended',
	'skinchanger'
}
