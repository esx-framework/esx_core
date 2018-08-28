resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX Whitelist'

version '1.1.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'config.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'server/main.lua',
	'server/commands.lua'
}
