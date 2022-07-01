-- This resource is part of the default Cfx.re asset pack (cfx-server-data)
-- Altering or recreating for local use only is strongly discouraged.

version '1.0.0'
description 'A basic resource for storing player identifiers.'
author 'Cfx.re <root@cfx.re>'
repository 'https://github.com/citizenfx/cfx-server-data'

fx_version 'bodacious'
game 'common'

server_script 'server.lua'

provides {
    'cfx.re/playerData.v1alpha1'
}
