fx_version 'adamant'

game 'gta5'

description 'ESX Optional Needs'

version '1.6.0'

shared_script '@es_extended/imports.lua'

server_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'locales/es.lua',
    'locales/fi.lua',
    'locales/fr.lua',
    'locales/pl.lua',
    'config.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}
