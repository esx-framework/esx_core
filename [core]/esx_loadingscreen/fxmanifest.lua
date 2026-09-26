-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

fx_version "cerulean"
game "gta5"
lua54 "yes"

author 'ESX-Framework'
description 'Allows resources to Run tasks at specific intervals.'
version '1.16.0'

loadscreen "web/index.html"
loadscreen_manual_shutdown "yes"

client_script "client/main.lua"

files {
    "web/index.html",
    "web/style.css",
    "web/script.js",
    "web/logo.png"
}
