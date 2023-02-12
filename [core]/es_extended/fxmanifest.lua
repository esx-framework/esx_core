fx_version 'adamant'

game 'gta5'

description 'ES Extended'

lua54 'yes'
version '1.9.1'

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
	'server/paycheck.lua',
	'server/main.lua',
	'server/commands.lua',

	-- modules
	'server/modules/actions.lua',
	'server/modules/blip.lua',
	'server/modules/npwd.lua',
	'server/modules/death.lua'
}

client_scripts {
	'client/common.lua',
	'client/functions.lua',
	'client/wrapper.lua',
	'client/main.lua',

	-- functions
	'client/functions/playerData.lua',
	'client/functions/stateBag.lua',
	'client/functions/registerInput.lua',
	'client/functions/isPlayerLoaded.lua',

	-- modules
	'client/modules/scaleform.lua',
	'client/modules/streaming.lua',
	'client/modules/actions.lua',
	'client/modules/death.lua',
	'client/modules/npwd.lua',
	'client/modules/textui.lua',
	'client/modules/context.lua',
	'client/modules/progressbar.lua',
	'client/modules/notify.lua',
	'client/modules/ui.lua',
	'client/modules/blip.lua',
	'client/modules/marker.lua'
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
