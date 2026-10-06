-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@return string
local function T(key, ...)
    return _(key, ...)
end

---Player-facing messages.
local MESSAGES <const> = {
    admin_only = T("admin_only"),
    not_whitelisted = T("not_whitelisted"),
    discord_missing = T("discord_required"),
    discord_role = T("discord_role_required"),
    discord_guild = T("discord_server_required"),
    discord_unavailable = T("discord_unavailable"),
    timeout = T("verification_timeout"),
    error = T("verification_error"),
}

---@param Util table
---@param Enum table
---@param RuntimeConfig table
---@param Identifier table
---@param AdminCache table
---@param Discord table
---@param Log fun(level: string, message: string, context: table?)
return function(Util, Enum, RuntimeConfig, Identifier, AdminCache, Discord, Log)
    local Service = {}

    local Method <const> = Enum.AuthMethod
    local Reason <const> = Enum.Reason

    local stats = {
        total = 0,
        allowed = 0,
        denied = 0,
        byMethod = {},
    }

    ---@param allowed boolean
    ---@param method string
    ---@param reason string
    ---@param identifier string?
    ---@param playerMessage string?
    ---@return table
    local function buildResult(allowed, method, reason, identifier, playerMessage)
        return {
            allowed = allowed,
            method = method,
            reason = reason,
            identifier = identifier,
            playerMessage = playerMessage,
        }
    end

    local function record(result)
        stats.total = stats.total + 1
        if result.allowed then
            stats.allowed = stats.allowed + 1
        else
            stats.denied = stats.denied + 1
        end
        local method = result.method or Method.DENIED
        stats.byMethod[method] = (stats.byMethod[method] or 0) + 1
    end

    ---@param identifiers string[]
    ---@return string?
    local function firstIdentifier(identifiers)
        return identifiers[1]
    end

    ---Runs the Discord leg of the pipeline with a hard deadline, so a
    ---player is never stuck in deferrals longer than VerificationTimeout.
    ---@param identifiers string[]
    ---@param progress fun(stage: string)? optional deferral progress sink
    ---@return table result
    local function checkDiscord(identifiers, progress)
        local cfg = RuntimeConfig:Get()
        local discordIdentifier = nil
        for i = 1, #identifiers do
            if identifiers[i]:sub(1, 8) == "discord:" then
                discordIdentifier = identifiers[i]
                break
            end
        end

        if not discordIdentifier then
            return buildResult(false, Method.DENIED, Reason.DISCORD_NO_IDENTIFIER, firstIdentifier(identifiers), MESSAGES.discord_missing)
        end

        local userId = Util.ExtractDiscordId(discordIdentifier)
        if not userId then
            return buildResult(false, Method.DENIED, Reason.DISCORD_NO_IDENTIFIER, discordIdentifier, MESSAGES.discord_missing)
        end

        local configured, problem = Discord:IsConfigured()
        if not configured then
            Log("error", "Discord verification requested but not configured: " .. tostring(problem))
            return buildResult(false, Method.DENIED, Reason.DISCORD_MISCONFIGURED, discordIdentifier, MESSAGES.discord_unavailable)
        end

        if progress then
            progress("Checking Discord membership...")
        end

        -- Race the verification against the global deadline.
        local timeoutMs = cfg.Performance.VerificationTimeout
        local race = promise.new()
        local settled = false

        Discord:VerifyAsync(userId):next(function(result)
            if settled then
                return
            end
            settled = true
            race:resolve(result)
        end)

        SetTimeout(timeoutMs, function()
            if settled then
                return
            end
            settled = true
            race:resolve(nil)
        end)

        local verification = Citizen.Await(race)
        if progress then
            progress("Verifying authorization...")
        end
        if not verification then
            return buildResult(false, Method.DENIED, Reason.TIMEOUT, discordIdentifier, MESSAGES.timeout)
        end

        if verification.allowed then
            return buildResult(true, Method.DISCORD, Reason.DISCORD_ALLOWED, discordIdentifier)
        end

        local status = verification.status
        if status == "role_missing" then
            return buildResult(false, Method.DENIED, Reason.DISCORD_ROLE_MISSING, discordIdentifier, MESSAGES.discord_role)
        elseif status == "not_in_guild" then
            return buildResult(false, Method.DENIED, Reason.DISCORD_NOT_IN_GUILD, discordIdentifier, MESSAGES.discord_guild)
        elseif status == "misconfigured" then
            return buildResult(false, Method.DENIED, Reason.DISCORD_MISCONFIGURED, discordIdentifier, MESSAGES.discord_unavailable)
        end
        return buildResult(false, Method.DENIED, Reason.DISCORD_UNAVAILABLE, discordIdentifier, MESSAGES.discord_unavailable)
    end

    ---Full authorization pipeline for a connecting player.
    ---May yield (Discord verification). Returns a structured result.
    ---@param rawIdentifiers string[] identifiers from GetPlayerIdentifiers
    ---@param progress fun(stage: string)? optional deferral progress sink
    ---@return table result
    function Service:CheckConnection(rawIdentifiers, progress)
        local cfg = RuntimeConfig:Get()

        -- Normalize once; every downstream check reuses this array.
        local identifiers = {}
        for i = 1, #rawIdentifiers do
            identifiers[i] = Util.NormalizeIdentifier(rawIdentifiers[i])
        end
        local stableIdentifier = Util.PickStableIdentifier(identifiers, cfg.Admin.IdentifierPriority) or identifiers[1]

        -- 0. Master switch.
        if not cfg.Whitelist.Enabled then
            return buildResult(true, Method.DISABLED, Reason.WHITELIST_DISABLED, stableIdentifier)
        end

        -- 1. Emergency bypass.
        if Identifier:MatchBypass(identifiers) then
            return buildResult(true, Method.BYPASS, Reason.BYPASS, stableIdentifier)
        end

        -- 2. Admin-only mode replaces the whole remaining pipeline.
        if cfg.AdminOnly.Enabled then
            if Identifier:MatchAdminOnly(identifiers) then
                return buildResult(true, Method.ADMIN_IDENTIFIER, Reason.ADMIN_ONLY_GRANTED, stableIdentifier)
            end
            local cachedGroup = AdminCache:GetGroup(identifiers, cfg.AdminOnly.Groups)
            if cachedGroup and cfg.AdminOnly.Groups[cachedGroup] then
                return buildResult(true, Method.ADMIN_GROUP, Reason.ADMIN_ONLY_GRANTED, stableIdentifier)
            end
            return buildResult(false, Method.DENIED, Reason.ADMIN_ONLY_DENIED, stableIdentifier, MESSAGES.admin_only)
        end

        -- 3. Persistent admin group cache (admins are never locked out of
        --    their own server by the public whitelist mechanisms).
        local cachedGroup = AdminCache:GetGroup(identifiers)
        if cachedGroup and cfg.Admin.Groups[cachedGroup] then
            return buildResult(true, Method.ADMIN_GROUP, Reason.ADMIN_GROUP, stableIdentifier)
        end

        -- 4-6. Mode-dependent verification.
        local mode = cfg.Whitelist.Mode
        if mode == "identifier" then
            local match = Identifier:MatchWhitelist(identifiers)
            if match then
                return buildResult(true, Method.IDENTIFIER, Reason.IDENTIFIER_MATCH, match)
            end
            return buildResult(false, Method.DENIED, Reason.IDENTIFIER_NO_MATCH, stableIdentifier, MESSAGES.not_whitelisted)
        end

        if mode == "discord" then
            return checkDiscord(identifiers, progress)
        end

        if mode == "both" then
            local match = Identifier:MatchWhitelist(identifiers)
            if cfg.Whitelist.CombinationMode == "or" then
                if match then
                    return buildResult(true, Method.IDENTIFIER, Reason.IDENTIFIER_MATCH, match)
                end
                return checkDiscord(identifiers, progress)
            end

            -- "and": fail fast on the cheap local check before spending a
            -- Discord API request.
            if not match then
                return buildResult(false, Method.DENIED, Reason.COMBINATION_UNMET, stableIdentifier, MESSAGES.not_whitelisted)
            end
            local discordResult = checkDiscord(identifiers, progress)
            if discordResult.allowed then
                return buildResult(true, "both", Reason.IDENTIFIER_MATCH, match)
            end
            return discordResult
        end

        -- Unknown mode: fail closed and surface the misconfiguration.
        Log("error", ("Unknown whitelist mode '%s'; failing closed"):format(tostring(mode)))
        return buildResult(false, Method.DENIED, Reason.ERROR, stableIdentifier, MESSAGES.error)
    end

    ---Checks an ONLINE player (diagnostic command). Identifiers come from
    ---the server, never from the client.
    ---@param playerId number|string
    ---@return table? result nil when the player does not exist
    function Service:CheckPlayer(playerId)
        local name = GetPlayerName(playerId)
        if not name then
            return nil
        end
        local rawIdentifiers = GetPlayerIdentifiers(playerId)
        return self:CheckConnection(rawIdentifiers)
    end

    ---Records a decision in the running statistics.
    ---@param result table
    function Service:Record(result)
        record(result)
    end

    ---@return table
    function Service:GetStats()
        return {
            total = stats.total,
            allowed = stats.allowed,
            denied = stats.denied,
            byMethod = stats.byMethod,
        }
    end

    ---@return table player-facing message catalog (for the panel)
    function Service:GetMessages()
        return MESSAGES
    end

    return Service
end
