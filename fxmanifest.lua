fx_version 'adamant'

game 'gta5'

description 'ESX Real Estate Job'

version '1.0.0'

server_scripts {
	'@es_extended/locale.lua',
	'@mysql-async/lib/MySQL.lua',
	'locales/de.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'locales/tr.lua',
	'locales/cs.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/de.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'locales/tr.lua',
	'locales/cs.lua',
	'config.lua',
	'client/main.lua'
}

dependencies {
	'es_extended',
	'esx_property',
	'esx_addonaccount',
	'esx_society'
}
