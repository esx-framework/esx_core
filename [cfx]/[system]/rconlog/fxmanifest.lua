-- This resource is part of the default Cfx.re asset pack (cfx-server-data)
-- Altering or recreating for local use only is strongly discouraged.

version '1.0.0'
author 'Cfx.re <root@cfx.re>'
description 'Handles old-style server player management commands.'
repository 'https://github.com/citizenfx/cfx-server-data'

client_script 'rconlog_client.lua'
server_script 'rconlog_server.lua'

fx_version 'adamant'
games { 'gta5', 'rdr3' }

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
