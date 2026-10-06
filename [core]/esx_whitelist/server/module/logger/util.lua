-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local LoggerUtil = {}

-- Discord embed colors, aligned with the ESX palette.
LoggerUtil.COLORS = {
    info = 0xFB9B04, -- brand orange
    warning = 0xE6A23C,
    error = 0xE74C3C,
    security = 0x9B59B6,
    success = 0x2ECC71,
}

---Builds one Discord embed from a log event.
---@param event { level: string, title: string, fields: table[]?, timestamp: integer }
---@return table
function LoggerUtil.BuildEmbed(event)
    local embed = {
        title = event.title,
        color = LoggerUtil.COLORS[event.level] or LoggerUtil.COLORS.info,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ', event.timestamp),
        footer = { text = 'esx_whitelist' },
    }

    if type(event.fields) == 'table' and #event.fields > 0 then
        local fields = {}

        for i = 1, math.min(#event.fields, 25) do
            local field = event.fields[i]

            if type(field) == 'table' and type(field.name) == 'string' then
                local value = tostring(field.value or '')

                if #value > 1024 then
                    value = value:sub(1, 1021) .. '...'
                end

                fields[#fields + 1] = {
                    name = field.name:sub(1, 256),
                    value = value,
                    inline = field.inline == true,
                }
            end
        end

        embed.fields = fields
    end

    return embed
end

---Masks a webhook URL for console output, keeping only host and tail.
---The URL path contains the webhook token and must never be printed fully.
---@param url string
---@return string
function LoggerUtil.MaskWebhook(url)
    local host = url:match('^https?://([^/]+)')

    if not host then
        return '(invalid webhook URL)'
    end

    local tail = url:match('([%w%-_]+)$') or ''

    if #tail > 4 then
        tail = tail:sub(-4)
    end

    return ('https://%s/...%s'):format(host, tail)
end

return LoggerUtil
