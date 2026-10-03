-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@class WhitelistServerConfig
---@field DiscordBotToken string

local Util = xLib.require "@esx_whitelist.server.module.whitelist.util"
local ServerConfig = {}

ServerConfig.AllowedIdentifiers = {
    --"license2:your-license-identifier",
    --"discord:123456789012345678"
}

-- Configure this in server.cfg:
-- set discord:botToken "YOUR_DISCORD_BOT_TOKEN"
local token = GetConvar("discord:botToken", "")
ServerConfig.DiscordBotToken = token

if token == "" then
    if Config.Debug then
        print("^3[esx_whitelist] Discord bot token is not configured. Discord role verification will be unavailable until discord:botToken is set.^7")
    end
elseif not Util.isValidBotToken(token) then
    if Config.Debug then
        print("^1[esx_whitelist] discord:botToken does not have a valid token format.^7")
    end
end

return ServerConfig
