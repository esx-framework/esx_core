-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

fx_version "cerulean"
game "gta5"
lua54 "yes"
use_experimental_fxv2_oal "yes"

author "ESX-Framework"
description "Whitelist System for ESX Framework"
version "1.16.0"

shared_scripts {
    "@esx_lib/imports.lua",
    "config/main.lua"
}

server_scripts {
    "server/main.lua"
}

client_scripts {
    "client/main.lua"
}

ui_page "web/dist/index.html"

files {
    "web/dist/index.html",
    "web/dist/assets/*",
    "client/module/**/*.lua",
}

dependencies {
    "esx_lib",
    "es_extended",
}
