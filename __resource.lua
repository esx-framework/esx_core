resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX Skin'

version '1.0.1'

server_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'locales/de.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'@mysql-async/lib/MySQL.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'locales/de.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'client/main.lua'
}
