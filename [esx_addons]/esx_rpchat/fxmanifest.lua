fx_version 'adamant'

game 'gta5'

description 'ESX RP Chat'

version '1.6.0'

shared_script '@es_extended/imports.lua'

server_scripts {
	'@es_extended/locale.lua',
	'locales/sv.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/cs.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/sv.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/cs.lua',
	'config.lua',
	'client/main.lua'
}

dependency 'es_extended'
