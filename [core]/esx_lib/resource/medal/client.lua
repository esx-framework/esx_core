xLib.getMedalConfig = function()
    return Config.Medal
end

xLib.triggerMedalClip = function(publicKey, eventName, clipOptions)
    if not publicKey or publicKey == '' then return end

    SendNUIMessage({
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
    })
end