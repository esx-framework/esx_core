local medal = {}

function medal.getConfig()
    return exports['esx_lib']:getMedalConfig()
end

function medal.triggerClip(publicKey, eventName, clipOptions)
    local cfg = medal.getConfig()
    if not cfg or not cfg.enabled then return end

    exports['esx_lib']:triggerMedalClip(
        publicKey or cfg.publicKey,
        eventName or cfg.eventName,
        clipOptions or cfg.clipOptions
    )
end

return medal