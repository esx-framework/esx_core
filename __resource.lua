resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX RP Chat'

version '1.3.1'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
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
