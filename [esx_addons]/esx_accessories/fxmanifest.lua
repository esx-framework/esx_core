fx_version 'adamant'

game 'gta5'

description 'ESX Accessories'

version '1.7.0'

shared_script '@es_extended/imports.lua'

server_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'locales/es.lua',
    'locales/ru.lua',
    'locales/fi.lua',
    'locales/fr.lua',
    'locales/sv.lua',
    'locales/cs.lua',
    'locales/pl.lua',
    'locales/hu.lua',
    'config.lua',
    'server/main.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'locales/es.lua',
    'locales/ru.lua',
    'locales/fi.lua',
    'locales/fr.lua',
    'locales/sv.lua',
    'locales/cs.lua',
    'locales/pl.lua',
    'locales/hu.lua',
    'config.lua',
    'client/main.lua'
}

dependencies {
    'es_extended',
    'esx_skin',
    'esx_datastore'
}
