fx_version 'adamant'

game 'gta5'

<<<<<<< HEAD
description 'ESX Banker job'

version '1.0.1'

server_scripts {
	'@async/async.lua',
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'config.lua',
	'locales/de.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/es.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'locales/de.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/es.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'client/main.lua'
}

dependency 'es_extended'
=======
description 'CruiseControl System for ESX'

version '1.0.0'

dependencies {
  'es_extended'
}

client_scripts {
  '@es_extended/locale.lua',
  'locales/fi.lua',
  'locales/fr.lua',
  'locales/en.lua',
  'locales/es.lua',
  'locales/ge.lua',
  'locales/pl.lua',
  'client/main.lua',
  'config.lua',
}
>>>>>>> esx_cruisecontrol/master
