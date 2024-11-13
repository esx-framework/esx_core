fx_version 'cerulean'

game 'gta5'
description 'The Core resource that provides the functionalities for all other resources.'
lua54 'yes'
version '1.11.2'

shared_scripts {
	'locale.lua',
	'locales/*.lua',

	'shared/config/main.lua',
    'shared/config/weapons.lua',
    'shared/config/adjustments.lua',

    'shared/main.lua',
    'shared/functions.lua',
    'shared/modules/*.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',

	'server/main.lua',
    'server/modules/utils/*.lua',
    'shared/config/logs.lua',
    'server/modules/*.lua',

	'server/classes/player.lua',
	'server/classes/overrides/*.lua',

    'server/bridge/**/*.lua',
	'server/events.lua',
}

client_scripts {
    'client/main.lua',
	'client/modules/utils/*.lua',
	'client/modules/*.lua',
}

ui_page {
	'html/ui.html'
}

files {
	'imports.lua',
    "client/imports/*.lua",

	'locale.js',
	'html/ui.html',

	'html/css/app.css',

	'html/js/mustache.min.js',
	'html/js/wrapper.js',
	'html/js/app.js',

	'html/fonts/pdown.ttf',
	'html/fonts/bankgothic.ttf',
}

dependencies {
	'oxmysql',
}
