-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

fx_version "cerulean"

game "gta5"
author "ESX-Framework"
description "Inventory for the ESX framework"
lua54 "yes"
use_fxv2_oal "yes"
version '1.16.0'

shared_scripts {
    "@esx_lib/imports.lua",
    "config/main.lua",
    "@es_extended/imports.lua",
    "@es_extended/locale.lua",
}

client_scripts {
    "client/main.lua",
    "client/module/slot/main.lua",
    "client/module/payload/main.lua",
    "client/module/ui/main.lua",
    "client/module/refresh/main.lua",
    "client/module/storage/main.lua",
    "client/module/keybind/main.lua",
}

server_scripts {
    "server/main.lua",
    "server/module/storage/main.lua",
}

ui_page "web/dist/index.html"

files {
    "locales/*.lua",
    "web/dist/**/*",
    "web/images/*.png",
}

dependencies {
    "es_extended",
    "esx_lib",
}
