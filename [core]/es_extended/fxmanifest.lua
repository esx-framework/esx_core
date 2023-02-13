fx_version 'cerulean'
game 'gta5'

description 'ES Extended'

lua54 'yes'
version '2.0.0'

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
	'server/functions/core/isPlayerAdmin.lua',
	'server/functions/core/savePlayer.lua',
	'server/functions/core/savePlayers.lua',
	'server/functions/createPickup.lua',
	'server/functions/doesJobExist.lua',
	'server/functions/getExtendedPlayers.lua',
	'server/functions/getIdentifier.lua',
	'server/functions/getItemLabel.lua',
	'server/functions/getJobs.lua',
	'server/functions/getPlayerFromId.lua',
	'server/functions/getPlayerFromIdentifier.lua',
	'server/functions/getPlayers.lua',
	'server/functions/getUsableItems.lua',
	'server/functions/getVehicleType.lua',
	'server/functions/refreshJobs.lua',
	'server/functions/registerCommand.lua',
	'server/functions/registerPlayerFunctionOverrides.lua',
	'server/functions/registerUsableItem.lua',
	'server/functions/setPlayerFunctionOverride.lua',
	'server/functions/trace.lua',
	'server/functions/useItem.lua',

	-- modules
	'server/modules/core/actions.lua',
	'server/modules/core/commands.lua',
	'server/modules/core/death.lua',
	'server/modules/blip.lua',
	'server/modules/debug.lua',
	'server/modules/marker.lua',
	'server/modules/paycheck.lua',
	'server/modules/log.lua'
}

client_scripts {
	'client/main.lua',
	'client/common.lua',
	'client/functions.lua',
	'client/wrapper.lua',

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
