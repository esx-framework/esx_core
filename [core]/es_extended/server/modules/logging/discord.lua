-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local function sendDiscordLog(webHook, embedData)
    PerformHttpRequest(
        webHook,
        function()
            return
        end,
        "POST",
        json.encode({
            username = "Logs",
            embeds = embedData,
        }),
        {
            ["Content-Type"] = "application/json",
        }
    )
end

---@param name string
---@param title string
---@param color string
---@param message string
---@return nil
function ESX.DiscordLog(name, title, color, message)
    local webHook = Config.DiscordLogs.Webhooks[name] or Config.DiscordLogs.Webhooks.default
    local embedData = {
        {
            ["title"] = title,
            ["color"] = Config.DiscordLogs.Colors[color] or Config.DiscordLogs.Colors.default,
            ["footer"] = {
                ["text"] = "| ESX Logs | " .. os.date(),
                ["icon_url"] = "https://cdn.discordapp.com/attachments/944789399852417096/1020099828266586193/blanc-800x800.png",
            },
            ["description"] = message,
            ["author"] = {
                ["name"] = "ESX Framework",
                ["icon_url"] = "https://cdn.discordapp.com/emojis/939245183621558362.webp?size=128&quality=lossless",
            },
        },
    }

    sendDiscordLog(webHook, embedData)
end

---@param name string
---@param title string
---@param color string
---@param fields table
---@return nil
function ESX.DiscordLogFields(name, title, color, fields)
    for i = 1, #fields do
        local field = fields[i]
        field.value = tostring(field.value)
    end

    local webHook = Config.DiscordLogs.Webhooks[name] or Config.DiscordLogs.Webhooks.default
    local embedData = {
        {
            ["title"] = title,
            ["color"] = Config.DiscordLogs.Colors[color] or Config.DiscordLogs.Colors.default,
            ["footer"] = {
                ["text"] = "| ESX Logs | " .. os.date(),
                ["icon_url"] = "https://cdn.discordapp.com/attachments/944789399852417096/1020099828266586193/blanc-800x800.png",
            },
            ["fields"] = fields,
            ["description"] = "",
            ["author"] = {
                ["name"] = "ESX Framework",
                ["icon_url"] = "https://cdn.discordapp.com/emojis/939245183621558362.webp?size=128&quality=lossless",
            },
        },
    }

    sendDiscordLog(webHook, embedData)
end
