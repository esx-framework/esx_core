-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Whitelist <const> = xLib.require "@esx_whitelist.server.module.whitelist.main"
local State <const> = xLib.require "@esx_whitelist.server.module.whitelist.state"
local Connection <const> = xLib.require "@esx_whitelist.server.module.whitelist.connection"
local Util <const> = xLib.require "@esx_whitelist.server.module.whitelist.util"

AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Whitelist.init()
    end
end)

AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
    local playerSource = source
    local sessionId = Connection.beginSession(playerSource)

    local ok, err = xpcall(function()
        Connection.verify(
            playerSource,
            playerName,
            setKickReason,
            deferrals,
            State.translations,
            sessionId
        )
    end, debug.traceback)

    if not ok then
        Connection.endSession(playerSource, sessionId)
        if Config.Debug then
            print("^1[esx_whitelist] Connection error:^7 " .. tostring(err))
        end
        local fallbackReason = "Whitelist authorization failed."
        local translated, reason = pcall(Util.translate, State.translations, "system_error")
        if not translated or type(reason) ~= "string" then reason = fallbackReason end

        local completed = pcall(function()
            deferrals.done("~r~" .. reason)
        end)
        if not completed and reason ~= fallbackReason then
            pcall(function() deferrals.done("~r~" .. fallbackReason) end)
        end
    end
end)

AddEventHandler("playerJoining", function(previousPlayerId)
    local playerSource = source
    local previousSource = tonumber(previousPlayerId)
    if previousSource and previousSource > 0 and previousSource ~= playerSource then
        Connection.endSession(previousSource)
    end
    Connection.beginSession(playerSource)
    Whitelist.onPlayerJoining(playerSource, previousPlayerId)
end)

AddEventHandler("playerDropped", function(reason)
    local playerSource = source
    Whitelist.onPlayerDropped(playerSource, reason)
    Connection.endSession(playerSource)
end)

AddEventHandler("esx:playerLoaded", function(playerId, xPlayer)
    Whitelist.onPlayerLoaded(playerId, xPlayer)
end)

AddEventHandler("esx:playerDropped", function(playerId, reason)
    Whitelist.onPlayerDropped(playerId, reason)
end)
