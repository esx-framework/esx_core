fx_version 'adamant'

game 'gta5'
description 'Allows the player to Pick their characters: Name, Gender, Height and Date-of-birth.'
lua54 'yes'
version '1.11.4'

shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'locales/*.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'locales/*.lua',
	'config.lua',
	'client/main.lua'
}

files ({
	'web/dist/assets/**',
	'web/dist/**',
})

ui_page 'web/dist/index.html'

dependency 'es_extended'
