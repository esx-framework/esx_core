-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

AddEventHandler("chatMessage", function(playerId, _, message)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer and message:sub(1, 1) == "/" and playerId > 0 then
        CancelEvent()
        local commandName = message:sub(1):gmatch("%w+")()
        xPlayer.showNotification(TranslateCap("commanderror_invalidcommand", commandName))
    end
end)

---@param reason string
AddEventHandler("playerDropped", function(reason)
    Core.PlayerSession.OnPlayerDropped(source --[[@as number]], reason)
end)

AddEventHandler("esx:playerLoaded", function(_, xPlayer, isNew)
    Core.PlayerSession.IncrementJobCount(xPlayer.getJob().name)

    if isNew then
        Player(xPlayer.source).state:set("isNew", true, false)
    end
end)

AddEventHandler("esx:setJob", function(_, job, lastJob)
    Core.PlayerSession.DecrementJobCount(lastJob.name)
    Core.PlayerSession.IncrementJobCount(job.name)
end)

AddEventHandler("esx:playerLogout", function(playerId, cb)
    Core.PlayerSession.OnPlayerDropped(playerId, "esx_player_logout", function()
        TriggerClientEvent("esx:onPlayerLogout", playerId)
        if cb then cb() end
    end)
end)
