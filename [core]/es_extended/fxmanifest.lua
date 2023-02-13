fx_version 'adamant'

game 'gta5'

description 'ES Extended'

lua54 'yes'
version '1.9.1'

--#TODO Mappákat át írni

shared_scripts {
	'locale.lua',
	'locales/*.lua',

	'config.lua',
	'config.weapons.lua',

	'shared/main.lua',
	'shared/modules/main.lua',
	'shared/modules/math.lua',
	'shared/modules/table.lua',
	'shared/modules/timeout.lua',
	'shared/functions/dumbTable.lua',
	'shared/functions/getConfig.lua',
	'shared/functions/getRandomNumber.lua',
	'shared/functions/getRandomString.lua',
	'shared/functions/round.lua',
	'shared/functions/weapon.lua',
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
	'server/modules/core/actions.lua',
	'server/modules/core/commands.lua',
	'server/modules/core/death.lua',
	'server/modules/blip.lua',
	'server/modules/debug.lua',
	'server/modules/marker.lua',
	'server/modules/paycheck.lua'
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
	'client/modules/core/actions.lua',
	'client/modules/core/npwd.lua',
	'client/modules/core/scaleform.lua',
	'client/modules/core/streaming.lua',
	'client/modules/core/death.lua',
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
