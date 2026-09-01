fx_version "cerulean"
game "gta5"
lua54 "yes"

description "ESX Loading Screen"
author "ESX Team"
version "1.0.0"

loadscreen "web/index.html"
loadscreen_manual_shutdown "yes"

client_script "client/main.lua"

files {
    "web/index.html",
    "web/style.css",
    "web/script.js",
    "web/logo.png"
}