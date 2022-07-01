-- This resource is part of the default Cfx.re asset pack (cfx-server-data)
-- Altering or recreating for local use only is strongly discouraged.

version '1.0.0'
author 'Cfx.re <root@cfx.re>'
description 'Limits the number of players to the amount set by sv_maxclients in your server.cfg.'
repository 'https://github.com/citizenfx/cfx-server-data'

client_script 'client.lua'
server_script 'server.lua'

fx_version 'adamant'
games { 'gta5', 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
