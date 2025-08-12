fx_version "cerulean"

game "gta5"
description "Inventory for the ESX framework"
lua54 "yes"
version "1.13.1"

shared_scripts {
    "/config/main.lua",
    "@es_extended/imports.lua",
    "@es_extended/locale.lua",
}

client_scripts {
    "/client/main.lua",
}

server_scripts {
    "/server/main.lua",
}

files {
    "/locales/*.lua"
}
