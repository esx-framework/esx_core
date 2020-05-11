fx_version 'adamant'

game 'gta5'

description 'ES Extended'

version '2.0.0'

server_scripts {
	'@async/async.lua',
	'@mysql-async/lib/MySQL.lua',

	'locale.lua',
	'locales/de.lua',
	'locales/br.lua',
	'locales/fr.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'locales/cs.lua',
	'locales/sc.lua',
	'locales/tc.lua',

	'config.lua',
	'config.weapons.lua',

	'server/common.lua',
	'server/classes/player.lua',
	'server/functions.lua',
	'server/paycheck.lua',
	'server/main.lua',
	'server/commands.lua',

	'common/modules/math.lua',
	'common/modules/table.lua',
  'common/functions.lua',

  'common/bootstrap.lua',
}

client_scripts {
	'locale.lua',
	'locales/de.lua',
	'locales/br.lua',
	'locales/fr.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'locales/cs.lua',
	'locales/sc.lua',
	'locales/tc.lua',

	'config.lua',
	'config.weapons.lua',

	'client/common.lua',
	'client/entityiter.lua',
	'client/functions.lua',
	'client/wrapper.lua',
	'client/main.lua',

	'client/modules/death.lua',
	'client/modules/scaleform.lua',
	'client/modules/streaming.lua',

	'common/modules/math.lua',
	'common/modules/table.lua',
  'common/functions.lua',

  'common/bootstrap.lua',
}

ui_page {
	'hud/index.html'
}

files {
  'client/bootstrap.lua',
	'locale.js',
	'hud/**/*',
}

exports {
  'getSharedObject',
  'OnESX',
}

server_exports {
  'getSharedObject',
  'OnESX',
}

dependencies {
	'mysql-async',
	'async'
}

-- ESX Modules
esxmodule = function(name)

	file('modules/' .. name .. '/data/**/*')

	client_script('modules/' .. name .. '/client/module.lua')
	client_script('modules/' .. name .. '/client/main.lua')
	client_script('modules/' .. name .. '/client/events.lua')

	server_script('modules/' .. name .. '/server/module.lua')
	server_script('modules/' .. name .. '/server/main.lua')
	server_script('modules/' .. name .. '/server/events.lua')

end

-- Misc
esxmodule 'input'          -- Evented input manager
esxmodule 'interact'       -- Interact menu (marker / npc)

-- Extend
esxmodule 'addonaccount'   -- Addon account
esxmodule 'addoninventory' -- Addon inventory
esxmodule 'datastore'      -- Arbitrary data store

-- UI
esxmodule 'hud'            -- Money / society etc... HUD
esxmodule 'menu_default'   -- Default menu
esxmodule 'menu_dialog'    -- Dialog menu
esxmodule 'menu_list'      -- List menu

-- Jobs
esxmodule 'job_police'     -- Job police
