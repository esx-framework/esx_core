-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

fx_version 'cerulean'

game 'gta5'
author 'ESX-Framework'
description 'The Core resource that provides the functionalities for all other resources.'
lua54 'yes'
version '1.16.0'

shared_scripts {
	'@esx_lib/imports.lua',
	'locale.lua',

	'shared/config/main.lua',
	'shared/config/weapons.lua',
	'shared/config/adjustments.lua',

	'shared/main.lua',
	'shared/functions.lua',
	'shared/modules/*.lua',
	'shared/compat.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'shared/config/logs.lua',

	'server/core.lua',
	'server/functions.lua',
	'server/modules/core/*.lua',
	'server/modules/player/*.lua',
	'server/modules/commands/register.lua',
	'server/modules/commands/context.lua',
	'server/modules/logging/*.lua',
	'server/modules/jobs/*.lua',
	'server/modules/items/*.lua',
	'server/modules/inventory/*.lua',
	'server/common.lua',
	'server/modules/callback.lua',
	'server/modules/vehicle/types.lua',
	'server/classes/player/*.lua',
	'server/classes/player.lua',
	'server/classes/vehicle.lua',
	'server/classes/vehicle/*.lua',
	'server/modules/vehicle/extended.lua',
	'server/classes/overrides/*.lua',
	'server/modules/onesync.lua',
	'server/modules/paycheck.lua',

	'server/main.lua',
	'server/modules/player/session/context.lua',
	'server/modules/player/session/runtime/*.lua',
	'server/modules/inventory/events/context.lua',
	'server/modules/inventory/events/registrations/*.lua',
	'server/modules/callbacks/*.lua',
	'server/modules/system/*.lua',
	'server/modules/commands.lua',
	'server/modules/commands/registrations/*.lua',

	'server/bridge/**/*.lua',
	'server/modules/npwd.lua',
	'server/modules/createJob.lua',
	'server/migration/**/main.lua',
	'server/migration/main.lua',

	'server/compat.lua'
}

client_scripts {
	'client/main.lua',
	'client/functions.lua',
	'client/modules/core/*.lua',
	'client/modules/player/data.lua',
	'client/modules/player/spawn.lua',
	'client/modules/ui/*.lua',
	'client/modules/game/*.lua',
	'client/modules/player/join.lua',
	'client/compat.lua',
	'client/modules/wrapper.lua',
	'client/modules/callback.lua',
	'client/modules/adjustments.lua',
	'client/modules/adjustments/*.lua',
	'client/modules/actions.lua',
	'client/modules/vehicle/*.lua',
	'client/modules/inventory/*.lua',
	'client/modules/player/lifecycle.lua',
	'client/modules/admin/*.lua',
	'client/modules/death.lua',
	'client/modules/npwd.lua',
}

ui_page {
	'html/ui.html'
}

files {
	'imports.lua',
	'locales/*.lua',
	'locale.js',
	'html/ui.html',

	'html/css/app.css',

	'html/js/mustache.min.js',
	'html/js/wrapper.js',
	'html/js/app.js',

	'html/fonts/pdown.ttf',
	'html/fonts/bankgothic.ttf',
	"client/imports/*.lua",
}

dependencies {
	'esx_lib',
	'/native:0x6AE51D4B',
	'/native:0xA61C8FC6',
	'oxmysql',
}
