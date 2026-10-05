-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@param Util table
---@param LoggerUtil table
---@param RuntimeConfig table
return function(Util, LoggerUtil, RuntimeConfig)
    local Logger = {}

    local queue = {}
    local drainScheduled = false
    local dropped = 0
    local sent = 0
    local failed = 0

    local function loggingConfig()
        return RuntimeConfig:Get().Logging
    end

    ---@return string
    local function resolveWebhook()
        local fromConvar = Util.Trim(GetConvar("whitelist:webhook", ""))
        if fromConvar ~= "" then
            return fromConvar
        end

        local cfg = loggingConfig()
        local fallback = cfg and cfg.Webhook or ""
        return Util.Trim(fallback)
    end

    ---Console output with level gating. Debug messages are suppressed
    ---unless Config.Debug is enabled.
    ---@param level string
    ---@param message string
    function Logger:Console(level, message)
        if level == "debug" and not RuntimeConfig:Get().Debug then
            return
        end
        print(("[esx_whitelist] [%s] %s"):format(level:upper(), message))
    end

    ---Whether a severity should hit the webhook.
    ---@param level string
    ---@return boolean
    local function levelEnabled(level)
        local cfg = loggingConfig()
        if not cfg.Enabled then
            return false
        end
        if resolveWebhook() == "" then
            return false
        end
        local levels = cfg.Levels
        if type(levels) ~= "table" then
            return true
        end
        return levels[level] == true
    end

    ---Sends one batched request with up to BatchSize embeds.
    ---@param events table[]
    local function deliverBatch(events)
        local webhook = resolveWebhook()
        if webhook == "" then
            return
        end

        local embeds = {}
        for i = 1, #events do
            embeds[i] = LoggerUtil.BuildEmbed(events[i])
        end

        local payload = json.encode({
            username = "ESX Whitelist",
            embeds = embeds,
        })
        if type(payload) ~= "string" then
            failed = failed + 1
            return
        end

        PerformHttpRequest(webhook, function(statusCode)
            local status = tonumber(statusCode) or 0
            if status >= 200 and status < 300 then
                sent = sent + #events
            else
                failed = failed + #events
                Logger:Console("warning", ("Webhook delivery failed (HTTP %d), %d event(s) dropped"):format(status, #events))
            end
        end, "POST", payload, { ["Content-Type"] = "application/json" })
    end

    local function scheduleDrain()
        if drainScheduled then
            return
        end
        drainScheduled = true
        SetTimeout(loggingConfig().MinInterval, function()
            drainScheduled = false
            if #queue == 0 then
                return
            end

            local batchSize = loggingConfig().BatchSize
            local batch = {}
            for i = 1, math.min(batchSize, #queue) do
                batch[i] = table.remove(queue, 1)
            end
            deliverBatch(batch)

            if #queue > 0 then
                scheduleDrain()
            end
        end)
    end

    ---Queues a webhook event. Never blocks the caller.
    ---@param level string info|warning|error|security
    ---@param title string
    ---@param fields table[]? array of { name, value, inline }
    function Logger:Event(level, title, fields)
        if not levelEnabled(level) then
            return
        end

        if #queue >= loggingConfig().QueueLimit then
            table.remove(queue, 1) -- drop oldest, never grow unbounded
            dropped = dropped + 1
        end

        queue[#queue + 1] = {
            level = level,
            title = title,
            fields = fields,
            timestamp = Util.Now(),
        }
        scheduleDrain()
    end

    ---Convenience: log a whitelist decision to console + webhook.
    ---@param result table authorization result
    ---@param playerName string
    ---@param source number|string
    function Logger:LogDecision(result, playerName, source)
        local level = result.allowed and "info" or "warning"
        if result.method == "bypass" or result.method == "admin_identifier" then
            level = "security"
        end

        local title = result.allowed and "Connection accepted" or "Connection denied"
        self:Event(level, title, {
            { name = "Player", value = tostring(playerName), inline = true },
            { name = "Method", value = tostring(result.method), inline = true },
            { name = "Reason", value = tostring(result.reason), inline = true },
            { name = "Identifier", value = Util.MaskIdentifier(result.identifier or ""), inline = true },
        })
        self:Console("debug", ("%s for %s (method=%s reason=%s)"):format(title, tostring(playerName), tostring(result.method), tostring(result.reason)))
    end

    ---@return table
    function Logger:GetStats()
        return {
            queued = #queue,
            sent = sent,
            failed = failed,
            dropped = dropped,
            webhookConfigured = resolveWebhook() ~= "",
        }
    end

    return Logger
end
