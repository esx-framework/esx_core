-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local placeHolders = {
    server_name = function()
        return GetConvar("sv_projectName", "ESX-Framework")
    end,
    server_endpoint = function()
        return GetCurrentServerEndpoint() or "localhost:30120"
    end,
    server_players = function()
        return GlobalState.playerCount or 0
    end,
    server_maxplayers = function()
        return GetConvarInt("sv_maxClients", 48)
    end,
    player_name = function()
        return GetPlayerName(ESX.playerId)
    end,
    player_rp_name = function()
        return ESX.PlayerData.name or "John Doe"
    end,
    player_id = function()
        return ESX.serverId
    end,
    player_street = function()
        if not ESX.PlayerData.ped then return "Unknown" end

        local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
        local streetHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)

        return GetStreetNameFromHashKey(streetHash) or "Unknown"
    end,
}

function Adjustments:ReplacePlaceholders(text)
    for placeholder, cb in pairs(placeHolders) do
        local success, result = pcall(cb)

        if not success then
            print(("[^1ERROR^7] Failed to execute placeholder: ^5%s^7\n%s"):format(placeholder, result))
            result = "Unknown"
        end

        text = text:gsub(("{%s}"):format(placeholder), (tostring(result):gsub("%%", "%%%%")))
    end
    return text
end

function Adjustments:DiscordPresence()
    if Config.DiscordActivity.appId ~= 0 then
        CreateThread(function()
            while ESX.PlayerLoaded do
                SetDiscordAppId(Config.DiscordActivity.appId)
                SetRichPresence(self:ReplacePlaceholders(Config.DiscordActivity.presence))
                SetDiscordRichPresenceAsset(Config.DiscordActivity.assetName)
                SetDiscordRichPresenceAssetText(self:ReplacePlaceholders(Config.DiscordActivity.assetText))

                for i = 1, #Config.DiscordActivity.buttons do
                    local button = Config.DiscordActivity.buttons[i]
                    local buttonUrl = self:ReplacePlaceholders(button.url)
                    SetDiscordRichPresenceAction(i - 1, button.label, buttonUrl)
                end

                Wait(Config.DiscordActivity.refresh)
            end
        end)
    end
end