fx_version "cerulean"

game "gta5"
description "Inventory for the ESX framework"
lua54 "yes"
use_fxv2_oal "yes"
version '1.13.4'

shared_scripts {
    "/config/main.lua",
    "@es_extended/imports.lua",
    "@es_extended/locale.lua",
}

client_scripts {
    "/client/main.lua",
}

files {
    "/locales/*.lua"
}
