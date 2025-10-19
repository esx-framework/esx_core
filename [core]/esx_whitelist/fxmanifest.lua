fx_version 'adamant'

game 'gta5'

description 'ESX Dynamic Whitelist System'

version '1.0.0'

lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/cfg_discord.lua',
    'server/commands.lua'
}

client_scripts {
    'client/main.lua'
}

ui_page 'web/dist/index.html'

files {
    'web/dist/**/*',
    'locales/*.json'
}