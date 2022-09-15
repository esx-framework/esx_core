fx_version 'bodacious'
game 'gta5'

description 'ESX Job Listing'
lua54 'yes'
version '1.7.5'

shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua'
}

server_script 'server/main.lua'

client_script 'client/main.lua'

dependency 'es_extended'
