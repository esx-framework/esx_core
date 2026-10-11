-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

xLib.getMedalConfig = function()
    return Config.Medal
end

xLib.triggerMedalClip = function(publicKey, eventName, clipOptions)
    if not publicKey or publicKey == '' then return end

    local message = {
        action = 'medalClip',
        publicKey = publicKey,
        payload = {
            eventId = ('esx-clip-%s-%s'):format(GetPlayerServerId(PlayerId()), GetGameTimer()),
            eventName = eventName or 'Event',
            triggerActions = { 'SaveClip' },
            clipOptions = clipOptions or {
                duration = 30,
                captureDelayMs = 0,
                alertType = 'Default'
            }
        }
    }

    xLib.nui.send(message)
end
