fx_version 'adamant'

game 'gta5'

description 'ESX Jobs'

version '1.1.0'

server_scripts {
	'@es_extended/locale.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/es.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'locales/cs.lua',
	'locales/de.lua',
	'config.lua',

	'jobs/fisherman.lua',
	'jobs/fueler.lua',
	'jobs/lumberjack.lua',
	'jobs/miner.lua',
	'jobs/reporter.lua',
	'jobs/slaughterer.lua',
	'jobs/tailor.lua',

	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/br.lua',
	'locales/fi.lua',
	'locales/en.lua',
	'locales/es.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'locales/cs.lua',
	'config.lua',

	'jobs/fisherman.lua',
	'jobs/fueler.lua',
	'jobs/lumberjack.lua',
	'jobs/miner.lua',
	'jobs/reporter.lua',
	'jobs/slaughterer.lua',
	'jobs/tailor.lua',

	'client/main.lua'
}

dependencies {
	'es_extended',
	'esx_addonaccount',
	'skinchanger',
	'esx_skin'
}
