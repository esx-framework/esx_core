resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'config.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'server/esx_joblisting_sv.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'client/esx_joblisting_cl.lua'
}
