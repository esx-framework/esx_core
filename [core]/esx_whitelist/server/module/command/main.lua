-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

--[[
    Admin command module.

    Subcommands:
        whitelist                -> open the panel (in-game admins)
        whitelist panel          -> same
        whitelist status         -> state + counters
        whitelist reload         -> reload runtime config, rebuild lookups
        whitelist cache          -> cache statistics
        whitelist cache clear    -> clear Discord verification cache
        whitelist test <id>      -> run the pipeline against an online player
]]

local EVENT_PREFIX <const> = "esxwl:"

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
            print(("[esx_whitelist] %s"):format(message))
        else
            TriggerClientEvent(EVENT_PREFIX .. "cl:notify", source, message)
        end
    end

    ---@param source number
    local function cmdStatus(source)
        local cfg = RuntimeConfig:Get()
        local serviceStats = Service:GetStats()
        local discordStats = Discord:GetStats()
        local configured, problem = Discord:IsConfigured()

        reply(source, ("Whitelist: %s | mode=%s (%s) | admin-only=%s"):format(
            cfg.Whitelist.Enabled and "ENABLED" or "DISABLED",
            cfg.Whitelist.Mode,
            cfg.Whitelist.CombinationMode,
            cfg.AdminOnly.Enabled and "ON" or "off"
        ))
        reply(source, ("Discord: %s | requests=%d cacheHits=%d shared=%d rateLimits=%d errors=%d"):format(
            configured and "ready" or ("NOT READY (" .. tostring(problem) .. ")"),
            discordStats.requests, discordStats.cacheHits, discordStats.shared,
            discordStats.rateLimits, discordStats.errors
        ))
        reply(source, ("Decisions: total=%d allowed=%d denied=%d | adminCache=%d entries"):format(
            serviceStats.total, serviceStats.allowed, serviceStats.denied, AdminCache:GetCount()
        ))
    end

    ---@param source number
    local function cmdReload(source)
        local ok = RuntimeConfig:Load()
        Identifier:Rebuild()
        Discord:LoadCache()
        reply(source, ok and "Runtime configuration reloaded." or "Runtime configuration file was corrupted; defaults restored.")
        Logger:Event("security", "Configuration reloaded via command", {
            { name = "Source", value = source == 0 and "console" or tostring(GetPlayerName(source)), inline = true },
        })
    end

    ---@param source number
    ---@param args string[]
    local function cmdCache(source, args)
        local sub = args[2]
        if sub == "clear" then
            Discord:ClearCache()
            reply(source, "Discord verification cache cleared.")
            return
        end

        local discordStats = Discord:GetStats()
        reply(source, ("Discord cache: %d entries | admin cache: %d entries | queue: %d (active %d)"):format(
            discordStats.cachedEntries, AdminCache:GetCount(), discordStats.queueLength, discordStats.activeRequests
        ))
    end

    ---@param source number
    ---@param args string[]
    local function cmdTest(source, args)
        local target = tonumber(args[2] or "")
        if not target then
            reply(source, "Usage: whitelist test <serverId>")
            return
        end
        if not GetPlayerName(target) then
            reply(source, ("No online player with server id %d."):format(target))
            return
        end

        -- The pipeline can yield (Discord HTTP); run it off the command thread.
        CreateThread(function()
            local result = Service:CheckPlayer(target)
            if not result then
                reply(source, "Player left before the check completed.")
                return
            end
            reply(source, ("Test for %s [%d]: %s | method=%s | reason=%s | identifier=%s"):format(
                tostring(GetPlayerName(target)),
                target,
                result.allowed and "ALLOWED" or "DENIED",
                tostring(result.method),
                tostring(result.reason),
                Util.MaskIdentifier(result.identifier or "")
            ))
        end)
    end

    ---Main dispatch. Shared by the in-game bridge and the server console.
    ---@param source number 0 for console
    ---@param args string[]
    function Command:Execute(source, args)
        if source ~= 0 and not IsAdmin(source) then
            reply(source, "You do not have permission to use this command.")
            Logger:Event("security", "Unauthorized command attempt", {
                { name = "Source", value = tostring(source), inline = true },
                { name = "Command", value = table.concat(args, " "), inline = true },
            })
            return
        end

        local sub = args[1]
        if sub == nil or sub == "" or sub == "panel" then
            if source == 0 then
                reply(0, "The panel can only be opened in-game.")
                return
            end
            TriggerClientEvent(EVENT_PREFIX .. "cl:requestOpen", source)
        elseif sub == "status" then
            cmdStatus(source)
        elseif sub == "reload" then
            cmdReload(source)
        elseif sub == "cache" then
            cmdCache(source, args)
        elseif sub == "test" then
            cmdTest(source, args)
        else
            reply(source, "Usage: whitelist [panel|status|reload|cache [clear]|test <id>]")
        end
    end

    ---Registers the server-side command. Player executions are ignored
    ---here (the client bridge forwards them as an event), so each
    ---invocation is handled exactly once.
    function Command:Register()
        local commandName = RuntimeConfig:Get().Panel.Command
        RegisterCommand(commandName, function(source, args)
            -- Player executions arrive twice (client bridge + this handler
            -- via the shared command name); only the console is served here.
            if source ~= 0 then
                return
            end
            Command:Execute(0, args)
        end, false)

        -- In-game bridge: the client-side command forwards argv here.
        RegisterNetEvent(EVENT_PREFIX .. "sv:command", function(args)
            local source = source
            if type(args) ~= "table" or #args > 8 then
                return
            end
            local clean = {}
            for i = 1, #args do
                if type(args[i]) ~= "string" or #args[i] > 64 then
                    return
                end
                clean[i] = args[i]
            end
            Command:Execute(source, clean)
        end)
    end

    return Command
end
