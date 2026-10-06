-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local EVENT_PREFIX <const> = 'esxwl:'

---@param deps { Util: table, RuntimeConfig: table, Identifier: table, AdminCache: table, Discord: table, Logger: table, Service: table, IsAdmin: fun(source: any): boolean, ESX: table }
return function(deps)
    local Util = deps.Util
    local RuntimeConfig = deps.RuntimeConfig
    local Identifier = deps.Identifier
    local AdminCache = deps.AdminCache
    local Discord = deps.Discord
    local Logger = deps.Logger
    local Service = deps.Service
    local IsAdmin = deps.IsAdmin

    local Panel = {}

    -- Per-player token buckets for management events.
    ---@type table<number, { tokens: number, resetAt: number }>
    local buckets = {}

    ---@param source number
    ---@return boolean allowed
    local function consumeRateToken(source)
        local cfg = RuntimeConfig:Get().Performance
        local now = GetGameTimer()
        local bucket = buckets[source]

        if not bucket or now >= bucket.resetAt then
            bucket = { tokens = cfg.PanelRateLimit, resetAt = now + cfg.PanelRateWindow }
            buckets[source] = bucket
        end

        if bucket.tokens <= 0 then
            return false
        end

        bucket.tokens = bucket.tokens - 1

        return true
    end

    AddEventHandler('playerDropped', function()
        buckets[source] = nil
    end)

    ---Builds the full sanitized panel state for one admin.
    ---@return table
    local function buildState()
        local state = RuntimeConfig:BuildPanelState({
            meta = {
                version = GetResourceMetadata(GetCurrentResourceName(), 'version', 0) or '1.0.0',
                botTokenConfigured = Discord:HasToken(),
                discordReady = (Discord:IsConfigured()),
                webhookConfigured = Logger:GetStats().webhookConfigured,
                resourceName = GetCurrentResourceName(),
            },
            stats = {
                service = Service:GetStats(),
                discord = Discord:GetStats(),
                logger = Logger:GetStats(),
                adminCacheEntries = AdminCache:GetCount(),
                identifierCounts = Identifier:GetCounts(),
            },
        })

        if Identifier then
            state.whitelist.allowedIdentifiers = Identifier:GetList('whitelist')
            state.adminOnly.allowedIdentifiers = Identifier:GetList('admin_only')
            state.bypass.allowedIdentifiers = Identifier:GetList('bypass')
        end

        return state
    end

    ---Guards a management event: admin permission + rate limit.
    ---@param source number
    ---@return boolean authorized
    local function guard(source)
        if not IsAdmin(source) then
            Logger:Event('security', 'Unauthorized panel access attempt', {
                { name = 'Source', value = tostring(source), inline = true },
            })
            Logger:Console(
                'warning',
                ('Rejected panel action from non-admin source %s'):format(tostring(source))
            )

            return false
        end

        if not consumeRateToken(source) then
            Logger:Console(
                'warning',
                ('Rate-limited panel action from source %s'):format(tostring(source))
            )

            return false
        end

        return true
    end

    ---Admin identifier for audit logs (masked at the logger layer).
    ---@param source number
    ---@return string
    local function adminIdentifier(source)
        local identifiers = GetPlayerIdentifiers(source)

        if not identifiers then
            return 'unknown'
        end

        local cfg = RuntimeConfig:Get()
        local normalized = {}

        for i = 1, #identifiers do
            normalized[i] = Util.NormalizeIdentifier(identifiers[i])
        end

        return Util.PickStableIdentifier(normalized, cfg.Admin.IdentifierPriority) or 'unknown'
    end

    -- Full state request (panel open / refresh).
    RegisterNetEvent(EVENT_PREFIX .. 'sv:requestPanel', function()
        local source = source

        if not guard(source) then
            return
        end

        TriggerClientEvent(EVENT_PREFIX .. 'cl:openPanel', source, buildState())
    end)

    RegisterNetEvent(EVENT_PREFIX .. 'sv:requestState', function()
        local source = source

        if not guard(source) then
            return
        end

        TriggerClientEvent(EVENT_PREFIX .. 'cl:stateUpdate', source, buildState())
    end)

    -- Single-setting update from the panel.
    RegisterNetEvent(EVENT_PREFIX .. 'sv:updateConfig', function(payload)
        local source = source

        if not guard(source) then
            return
        end

        if type(payload) ~= 'table' or type(payload.key) ~= 'string' then
            TriggerClientEvent(
                EVENT_PREFIX .. 'cl:configAck',
                source,
                { ok = false, error = 'malformed payload' }
            )

            return
        end

        local key = payload.key
        local value = payload.value

        local ok, err = RuntimeConfig:Set(key, value)

        if ok then
            -- Identifier lists feed hash lookups; rebuild them so the
            -- change is effective for the very next connection.
            if key:find('Identifiers', 1, true) then
                if deps.Database and deps.Database.ready then
                    local idType = 'whitelist'

                    if key:find('AdminOnly', 1, true) then
                        idType = 'admin_only'
                    elseif key:find('Bypass', 1, true) then
                        idType = 'bypass'
                    end

                    deps.Database:SyncIdentifiers(idType, value)
                end

                Identifier:Rebuild()
            end

            Logger:Event('security', 'Configuration changed via panel', {
                { name = 'Setting', value = key, inline = true },
                {
                    name = 'Admin',
                    value = Util.MaskIdentifier(adminIdentifier(source)),
                    inline = true,
                },
                {
                    name = 'Player',
                    value = tostring(GetPlayerName(source) or source),
                    inline = true,
                },
            })

            TriggerClientEvent(EVENT_PREFIX .. 'cl:configAck', source, {
                ok = true,
                key = key,
                state = buildState(),
            })
        else
            TriggerClientEvent(EVENT_PREFIX .. 'cl:configAck', source, {
                ok = false,
                key = key,
                error = err,
            })
        end
    end)

    return Panel
end
