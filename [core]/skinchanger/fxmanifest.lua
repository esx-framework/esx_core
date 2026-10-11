-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

fx_version 'cerulean'

game 'gta5'
author 'ESX-Framework'
description 'Saves/loads character appearances for ESX Legacy.'
version '1.16.0'
lua54 'yes'

client_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
	'client/main.lua'
}
