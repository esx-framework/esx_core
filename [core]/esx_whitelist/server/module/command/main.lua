-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

--[[
    Admin command module.

    Subcommands:
        whitelist                -> open the panel (in-game admins)
        whitelist panel          -> same
        whitelist add <id> [type]    -> add identifier to whitelist/admin/bypass
        whitelist remove <id> [type] -> remove identifier from whitelist/admin/bypass
        whitelist status         -> state + counters
        whitelist reload         -> reload runtime config, rebuild lookups
        whitelist cache          -> cache statistics
        whitelist cache clear    -> clear Discord verification cache
        whitelist test <id>      -> run the pipeline against an online player
]]

local EVENT_PREFIX <const> = 'esxwl:'

---@param deps { Util: table, RuntimeConfig: table, Identifier: table, AdminCache: table, Discord: table, Logger: table, Service: table, IsAdmin: fun(source: any): boolean }
return function(deps)
    local Util = deps.Util
    local RuntimeConfig = deps.RuntimeConfig
    local Identifier = deps.Identifier
    local AdminCache = deps.AdminCache
    local Discord = deps.Discord
    local Logger = deps.Logger
    local Service = deps.Service
    local IsAdmin = deps.IsAdmin

    local Command = {}

    ---Sends command output to the caller (server console or in-game chat).
    ---@param source number
    ---@param message string
    local function reply(source, message)
        if source == 0 then
            print(('[esx_whitelist] %s'):format(message))
        else
            TriggerClientEvent(EVENT_PREFIX .. 'cl:notify', source, message)
        end
    end

    local function locale(key, ...)
        return _(key, ...)
    end

    ---@param source number
    local function cmdStatus(source)
        local cfg = RuntimeConfig:Get()
        local serviceStats = Service:GetStats()
        local discordStats = Discord:GetStats()
        local configured, problem = Discord:IsConfigured()

        reply(
            source,
            locale(
                'command_status',
                cfg.Whitelist.Enabled and 'ENABLED' or 'DISABLED',
                cfg.Whitelist.Mode,
                cfg.Whitelist.CombinationMode,
                cfg.AdminOnly.Enabled and 'ON' or 'off'
            )
        )
        reply(
            source,
            locale(
                'command_status_discord',
                configured and 'ready' or ('NOT READY (' .. tostring(problem) .. ')'),
                discordStats.requests,
                discordStats.cacheHits,
                discordStats.shared,
                discordStats.rateLimits,
                discordStats.errors
            )
        )
        reply(
            source,
            locale(
                'command_status_decisions',
                serviceStats.total,
                serviceStats.allowed,
                serviceStats.denied,
                AdminCache:GetCount()
            )
        )
    end

    ---@param source number
    local function cmdReload(source)
        local ok = RuntimeConfig:Load()
        Identifier:Rebuild()
        Discord:LoadCache()
        reply(source, ok and locale('runtime_reloaded') or locale('runtime_reloaded_fallback'))
        Logger:Event('security', 'Configuration reloaded via command', {
            {
                name = 'Source',
                value = source == 0 and 'console' or tostring(GetPlayerName(source)),
                inline = true,
            },
        })
    end

    ---@param source number
    ---@param args string[]
    local function cmdCache(source, args)
        local subcommands = RuntimeConfig:Get().Panel.Subcommands
        local sub = args[2]

        if sub == subcommands.CacheClear then
            Discord:ClearCache()
            reply(source, locale('discord_cache_cleared'))

            return
        end

        local discordStats = Discord:GetStats()
        reply(
            source,
            locale(
                'command_cache_stats',
                discordStats.cachedEntries,
                AdminCache:GetCount(),
                discordStats.queueLength,
                discordStats.activeRequests
            )
        )
    end

    ---@param source number
    ---@param args string[]
    local function cmdTest(source, args)
        local target = tonumber(args[2] or '')

        if not target then
            local cfg = RuntimeConfig:Get()
            reply(
                source,
                locale('command_usage_test', cfg.Panel.Command, cfg.Panel.Subcommands.Test)
            )

            return
        end

        if not GetPlayerName(target) then
            reply(source, locale('no_online_player', target))

            return
        end

        -- The pipeline can yield (Discord HTTP); run it off the command thread.
        CreateThread(function()
            local result = Service:CheckPlayer(target)

            if not result then
                reply(source, locale('player_left_before_check'))

                return
            end

            reply(
                source,
                locale(
                    'command_test_result',
                    tostring(GetPlayerName(target)),
                    target,
                    result.allowed and 'ALLOWED' or 'DENIED',
                    tostring(result.method),
                    tostring(result.reason),
                    Util.MaskIdentifier(result.identifier or '')
                )
            )
        end)
    end

    ---Main dispatch. Shared by the in-game bridge and the server console.
    ---@param source number 0 for console
    ---@param args string[]
    function Command:Execute(source, args)
        if source ~= 0 and not IsAdmin(source) then
            reply(source, locale('command_no_permission'))
            Logger:Event('security', 'Unauthorized command attempt', {
                { name = 'Source', value = tostring(source), inline = true },
                { name = 'Command', value = table.concat(args, ' '), inline = true },
            })

            return
        end

        local subcommands = RuntimeConfig:Get().Panel.Subcommands
        local sub = args[1]

        if sub == nil or sub == '' or sub == subcommands.Panel then
            if source == 0 then
                reply(0, locale('panel_only_in_game'))

                return
            end

            TriggerClientEvent(EVENT_PREFIX .. 'cl:requestOpen', source)
        elseif sub == subcommands.Status then
            cmdStatus(source)
        elseif sub == subcommands.Reload then
            cmdReload(source)
        elseif sub == subcommands.Cache then
            cmdCache(source, args)
        elseif sub == subcommands.Test then
            cmdTest(source, args)
        elseif sub == subcommands.Add then
            local identifier = args[2]
            local idType = args[3] or 'whitelist'

            if
                not identifier
                or (idType ~= 'whitelist' and idType ~= 'admin_only' and idType ~= 'bypass')
            then
                local cfg = RuntimeConfig:Get()
                reply(
                    source,
                    locale('command_usage_add', cfg.Panel.Command, cfg.Panel.Subcommands.Add)
                )

                return
            end

            local ok, err = Identifier:Add(identifier, idType)

            if ok then
                reply(source, locale('command_identifier_added', identifier, idType))
                Logger:Event('security', 'Identifier added via command', {
                    { name = 'Identifier', value = identifier, inline = true },
                    { name = 'Type', value = idType, inline = true },
                    {
                        name = 'Admin',
                        value = source == 0 and 'console' or tostring(GetPlayerName(source)),
                        inline = true,
                    },
                })
            else
                reply(source, locale('command_invalid_identifier', identifier))
            end
        elseif sub == subcommands.Remove then
            local identifier = args[2]
            local idType = args[3] or 'whitelist'

            if not identifier then
                local cfg = RuntimeConfig:Get()
                reply(
                    source,
                    locale('command_usage_remove', cfg.Panel.Command, cfg.Panel.Subcommands.Remove)
                )

                return
            end

            Identifier:Remove(identifier, idType)
            reply(source, locale('command_identifier_removed', identifier, idType))
            Logger:Event('security', 'Identifier removed via command', {
                { name = 'Identifier', value = identifier, inline = true },
                { name = 'Type', value = idType, inline = true },
                {
                    name = 'Admin',
                    value = source == 0 and 'console' or tostring(GetPlayerName(source)),
                    inline = true,
                },
            })
        else
            reply(
                source,
                locale(
                    'command_usage',
                    RuntimeConfig:Get().Panel.Command,
                    subcommands.Panel,
                    subcommands.Status,
                    subcommands.Reload,
                    subcommands.Cache,
                    subcommands.CacheClear,
                    subcommands.Test,
                    subcommands.Add,
                    subcommands.Remove
                )
            )
        end
    end

    ---Registers the server console command.
    function Command:Register()
        local cfg = RuntimeConfig:Get()
        local commandName = cfg.Panel.Command

        RegisterCommand(commandName, function(source, args)
            -- Player input is handled by the client bridge below.
            if source ~= 0 then
                return
            end

            Command:Execute(0, args)
        end, false)

        -- In-game bridge: the client-side command forwards argv here.
        RegisterNetEvent(EVENT_PREFIX .. 'sv:command', function(args)
            local source = source

            if type(args) ~= 'table' or #args > 8 then
                return
            end

            local clean = {}

            for i = 1, #args do
                if type(args[i]) ~= 'string' or #args[i] > 64 then
                    return
                end

                clean[i] = args[i]
            end

            Command:Execute(source, clean)
        end)
    end

    return Command
end
