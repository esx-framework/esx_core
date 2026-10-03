-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

fx_version "cerulean"
game "gta5"
description "ESX Dynamic Whitelist System"
version "1.16.0"
lua54 "yes"
use_fxv2_oal "yes"

shared_scripts {
    "@esx_lib/imports.lua",
    "@es_extended/imports.lua",
    "config/main.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua"
}

client_scripts {
    "client/main.lua"
}

ui_page "web/dist/index.html"

files {
    "locales/*.json",

    "client/*.lua",
    "client/**/*.lua",

    "web/dist/**/*"
}

dependencies {
    "es_extended",
    "esx_lib",
    "oxmysql"
}
