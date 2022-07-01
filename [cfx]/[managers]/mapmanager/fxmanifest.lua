-- This resource is part of the default Cfx.re asset pack (cfx-server-data)
-- Altering or recreating for local use only is strongly discouraged.

version '1.0.0'
author 'Cfx.re <root@cfx.re>'
description 'A flexible handler for game type/map association.'
repository 'https://github.com/citizenfx/cfx-server-data'

client_scripts {
    "mapmanager_shared.lua",
    "mapmanager_client.lua"
}

server_scripts {
    "mapmanager_shared.lua",
    "mapmanager_server.lua"
}

fx_version 'adamant'
games { 'gta5', 'rdr3' }

server_export "getCurrentGameType"
server_export "getCurrentMap"
server_export "changeGameType"
server_export "changeMap"
server_export "doesMapSupportGameType"
server_export "getMaps"
server_export "roundEnded"

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
