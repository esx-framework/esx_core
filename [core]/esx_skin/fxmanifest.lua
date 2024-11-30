fx_version 'adamant'

game 'gta5'
description 'Allows players to customise their character\'s appearance'
version '1.11.4'
lua54 'yes'

shared_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'@es_extended/imports.lua',
	'config.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

client_scripts {
	'client/main.lua',
	'client/modules/*.lua'
}

dependencies {
	'es_extended',
	'skinchanger'
}
