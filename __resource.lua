resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX RP Chat'

version '1.1.0'

server_scripts {
	'@es_extended/locale.lua',
	'locates/sv.lua',
	'locates/en.lua',
	'locates/fr.lua',	
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locates/sv.lua',
	'locates/en.lua',
	'locates/fr.lua',	
	'config.lua',
	'client/main.lua'
}
