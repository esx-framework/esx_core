fx_version 'adamant'

game 'gta5'

description 'ES Extended'

lua54 'yes'
version '1.9.1'

--#TODO Mappákat át írni

shared_scripts {
	'shared/main.lua',
	'shared/functions/*.lua',
	'shared/modules/*.lua',
	'locale.lua',
	'locales/*.lua',

	'config.lua',
	'config.weapons.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config.logs.lua',
	'server/common.lua',
	'server/classes/player.lua',
	'server/classes/overrides/*.lua',
	'server/functions.lua',
	'server/onesync.lua',
	'server/main.lua',

	-- functions
	'sever/functions/core/*.lua',
	'server/functions/*.lua',

	-- modules
	'server/modules/core/*.lua',
	'server/modules/*.lua',
}

client_scripts {
	'client/functions.lua',
	'client/wrapper.lua',
	'client/main.lua',

	-- functions
	'client/functions/*.lua',

	-- modules
	'client/modules/core/*.lua',
	'client/modules/*.lua',
}

ui_page {
	'html/ui.html'
}

files {
	'imports.lua',
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
	'/server:5949',
	'/onesync',
	'oxmysql',
	'spawnmanager',
}
