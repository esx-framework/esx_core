-- This resource is part of the default Cfx.re asset pack (cfx-server-data)
-- Altering or recreating for local use only is strongly discouraged.

version '1.0.0'
author 'Cfx.re <root@cfx.re>'
description 'Example spawn points for RedM.'
repository 'https://github.com/citizenfx/cfx-server-data'

resource_type 'map' { gameTypes = { ['basic-gamemode'] = true } }

map 'map.lua'

fx_version 'adamant'
game 'rdr3'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
